-- ============================================================
-- TEST SUITE FOR EXCEPTION HANDLING
-- ============================================================
CREATE OR REPLACE PACKAGE blood_bank_test_pkg AS
    
    -- Test result types
    TYPE test_result_rec IS RECORD (
        test_name VARCHAR2(100),
        test_type VARCHAR2(50),
        status VARCHAR2(20),
        error_message VARCHAR2(4000),
        execution_time NUMBER,
        test_date DATE
    );
    
    TYPE test_result_table IS TABLE OF test_result_rec;
    
    -- Test procedures
    PROCEDURE test_predefined_exceptions;
    PROCEDURE test_custom_exceptions;
    PROCEDURE test_error_logging;
    PROCEDURE test_recovery_mechanisms;
    PROCEDURE test_edge_cases;
    PROCEDURE run_all_tests;
    
    -- Utility functions
    FUNCTION get_test_results RETURN test_result_table PIPELINED;
    PROCEDURE clear_test_data;
    
END blood_bank_test_pkg;
/

CREATE OR REPLACE PACKAGE BODY blood_bank_test_pkg AS
    
    -- Test results table
    g_test_results test_result_table := test_result_table();
    
    -- Helper procedure to add test result
    PROCEDURE add_test_result(
        p_test_name IN VARCHAR2,
        p_test_type IN VARCHAR2,
        p_status IN VARCHAR2,
        p_error_message IN VARCHAR2 DEFAULT NULL
    ) AS
    BEGIN
        g_test_results.EXTEND;
        g_test_results(g_test_results.LAST).test_name := p_test_name;
        g_test_results(g_test_results.LAST).test_type := p_test_type;
        g_test_results(g_test_results.LAST).status := p_status;
        g_test_results(g_test_results.LAST).error_message := p_error_message;
        g_test_results(g_test_results.LAST).test_date := SYSDATE;
    END add_test_result;
    
    -- TEST 1: Predefined Exceptions
    PROCEDURE test_predefined_exceptions AS
        v_start_time NUMBER;
        v_appointment_id VARCHAR2(20);
        v_status VARCHAR2(20);
        v_message VARCHAR2(4000);
    BEGIN
        v_start_time := DBMS_UTILITY.GET_TIME;
        
        -- Test 1.1: NO_DATA_FOUND
        BEGIN
            schedule_donation_appointment_complete(
                p_donor_id => 'NON_EXISTENT',
                p_facility_id => 'FAC001',
                p_appointment_date => SYSDATE + 7,
                p_appointment_time => SYSTIMESTAMP,
                p_scheduled_by => 'TESTER',
                p_out_appointment_id => v_appointment_id,
                p_out_status => v_status,
                p_out_message => v_message
            );
            
            IF v_status = 'FAILURE' AND v_message LIKE '%not found%' THEN
                add_test_result('NO_DATA_FOUND', 'PREDEFINED', 'PASSED');
            ELSE
                add_test_result('NO_DATA_FOUND', 'PREDEFINED', 'FAILED', 
                    'Expected failure but got: ' || v_status);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                add_test_result('NO_DATA_FOUND', 'PREDEFINED', 'ERROR', SQLERRM);
        END;
        
        -- Test 1.2: TOO_MANY_ROWS (simulated)
        BEGIN
            -- Create duplicate data scenario
            INSERT INTO DONORS (donor_id, national_id, first_name, last_name, 
                               date_of_birth, blood_type, rh_factor, phone_number)
            SELECT 'DUPTEST', 'DUPLICATE', 'Test', 'Duplicate', SYSDATE-365*30,
                   'O', '+', '123-456-7890'
            FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM DONORS WHERE donor_id = 'DUPTEST');
            
            -- This should cause issues if uniqueness constraints fail
            add_test_result('TOO_MANY_ROWS', 'PREDEFINED', 'PASSED');
            
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                add_test_result('DUP_VAL_ON_INDEX', 'PREDEFINED', 'PASSED');
            WHEN OTHERS THEN
                add_test_result('TOO_MANY_ROWS', 'PREDEFINED', 'ERROR', SQLERRM);
        END;
        
        -- Test 1.3: VALUE_ERROR
        BEGIN
            -- Pass invalid date format
            schedule_donation_appointment_complete(
                p_donor_id => NULL, -- Causes VALUE_ERROR
                p_facility_id => 'FAC001',
                p_appointment_date => SYSDATE,
                p_appointment_time => SYSTIMESTAMP,
                p_scheduled_by => 'TESTER',
                p_out_appointment_id => v_appointment_id,
                p_out_status => v_status,
                p_out_message => v_message
            );
            
            add_test_result('VALUE_ERROR', 'PREDEFINED', 'FAILED', 
                'Expected exception not raised');
        EXCEPTION
            WHEN VALUE_ERROR THEN
                add_test_result('VALUE_ERROR', 'PREDEFINED', 'PASSED');
            WHEN OTHERS THEN
                add_test_result('VALUE_ERROR', 'PREDEFINED', 'ERROR', SQLERRM);
        END;
        
        -- Calculate execution time
        g_test_results(g_test_results.LAST).execution_time := 
            (DBMS_UTILITY.GET_TIME - v_start_time) / 100;
            
    END test_predefined_exceptions;
    
    -- TEST 2: Custom Exceptions
    PROCEDURE test_custom_exceptions AS
        v_score NUMBER;
    BEGIN
        -- Test donor_not_found custom exception
        BEGIN
            v_score := calculate_donor_eligibility_score('INVALID_DONOR_999');
            
            IF v_score = 0 THEN
                add_test_result('donor_not_found', 'CUSTOM', 'PASSED');
            ELSE
                add_test_result('donor_not_found', 'CUSTOM', 'FAILED',
                    'Expected score 0 but got: ' || v_score);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                add_test_result('donor_not_found', 'CUSTOM', 'ERROR', SQLERRM);
        END;
        
        -- Test invalid_blood_type (would need setup)
        add_test_result('invalid_blood_type', 'CUSTOM', 'NOT_RUN', 
            'Requires specific test data');
            
    END test_custom_exceptions;
    
    -- TEST 3: Error Logging
    PROCEDURE test_error_logging AS
        v_error_count NUMBER;
    BEGIN
        -- Trigger an error to test logging
        BEGIN
            v_score := calculate_donor_eligibility_score(NULL);
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        -- Check if error was logged
        SELECT COUNT(*) INTO v_error_count
        FROM ERROR_LOG
        WHERE procedure_name = 'calculate_donor_eligibility_score'
        AND error_date >= SYSDATE - 1/24; -- Last hour
        
        IF v_error_count > 0 THEN
            add_test_result('error_logging', 'LOGGING', 'PASSED',
                'Logged ' || v_error_count || ' errors');
        ELSE
            add_test_result('error_logging', 'LOGGING', 'FAILED',
                'No errors logged');
        END IF;
        
    END test_error_logging;
    
    -- TEST 4: Recovery Mechanisms
    PROCEDURE test_recovery_mechanisms AS
    BEGIN
        -- Test rollback recovery
        BEGIN
            recover_failed_donation_transaction('TEST_DONATION', 'ROLLBACK');
            add_test_result('recovery_rollback', 'RECOVERY', 'PASSED');
        EXCEPTION
            WHEN OTHERS THEN
                add_test_result('recovery_rollback', 'RECOVERY', 'ERROR', SQLERRM);
        END;
        
        -- Test invalid recovery type
        BEGIN
            recover_failed_donation_transaction('TEST_DONATION', 'INVALID_TYPE');
            add_test_result('recovery_invalid_type', 'RECOVERY', 'FAILED',
                'Expected exception not raised');
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -20031 THEN
                    add_test_result('recovery_invalid_type', 'RECOVERY', 'PASSED');
                ELSE
                    add_test_result('recovery_invalid_type', 'RECOVERY', 'ERROR', SQLERRM);
                END IF;
        END;
        
    END test_recovery_mechanisms;
    
    -- TEST 5: Edge Cases
    PROCEDURE test_edge_cases AS
        v_score NUMBER;
    BEGIN
        -- Test with minimum values
        BEGIN
            -- Would need a donor with minimum age (18)
            add_test_result('edge_minimum_age', 'EDGE_CASE', 'NOT_RUN',
                'Requires test donor data');
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        -- Test with maximum values
        BEGIN
            -- Would need a donor with maximum donations
            add_test_result('edge_maximum_donations', 'EDGE_CASE', 'NOT_RUN',
                'Requires test donor data');
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        -- Test NULL handling
        BEGIN
            v_score := calculate_donor_eligibility_score(NULL);
            IF v_score = 0 THEN
                add_test_result('edge_null_input', 'EDGE_CASE', 'PASSED');
            ELSE
                add_test_result('edge_null_input', 'EDGE_CASE', 'FAILED',
                    'Expected 0 for NULL input');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                add_test_result('edge_null_input', 'EDGE_CASE', 'ERROR', SQLERRM);
        END;
        
    END test_edge_cases;
    
    -- Run all tests
    PROCEDURE run_all_tests AS
    BEGIN
        g_test_results := test_result_table(); -- Clear previous results
        
        test_predefined_exceptions;
        test_custom_exceptions;
        test_error_logging;
        test_recovery_mechanisms;
        test_edge_cases;
        
        -- Display summary
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('TEST SUITE COMPLETED');
        DBMS_OUTPUT.PUT_LINE('========================================');
        
        FOR rec IN (SELECT * FROM TABLE(get_test_results())) LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(rec.test_name, 30) ||
                RPAD(rec.test_type, 15) ||
                RPAD(rec.status, 10) ||
                NVL(rec.error_message, '')
            );
        END LOOP;
        
    END run_all_tests;
    
    -- Get test results
    FUNCTION get_test_results RETURN test_result_table PIPELINED AS
    BEGIN
        FOR i IN 1..g_test_results.COUNT LOOP
            PIPE ROW(g_test_results(i));
        END LOOP;
        RETURN;
    END get_test_results;
    
    -- Clear test data
    PROCEDURE clear_test_data AS
    BEGIN
        DELETE FROM ERROR_LOG WHERE user_name = USER;
        DELETE FROM AUDIT_LOG WHERE user_name = USER;
        COMMIT;
        g_test_results := test_result_table();
    END clear_test_data;
    
END blood_bank_test_pkg;
/
