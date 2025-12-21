-- Drop and recreate the package body
CREATE OR REPLACE PACKAGE BODY blood_bank_pkg AS
    
    -- Procedure: schedule_donation_appointment
    PROCEDURE schedule_donation_appointment (
        p_donor_id      IN VARCHAR2,
        p_facility_id   IN VARCHAR2,
        p_appointment_date IN DATE,
        p_appointment_time IN TIMESTAMP,
        p_appointment_type IN VARCHAR2 DEFAULT 'Blood Donation',
        p_scheduled_by  IN VARCHAR2
    ) IS
        v_appointment_id VARCHAR2(20);
    BEGIN
        v_appointment_id := 'APP' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4);
        
        INSERT INTO APPOINTMENTS (
            appointment_id, donor_id, facility_id, appointment_date,
            appointment_time, appointment_type, status, scheduled_by, created_at
        ) VALUES (
            v_appointment_id, p_donor_id, p_facility_id, p_appointment_date,
            p_appointment_time, p_appointment_type, 'Scheduled', p_scheduled_by, SYSTIMESTAMP
        );
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Appointment scheduled: ' || v_appointment_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END schedule_donation_appointment;
    
    -- Function: check_donor_eligibility
    FUNCTION check_donor_eligibility (
        p_donor_id IN VARCHAR2
    ) RETURN VARCHAR2 AS
        v_last_donation DATE;
        v_deferral_until DATE;
        v_status VARCHAR2(20);
    BEGIN
        SELECT last_donation_date, status INTO v_last_donation, v_status
        FROM DONORS WHERE donor_id = p_donor_id;
        
        SELECT MAX(deferred_until) INTO v_deferral_until
        FROM DONOR_DEFERRALS 
        WHERE donor_id = p_donor_id AND deferred_until > SYSDATE;
        
        IF v_deferral_until IS NOT NULL THEN
            RETURN 'Deferred until ' || TO_CHAR(v_deferral_until, 'DD-MON-YYYY');
        END IF;
        
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
    END check_donor_eligibility;
    
    -- Function: get_available_blood_units
    FUNCTION get_available_blood_units (
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
    END get_available_blood_units;
    
    -- Cursor: get_donor_history
    CURSOR get_donor_history (p_donor_id VARCHAR2) RETURN DONATIONS%ROWTYPE IS
        SELECT * FROM DONATIONS 
        WHERE donor_id = p_donor_id 
        ORDER BY donation_date DESC;
        
END blood_bank_pkg;
/
