-- 1. Procedure to schedule a donation appointment
CREATE OR REPLACE PROCEDURE schedule_donation_appointment (
    p_donor_id      IN VARCHAR2,
    p_facility_id   IN VARCHAR2,
    p_appointment_date IN DATE,
    p_appointment_time IN TIMESTAMP,
    p_appointment_type IN VARCHAR2 DEFAULT 'Blood Donation',
    p_scheduled_by  IN VARCHAR2
) AS
    v_appointment_id VARCHAR2(20);
BEGIN
    -- Generate appointment ID
    v_appointment_id := 'APP' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4);
    
    INSERT INTO APPOINTMENTS (
        appointment_id, donor_id, facility_id, appointment_date,
        appointment_time, appointment_type, status, scheduled_by, created_at
    ) VALUES (
        v_appointment_id, p_donor_id, p_facility_id, p_appointment_date,
        p_appointment_time, p_appointment_type, 'Scheduled', p_scheduled_by, SYSTIMESTAMP
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment ' || v_appointment_id || ' scheduled successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error scheduling appointment: ' || SQLERRM);
END;
/
    
-- ============================================================
-- ENHANCED DONATION SCHEDULING PROCEDURE
-- ============================================================
CREATE OR REPLACE PROCEDURE schedule_donation_appointment_complete (
    p_donor_id      IN VARCHAR2,
    p_facility_id   IN VARCHAR2,
    p_appointment_date IN DATE,
    p_appointment_time IN TIMESTAMP,
    p_appointment_type IN VARCHAR2 DEFAULT 'Blood Donation',
    p_scheduled_by  IN VARCHAR2,
    p_out_appointment_id OUT VARCHAR2,
    p_out_status    OUT VARCHAR2,
    p_out_message   OUT VARCHAR2
) AS
    v_appointment_id VARCHAR2(20);
    v_facility_status VARCHAR2(1);
    v_donor_status VARCHAR2(20);
    v_last_donation DATE;
    v_deferral_date DATE;
    v_parameters VARCHAR2(1000);
    
    -- Custom local exceptions
    donor_too_young EXCEPTION;
    donor_too_old EXCEPTION;
    invalid_appointment_time EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(donor_too_young, -20009);
    PRAGMA EXCEPTION_INIT(donor_too_old, -20010);
    PRAGMA EXCEPTION_INIT(invalid_appointment_time, -20011);
BEGIN
    -- Initialize output parameters
    p_out_status := 'FAILURE';
    p_out_message := NULL;
    
    -- Build parameter string for error logging
    v_parameters := 'donor_id=' || p_donor_id || 
                   ', facility_id=' || p_facility_id || 
                   ', appointment_date=' || TO_CHAR(p_appointment_date, 'YYYY-MM-DD');
    
    -- PRECONDITION CHECKS
    -- 1. Check facility exists and is active
    BEGIN
        SELECT is_active INTO v_facility_status
        FROM FACILITIES 
        WHERE facility_id = p_facility_id;
        
        IF v_facility_status != 'Y' THEN
            RAISE blood_bank_exceptions_pkg.facility_closed;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE blood_bank_exceptions_pkg.donor_not_found;
    END;
    
    -- 2. Check donor exists and is active
    BEGIN
        SELECT status, last_donation_date INTO v_donor_status, v_last_donation
        FROM DONORS 
        WHERE donor_id = p_donor_id;
        
        IF v_donor_status != 'Active' THEN
            RAISE blood_bank_exceptions_pkg.donor_deferred;
        END IF;
        
        -- Check age restrictions
        DECLARE
            v_age_years NUMBER;
        BEGIN
            SELECT MONTHS_BETWEEN(SYSDATE, date_of_birth)/12 INTO v_age_years
            FROM DONORS WHERE donor_id = p_donor_id;
            
            IF v_age_years < 18 THEN
                RAISE donor_too_young;
            ELSIF v_age_years > 65 THEN
                RAISE donor_too_old;
            END IF;
        END;
        
        -- Check donation interval (56 days minimum)
        IF v_last_donation IS NOT NULL AND p_appointment_date - v_last_donation < 56 THEN
            RAISE_APPLICATION_ERROR(-20012, 
                'Donor must wait 56 days between donations. Last donation: ' || 
                TO_CHAR(v_last_donation, 'DD-MON-YYYY'));
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE blood_bank_exceptions_pkg.donor_not_found;
    END;
    
    -- 3. Check appointment time is during business hours (9 AM - 5 PM)
    IF TO_NUMBER(TO_CHAR(p_appointment_time, 'HH24')) < 9 OR 
       TO_NUMBER(TO_CHAR(p_appointment_time, 'HH24')) >= 17 THEN
        RAISE invalid_appointment_time;
    END IF;
    
    -- 4. Check for appointment conflicts
    DECLARE
        v_conflict_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_conflict_count
        FROM APPOINTMENTS
        WHERE donor_id = p_donor_id
        AND appointment_date = p_appointment_date
        AND status NOT IN ('Cancelled', 'No-Show')
        AND ABS(EXTRACT(HOUR FROM appointment_time) - 
                EXTRACT(HOUR FROM p_appointment_time)) < 2; -- 2-hour buffer
        
        IF v_conflict_count > 0 THEN
            RAISE blood_bank_exceptions_pkg.appointment_conflict;
        END IF;
    END;
    
    -- MAIN TRANSACTION
    v_appointment_id := 'APP' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4);
    
    INSERT INTO APPOINTMENTS (
        appointment_id, donor_id, facility_id, appointment_date,
        appointment_time, appointment_type, status, scheduled_by, created_at
    ) VALUES (
        v_appointment_id, p_donor_id, p_facility_id, p_appointment_date,
        p_appointment_time, p_appointment_type, 'Scheduled', p_scheduled_by, SYSTIMESTAMP
    );
    
    -- Update donor's last scheduled date
    UPDATE DONORS 
    SET updated_at = SYSTIMESTAMP
    WHERE donor_id = p_donor_id;
    
    -- Commit transaction
    COMMIT;
    
    -- Set success outputs
    p_out_appointment_id := v_appointment_id;
    p_out_status := 'SUCCESS';
    p_out_message := 'Appointment ' || v_appointment_id || ' scheduled successfully.';
    
    -- Log success (optional)
    INSERT INTO AUDIT_LOG (
        audit_id, table_name, operation_type, record_id,
        attempt_status, user_name
    ) VALUES (
        'AUD' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4),
        'APPOINTMENTS', 'INSERT', v_appointment_id,
        'ALLOWED', USER
    );
    COMMIT;
    
