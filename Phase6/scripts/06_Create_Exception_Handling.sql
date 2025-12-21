-- ============================================================
-- ERROR LOGGING TABLE (for tracking all exceptions)
-- ============================================================
CREATE TABLE ERROR_LOG (
    error_id VARCHAR2(20) PRIMARY KEY,
    procedure_name VARCHAR2(100) NOT NULL,
    error_code NUMBER,
    error_message VARCHAR2(4000) NOT NULL,
    error_stack CLOB,
    error_backtrace CLOB,
    call_stack CLOB,
    parameters CLOB,
    user_name VARCHAR2(100) DEFAULT USER,
    error_date DATE DEFAULT SYSDATE,
    error_time TIMESTAMP DEFAULT SYSTIMESTAMP,
    resolved CHAR(1) DEFAULT 'N' CHECK (resolved IN ('Y', 'N')),
    resolved_by VARCHAR2(100),
    resolved_date DATE,
    notes CLOB
);

CREATE INDEX idx_error_log_date ON ERROR_LOG(error_date);
CREATE INDEX idx_error_log_procedure ON ERROR_LOG(procedure_name);
CREATE INDEX idx_error_log_resolved ON ERROR_LOG(resolved);

-- ============================================================
-- PACKAGE FOR CUSTOM EXCEPTIONS
-- ============================================================
CREATE OR REPLACE PACKAGE blood_bank_exceptions_pkg AS
    -- Custom exception declarations
    donor_not_found EXCEPTION;
    insufficient_blood EXCEPTION;
    invalid_blood_type EXCEPTION;
    appointment_conflict EXCEPTION;
    facility_closed EXCEPTION;
    donor_deferred EXCEPTION;
    equipment_failure EXCEPTION;
    data_integrity_violation EXCEPTION;
    
    -- Associate exceptions with error codes
    PRAGMA EXCEPTION_INIT(donor_not_found, -20001);
    PRAGMA EXCEPTION_INIT(insufficient_blood, -20002);
    PRAGMA EXCEPTION_INIT(invalid_blood_type, -20003);
    PRAGMA EXCEPTION_INIT(appointment_conflict, -20004);
    PRAGMA EXCEPTION_INIT(facility_closed, -20005);
    PRAGMA EXCEPTION_INIT(donor_deferred, -20006);
    PRAGMA EXCEPTION_INIT(equipment_failure, -20007);
    PRAGMA EXCEPTION_INIT(data_integrity_violation, -20008);
    
    -- Error logging procedure
    PROCEDURE log_error(
        p_procedure_name IN VARCHAR2,
        p_error_code IN NUMBER DEFAULT NULL,
        p_error_message IN VARCHAR2,
        p_parameters IN VARCHAR2 DEFAULT NULL
    );
    
    -- Error recovery utilities
    FUNCTION get_last_error RETURN VARCHAR2;
    PROCEDURE mark_error_resolved(p_error_id IN VARCHAR2, p_notes IN CLOB DEFAULT NULL);
    
END blood_bank_exceptions_pkg;
/

CREATE OR REPLACE PACKAGE BODY blood_bank_exceptions_pkg AS
    
    PROCEDURE log_error(
        p_procedure_name IN VARCHAR2,
        p_error_code IN NUMBER DEFAULT NULL,
        p_error_message IN VARCHAR2,
        p_parameters IN VARCHAR2 DEFAULT NULL
    ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_error_id VARCHAR2(20);
    BEGIN
        v_error_id := 'ERR' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4);
        
        INSERT INTO ERROR_LOG (
            error_id, procedure_name, error_code, error_message,
            error_stack, error_backtrace, call_stack,
            parameters, user_name
        ) VALUES (
            v_error_id, p_procedure_name, p_error_code, p_error_message,
            DBMS_UTILITY.FORMAT_ERROR_STACK,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            DBMS_UTILITY.FORMAT_CALL_STACK,
            p_parameters, USER
        );
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Even if error logging fails, don't propagate
            NULL;
    END log_error;
    
    FUNCTION get_last_error RETURN VARCHAR2 AS
        v_error_message VARCHAR2(4000);
    BEGIN
        SELECT error_message INTO v_error_message
        FROM ERROR_LOG
        WHERE error_date = (SELECT MAX(error_date) FROM ERROR_LOG)
        AND ROWNUM = 1;
        
        RETURN v_error_message;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'No errors found';
    END get_last_error;
    
    PROCEDURE mark_error_resolved(p_error_id IN VARCHAR2, p_notes IN CLOB DEFAULT NULL) AS
    BEGIN
        UPDATE ERROR_LOG
        SET resolved = 'Y',
            resolved_by = USER,
            resolved_date = SYSDATE,
            notes = COALESCE(notes || CHR(10) || 'Resolved: ' || p_notes, p_notes)
        WHERE error_id = p_error_id;
        
        COMMIT;
    END mark_error_resolved;
    
END blood_bank_exceptions_pkg;
/
