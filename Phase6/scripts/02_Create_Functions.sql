-- 1. Function to calculate donor eligibility
CREATE OR REPLACE FUNCTION check_donor_eligibility (
    p_donor_id IN VARCHAR2
) RETURN VARCHAR2 AS
    v_last_donation DATE;
    v_deferral_until DATE;
    v_age_months NUMBER;
    v_status VARCHAR2(20);
BEGIN
    SELECT last_donation_date, status INTO v_last_donation, v_status
    FROM DONORS WHERE donor_id = p_donor_id;
    
    SELECT MAX(deferred_until) INTO v_deferral_until
    FROM DONOR_DEFERRALS 
    WHERE donor_id = p_donor_id AND deferred_until > SYSDATE;
    
    -- Check deferral period
    IF v_deferral_until IS NOT NULL THEN
        RETURN 'Deferred until ' || TO_CHAR(v_deferral_until, 'DD-MON-YYYY');
    END IF;
    
    -- Check donation interval (56 days for whole blood)
    IF v_last_donation IS NOT NULL AND SYSDATE - v_last_donation < 56 THEN
        RETURN 'Last donation too recent';
    END IF;
    
    IF v_status != 'Active' THEN
        RETURN 'Donor status: ' || v_status;
    END IF;
    
    RETURN 'Eligible';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Donor not found';
END;
/

