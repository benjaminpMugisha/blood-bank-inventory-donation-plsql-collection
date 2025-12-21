-- ============================================================
-- BLOOD BANK MANAGEMENT SYSTEM - TABLE CREATION (DDL)
-- ============================================================
-- Phase V: Table Implementation
-- Oracle Database Compatible
-- ============================================================

-- Drop existing tables (in reverse dependency order)
BEGIN
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
        'TRANSFER_ITEMS','REQUEST_ITEMS','BLOOD_UNIT_HISTORY','TEST_RESULTS',
        'DONATION_ADVERSE_EVENTS','EQUIPMENT','FACILITY_STAFF','TRANSFERS',
        'REQUESTS','INVENTORY','BLOOD_UNITS','DONOR_DEFERRALS','APPOINTMENTS',
        'ELIGIBILITY_CHECKS','DONATIONS','FACILITIES','DONORS'
    )) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- ============================================================
-- 1. FACILITIES TABLE (Independent Entity)
-- ============================================================
CREATE TABLE FACILITIES (
    facility_id VARCHAR2(20) PRIMARY KEY,
    facility_name VARCHAR2(200) NOT NULL,
    facility_type VARCHAR2(50) NOT NULL 
        CHECK (facility_type IN ('Blood Bank', 'Hospital', 'Collection Center', 'Mobile Unit')),
    license_number VARCHAR2(50) UNIQUE NOT NULL,
    address VARCHAR2(300) NOT NULL,
    city VARCHAR2(100) NOT NULL,
    district VARCHAR2(100) NOT NULL,
    latitude NUMBER(10,7),
    longitude NUMBER(10,7),
    phone_number VARCHAR2(20) NOT NULL,
    email VARCHAR2(100),
    storage_capacity_units NUMBER(6) DEFAULT 0 CHECK (storage_capacity_units >= 0),
    operating_hours VARCHAR2(100) DEFAULT '24/7',
    accreditation_status VARCHAR2(50) DEFAULT 'Pending' 
        CHECK (accreditation_status IN ('Accredited', 'Pending', 'Expired', 'Revoked')),
    accreditation_expiry DATE,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for FACILITIES
CREATE INDEX idx_facilities_city ON FACILITIES(city);
CREATE INDEX idx_facilities_type ON FACILITIES(facility_type);
CREATE INDEX idx_facilities_status ON FACILITIES(is_active);

-- ============================================================
-- 2. DONORS TABLE (Independent Entity)
-- ============================================================
CREATE TABLE DONORS (
    donor_id VARCHAR2(20) PRIMARY KEY,
    national_id VARCHAR2(20) UNIQUE NOT NULL,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    blood_type VARCHAR2(3) NOT NULL 
        CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
    rh_factor VARCHAR2(3) NOT NULL 
        CHECK (rh_factor IN ('+', '-')),
    weight_kg NUMBER(5,2) CHECK (weight_kg >= 45 AND weight_kg <= 200),
    phone_number VARCHAR2(20) UNIQUE NOT NULL,
    email VARCHAR2(100) UNIQUE,
    address VARCHAR2(300),
    city VARCHAR2(100),
    district VARCHAR2(100),
    emergency_contact_name VARCHAR2(200),
    emergency_contact_phone VARCHAR2(20),
    total_donations NUMBER(4) DEFAULT 0 CHECK (total_donations >= 0),
    last_donation_date DATE,
    status VARCHAR2(20) DEFAULT 'Active' 
        CHECK (status IN ('Active', 'Deferred', 'Inactive', 'Blacklisted')),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_donor_age CHECK (MONTHS_BETWEEN(SYSDATE, date_of_birth)/12 >= 18)
);

-- Indexes for DONORS
CREATE INDEX idx_donors_blood_type ON DONORS(blood_type, rh_factor);
CREATE INDEX idx_donors_status ON DONORS(status);
CREATE INDEX idx_donors_city ON DONORS(city);

-- ============================================================
-- 3. DONATIONS TABLE (Dependent on DONORS and FACILITIES)
-- ============================================================
CREATE TABLE DONATIONS (
    donation_id VARCHAR2(20) PRIMARY KEY,
    donor_id VARCHAR2(20) NOT NULL,
    facility_id VARCHAR2(20) NOT NULL,
    donation_date DATE NOT NULL,
    donation_time TIMESTAMP NOT NULL,
    donation_type VARCHAR2(50) DEFAULT 'Whole Blood' 
        CHECK (donation_type IN ('Whole Blood', 'Plasma', 'Platelets', 'Double Red Cells')),
    donation_number NUMBER(4) DEFAULT 1 CHECK (donation_number > 0),
    hemoglobin_level NUMBER(4,2) CHECK (hemoglobin_level BETWEEN 5 AND 20),
    systolic_bp NUMBER(3) CHECK (systolic_bp BETWEEN 80 AND 200),
    diastolic_bp NUMBER(3) CHECK (diastolic_bp BETWEEN 50 AND 130),
    pulse_rate NUMBER(3) CHECK (pulse_rate BETWEEN 40 AND 150),
    temperature NUMBER(4,2) CHECK (temperature BETWEEN 35 AND 40),
    volume_collected_ml NUMBER(5,2) DEFAULT 450 CHECK (volume_collected_ml > 0),
    collection_bag_number VARCHAR2(50) UNIQUE NOT NULL,
    phlebotomist_id VARCHAR2(20),
    status VARCHAR2(20) DEFAULT 'Completed' 
        CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled', 'Adverse Event')),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_donations_donor FOREIGN KEY (donor_id) REFERENCES DONORS(donor_id),
    CONSTRAINT fk_donations_facility FOREIGN KEY (facility_id) REFERENCES FACILITIES(facility_id)
);

-- Indexes for DONATIONS
CREATE INDEX idx_donations_donor ON DONATIONS(donor_id);
CREATE INDEX idx_donations_facility ON DONATIONS(facility_id);
CREATE INDEX idx_donations_date ON DONATIONS(donation_date);
CREATE INDEX idx_donations_type ON DONATIONS(donation_type);

-- ============================================================
-- 4. ELIGIBILITY_CHECKS TABLE
-- ============================================================
CREATE TABLE ELIGIBILITY_CHECKS (
    check_id VARCHAR2(20) PRIMARY KEY,
    donor_id VARCHAR2(20) NOT NULL,
    facility_id VARCHAR2(20) NOT NULL,
    check_date DATE NOT NULL,
    check_time TIMESTAMP NOT NULL,
    is_eligible CHAR(1) DEFAULT 'N' CHECK (is_eligible IN ('Y', 'N')),
    deferral_reason VARCHAR2(200),
    deferral_until DATE,
    weight_kg NUMBER(5,2) CHECK (weight_kg >= 30 AND weight_kg <= 200),
    hemoglobin_level NUMBER(4,2) CHECK (hemoglobin_level BETWEEN 5 AND 20),
    systolic_bp NUMBER(3) CHECK (systolic_bp BETWEEN 80 AND 200),
    diastolic_bp NUMBER(3) CHECK (diastolic_bp BETWEEN 50 AND 130),
    pulse_rate NUMBER(3) CHECK (pulse_rate BETWEEN 40 AND 150),
    temperature NUMBER(4,2) CHECK (temperature BETWEEN 35 AND 40),
    recent_travel CHAR(1) DEFAULT 'N' CHECK (recent_travel IN ('Y', 'N')),
    on_medication CHAR(1) DEFAULT 'N' CHECK (on_medication IN ('Y', 'N')),
    recent_vaccination CHAR(1) DEFAULT 'N' CHECK (recent_vaccination IN ('Y', 'N')),
    recent_surgery CHAR(1) DEFAULT 'N' CHECK (recent_surgery IN ('Y', 'N')),
    medical_history_notes CLOB,
    screened_by VARCHAR2(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_eligibility_donor FOREIGN KEY (donor_id) REFERENCES DONORS(donor_id),
    CONSTRAINT fk_eligibility_facility FOREIGN KEY (facility_id) REFERENCES FACILITIES(facility_id)
);

-- Indexes for ELIGIBILITY_CHECKS
CREATE INDEX idx_eligibility_donor ON ELIGIBILITY_CHECKS(donor_id);
CREATE INDEX idx_eligibility_date ON ELIGIBILITY_CHECKS(check_date);
CREATE INDEX idx_eligibility_result ON ELIGIBILITY_CHECKS(is_eligible);

-- ============================================================
-- 5. APPOINTMENTS TABLE
-- ============================================================
CREATE TABLE APPOINTMENTS (
    appointment_id VARCHAR2(20) PRIMARY KEY,
    donor_id VARCHAR2(20) NOT NULL,
    facility_id VARCHAR2(20) NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIMESTAMP NOT NULL,
    appointment_type VARCHAR2(50) DEFAULT 'Blood Donation' 
        CHECK (appointment_type IN ('Blood Donation', 'Eligibility Check', 'Follow-up', 'Consultation')),
    status VARCHAR2(20) DEFAULT 'Scheduled' 
        CHECK (status IN ('Scheduled', 'Confirmed', 'Completed', 'Cancelled', 'No-Show')),
    scheduled_date DATE DEFAULT SYSDATE,
    scheduled_by VARCHAR2(100),
    cancelled_date DATE,
    cancelled_by VARCHAR2(100),
    cancellation_reason CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointments_donor FOREIGN KEY (donor_id) REFERENCES DONORS(donor_id),
    CONSTRAINT fk_appointments_facility FOREIGN KEY (facility_id) REFERENCES FACILITIES(facility_id),
    CONSTRAINT chk_appointment_future CHECK (appointment_date >= TRUNC(scheduled_date))
);

-- Indexes for APPOINTMENTS
CREATE INDEX idx_appointments_donor ON APPOINTMENTS(donor_id);
CREATE INDEX idx_appointments_facility ON APPOINTMENTS(facility_id);
CREATE INDEX idx_appointments_date ON APPOINTMENTS(appointment_date);
CREATE INDEX idx_appointments_status ON APPOINTMENTS(status);

-- ============================================================
-- 6. DONOR_DEFERRALS TABLE
-- ============================================================
CREATE TABLE DONOR_DEFERRALS (
    deferral_id VARCHAR2(20) PRIMARY KEY,
    donor_id VARCHAR2(20) NOT NULL,
    deferral_type VARCHAR2(50) NOT NULL 
        CHECK (deferral_type IN ('Medical', 'Behavioral', 'Travel', 'Medication', 'Other')),
    reason VARCHAR2(500) NOT NULL,
    deferred_date DATE NOT NULL,
    deferred_until DATE,
    deferred_by VARCHAR2(100),
    is_permanent CHAR(1) DEFAULT 'N' CHECK (is_permanent IN ('Y', 'N')),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_deferrals_donor FOREIGN KEY (donor_id) REFERENCES DONORS(donor_id),
    CONSTRAINT chk_deferral_dates CHECK (deferred_until IS NULL OR deferred_until > deferred_date)
);

-- Indexes for DONOR_DEFERRALS
CREATE INDEX idx_deferrals_donor ON DONOR_DEFERRALS(donor_id);
CREATE INDEX idx_deferrals_type ON DONOR_DEFERRALS(deferral_type);
CREATE INDEX idx_deferrals_until ON DONOR_DEFERRALS(deferred_until);

-- ============================================================
-- 7. BLOOD_UNITS TABLE
-- ============================================================
CREATE TABLE BLOOD_UNITS (
    unit_id VARCHAR2(20) PRIMARY KEY,
    donation_id VARCHAR2(20) NOT NULL,
    facility_id VARCHAR2(20) NOT NULL,
    blood_type VARCHAR2(3) NOT NULL CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
    rh_factor VARCHAR2(3) NOT NULL CHECK (rh_factor IN ('+', '-')),
    component_type VARCHAR2(50) NOT NULL 
        CHECK (component_type IN ('Whole Blood', 'Red Blood Cells', 'Plasma', 'Platelets', 'Cryoprecipitate')),
    volume_ml NUMBER(6,2) CHECK (volume_ml > 0),
    unit_number VARCHAR2(50) UNIQUE NOT NULL,
    collection_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    status VARCHAR2(20) DEFAULT 'Available' 
        CHECK (status IN ('Available', 'Reserved', 'Allocated', 'Transfused', 'Expired', 'Discarded', 'Quarantined')),
    is_quarantined CHAR(1) DEFAULT 'N' CHECK (is_quarantined IN ('Y', 'N')),
    storage_temperature NUMBER(5,2) CHECK (storage_temperature BETWEEN -80 AND 25),
    storage_location VARCHAR2(100),
    test_completion_date DATE,
    allocated_request_id VARCHAR2(20),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_blood_units_donation FOREIGN KEY (donation_id) REFERENCES DONATIONS(donation_id),
    CONSTRAINT fk_blood_units_facility FOREIGN KEY (facility_id) REFERENCES FACILITIES(facility_id),
    CONSTRAINT chk_expiration CHECK (expiration_date > collection_date)
);

-- Indexes for BLOOD_UNITS
CREATE INDEX idx_blood_units_donation ON BLOOD_UNITS(donation_id);
CREATE INDEX idx_blood_units_facility ON BLOOD_UNITS(facility_id);
CREATE INDEX idx_blood_units_type ON BLOOD_UNITS(blood_type, rh_factor, component_type);
CREATE INDEX idx_blood_units_status ON BLOOD_UNITS(status);
CREATE INDEX idx_blood_units_expiration ON BLOOD_UNITS(expiration_date);

-- ============================================================
-- 8. DONATION_ADVERSE_EVENTS TABLE
-- ============================================================
CREATE TABLE DONATION_ADVERSE_EVENTS (
    event_id VARCHAR2(20) PRIMARY KEY,
    donation_id VARCHAR2(20) NOT NULL,
    event_type VARCHAR2(100) NOT NULL 
        CHECK (event_type IN ('Fainting', 'Dizziness', 'Nausea', 'Hematoma', 'Nerve Injury', 'Allergic Reaction', 'Other')),
    severity VARCHAR2(20) DEFAULT 'Minor' 
        CHECK (severity IN ('Minor', 'Moderate', 'Severe', 'Critical')),
    description CLOB NOT NULL,
    treatment_given VARCHAR2(500),
    reported_by VARCHAR2(100),
    event_date DATE NOT NULL,
    event_time TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_adverse_events_donation FOREIGN KEY (donation_id) REFERENCES DONATIONS(donation_id)
);

-- Indexes for DONATION_ADVERSE_EVENTS
CREATE INDEX idx_adverse_events_donation ON DONATION_ADVERSE_EVENTS(donation_id);
CREATE INDEX idx_adverse_events_type ON DONATION_ADVERSE_EVENTS(event_type);
CREATE INDEX idx_adverse_events_severity ON DONATION_ADVERSE_EVENTS(severity);

-- ============================================================
-- 9. TEST_RESULTS TABLE
-- ============================================================
CREATE TABLE TEST_RESULTS (
    test_id VARCHAR2(20) PRIMARY KEY,
    unit_id VARCHAR2(20) NOT NULL,
    test_type VARCHAR2(100) NOT NULL 
        CHECK (test_type IN ('HIV', 'Hepatitis B', 'Hepatitis C', 'Syphilis', 'Malaria', 'Blood Typing', 'Antibody Screening', 'Other')),
    test_result VARCHAR2(50) NOT NULL 
        CHECK (test_result IN ('Negative', 'Positive', 'Reactive', 'Non-Reactive', 'Inconclusive', 'Pending')),
    test_date DATE NOT NULL,
    tested_by VARCHAR2(100),
    equipment_id VARCHAR2(20),
    laboratory_id VARCHAR2(50),
    is_confirmed CHAR(1) DEFAULT 'N' CHECK (is_confirmed IN ('Y', 'N')),
    remarks CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_test_results_unit FOREIGN KEY (unit_id) REFERENCES BLOOD_UNITS(unit_id)
);

-- Indexes for TEST_RESULTS
CREATE INDEX idx_test_results_unit ON TEST_RESULTS(unit_id);
CREATE INDEX idx_test_results_type ON TEST_RESULTS(test_type);
CREATE INDEX idx_test_results_result ON TEST_RESULTS(test_result);

-- ============================================================
-- 10. BLOOD_UNIT_HISTORY TABLE
-- ============================================================
CREATE TABLE BLOOD_UNIT_HISTORY (
    history_id VARCHAR2(20) PRIMARY KEY,
    unit_id VARCHAR2(20) NOT NULL,
    event_type VARCHAR2(50) NOT NULL 
        CHECK (event_type IN ('Created', 'Tested', 'Moved', 'Reserved', 'Allocated', 'Transfused', 'Expired', 'Discarded')),
    old_status VARCHAR2(20),
    new_status VARCHAR2(20),
    old_location VARCHAR2(100),
    new_location VARCHAR2(100),
    event_date DATE NOT NULL,
    event_time TIMESTAMP NOT NULL,
    performed_by VARCHAR2(100),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_unit FOREIGN KEY (unit_id) REFERENCES BLOOD_UNITS(unit_id)
);

-- Indexes for BLOOD_UNIT_HISTORY
CREATE INDEX idx_history_unit ON BLOOD_UNIT_HISTORY(unit_id);
CREATE INDEX idx_history_event ON BLOOD_UNIT_HISTORY(event_type);
CREATE INDEX idx_history_date ON BLOOD_UNIT_HISTORY(event_date);

-- ============================================================
-- 11. INVENTORY TABLE
-- ============================================================
CREATE TABLE INVENTORY (
    inventory_id VARCHAR2(20) PRIMARY KEY,
    facility_id VARCHAR2(20) NOT NULL,
    blood_type VARCHAR2(3) NOT NULL CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
    rh_factor VARCHAR2(3) NOT NULL CHECK (rh_factor IN ('+', '-')),
    component_type VARCHAR2(50) NOT NULL 
        CHECK (component_type IN ('Whole Blood', 'Red Blood Cells', 'Plasma', 'Platelets', 'Cryoprecipitate')),
    quantity_available NUMBER(6) DEFAULT 0 CHECK (quantity_available >= 0),
    quantity_reserved NUMBER(6) DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_expired NUMBER(6) DEFAULT 0 CHECK (quantity_expired >= 0),
    last_updated DATE DEFAULT SYSDATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_facility FOREIGN KEY (facility_id) REFERENCES FACILITIES(facility_id),
    CONSTRAINT uk_inventory_unique UNIQUE (facility_id, blood_type, rh_factor, component_type)
);

-- Indexes for INVENTORY
CREATE INDEX idx_inventory_facility ON INVENTORY(facility_id);
CREATE INDEX idx_inventory_blood_type ON INVENTORY(blood_type, rh_factor, component_type);

-- ============================================================
-- 12. REQUESTS TABLE
-- ============================================================
CREATE TABLE REQUESTS (
    request_id VARCHAR2(20) PRIMARY KEY,
    requesting_facility_id VARCHAR2(20) NOT NULL,
    fulfilling_facility_id VARCHAR2(20),
    request_date DATE NOT NULL,
    request_time TIMESTAMP NOT NULL,
    blood_type VARCHAR2(3) NOT NULL CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
    rh_factor VARCHAR2(3) NOT NULL CHECK (rh_factor IN ('+', '-')),
    component_type VARCHAR2(50) NOT NULL,
    quantity_requested NUMBER(5) CHECK (quantity_requested > 0),
    quantity_fulfilled NUMBER(5) DEFAULT 0 CHECK (quantity_fulfilled >= 0),
    urgency_level VARCHAR2(20) DEFAULT 'Routine' 
        CHECK (urgency_level IN ('Emergency', 'Urgent', 'Routine', 'Scheduled')),
    patient_id VARCHAR2(50),
    patient_name VARCHAR2(200),
    patient_age NUMBER(3) CHECK (patient_age > 0 AND patient_age <= 150),
    patient_weight NUMBER(5,2),
    medical_condition VARCHAR2(500),
    status VARCHAR2(20) DEFAULT 'Pending' 
        CHECK (status IN ('Pending', 'Approved', 'Partially Fulfilled', 'Fulfilled', 'Cancelled', 'Rejected')),
    required_by_date DATE,
    required_by_time TIMESTAMP,
    fulfilled_date DATE,
    approved_by VARCHAR2(100),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_requests_requesting FOREIGN KEY (requesting_facility_id) REFERENCES FACILITIES(facility_id),
    CONSTRAINT fk_requests_fulfilling FOREIGN KEY (fulfilling_facility_id) REFERENCES FACILITIES(facility_id),
    CONSTRAINT chk_quantity_fulfilled CHECK (quantity_fulfilled <= quantity_requested)
);

-- Indexes for REQUESTS
CREATE INDEX idx_requests_requesting ON REQUESTS(requesting_facility_id);
CREATE INDEX idx_requests_fulfilling ON REQUESTS(fulfilling_facility_id);
CREATE INDEX idx_requests_date ON REQUESTS(request_date);
CREATE INDEX idx_requests_status ON REQUESTS(status);
CREATE INDEX idx_requests_urgency ON REQUESTS(urgency_level);

-- ============================================================
-- 13. REQUEST_ITEMS TABLE
-- ============================================================
CREATE TABLE REQUEST_ITEMS (
    request_item_id VARCHAR2(20) PRIMARY KEY,
    request_id VARCHAR2(20) NOT NULL,
    unit_id VARCHAR2(20),
    blood_type VARCHAR2(3) CHECK (blood_type IN ('A', 'B', 'AB', 'O')),
    component_type VARCHAR2(50),
    quantity NUMBER(3) DEFAULT 1 CHECK (quantity > 0),
    status VARCHAR2(20) DEFAULT 'Pending' 
        CHECK (status IN ('Pending', 'Allocated', 'Fulfilled', 'Cancelled')),
    allocated_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_request_items_request FOREIGN KEY (request_id) REFERENCES REQUESTS(request_id),
    CONSTRAINT fk_request_items_unit FOREIGN KEY (unit_id) REFERENCES BLOOD_UNITS(unit_id)
);

-- Indexes for REQUEST_ITEMS
CREATE INDEX idx_request_items_request ON REQUEST_ITEMS(request_id);
CREATE INDEX idx_request_items_unit ON REQUEST_ITEMS(unit_id);

-- ============================================================
-- 14. TRANSFERS TABLE
-- ============================================================
CREATE TABLE TRANSFERS (
    transfer_id VARCHAR2(20) PRIMARY KEY,
    source_facility_id VARCHAR2(20) NOT NULL,
    destination_facility_id VARCHAR2(20) NOT NULL,
    request_id VARCHAR2(20),
    transfer_date DATE NOT NULL,
    transfer_time TIMESTAMP NOT NULL,
    courier_name VARCHAR2(200),
    vehicle_number VARCHAR2(50),
    transport_method VARCHAR2(50) DEFAULT 'Ground' 
        CHECK (transport_method IN ('Ground', 'Air', 'Courier', 'Emergency')),
    estimated_duration_hours NUMBER(5,2) CHECK (estimated_duration_hours > 0),
    expected_arrival_date DATE,
    expected_arrival_time TIMESTAMP,
    actual_arrival_date DATE,
    actual_arrival_time TIMESTAMP,
    status VARCHAR2(20) DEFAULT 'Scheduled' 
        CHECK (status IN ('Scheduled', 'In Transit', 'Delivered', 'Cancelled', 'Delayed')),
    temperature_maintained CHAR(1) DEFAULT 'Y' CHECK (temperature_maintained IN ('Y', 'N')),
    avg_temperature NUMBER(5,2),
    sent_by VARCHAR2(100),
    received_by VARCHAR2(100),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transfers_source FOREIGN KEY (source_facility_id) REFERENCES FACILITIES(facility_id),
    CONSTRAINT fk_transfers_destination FOREIGN KEY (destination_facility_id) REFERENCES FACILITIES(facility_id),
    CONSTRAINT fk_transfers_request FOREIGN KEY (request_id) REFERENCES REQUESTS(request_id),
    CONSTRAINT chk_different_facilities CHECK (source_facility_id != destination_facility_id)
);

-- Indexes for TRANSFERS
CREATE INDEX idx_transfers_source ON TRANSFERS(source_facility_id);
CREATE INDEX idx_transfers_destination ON TRANSFERS(destination_facility_id);
CREATE INDEX idx_transfers_date ON TRANSFERS(transfer_date);
CREATE INDEX idx_transfers_status ON TRANSFERS(status);

-- ============================================================
-- 15. TRANSFER_ITEMS TABLE
-- ============================================================
CREATE TABLE TRANSFER_ITEMS (
    transfer_item_id VARCHAR2(20) PRIMARY KEY,
    transfer_id VARCHAR2(20) NOT NULL,
    unit_id VARCHAR2(20) NOT NULL,
    blood_type VARCHAR2(3),
    component_type VARCHAR2(50),
    condition_on_departure VARCHAR2(50) DEFAULT 'Good' 
        CHECK (condition_on_departure IN ('Good', 'Fair', 'Compromised', 'Damaged')),
    condition_on_arrival VARCHAR2(50) 
        CHECK (condition_on_arrival IN ('Good', 'Fair', 'Compromised', 'Damaged')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transfer_items_transfer FOREIGN KEY (transfer_id) REFERENCES TRANSFERS(transfer_id),
    CONSTRAINT fk_transfer_items_unit FOREIGN KEY (unit_id) REFERENCES BLOOD_UNITS(unit_id)
);

-- Indexes for TRANSFER_ITEMS
CREATE INDEX idx_transfer_items_transfer ON TRANSFER_ITEMS(transfer_id);
CREATE INDEX idx_transfer_items_unit ON TRANSFER_ITEMS(unit_id);

-- ============================================================
-- 16. FACILITY_STAFF TABLE
-- ============================================================
CREATE TABLE FACILITY_STAFF (
    staff_id VARCHAR2(20) PRIMARY KEY,
    facility_id VARCHAR2(20) NOT NULL,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    role VARCHAR2(100) NOT NULL 
        CHECK (role IN ('Phlebotomist', 'Lab Technician', 'Nurse', 'Doctor', 'Administrator', 'Coordinator', 'Manager')),
    qualification VARCHAR2(200),
    license_number VARCHAR2(50) UNIQUE,
    license_expiry DATE,
    phone_number VARCHAR2(20),
    email VARCHAR2(100),
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_staff_facility FOREIGN KEY (facility_id) REFERENCES FACILITIES(facility_id)
);

-- Indexes for FACILITY_STAFF
CREATE INDEX idx_staff_facility ON FACILITY_STAFF(facility_id);
CREATE INDEX idx_staff_role ON FACILITY_STAFF(role);

-- ============================================================
-- 17. EQUIPMENT TABLE
-- ============================================================
CREATE TABLE EQUIPMENT (
    equipment_id VARCHAR2(20) PRIMARY KEY,
    facility_id VARCHAR2(20) NOT NULL,
    equipment_name VARCHAR2(200) NOT NULL,
    equipment_type VARCHAR2(100) NOT NULL 
        CHECK (equipment_type IN ('Refrigerator', 'Freezer', 'Centrifuge', 'Analyzer', 'Sterilizer', 'Blood Warmer', 'Other')),
    serial_number VARCHAR2(100) UNIQUE NOT NULL,
    purchase_date DATE,
    last_calibration_date DATE,
    next_calibration_date DATE,
    status VARCHAR2(20) DEFAULT 'Operational' 
        CHECK (status IN ('Operational', 'Under Maintenance', 'Out of Service', 'Retired')),
    manufacturer VARCHAR2(200),
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_equipment_facility FOREIGN KEY (facility_id) REFERENCES FACILITIES(facility_id)
);

-- Indexes for EQUIPMENT
CREATE INDEX idx_equipment_facility ON EQUIPMENT(facility_id);
CREATE INDEX idx_equipment_type ON EQUIPMENT(equipment_type);
CREATE INDEX idx_equipment_status ON EQUIPMENT(status);

-- ============================================================
-- COMMIT ALL CHANGES
-- ============================================================
COMMIT;

-- Display table count
SELECT 'Tables created successfully!' AS status FROM dual;
SELECT table_name FROM user_tables 
WHERE table_name IN (
    'FACILITIES','DONORS','DONATIONS','ELIGIBILITY_CHECKS','APPOINTMENTS',
    'DONOR_DEFERRALS','BLOOD_UNITS','DONATION_ADVERSE_EVENTS','TEST_RESULTS',
    'BLOOD_UNIT_HISTORY','INVENTORY','REQUESTS','REQUEST_ITEMS','TRANSFERS',
    'TRANSFER_ITEMS','FACILITY_STAFF','EQUIPMENT'
)
ORDER BY table_name;
