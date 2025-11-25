SET SERVEROUTPUT ON;

-- DEMONSTRATION 1: ASSOCIATIVE ARRAYS for Donor Quick Lookup
DECLARE
    TYPE donor_phone_map IS TABLE OF donors%ROWTYPE INDEX BY VARCHAR2(15);
    v_donor_by_phone donor_phone_map;
    
    TYPE blood_inventory_map IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
    v_blood_stock blood_inventory_map;
    
    v_phone donors.phone%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ASSOCIATIVE ARRAYS DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Donor Management by Phone Number');
    DBMS_OUTPUT.PUT_LINE('=========================================');
    
    -- Load donors into associative array indexed by phone
    FOR rec IN (SELECT * FROM donors) LOOP
        v_donor_by_phone(rec.phone) := rec;
    END LOOP;
    
    -- Demonstrate quick lookup
    v_phone := '555-0102';
    IF v_donor_by_phone.EXISTS(v_phone) THEN
        DBMS_OUTPUT.PUT_LINE('Donor Found: ' || v_donor_by_phone(v_phone).first_name || ' ' || 
                           v_donor_by_phone(v_phone).last_name || ' - Blood Type: ' || 
                           v_donor_by_phone(v_phone).blood_type);
    END IF;
    
    -- Display all donors in associative array
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'All donors in phone directory:');
    v_phone := v_donor_by_phone.FIRST;
    WHILE v_phone IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE('Phone: ' || v_phone || ' - ' || 
                           v_donor_by_phone(v_phone).first_name || ' ' || 
                           v_donor_by_phone(v_phone).last_name);
        v_phone := v_donor_by_phone.NEXT(v_phone);
    END LOOP;
END;
/

-- DEMONSTRATION 2: VARRAYS for Fixed Blood Inventory Tracking
DECLARE
    TYPE blood_unit_array IS VARRAY(10) OF blood_units%ROWTYPE;
    v_recent_units blood_unit_array := blood_unit_array();
    
    v_total_volume NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== VARRAYS DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Recent Blood Units Collection (Fixed Size)');
    DBMS_OUTPUT.PUT_LINE('=========================================');
    
    -- Load recent blood units into VARRAY
    SELECT * 
    BULK COLLECT INTO v_recent_units
    FROM (
        SELECT * FROM blood_units 
        WHERE collection_date >= SYSDATE - 30 
        ORDER BY collection_date DESC
    ) WHERE ROWNUM <= 10;
    
    DBMS_OUTPUT.PUT_LINE('Recent units collected: ' || v_recent_units.COUNT);
    
    -- Process VARRAY elements
    FOR i IN 1..v_recent_units.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Unit ' || i || ': ' || v_recent_units(i).blood_type || 
                           ' - Collected: ' || TO_CHAR(v_recent_units(i).collection_date, 'DD-MON-YYYY') ||
                           ' - Expires: ' || TO_CHAR(v_recent_units(i).expiry_date, 'DD-MON-YYYY'));
        v_total_volume := v_total_volume + v_recent_units(i).volume_ml;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total blood volume in recent collection: ' || v_total_volume || ' ml');
END;
/

-- DEMONSTRATION 3: NESTED TABLES for Blood Type Analysis
DECLARE
    TYPE blood_type_table IS TABLE OF VARCHAR2(3);
    v_available_types blood_type_table := blood_type_table();
    
    TYPE stock_analysis_table IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
    v_type_count stock_analysis_table;
    
    v_rare_types NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== NESTED TABLES DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('Blood Type Distribution Analysis');
    DBMS_OUTPUT.PUT_LINE('================================');
    
    -- Get all available blood types using nested table
    SELECT DISTINCT blood_type 
    BULK COLLECT INTO v_available_types
    FROM blood_units 
    WHERE status = 'Available' 
    AND expiry_date > SYSDATE;
    
    -- Count units per blood type
    FOR i IN 1..v_available_types.COUNT LOOP
        SELECT COUNT(*) 
        INTO v_type_count(v_available_types(i))
        FROM blood_units 
        WHERE blood_type = v_available_types(i) 
        AND status = 'Available';
        
        DBMS_OUTPUT.PUT_LINE('Blood Type ' || v_available_types(i) || ': ' || 
                           v_type_count(v_available_types(i)) || ' units available');
        
        -- Identify rare blood types
        IF v_available_types(i) IN ('O-', 'AB-') THEN
            v_rare_types := v_rare_types + v_type_count(v_available_types(i));
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Total rare blood types (O-, AB-) available: ' || v_rare_types || ' units');
    
    -- Demonstrate DELETE operation on nested table
    IF v_available_types.COUNT > 0 THEN
        v_available_types.DELETE(1);  -- Remove first element
        DBMS_OUTPUT.PUT_LINE('After deletion, nested table count: ' || v_available_types.COUNT);
    END IF;
END;
/
