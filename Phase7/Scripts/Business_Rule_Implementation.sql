-- 1. Holiday Management Table
CREATE TABLE HOLIDAYS (
    holiday_id VARCHAR2(20) PRIMARY KEY,
    holiday_name VARCHAR2(200) NOT NULL,
    holiday_date DATE NOT NULL,
    holiday_type VARCHAR2(50) DEFAULT 'Public' 
        CHECK (holiday_type IN ('Public', 'Bank', 'Regional')),
    country VARCHAR2(100) DEFAULT 'Rwanda',
    is_recurring CHAR(1) DEFAULT 'Y' CHECK (is_recurring IN ('Y', 'N')),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE INDEX idx_holidays_date ON HOLIDAYS(holiday_date);

-- Insert sample holidays for next month
INSERT INTO HOLIDAYS (holiday_id, holiday_name, holiday_date) VALUES
('HOL001', 'New Year''s Day', TO_DATE('2025-01-01', 'YYYY-MM-DD')),
('HOL002', 'National Heroes Day', TO_DATE('2025-02-01', 'YYYY-MM-DD')),
('HOL003', 'Good Friday', TO_DATE('2025-04-18', 'YYYY-MM-DD'));
COMMIT;

-- 2. Audit Log Table
CREATE TABLE AUDIT_LOG (
    audit_id VARCHAR2(20) PRIMARY KEY,
    table_name VARCHAR2(100) NOT NULL,
    operation_type VARCHAR2(10) CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id VARCHAR2(100),
    old_values CLOB,
    new_values CLOB,
    user_name VARCHAR2(100) DEFAULT USER,
    attempted_date DATE DEFAULT SYSDATE,
    attempted_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    attempt_status VARCHAR2(20) DEFAULT 'DENIED' 
        CHECK (attempt_status IN ('ALLOWED', 'DENIED')),
    denial_reason VARCHAR2(500),
    ip_address VARCHAR2(50),
    session_id VARCHAR2(100)
);

CREATE INDEX idx_audit_user_date ON AUDIT_LOG(user_name, attempted_date);
CREATE INDEX idx_audit_status ON AUDIT_LOG(attempt_status);

-- 3. Function to check if today is a holiday
CREATE OR REPLACE FUNCTION is_holiday_today RETURN BOOLEAN AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM HOLIDAYS 
    WHERE holiday_date = TRUNC(SYSDATE)
    AND holiday_date BETWEEN TRUNC(SYSDATE) AND ADD_MONTHS(TRUNC(SYSDATE), 1);
    
    RETURN v_count > 0;
END;
/

-- 4. Function to check weekday restriction
CREATE OR REPLACE FUNCTION is_weekday RETURN BOOLEAN AS
    v_day_of_week VARCHAR2(20);
BEGIN
    SELECT TO_CHAR(SYSDATE, 'DY') INTO v_day_of_week FROM dual;
    RETURN v_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI');
END;
/

-- 5. Function to check employee S restriction
CREATE OR REPLACE FUNCTION check_employee_s_restriction 
RETURN VARCHAR2 AS
BEGIN
    -- Check if current user is 'EMPLOYEE_S'
    IF USER = 'EMPLOYEE_S' THEN
        -- Check weekday restriction
        IF is_weekday() THEN
            RETURN 'DENIED: Operation not allowed on weekdays (Monday-Friday)';
        END IF;
        
        -- Check holiday restriction
        IF is_holiday_today() THEN
            RETURN 'DENIED: Operation not allowed on public holidays';
        END IF;
    END IF;
    
    RETURN 'ALLOWED';
END;
/

-- 6. Audit logging function
CREATE OR REPLACE FUNCTION log_audit_event (
    p_table_name    IN VARCHAR2,
    p_operation     IN VARCHAR2,
    p_record_id     IN VARCHAR2,
    p_old_values    IN CLOB DEFAULT NULL,
    p_new_values    IN CLOB DEFAULT NULL,
    p_status        IN VARCHAR2,
    p_reason        IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 AS
    v_audit_id VARCHAR2(20);
BEGIN
    v_audit_id := 'AUD' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4);
    
    INSERT INTO AUDIT_LOG (
        audit_id, table_name, operation_type, record_id,
        old_values, new_values, attempt_status, denial_reason,
        user_name, ip_address, session_id
    ) VALUES (
        v_audit_id, p_table_name, p_operation, p_record_id,
        p_old_values, p_new_values, p_status, p_reason,
        USER, SYS_CONTEXT('USERENV', 'IP_ADDRESS'), SYS_CONTEXT('USERENV', 'SESSIONID')
    );
    
    COMMIT;
    RETURN v_audit_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

-- 7. Simple Trigger for DONATIONS table
CREATE OR REPLACE TRIGGER trg_donations_employee_s_restriction
BEFORE INSERT OR UPDATE OR DELETE ON DONATIONS
FOR EACH ROW
DECLARE
    v_restriction_result VARCHAR2(500);
    v_audit_id VARCHAR2(20);
BEGIN
    v_restriction_result := check_employee_s_restriction();
    
    IF v_restriction_result != 'ALLOWED' THEN
        -- Log the denied attempt
        v_audit_id := log_audit_event(
            'DONATIONS',
            CASE 
                WHEN INSERTING THEN 'INSERT'
                WHEN UPDATING THEN 'UPDATE'
                WHEN DELETING THEN 'DELETE'
            END,
            COALESCE(:NEW.donation_id, :OLD.donation_id),
            NULL,
            NULL,
            'DENIED',
            v_restriction_result
        );
        
        RAISE_APPLICATION_ERROR(-20001, 
            'EMPLOYEE_S restriction: ' || v_restriction_result || 
            ' | Audit ID: ' || v_audit_id);
    ELSE
        -- Log allowed attempt
        log_audit_event(
            'DONATIONS',
            CASE 
                WHEN INSERTING THEN 'INSERT'
                WHEN UPDATING THEN 'UPDATE'
                WHEN DELETING THEN 'DELETE'
            END,
            COALESCE(:NEW.donation_id, :OLD.donation_id),
            NULL,
            NULL,
            'ALLOWED',
            NULL
        );
    END IF;
END;
/

-- 8. Compound Trigger for BLOOD_UNITS table
CREATE OR REPLACE TRIGGER trg_blood_units_employee_s_compound
FOR INSERT OR UPDATE OR DELETE ON BLOOD_UNITS
COMPOUND TRIGGER
    
    TYPE t_audit_rec IS RECORD (
        operation VARCHAR2(10),
        record_id VARCHAR2(20)
    );
    
    TYPE t_audit_table IS TABLE OF t_audit_rec;
    v_audit_events t_audit_table := t_audit_table();
    
    v_restriction_result VARCHAR2(500);
    
    -- Before each row
    BEFORE EACH ROW IS
    BEGIN
        v_restriction_result := check_employee_s_restriction();
        
        IF v_restriction_result != 'ALLOWED' THEN
            RAISE_APPLICATION_ERROR(-20002, 
                'EMPLOYEE_S restriction: ' || v_restriction_result);
        END IF;
        
        -- Store operation for bulk audit logging
        v_audit_events.EXTEND;
        v_audit_events(v_audit_events.LAST).operation := 
            CASE 
                WHEN INSERTING THEN 'INSERT'
                WHEN UPDATING THEN 'UPDATE'
                WHEN DELETING THEN 'DELETE'
            END;
        v_audit_events(v_audit_events.LAST).record_id := 
            COALESCE(:NEW.unit_id, :OLD.unit_id);
    END BEFORE EACH ROW;
    
    -- After statement
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1..v_audit_events.COUNT LOOP
            log_audit_event(
                'BLOOD_UNITS',
                v_audit_events(i).operation,
                v_audit_events(i).record_id,
                NULL,
                NULL,
                'ALLOWED',
                NULL
            );
        END LOOP;
        
        -- Clear the collection
        v_audit_events.DELETE;
    END AFTER STATEMENT;
    
END trg_blood_units_employee_s_compound;
/

-- 9. Additional trigger for FACILITIES table
CREATE OR REPLACE TRIGGER trg_facilities_audit
BEFORE INSERT OR UPDATE OR DELETE ON FACILITIES
FOR EACH ROW
DECLARE
    v_old_values CLOB;
    v_new_values CLOB;
    v_restriction_result VARCHAR2(500);
BEGIN
    -- Create JSON-like string of old values
    IF UPDATING OR DELETING THEN
        v_old_values := 
            '{' ||
            '"facility_id":"' || :OLD.facility_id || '",' ||
            '"facility_name":"' || :OLD.facility_name || '",' ||
            '"status":"' || :OLD.is_active || '"' ||
            '}';
    END IF;
    
    -- Create JSON-like string of new values
    IF INSERTING OR UPDATING THEN
        v_new_values := 
            '{' ||
            '"facility_id":"' || :NEW.facility_id || '",' ||
            '"facility_name":"' || :NEW.facility_name || '",' ||
            '"status":"' || :NEW.is_active || '"' ||
            '}';
    END IF;
    
    v_restriction_result := check_employee_s_restriction();
    
    IF v_restriction_result != 'ALLOWED' THEN
        log_audit_event(
            'FACILITIES',
            CASE 
                WHEN INSERTING THEN 'INSERT'
                WHEN UPDATING THEN 'UPDATE'
                WHEN DELETING THEN 'DELETE'
            END,
            COALESCE(:NEW.facility_id, :OLD.facility_id),
            v_old_values,
            v_new_values,
            'DENIED',
            v_restriction_result
        );
        
        RAISE_APPLICATION_ERROR(-20003, 
            'EMPLOYEE_S restriction: ' || v_restriction_result);
    ELSE
        log_audit_event(
            'FACILITIES',
            CASE 
                WHEN INSERTING THEN 'INSERT'
                WHEN UPDATING THEN 'UPDATE'
                WHEN DELETING THEN 'DELETE'
            END,
            COALESCE(:NEW.facility_id, :OLD.facility_id),
            v_old_values,
            v_new_values,
            'ALLOWED',
            NULL
        );
    END IF;
END;
/
