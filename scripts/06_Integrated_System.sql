SET SERVEROUTPUT ON;


DECLARE

    TYPE donor_ids_table IS TABLE OF donors.donor_id%TYPE;
    TYPE donor_records_table IS TABLE OF donors%ROWTYPE;
    TYPE emergency_map IS TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(3);
    

    TYPE blood_analysis_rec IS RECORD (
        blood_type blood_units.blood_type%TYPE,
        total_units NUMBER,
        available_units NUMBER,
        requested_units NUMBER,
        shortage_level NUMBER,
        emergency_status VARCHAR2(20)
    );
    

    v_donor_ids donor_ids_table;
    v_donors donor_records_table;
    v_emergency_alerts emergency_map;
    v_analysis blood_analysis_rec;
    v_processing_complete BOOLEAN := FALSE;
    v_critical_blood_types NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== COMPREHENSIVE PL/SQL FEATURES DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Blood Donation System - Integrated Emergency Management');
    DBMS_OUTPUT.PUT_LINE('Collections + Records + GOTO Statements');
    DBMS_OUTPUT.PUT_LINE('=====================================================');
    
 
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PHASE 1: DATA GATHERING WITH COLLECTIONS');
    

    SELECT donor_id 
    BULK COLLECT INTO v_donor_ids
    FROM donors
    WHERE status = 'Active';
    
    DBMS_OUTPUT.PUT_LINE('Active donors in system: ' || v_donor_ids.COUNT);
    

    SELECT *
    BULK COLLECT INTO v_donors
    FROM donors
    WHERE status = 'Active';
    

    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PHASE 2: BLOOD TYPE ANALYSIS WITH RECORDS');
    

    FOR blood_rec IN (
        SELECT DISTINCT blood_type FROM blood_units
    ) LOOP
 
        IF v_processing_complete THEN
            GOTO emergency_activation;
        END IF;
        
    
        SELECT blood_rec.blood_type,
               COUNT(*),
               SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END),
               NVL((SELECT SUM(quantity) FROM blood_requests 
                   WHERE blood_type = blood_rec.blood_type AND status = 'Pending'), 0),
               GREATEST(0, NVL((SELECT SUM(quantity) FROM blood_requests 
                           WHERE blood_type = blood_rec.blood_type AND status = 'Pending'), 0) - 
                      SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END)),
               CASE 
                   WHEN SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) = 0 THEN 'Critical'
                   WHEN NVL((SELECT SUM(quantity) FROM blood_requests 
                           WHERE blood_type = blood_rec.blood_type AND status = 'Pending'), 0) > 
                        SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) THEN 'High'
                   WHEN SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) <= 2 THEN 'Medium'
                   ELSE 'NORMAL'
               END
        INTO v_analysis
        FROM blood_units
        WHERE blood_type = blood_rec.blood_type;
        

        DBMS_OUTPUT.PUT_LINE('Blood Type ' || v_analysis.blood_type || 
                           ' | Available: ' || v_analysis.available_units ||
                           ' | Requested: ' || v_analysis.requested_units ||
                           ' | Status: ' || v_analysis.emergency_status);
        
    
        IF v_analysis.emergency_status = 'Critical' THEN
            v_critical_blood_types := v_critical_blood_types + 1;
            v_emergency_alerts(v_analysis.blood_type) := 
                'CRITICAL SHORTAGE: Zero units available for ' || v_analysis.blood_type;
            
 
            IF v_critical_blood_types >= 1 THEN
                DBMS_OUTPUT.PUT_LINE(CHR(10) || '🚨 CRITICAL BLOOD SHORTAGE DETECTED!');
                v_processing_complete := TRUE;
                GOTO emergency_activation;
            END IF;
        END IF;
        
    END LOOP;
    

    <<normal_completion>>
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PHASE 3: SYSTEM ANALYSIS COMPLETED NORMALLY');
    DBMS_OUTPUT.PUT_LINE('No critical emergencies detected.');
    GOTO final_report;
    
  
    <<emergency_activation>>
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '🚨 EMERGENCY PROTOCOL ACTIVATED!');
    DBMS_OUTPUT.PUT_LINE('Critical blood shortages detected in the system.');
    DBMS_OUTPUT.PUT_LINE('Immediate actions required:');
    DBMS_OUTPUT.PUT_LINE('1. Activate mass donor notification system');
    DBMS_OUTPUT.PUT_LINE('2. Contact regional blood bank partners');
    DBMS_OUTPUT.PUT_LINE('3. Implement emergency blood rationing');
    DBMS_OUTPUT.PUT_LINE('4. Notify hospital emergency departments');
    

    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'CRITICAL ALERTS:');
    DECLARE
        v_blood_type VARCHAR2(3) := v_emergency_alerts.FIRST;
    BEGIN
        WHILE v_blood_type IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE('• ' || v_emergency_alerts(v_blood_type));
            v_blood_type := v_emergency_alerts.NEXT(v_blood_type);
        END LOOP;
    END;
    
    <<final_report>>
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PHASE 4: FINAL SYSTEM REPORT');
    DBMS_OUTPUT.PUT_LINE('====================================');
    DBMS_OUTPUT.PUT_LINE('Total Active Donors: ' || v_donor_ids.COUNT);
    DBMS_OUTPUT.PUT_LINE('Critical Blood Types: ' || v_critical_blood_types);
    DBMS_OUTPUT.PUT_LINE('Emergency Status: ' || 
                        CASE WHEN v_processing_complete THEN 'ACTIVATED' ELSE 'NORMAL' END);
    DBMS_OUTPUT.PUT_LINE('====================================');
    

    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Collection Methods Demonstration:');
    DBMS_OUTPUT.PUT_LINE('First Donor ID: ' || v_donor_ids.FIRST);
    DBMS_OUTPUT.PUT_LINE('Last Donor ID: ' || v_donor_ids.LAST);
    DBMS_OUTPUT.PUT_LINE('Donor ID exists at position 1: ' || 
                        CASE WHEN v_donor_ids.EXISTS(1) THEN 'YES' ELSE 'NO' END);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in integrated system: ' || SQLERRM);
END;
/