EXCEPTION
    -- PREDEFINED EXCEPTIONS
    WHEN NO_DATA_FOUND THEN
        p_out_message := 'Required data not found.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            SQLCODE,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN TOO_MANY_ROWS THEN
        p_out_message := 'Multiple records found for single lookup.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            SQLCODE,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN DUP_VAL_ON_INDEX THEN
        p_out_message := 'Duplicate appointment ID generated. Retrying...';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            SQLCODE,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        -- RECOVERY MECHANISM: Retry with new ID
        p_out_appointment_id := 'APP' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 5);
        
    WHEN VALUE_ERROR THEN
        p_out_message := 'Invalid parameter value detected.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            SQLCODE,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    -- CUSTOM EXCEPTIONS
    WHEN blood_bank_exceptions_pkg.donor_not_found THEN
        p_out_message := 'Donor ID ' || p_donor_id || ' not found.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            -20001,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN blood_bank_exceptions_pkg.facility_closed THEN
        p_out_message := 'Facility ' || p_facility_id || ' is not active.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            -20005,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN blood_bank_exceptions_pkg.donor_deferred THEN
        p_out_message := 'Donor ' || p_donor_id || ' is currently deferred.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            -20006,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN blood_bank_exceptions_pkg.appointment_conflict THEN
        p_out_message := 'Donor has conflicting appointment on ' || 
                        TO_CHAR(p_appointment_date, 'DD-MON-YYYY');
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            -20004,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN donor_too_young THEN
        p_out_message := 'Donor must be at least 18 years old.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            -20009,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN donor_too_old THEN
        p_out_message := 'Donor exceeds maximum age limit of 65 years.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            -20010,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    WHEN invalid_appointment_time THEN
        p_out_message := 'Appointments only available 9 AM - 5 PM.';
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            -20011,
            p_out_message,
            v_parameters
        );
        ROLLBACK;
        
    -- APPLICATION ERRORS (RAISE_APPLICATION_ERROR)
    WHEN OTHERS THEN
        p_out_message := 'Unexpected error: ' || SQLERRM;
        blood_bank_exceptions_pkg.log_error(
            'schedule_donation_appointment_complete',
            SQLCODE,
            p_out_message || ' | Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK,
            v_parameters
        );
        ROLLBACK;
        
