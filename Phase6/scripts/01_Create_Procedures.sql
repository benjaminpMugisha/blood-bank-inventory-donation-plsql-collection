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
