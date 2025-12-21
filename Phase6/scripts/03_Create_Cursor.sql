-- Now test with triggers enabled
DECLARE
    CURSOR c_expired_units IS
        SELECT unit_id, facility_id, blood_type, rh_factor, component_type
        FROM BLOOD_UNITS 
        WHERE status = 'Available' AND expiration_date <= SYSDATE
        AND ROWNUM <= 3; -- Small test batch
    
    TYPE t_unit_table IS TABLE OF c_expired_units%ROWTYPE;
    v_units t_unit_table;
BEGIN
    OPEN c_expired_units;
    
    LOOP
        FETCH c_expired_units BULK COLLECT INTO v_units LIMIT 10;
        EXIT WHEN v_units.COUNT = 0;
        
        DBMS_OUTPUT.PUT_LINE('Processing ' || v_units.COUNT || ' units...');
        
        FORALL i IN 1..v_units.COUNT
            UPDATE BLOOD_UNITS 
            SET status = 'Expired', updated_at = SYSTIMESTAMP
            WHERE unit_id = v_units(i).unit_id;
        
        FORALL i IN 1..v_units.COUNT
            INSERT INTO BLOOD_UNIT_HISTORY (
                history_id, unit_id, event_type, old_status, new_status,
                event_date, event_time, performed_by
            ) VALUES (
                'HIS' || TO_CHAR(SYSDATE, 'YYMMDDHH24MISS') || DBMS_RANDOM.STRING('X', 4),
                v_units(i).unit_id, 'Expired', 'Available', 'Expired',
                SYSDATE, SYSTIMESTAMP, 'SYSTEM'
            );
        
        DBMS_OUTPUT.PUT_LINE('Marked ' || v_units.COUNT || ' units as expired.');
    END LOOP;
    
    CLOSE c_expired_units;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Test completed successfully with triggers enabled.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/
