-- View to monitor employee S activities
CREATE OR REPLACE VIEW vw_employee_s_audit AS
SELECT 
    audit_id,
    table_name,
    operation_type,
    attempt_status,
    denial_reason,
    attempted_date,
    attempted_time,
    user_name,
    ip_address
FROM AUDIT_LOG 
WHERE user_name = 'EMPLOYEE_S'
ORDER BY attempted_time DESC;

-- Procedure to generate audit report
CREATE OR REPLACE PROCEDURE generate_audit_report (
    p_start_date IN DATE DEFAULT TRUNC(SYSDATE) - 30,
    p_end_date   IN DATE DEFAULT SYSDATE
) AS
    CURSOR c_audit IS
        SELECT 
            attempt_status,
            table_name,
            operation_type,
            COUNT(*) as attempt_count,
            MIN(attempted_date) as first_attempt,
            MAX(attempted_date) as last_attempt
        FROM AUDIT_LOG 
        WHERE attempted_date BETWEEN p_start_date AND p_end_date
        GROUP BY attempt_status, table_name, operation_type
        ORDER BY attempt_count DESC;
        
    v_total_attempts NUMBER;
    v_denied_attempts NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_attempts
    FROM AUDIT_LOG 
    WHERE attempted_date BETWEEN p_start_date AND p_end_date;
    
    SELECT COUNT(*) INTO v_denied_attempts
    FROM AUDIT_LOG 
    WHERE attempted_date BETWEEN p_start_date AND p_end_date
    AND attempt_status = 'DENIED';
    
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 70, '='));
    DBMS_OUTPUT.PUT_LINE('AUDIT REPORT: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || 
                         ' to ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 70, '='));
    DBMS_OUTPUT.PUT_LINE('Total attempts: ' || v_total_attempts);
    DBMS_OUTPUT.PUT_LINE('Denied attempts: ' || v_denied_attempts);
    DBMS_OUTPUT.PUT_LINE('Allowed attempts: ' || (v_total_attempts - v_denied_attempts));
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR rec IN c_audit LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.attempt_status, 10) ||
            RPAD(rec.table_name, 20) ||
            RPAD(rec.operation_type, 10) ||
            LPAD(rec.attempt_count, 8) || ' attempts' ||
            ' | First: ' || TO_CHAR(rec.first_attempt, 'DD-MON') ||
            ' | Last: ' || TO_CHAR(rec.last_attempt, 'DD-MON')
        );
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('=' || RPAD('=', 70, '='));
END;
/

-- Test the audit report
BEGIN
    generate_audit_report(TRUNC(SYSDATE) - 7, SYSDATE);
END;
/
