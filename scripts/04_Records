SET SERVEROUTPUT ON;


DECLARE
    r_donor donors%ROWTYPE;
    r_blood_unit blood_units%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TABLE-BASED RECORDS DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Donor and Blood Unit Information');
    DBMS_OUTPUT.PUT_LINE('=================================');
    
    -- Get donor record
    SELECT * INTO r_donor
    FROM donors 
    WHERE donor_id = 1002;
    
    DBMS_OUTPUT.PUT_LINE('Donor: ' || r_donor.first_name || ' ' || r_donor.last_name);
    DBMS_OUTPUT.PUT_LINE('Blood Type: ' || r_donor.blood_type);
    DBMS_OUTPUT.PUT_LINE('Status: ' || r_donor.status);
    
    -- Get blood unit record
    SELECT * INTO r_blood_unit
    FROM blood_units 
    WHERE donor_id = 1002 
    AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Blood Unit: ' || r_blood_unit.unit_id || ' - Expires: ' || 
                        TO_CHAR(r_blood_unit.expiry_date, 'DD-MON-YYYY'));
END;
/


DECLARE
    TYPE donor_medical_profile IS RECORD (
        donor_id donors.donor_id%TYPE,
        full_name VARCHAR2(100),
        blood_type donors.blood_type%TYPE,
        age NUMBER,
        last_donation_status VARCHAR2(50),
        eligibility_status VARCHAR2(20),
        next_eligible_date DATE
    );
    
    r_donor_profile donor_medical_profile;
    
    TYPE inventory_summary IS RECORD (
        blood_type blood_units.blood_type%TYPE,
        total_units NUMBER,
        available_units NUMBER,
        expiring_soon NUMBER,
        utilization_rate NUMBER
    );
    
    r_inventory inventory_summary;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== USER-DEFINED RECORDS DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Donor Medical Profiles and Inventory Summary');
    DBMS_OUTPUT.PUT_LINE('============================================');
    
    -- Populate donor medical profile record
    SELECT d.donor_id,
           d.first_name || ' ' || d.last_name,
           d.blood_type,
           FLOOR(MONTHS_BETWEEN(SYSDATE, d.date_of_birth)/12),
           CASE 
               WHEN d.last_donation_date IS NULL THEN 'First-time donor'
               WHEN SYSDATE - d.last_donation_date < 90 THEN 'Recent donor - ineligible'
               ELSE 'Eligible for donation'
           END,
           CASE 
               WHEN d.status != 'Active' THEN 'Not Active'
               WHEN SYSDATE - NVL(d.last_donation_date, SYSDATE-100) < 90 THEN 'Wait Period'
               ELSE 'Eligible'
           END,
           NVL(d.last_donation_date + 90, SYSDATE)
    INTO r_donor_profile
    FROM donors d
    WHERE d.donor_id = 1002;
    
   
    DBMS_OUTPUT.PUT_LINE('DONOR MEDICAL PROFILE:');
    DBMS_OUTPUT.PUT_LINE('Name: ' || r_donor_profile.full_name);
    DBMS_OUTPUT.PUT_LINE('Age: ' || r_donor_profile.age || ' years');
    DBMS_OUTPUT.PUT_LINE('Blood Type: ' || r_donor_profile.blood_type);
    DBMS_OUTPUT.PUT_LINE('Last Donation Status: ' || r_donor_profile.last_donation_status);
    DBMS_OUTPUT.PUT_LINE('Eligibility: ' || r_donor_profile.eligibility_status);
    DBMS_OUTPUT.PUT_LINE('Next Eligible Date: ' || TO_CHAR(r_donor_profile.next_eligible_date, 'DD-MON-YYYY'));
    
    -- Populate inventory summary record for O- blood type
    SELECT 'O-',
           COUNT(*),
           SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END),
           SUM(CASE WHEN expiry_date - SYSDATE <= 7 THEN 1 ELSE 0 END),
           ROUND((SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2)
    INTO r_inventory
    FROM blood_units 
    WHERE blood_type = 'O-';
    
    -- Display inventory summary
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'INVENTORY SUMMARY for ' || r_inventory.blood_type || ':');
    DBMS_OUTPUT.PUT_LINE('Total Units: ' || r_inventory.total_units);
    DBMS_OUTPUT.PUT_LINE('Available Units: ' || r_inventory.available_units);
    DBMS_OUTPUT.PUT_LINE('Expiring Soon: ' || r_inventory.expiring_soon);
    DBMS_OUTPUT.PUT_LINE('Utilization Rate: ' || r_inventory.utilization_rate || '%');
END;
/


DECLARE
    CURSOR c_critical_requests IS
        SELECT r.request_id, r.hospital_name, r.blood_type, r.quantity, r.urgency,
               (SELECT COUNT(*) FROM blood_units bu 
                WHERE bu.blood_type = r.blood_type AND bu.status = 'Available') as available_stock
        FROM blood_requests r
        WHERE r.urgency = 'Critical' AND r.status = 'Pending';
    
    r_request c_critical_requests%ROWTYPE;
    
    TYPE request_analysis_table IS TABLE OF c_critical_requests%ROWTYPE;
    v_critical_requests request_analysis_table;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== CURSOR-BASED RECORDS DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Critical Blood Request Analysis');
    DBMS_OUTPUT.PUT_LINE('================================');
    
    OPEN c_critical_requests;
    FETCH c_critical_requests BULK COLLECT INTO v_critical_requests;
    CLOSE c_critical_requests;
    
    DBMS_OUTPUT.PUT_LINE('Critical requests found: ' || v_critical_requests.COUNT);
    
    FOR i IN 1..v_critical_requests.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Request ' || i || ': ' || v_critical_requests(i).hospital_name);
        DBMS_OUTPUT.PUT_LINE('  Blood Type: ' || v_critical_requests(i).blood_type);
        DBMS_OUTPUT.PUT_LINE('  Required: ' || v_critical_requests(i).quantity || ' units');
        DBMS_OUTPUT.PUT_LINE('  Available: ' || v_critical_requests(i).available_stock || ' units');
        DBMS_OUTPUT.PUT_LINE('  Shortage: ' || GREATEST(0, v_critical_requests(i).quantity - v_critical_requests(i).available_stock) || ' units');
    END LOOP;
END;
/
