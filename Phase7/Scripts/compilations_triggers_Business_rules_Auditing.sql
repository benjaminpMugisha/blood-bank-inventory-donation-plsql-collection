-- ============================================================
-- BLOOD BANK MANAGEMENT SYSTEM - ADVANCED PROGRAMMING
-- Phase VII: Triggers, Business Rules, Auditing
-- ============================================================

-- ============================================================
-- STEP 1: CREATE HOLIDAY MANAGEMENT TABLE
-- ============================================================
CREATE TABLE PUBLIC_HOLIDAYS (
    holiday_id VARCHAR2(20) PRIMARY KEY,
    holiday_name VARCHAR2(200) NOT NULL,
    holiday_date DATE NOT NULL,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_holiday_date UNIQUE (holiday_date)
);

-- Insert Rwanda Public Holidays for upcoming month (January 2025)
INSERT INTO PUBLIC_HOLIDAYS VALUES ('HOL001', 'New Year''s Day', DATE '2025-01-01', 'Y', SYSTIMESTAMP);
INSERT INTO PUBLIC_HOLIDAYS VALUES ('HOL002', 'Liberation Day', DATE '2025-01-04', 'Y', SYSTIMESTAMP);
COMMIT;

-- ============================================================
-- STEP 2: CREATE AUDIT LOG TABLE
-- ============================================================
CREATE TABLE AUDIT_LOG (
    audit_id VARCHAR2(20) PRIMARY KEY,
    table_name VARCHAR2(100) NOT NULL,
    operation_type VARCHAR2(20) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    attempted_by VARCHAR2(100) NOT NULL,
    attempted_at TIMESTAMP NOT NULL,
    is_allowed CHAR(1) NOT NULL CHECK (is_allowed IN ('Y', 'N')),
    denial_reason VARCHAR2(500),
    user_ip VARCHAR2(50),
    session_id VARCHAR2(100),
    old_values CLOB,
    new_values CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create sequence for audit log
CREATE SEQUENCE seq_audit_log START WITH 1 INCREMENT BY 1 NOCACHE;

-- Index for audit queries
CREATE INDEX idx_audit_table ON AUDIT_LOG(table_name, attempted_at);
CREATE INDEX idx_audit_user ON AUDIT_LOG(attempted_by, attempted_at);
CREATE INDEX idx_audit_allowed ON AUDIT_LOG(is_allowed, attempted_at);

-- ============================================================
-- STEP 3: AUDIT LOGGING FUNCTION
-- ============================================================
CREATE OR REPLACE FUNCTION fn_log_audit (
    p_table_name IN VARCHAR2,
    p_operation IN VARCHAR2,
    p_is_allowed IN CHAR,
    p_denial_reason IN VARCHAR2 DEFAULT NULL,
    p_old_values IN VARCHAR2 DEFAULT NULL,
    p_new_values IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_audit_id VARCHAR2(20);
    v_username VARCHAR2(100);
    v_ip VARCHAR2(50);
    v_session_id VARCHAR2(100);
BEGIN
    -- Get session information
    v_username := SYS_CONTEXT('USERENV', 'SESSION_USER');
    v_ip := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
    v_session_id := SYS_CONTEXT('USERENV', 'SESSIONID');
    
    -- Generate audit ID
    v_audit_id := 'AUD' || LPAD(seq_audit_log.NEXTVAL, 10, '0');
    
    -- Insert audit record
    INSERT INTO AUDIT_LOG (
        audit_id, table_name, operation_type, attempted_by,
        attempted_at, is_allowed, denial_reason, user_ip,
        session_id, old_values, new_values
    ) VALUES (
        v_audit_id, p_table_name, p_operation, v_username,
        SYSTIMESTAMP, p_is_allowed, p_denial_reason, v_ip,
        v_session_id, p_old_values, p_new_values
    );
    
    COMMIT;
    RETURN v_audit_id;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN NULL;
END fn_log_audit;
/

-- ============================================================
-- STEP 4: RESTRICTION CHECK FUNCTION
-- ============================================================
CREATE OR REPLACE FUNCTION fn_check_operation_allowed (
    p_operation_type IN VARCHAR2
) RETURN VARCHAR2 AS
    v_day_name VARCHAR2(10);
    v_is_holiday NUMBER;
    v_denial_reason VARCHAR2(500);
BEGIN
    -- Get current day of week
    v_day_name := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    
    -- Check if it's a weekday (Monday-Friday)
    IF v_day_name IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
        v_denial_reason := 'Operation denied: ' || p_operation_type || 
                          ' operations are not allowed on weekdays (Monday-Friday)';
        RETURN v_denial_reason;
    END IF;
    
    -- Check if it's a public holiday (upcoming month only)
    SELECT COUNT(*) INTO v_is_holiday
    FROM PUBLIC_HOLIDAYS
    WHERE holiday_date = TRUNC(SYSDATE)
      AND is_active = 'Y'
      AND holiday_date BETWEEN TRUNC(SYSDATE) AND ADD_MONTHS(TRUNC(SYSDATE), 1);
    
    IF v_is_holiday > 0 THEN
        SELECT 'Operation denied: ' || p_operation_type || 
               ' operations are not allowed on public holidays (' || holiday_name || ')'
        INTO v_denial_reason
        FROM PUBLIC_HOLIDAYS
        WHERE holiday_date = TRUNC(SYSDATE)
          AND is_active = 'Y';
        
        RETURN v_denial_reason;
    END IF;
    
    -- Operation is allowed
    RETURN NULL;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error checking restrictions: ' || SQLERRM;
END fn_check_operation_allowed;
/

-- ============================================================
-- STEP 5: SIMPLE TRIGGERS FOR MAIN TABLES
-- ============================================================

-- Trigger 1: DONORS Table - INSERT Restriction
CREATE OR REPLACE TRIGGER trg_donors_insert_restrict
BEFORE INSERT ON DONORS
FOR EACH ROW
DECLARE
    v_denial_reason VARCHAR2(500);
    v_audit_id VARCHAR2(20);
BEGIN
    -- Check if operation is allowed
    v_denial_reason := fn_check_operation_allowed('INSERT');
    
    IF v_denial_reason IS NOT NULL THEN
        -- Log denied attempt
        v_audit_id := fn_log_audit(
            p_table_name => 'DONORS',
            p_operation => 'INSERT',
            p_is_allowed => 'N',
            p_denial_reason => v_denial_reason,
            p_new_values => 'donor_id=' || :NEW.donor_id || 
                           ', name=' || :NEW.first_name || ' ' || :NEW.last_name
        );
        
        -- Raise error to prevent operation
        RAISE_APPLICATION_ERROR(-20001, v_denial_reason);
    ELSE
        -- Log allowed operation
        v_audit_id := fn_log_audit(
            p_table_name => 'DONORS',
            p_operation => 'INSERT',
            p_is_allowed => 'Y',
            p_new_values => 'donor_id=' || :NEW.donor_id
        );
    END IF;
END;
/

-- Trigger 2: DONORS Table - UPDATE Restriction
CREATE OR REPLACE TRIGGER trg_donors_update_restrict
BEFORE UPDATE ON DONORS
FOR EACH ROW
DECLARE
    v_denial_reason VARCHAR2(500);
    v_audit_id VARCHAR2(20);
BEGIN
    v_denial_reason := fn_check_operation_allowed('UPDATE');
    
    IF v_denial_reason IS NOT NULL THEN
        v_audit_id := fn_log_audit(
            p_table_name => 'DONORS',
            p_operation => 'UPDATE',
            p_is_allowed => 'N',
            p_denial_reason => v_denial_reason,
            p_old_values => 'donor_id=' || :OLD.donor_id || ', status=' || :OLD.status,
            p_new_values => 'donor_id=' || :NEW.donor_id || ', status=' || :NEW.status
        );
        
        RAISE_APPLICATION_ERROR(-20002, v_denial_reason);
    ELSE
        v_audit_id := fn_log_audit(
            p_table_name => 'DONORS',
            p_operation => 'UPDATE',
            p_is_allowed => 'Y',
            p_old_values => 'donor_id=' || :OLD.donor_id,
            p_new_values => 'donor_id=' || :NEW.donor_id
        );
    END IF;
END;
/

-- Trigger 3: DONORS Table - DELETE Restriction
CREATE OR REPLACE TRIGGER trg_donors_delete_restrict
BEFORE DELETE ON DONORS
FOR EACH ROW
DECLARE
    v_denial_reason VARCHAR2(500);
    v_audit_id VARCHAR2(20);
BEGIN
    v_denial_reason := fn_check_operation_allowed('DELETE');
    
    IF v_denial_reason IS NOT NULL THEN
        v_audit_id := fn_log_audit(
            p_table_name => 'DONORS',
            p_operation => 'DELETE',
            p_is_allowed => 'N',
            p_denial_reason => v_denial_reason,
            p_old_values => 'donor_id=' || :OLD.donor_id || 
                           ', name=' || :OLD.first_name || ' ' || :OLD.last_name
        );
        
        RAISE_APPLICATION_ERROR(-20003, v_denial_reason);
    ELSE
        v_audit_id := fn_log_audit(
            p_table_name => 'DONORS',
            p_operation => 'DELETE',
            p_is_allowed => 'Y',
            p_old_values => 'donor_id=' || :OLD.donor_id
        );
    END IF;
END;
/

-- Trigger 4: DONATIONS Table - INSERT Restriction
CREATE OR REPLACE TRIGGER trg_donations_insert_restrict
BEFORE INSERT ON DONATIONS
FOR EACH ROW
DECLARE
    v_denial_reason VARCHAR2(500);
    v_audit_id VARCHAR2(20);
BEGIN
    v_denial_reason := fn_check_operation_allowed('INSERT');
    
    IF v_denial_reason IS NOT NULL THEN
        v_audit_id := fn_log_audit(
            p_table_name => 'DONATIONS',
            p_operation => 'INSERT',
            p_is_allowed => 'N',
            p_denial_reason => v_denial_reason,
            p_new_values => 'donation_id=' || :NEW.donation_id || 
                           ', donor_id=' || :NEW.donor_id
        );
        
        RAISE_APPLICATION_ERROR(-20004, v_denial_reason);
    ELSE
        v_audit_id := fn_log_audit(
            p_table_name => 'DONATIONS',
            p_operation => 'INSERT',
            p_is_allowed => 'Y',
            p_new_values => 'donation_id=' || :NEW.donation_id
        );
    END IF;
END;
/

-- Trigger 5: BLOOD_UNITS Table - DELETE Restriction
CREATE OR REPLACE TRIGGER trg_blood_units_delete_restrict
BEFORE DELETE ON BLOOD_UNITS
FOR EACH ROW
DECLARE
    v_denial_reason VARCHAR2(500);
    v_audit_id VARCHAR2(20);
BEGIN
    v_denial_reason := fn_check_operation_allowed('DELETE');
    
    IF v_denial_reason IS NOT NULL THEN
        v_audit_id := fn_log_audit(
            p_table_name => 'BLOOD_UNITS',
            p_operation => 'DELETE',
            p_is_allowed => 'N',
            p_denial_reason => v_denial_reason,
            p_old_values => 'unit_id=' || :OLD.unit_id || 
                           ', status=' || :OLD.status
        );
        
        RAISE_APPLICATION_ERROR(-20005, v_denial_reason);
    ELSE
        v_audit_id := fn_log_audit(
            p_table_name => 'BLOOD_UNITS',
            p_operation => 'DELETE',
            p_is_allowed => 'Y',
            p_old_values => 'unit_id=' || :OLD.unit_id
        );
    END IF;
END;
/

-- ============================================================
-- STEP 6: COMPOUND TRIGGER FOR COMPREHENSIVE AUDITING
-- ============================================================
CREATE OR REPLACE TRIGGER trg_facilities_compound_audit
FOR INSERT OR UPDATE OR DELETE ON FACILITIES
COMPOUND TRIGGER
    
    -- Collection type for storing changes
    TYPE t_changes IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
    v_changes t_changes;
    v_counter PLS_INTEGER := 0;
    
    -- BEFORE STATEMENT
    BEFORE STATEMENT IS
    BEGIN
        v_counter := 0;
        DBMS_OUTPUT.PUT_LINE('=== FACILITIES OPERATION STARTED ===');
    END BEFORE STATEMENT;
    
    -- BEFORE EACH ROW
    BEFORE EACH ROW IS
        v_denial_reason VARCHAR2(500);
        v_operation VARCHAR2(20);
    BEGIN
        -- Determine operation type
        IF INSERTING THEN
            v_operation := 'INSERT';
        ELSIF UPDATING THEN
            v_operation := 'UPDATE';
        ELSIF DELETING THEN
            v_operation := 'DELETE';
        END IF;
        
        -- Check restrictions
        v_denial_reason := fn_check_operation_allowed(v_operation);
        
        IF v_denial_reason IS NOT NULL THEN
            -- Log and block
            DECLARE
                v_audit_id VARCHAR2(20);
            BEGIN
                v_audit_id := fn_log_audit(
                    p_table_name => 'FACILITIES',
                    p_operation => v_operation,
                    p_is_allowed => 'N',
                    p_denial_reason => v_denial_reason
                );
            END;
            
            RAISE_APPLICATION_ERROR(-20006, v_denial_reason);
        END IF;
    END BEFORE EACH ROW;
    
    -- AFTER EACH ROW
    AFTER EACH ROW IS
        v_change_desc VARCHAR2(4000);
        v_audit_id VARCHAR2(20);
    BEGIN
        v_counter := v_counter + 1;
        
        IF INSERTING THEN
            v_change_desc := 'INSERT: facility_id=' || :NEW.facility_id || 
                           ', name=' || :NEW.facility_name;
            v_audit_id := fn_log_audit(
                p_table_name => 'FACILITIES',
                p_operation => 'INSERT',
                p_is_allowed => 'Y',
                p_new_values => v_change_desc
            );
        ELSIF UPDATING THEN
            v_change_desc := 'UPDATE: facility_id=' || :NEW.facility_id || 
                           ', old_status=' || :OLD.is_active || 
                           ', new_status=' || :NEW.is_active;
            v_audit_id := fn_log_audit(
                p_table_name => 'FACILITIES',
                p_operation => 'UPDATE',
                p_is_allowed => 'Y',
                p_old_values => 'status=' || :OLD.is_active,
                p_new_values => 'status=' || :NEW.is_active
            );
        ELSIF DELETING THEN
            v_change_desc := 'DELETE: facility_id=' || :OLD.facility_id || 
                           ', name=' || :OLD.facility_name;
            v_audit_id := fn_log_audit(
                p_table_name => 'FACILITIES',
                p_operation => 'DELETE',
                p_is_allowed => 'Y',
                p_old_values => v_change_desc
            );
        END IF;
        
        v_changes(v_counter) := v_change_desc;
    END AFTER EACH ROW;
    
    -- AFTER STATEMENT
    AFTER STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Total rows affected: ' || v_counter);
        FOR i IN 1..v_counter LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || v_changes(i));
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('=== FACILITIES OPERATION COMPLETED ===');
    END AFTER STATEMENT;
    
END trg_facilities_compound_audit;
/

-- ============================================================
-- TESTING SCRIPT
-- ============================================================

-- Enable DBMS_OUTPUT
SET SERVEROUTPUT ON;

-- Test Suite
DECLARE
    v_test_donor_id VARCHAR2(20) := 'DNR99999';
    v_error_msg VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('======================================');
    DBMS_OUTPUT.PUT_LINE('TRIGGER TESTING - BLOOD BANK SYSTEM');
    DBMS_OUTPUT.PUT_LINE('Current Day: ' || TO_CHAR(SYSDATE, 'DAY'));
    DBMS_OUTPUT.PUT_LINE('Current Date: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('======================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 1: Try to INSERT on current day
    DBMS_OUTPUT.PUT_LINE('TEST 1: Attempting INSERT on DONORS table...');
    BEGIN
        INSERT INTO DONORS (
            donor_id, national_id, first_name, last_name, date_of_birth,
            gender, blood_type, rh_factor, weight_kg, phone_number,
            status, is_active
        ) VALUES (
            v_test_donor_id, '1199912345678901', 'Test', 'Donor',
            DATE '1990-01-01', 'M', 'O', '+', 70, '+250788999999',
            'Active', 'Y'
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✓ INSERT ALLOWED - Operation completed successfully');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('✗ INSERT DENIED - ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 2: Try to UPDATE
    DBMS_OUTPUT.PUT_LINE('TEST 2: Attempting UPDATE on DONORS table...');
    BEGIN
        UPDATE DONORS
        SET status = 'Deferred'
        WHERE donor_id = 'DNR00001';
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✓ UPDATE ALLOWED - Operation completed successfully');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('✗ UPDATE DENIED - ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 3: Try to DELETE
    DBMS_OUTPUT.PUT_LINE('TEST 3: Attempting DELETE on DONORS table...');
    BEGIN
        DELETE FROM DONORS WHERE donor_id = v_test_donor_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✓ DELETE ALLOWED - Operation completed successfully');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('✗ DELETE DENIED - ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- TEST 4: Insert on DONATIONS
    DBMS_OUTPUT.PUT_LINE('TEST 4: Attempting INSERT on DONATIONS table...');
    BEGIN
        INSERT INTO DONATIONS (
            donation_id, donor_id, facility_id, donation_date,
            donation_time, donation_type, collection_bag_number, status
        ) VALUES (
            'DON99999', 'DNR00001', 'FAC001', TRUNC(SYSDATE),
            SYSTIMESTAMP, 'Whole Blood', 'BAGTEST99999', 'Completed'
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✓ INSERT ALLOWED - Donation recorded');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('✗ INSERT DENIED - ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('======================================');
END;
/

-- ============================================================
-- AUDIT LOG QUERIES
-- ============================================================

-- Query 1: View all audit attempts
SELECT 
    audit_id,
    table_name,
    operation_type,
    attempted_by,
    TO_CHAR(attempted_at, 'YYYY-MM-DD HH24:MI:SS') AS attempt_time,
    is_allowed,
    SUBSTR(denial_reason, 1, 50) AS reason,
    user_ip
FROM AUDIT_LOG
ORDER BY attempted_at DESC
FETCH FIRST 20 ROWS ONLY;

-- Query 2: Count denied vs allowed operations
SELECT 
    table_name,
    operation_type,
    is_allowed,
    COUNT(*) AS total_attempts,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY table_name, operation_type), 2) AS percentage
FROM AUDIT_LOG
GROUP BY table_name, operation_type, is_allowed
ORDER BY table_name, operation_type, is_allowed;

-- Query 3: Denied operations by day
SELECT 
    TO_CHAR(attempted_at, 'YYYY-MM-DD') AS attempt_date,
    TO_CHAR(attempted_at, 'DAY') AS day_name,
    COUNT(*) AS denied_attempts,
    table_name
FROM AUDIT_LOG
WHERE is_allowed = 'N'
GROUP BY TO_CHAR(attempted_at, 'YYYY-MM-DD'), TO_CHAR(attempted_at, 'DAY'), table_name
ORDER BY attempt_date DESC;

-- Query 4: User activity summary
SELECT 
    attempted_by,
    table_name,
    operation_type,
    SUM(CASE WHEN is_allowed = 'Y' THEN 1 ELSE 0 END) AS allowed,
    SUM(CASE WHEN is_allowed = 'N' THEN 1 ELSE 0 END) AS denied
FROM AUDIT_LOG
GROUP BY attempted_by, table_name, operation_type
ORDER BY attempted_by, table_name;

-- Query 5: Recent violations
SELECT 
    TO_CHAR(attempted_at, 'YYYY-MM-DD HH24:MI:SS') AS violation_time,
    attempted_by,
    table_name,
    operation_type,
    SUBSTR(denial_reason, 1, 100) AS reason
FROM AUDIT_LOG
WHERE is_allowed = 'N'
ORDER BY attempted_at DESC
FETCH FIRST 10 ROWS ONLY;

COMMIT;
