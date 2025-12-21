-- Test 1: Attempt INSERT on weekday (should be DENIED for EMPLOYEE_S)
-- Run this on a Monday-Friday
BEGIN
    -- First, create EMPLOYEE_S user if not exists
    EXECUTE IMMEDIATE 'CREATE USER employee_s IDENTIFIED BY password123';
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO employee_s';
    EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON DONATIONS TO employee_s';
    EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON BLOOD_UNITS TO employee_s';
    EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON FACILITIES TO employee_s';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Switch to EMPLOYEE_S session (simulated)
-- In a real scenario, you would connect as EMPLOYEE_S
-- This test simulates the behavior:

DECLARE
    v_result VARCHAR2(500);
BEGIN
    -- Test weekday restriction
    v_result := check_employee_s_restriction();
    DBMS_OUTPUT.PUT_LINE('Restriction check result: ' || v_result);
    
    -- Attempt to insert (will be denied on weekdays)
    BEGIN
        INSERT INTO DONATIONS (donation_id, donor_id, facility_id, donation_date, donation_time)
        VALUES ('TEST001', 'DON001', 'FAC001', SYSDATE, SYSTIMESTAMP);
        DBMS_OUTPUT.PUT_LINE('INSERT allowed');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('INSERT denied: ' || SQLERRM);
    END;
END;
/

-- Test 2: Check audit log
SELECT 
    audit_id,
    table_name,
    operation_type,
    attempt_status,
    denial_reason,
    TO_CHAR(attempted_date, 'DD-MON-YYYY') as attempt_date,
    user_name
FROM AUDIT_LOG 
ORDER BY attempted_time DESC;

-- Test 3: Verify holiday restriction
-- Add a holiday for today
INSERT INTO HOLIDAYS (holiday_id, holiday_name, holiday_date) 
VALUES ('TEST_HOL', 'Test Holiday', TRUNC(SYSDATE));
COMMIT;

-- Test holiday restriction
DECLARE
    v_result VARCHAR2(500);
BEGIN
    v_result := check_employee_s_restriction();
    DBMS_OUTPUT.PUT_LINE('Holiday restriction check: ' || v_result);
END;
/

-- Test 4: Weekend test (should be ALLOWED)
-- To test this, you would need to run on a Saturday or Sunday
-- Or temporarily modify the is_weekday function

-- Test 5: Clean up test data
DELETE FROM HOLIDAYS WHERE holiday_id = 'TEST_HOL';
COMMIT;

-- Display audit log summary
SELECT 
    attempt_status,
    COUNT(*) as attempt_count,
    table_name,
    operation_type
FROM AUDIT_LOG 
GROUP BY attempt_status, table_name, operation_type
ORDER BY attempt_status, attempt_count DESC;
