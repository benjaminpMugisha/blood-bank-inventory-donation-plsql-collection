SET SERVEROUTPUT ON;

DECLARE
    v_blood_type blood_requests.blood_type%TYPE := 'O-';
    v_required_quantity NUMBER := 3;
    v_available_stock NUMBER;
    v_emergency_level VARCHAR2(20);
    v_alert_message VARCHAR2(500);
    
    v_critical_shortages NUMBER := 0;
    v_high_shortages NUMBER := 0;
    v_medium_shortages NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== GOTO STATEMENTS DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Emergency Blood Shortage Management System');
    DBMS_OUTPUT.PUT_LINE('Using GOTO for conditional emergency branching');
    DBMS_OUTPUT.PUT_LINE('=============================================');
    
    
    SELECT COUNT(*) 
    INTO v_available_stock
    FROM blood_units 
    WHERE blood_type = v_blood_type 
    AND status = 'Available'
    AND expiry_date > SYSDATE;
    
    DBMS_OUTPUT.PUT_LINE('Blood Type: ' || v_blood_type);
    DBMS_OUTPUT.PUT_LINE('Required Quantity: ' || v_required_quantity);
    DBMS_OUTPUT.PUT_LINE('Available Stock: ' || v_available_stock);
    DBMS_OUTPUT.PUT_LINE('Shortage: ' || GREATEST(0, v_required_quantity - v_available_stock));
    DBMS_OUTPUT.PUT_LINE('');
    
 
    IF v_available_stock = 0 AND v_required_quantity > 0 THEN
        v_emergency_level := 'Critical';
        v_alert_message := 'CRITICAL: Zero stock available for ' || v_blood_type || ' - Immediate action required!';
        v_critical_shortages := v_critical_shortages + 1;
        GOTO critical_shortage_protocol;
    END IF;
    
    IF v_required_quantity > v_available_stock * 2 THEN
        v_emergency_level := 'Critical';
        v_alert_message := 'CRITICAL: Severe shortage for ' || v_blood_type || 
                          ' - Required: ' || v_required_quantity || ', Available: ' || v_available_stock;
        v_critical_shortages := v_critical_shortages + 1;
        GOTO critical_shortage_protocol;
    END IF;
    

    GOTO check_high_shortage;
    
 
    <<critical_shortage_protocol>>
    DBMS_OUTPUT.PUT_LINE('🚨 ' || v_alert_message);
    DBMS_OUTPUT.PUT_LINE('IMMEDIATE ACTIONS REQUIRED:');
    DBMS_OUTPUT.PUT_LINE('1. Activate emergency donor recall system');
    DBMS_OUTPUT.PUT_LINE('2. Contact regional blood bank network');
    DBMS_OUTPUT.PUT_LINE('3. Notify hospital emergency departments');
    DBMS_OUTPUT.PUT_LINE('4. Escalate to national blood service');
    GOTO log_emergency_alert;
    
 
    <<check_high_shortage>>
    IF v_required_quantity > v_available_stock THEN
        v_emergency_level := 'High';
        v_alert_message := 'HIGH: Shortage for ' || v_blood_type || 
                          ' - Required: ' || v_required_quantity || ', Available: ' || v_available_stock;
        v_high_shortages := v_high_shortages + 1;
        GOTO high_shortage_protocol;
    END IF;
    
    IF v_available_stock <= 2 THEN  -- Low stock warning
        v_emergency_level := 'High';
        v_alert_message := 'HIGH: Low stock warning for ' || v_blood_type || ' - Only ' || v_available_stock || ' units remaining';
        v_high_shortages := v_high_shortages + 1;
        GOTO high_shortage_protocol;
    END IF;
    
    -- If no high shortage, check medium priority
    GOTO check_medium_shortage;
    
    -- ===== HIGH SHORTAGE PROTOCOL =====
    <<high_shortage_protocol>>
    DBMS_OUTPUT.PUT_LINE('⚠️ ' || v_alert_message);
    DBMS_OUTPUT.PUT_LINE('REQUIRED ACTIONS:');
    DBMS_OUTPUT.PUT_LINE('1. Contact eligible donors of ' || v_blood_type || ' blood type');
    DBMS_OUTPUT.PUT_LINE('2. Check incoming inventory shipments');
    DBMS_OUTPUT.PUT_LINE('3. Monitor stock levels hourly');
    GOTO log_emergency_alert;
    
  
    <<check_medium_shortage>>
    IF v_available_stock <= 5 THEN
        v_emergency_level := 'Medium';
        v_alert_message := 'MEDIUM: Stock level alert for ' || v_blood_type || ' - ' || v_available_stock || ' units available';
        v_medium_shortages := v_medium_shortages + 1;
        GOTO medium_shortage_protocol;
    END IF;
    
  
    GOTO stock_sufficient;
    
 
    <<medium_shortage_protocol>>
    DBMS_OUTPUT.PUT_LINE('🔶 ' || v_alert_message);
    DBMS_OUTPUT.PUT_LINE('RECOMMENDED ACTIONS:');
    DBMS_OUTPUT.PUT_LINE('1. Schedule additional donation appointments');
    DBMS_OUTPUT.PUT_LINE('2. Review inventory usage patterns');
    DBMS_OUTPUT.PUT_LINE('3. Prepare donor outreach campaign');
    GOTO log_emergency_alert;
    
    <<stock_sufficient>>
    DBMS_OUTPUT.PUT_LINE('✅ Stock levels sufficient for ' || v_blood_type);
    DBMS_OUTPUT.PUT_LINE('Available: ' || v_available_stock || ' units, Required: ' || v_required_quantity || ' units');
    DBMS_OUTPUT.PUT_LINE('Continue normal operations');
    GOTO completion;
    
    <<log_emergency_alert>>
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Logging emergency alert in system...');
    DBMS_OUTPUT.PUT_LINE('Alert Type: ' || v_emergency_level);
    DBMS_OUTPUT.PUT_LINE('Blood Type: ' || v_blood_type);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_alert_message);
    DBMS_OUTPUT.PUT_LINE('Timestamp: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    
  
    INSERT INTO emergency_alerts (alert_id, alert_type, blood_type, severity, description)
    VALUES (alert_seq.NEXTVAL, 'SHORTAGE_ALERT', v_blood_type, v_emergency_level, v_alert_message);
    
    COMMIT;
    
    <<completion>>
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== EMERGENCY ASSESSMENT SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('Critical Shortages: ' || v_critical_shortages);
    DBMS_OUTPUT.PUT_LINE('High Shortages: ' || v_high_shortages);
    DBMS_OUTPUT.PUT_LINE('Medium Shortages: ' || v_medium_shortages);
    DBMS_OUTPUT.PUT_LINE('================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in emergency assessment: ' || SQLERRM);
        ROLLBACK;
END;
/