END schedule_donation_appointment_complete;
/
    

-- 2. Procedure to update blood unit status
CREATE OR REPLACE PROCEDURE update_blood_unit_status (
    p_unit_id    IN VARCHAR2,
    p_new_status IN VARCHAR2,
    p_performed_by IN VARCHAR2
) AS
    v_old_status VARCHAR2(20);
    v_old_location VARCHAR2(100);
BEGIN
    SELECT status, storage_location INTO v_old_status, v_old_location
    FROM BLOOD_UNITS WHERE unit_id = p_unit_id FOR UPDATE;
    
    UPDATE BLOOD_UNITS 
    SET status = p_new_status, updated_at = SYSTIMESTAMP
    WHERE unit_id = p_unit_id;
    
    INSERT INTO BLOOD_UNIT_HISTORY (
        history_id, unit_id, event_type, old_status, new_status,
        old_location, event_date, event_time, performed_by
    ) VALUES (
        'HIS' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4),
        p_unit_id, 'Moved', v_old_status, p_new_status,
        v_old_location, SYSDATE, SYSTIMESTAMP, p_performed_by
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Unit ' || p_unit_id || ' status updated to ' || p_new_status);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Unit ID ' || p_unit_id || ' not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating unit status: ' || SQLERRM);
END;
/

-- 3. Procedure to process a blood request
CREATE OR REPLACE PROCEDURE process_blood_request (
    p_request_id   IN VARCHAR2,
    p_fulfilling_facility_id IN VARCHAR2,
    p_approved_by  IN VARCHAR2
) AS
    v_blood_type VARCHAR2(3);
    v_rh_factor VARCHAR2(3);
    v_component_type VARCHAR2(50);
    v_quantity NUMBER;
    v_available_units NUMBER;
BEGIN
    SELECT blood_type, rh_factor, component_type, quantity_requested 
    INTO v_blood_type, v_rh_factor, v_component_type, v_quantity
    FROM REQUESTS 
    WHERE request_id = p_request_id AND status = 'Pending';
    
    SELECT COUNT(*) INTO v_available_units
    FROM BLOOD_UNITS 
    WHERE facility_id = p_fulfilling_facility_id 
    AND blood_type = v_blood_type 
    AND rh_factor = v_rh_factor 
    AND component_type = v_component_type
    AND status = 'Available'
    AND expiration_date > SYSDATE;
    
    IF v_available_units >= v_quantity THEN
        UPDATE REQUESTS 
        SET status = 'Approved', 
            fulfilling_facility_id = p_fulfilling_facility_id,
            approved_by = p_approved_by,
            updated_at = SYSTIMESTAMP
        WHERE request_id = p_request_id;
        
        DBMS_OUTPUT.PUT_LINE('Request ' || p_request_id || ' approved.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Insufficient units available. Only ' || v_available_units || ' units in stock.');
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Request not found or not pending.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error processing request: ' || SQLERRM);
END;
/
