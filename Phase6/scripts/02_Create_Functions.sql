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