-- 2. Function to get available blood units count
CREATE OR REPLACE FUNCTION get_available_blood_units (
    p_facility_id   IN VARCHAR2,
    p_blood_type    IN VARCHAR2 DEFAULT NULL,
    p_rh_factor     IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM BLOOD_UNITS 
    WHERE facility_id = p_facility_id 
    AND status = 'Available'
    AND expiration_date > SYSDATE
    AND (p_blood_type IS NULL OR blood_type = p_blood_type)
    AND (p_rh_factor IS NULL OR rh_factor = p_rh_factor);
    
    RETURN v_count;
END;
/

-- 3. Function to calculate donor's next eligible donation date
CREATE OR REPLACE FUNCTION calculate_next_donation_date (
    p_donor_id IN VARCHAR2
) RETURN DATE AS
    v_last_donation DATE;
    v_deferral_until DATE;
BEGIN
    SELECT last_donation_date INTO v_last_donation
    FROM DONORS WHERE donor_id = p_donor_id;
    
    SELECT MAX(deferred_until) INTO v_deferral_until
    FROM DONOR_DEFERRALS 
    WHERE donor_id = p_donor_id AND deferred_until > SYSDATE;
    
    IF v_deferral_until IS NOT NULL AND v_deferral_until > SYSDATE + 56 THEN
        RETURN v_deferral_until;
    ELSIF v_last_donation IS NOT NULL THEN
        RETURN v_last_donation + 56; -- 56-day deferral period
    ELSE
        RETURN SYSDATE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/
CREATE OR REPLACE FUNCTION log_audit_event (
    p_table_name    IN VARCHAR2,
    p_operation     IN VARCHAR2,
    p_record_id     IN VARCHAR2,
    p_old_values    IN CLOB DEFAULT NULL,
    p_new_values    IN CLOB DEFAULT NULL,
    p_status        IN VARCHAR2,
    p_reason        IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 AS
    PRAGMA AUTONOMOUS_TRANSACTION; -- Important for triggers
    v_audit_id VARCHAR2(20);
BEGIN
    -- Generate audit ID
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
        ROLLBACK;
        RETURN NULL;
END log_audit_event;
/
-- ============================================================
-- FUNCTION WITH EXCEPTION HANDLING AND VALIDATION
-- ============================================================
CREATE OR REPLACE FUNCTION calculate_donor_eligibility_score (
    p_donor_id IN VARCHAR2
) RETURN NUMBER AS
    v_score NUMBER := 0;
    v_age_months NUMBER;
    v_last_donation DATE;
    v_total_donations NUMBER;
    v_health_checks_passed NUMBER := 0;
    v_parameters VARCHAR2(500);
    
    -- Custom exceptions
    invalid_donor_data EXCEPTION;
    calculation_error EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(invalid_donor_data, -20020);
    PRAGMA EXCEPTION_INIT(calculation_error, -20021);
BEGIN
    v_parameters := 'donor_id=' || p_donor_id;
    
    -- Parameter validation
    IF p_donor_id IS NULL OR LENGTH(TRIM(p_donor_id)) = 0 THEN
        RAISE_APPLICATION_ERROR(-20022, 'Donor ID cannot be null or empty');
    END IF;
    
    -- Retrieve donor data with validation
    BEGIN
        SELECT 
            MONTHS_BETWEEN(SYSDATE, date_of_birth),
            last_donation_date,
            total_donations
        INTO 
            v_age_months,
            v_last_donation,
            v_total_donations
        FROM DONORS 
        WHERE donor_id = p_donor_id;
        
        IF v_age_months IS NULL THEN
            RAISE invalid_donor_data;
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE invalid_donor_data;
    END;
    
    -- SCORE CALCULATION WITH VALIDATION
    -- 1. Age score (18-60 = 30 points, outside = 0)
    IF v_age_months/12 BETWEEN 18 AND 60 THEN
        v_score := v_score + 30;
    END IF;
    
    -- 2. Donation frequency score
    IF v_last_donation IS NULL THEN
        v_score := v_score + 20; -- First-time donor bonus
    ELSIF SYSDATE - v_last_donation >= 56 THEN
        v_score := v_score + 25; -- Eligible for donation
    ELSIF SYSDATE - v_last_donation >= 30 THEN
        v_score := v_score + 15; -- Recently donated
    END IF;
    
    -- 3. Experience score
    IF v_total_donations > 10 THEN
        v_score := v_score + 30;
    ELSIF v_total_donations > 5 THEN
        v_score := v_score + 20;
    ELSIF v_total_donations > 0 THEN
        v_score := v_score + 10;
    END IF;
    
    -- 4. Health check score (simulated)
    DECLARE
        v_health_score NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_health_checks_passed
        FROM (
            -- Simulated health checks
            SELECT 1 FROM DUAL WHERE v_age_months/12 BETWEEN 18 AND 65
            UNION ALL
            SELECT 1 FROM DUAL WHERE v_total_donations < 50 -- Not excessive
            UNION ALL
            SELECT 1 FROM DUAL WHERE v_last_donation IS NULL 
                OR SYSDATE - v_last_donation >= 56 -- Proper interval
        );
        
        v_score := v_score + (v_health_checks_passed * 5);
        
        -- Validate score calculation
        IF v_score < 0 OR v_score > 100 THEN
            RAISE calculation_error;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            blood_bank_exceptions_pkg.log_error(
                'calculate_donor_eligibility_score',
                SQLCODE,
                'Health check calculation failed: ' || SQLERRM,
                v_parameters
            );
            v_score := 50; -- Default score on calculation error
    END;
    
    RETURN LEAST(GREATEST(v_score, 0), 100); -- Ensure score 0-100
    
EXCEPTION
    WHEN invalid_donor_data THEN
        blood_bank_exceptions_pkg.log_error(
            'calculate_donor_eligibility_score',
            -20020,
            'Invalid or missing donor data for ID: ' || p_donor_id,
            v_parameters
        );
        RETURN 0; -- Recovery: return minimum score
        
    WHEN calculation_error THEN
        blood_bank_exceptions_pkg.log_error(
            'calculate_donor_eligibility_score',
            -20021,
            'Score calculation out of bounds: ' || v_score,
            v_parameters
        );
        RETURN 50; -- Recovery: return median score
        
    WHEN VALUE_ERROR THEN
        blood_bank_exceptions_pkg.log_error(
            'calculate_donor_eligibility_score',
            SQLCODE,
            'Value error in parameters: ' || SQLERRM,
            v_parameters
        );
        RETURN 0;
        
    WHEN OTHERS THEN
        blood_bank_exceptions_pkg.log_error(
            'calculate_donor_eligibility_score',
            SQLCODE,
            'Unexpected error: ' || SQLERRM || ' | Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK,
            v_parameters
        );
        RETURN 0; -- Recovery: safe default
        
END calculate_donor_eligibility_score;
/
