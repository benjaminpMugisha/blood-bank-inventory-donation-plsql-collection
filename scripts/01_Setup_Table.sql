
CREATE TABLE donors (
    donor_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    blood_type VARCHAR2(3) NOT NULL CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    phone VARCHAR2(15),
    email VARCHAR2(100),
    date_of_birth DATE NOT NULL,
    last_donation_date DATE,
    status VARCHAR2(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Suspended', 'Inactive'))
);

CREATE TABLE blood_units (
    unit_id NUMBER PRIMARY KEY,
    donor_id NUMBER REFERENCES donors(donor_id),
    blood_type VARCHAR2(3) NOT NULL,
    collection_date DATE DEFAULT SYSDATE,
    expiry_date DATE NOT NULL,
    volume_ml NUMBER DEFAULT 450,
    test_status VARCHAR2(20) DEFAULT 'Pending' CHECK (test_status IN ('Pending', 'Passed', 'Failed')),
    current_location VARCHAR2(50),
    status VARCHAR2(20) DEFAULT 'Available' CHECK (status IN ('Available', 'Reserved', 'Transfused', 'Expired', 'Discarded'))
);

CREATE TABLE blood_requests (
    request_id NUMBER PRIMARY KEY,
    hospital_name VARCHAR2(100) NOT NULL,
    blood_type VARCHAR2(3) NOT NULL,
    quantity NUMBER NOT NULL,
    urgency VARCHAR2(20) DEFAULT 'Normal' CHECK (urgency IN ('Normal', 'High', 'Critical')),
    request_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Fulfilled', 'Partial', 'Cancelled'))
);

CREATE TABLE emergency_alerts (
    alert_id NUMBER PRIMARY KEY,
    alert_type VARCHAR2(50) NOT NULL,
    blood_type VARCHAR2(3),
    severity VARCHAR2(20) CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    description VARCHAR2(500),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_date TIMESTAMP
);

-- Sequences
CREATE SEQUENCE donor_seq START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE unit_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE request_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE alert_seq START WITH 1 INCREMENT BY 1;
