PHASE III: LOGICAL MODEL DESIGN
BLOOD DONATION AND DISTRIBUTION MANAGEMENT SYSTEM
________________________________________
TABLE OF CONTENTS
1.	Entity-Relationship Model
2.	Normalization Process
3.	Complete Data Dictionary
4.	Business Intelligence Considerations
5.	Assumptions and Constraints
________________________________________
1. ENTITY-RELATIONSHIP MODEL
COMPLETE ER DIAGRAM### DETAILED ENTITY DESCRIPTIONS
Core Entities:
1.	DONORS - Individuals who donate blood
2.	DONATIONS - Individual donation sessions
3.	BLOOD_UNITS - Individual units of blood/components
4.	TEST_RESULTS - Laboratory test results for blood units
5.	FACILITIES - Blood banks, hospitals, donation centers
6.	REQUESTS - Blood requests from facilities
7.	TRANSFERS - Movement of blood between facilities
Supporting Entities:
8.	REQUEST_ITEMS - Individual units in a request
9.	TRANSFER_ITEMS - Individual units in a transfer
10.	ELIGIBILITY_CHECKS - Pre-donation screening
11.	APPOINTMENTS - Scheduled donation appointments
12.	INVENTORY - Current stock levels by facility
13.	DONOR_DEFERRALS - Temporary or permanent donor deferrals
14.	BLOOD_UNIT_HISTORY - Audit trail for blood units
15.	DONATION_ADVERSE_EVENTS - Donor reactions during donation
16.	FACILITY_STAFF - Personnel at facilities
17.	EQUIPMENT - Medical equipment inventory
________________________________________
CARDINALITY DEFINITIONS
Relationship	Cardinality	Explanation
DONORS → DONATIONS	1:M	One donor makes many donations over time
DONATIONS → BLOOD_UNITS	1:M	One donation produces multiple components (RBCs, Plasma, Platelets)
BLOOD_UNITS → TEST_RESULTS	1:M	Each unit undergoes multiple tests (HIV, HepB, HepC, etc.)
FACILITIES → BLOOD_UNITS	1:M	One facility stores many blood units
FACILITIES → REQUESTS	1:M	One facility makes/receives many requests
REQUESTS → REQUEST_ITEMS	1:M	One request contains multiple units
TRANSFERS → TRANSFER_ITEMS	1:M	One transfer moves multiple units
DONORS → ELIGIBILITY_CHECKS	1:M	One donor undergoes multiple eligibility checks
DONORS → APPOINTMENTS	1:M	One donor schedules multiple appointments
FACILITIES → INVENTORY	1:M	One facility has inventory for multiple blood types
________________________________________
2. NORMALIZATION PROCESS
First Normal Form (1NF) - Eliminate Repeating Groups
❌ BEFORE 1NF (Unnormalized):
DONOR_RECORD
├─ donor_id (PK)
├─ name
├─ blood_type
├─ donation_dates (REPEATING GROUP: "2024-01-15, 2024-03-20, 2024-05-10")
├─ donation_volumes (REPEATING GROUP: "450ml, 450ml, 450ml")
├─ test_results (REPEATING GROUP: "HIV-, HepB-, HIV-, HepB-")
└─ phone_numbers (REPEATING GROUP: "0788123456, 0722987654")
Problem: Multiple values in single fields violate atomicity.
✅ AFTER 1NF:
DONORS
├─ donor_id (PK)
├─ first_name
├─ last_name
├─ blood_type
├─ rh_factor
└─ phone_number (primary only)

DONATIONS (NEW TABLE)
├─ donation_id (PK)
├─ donor_id (FK)
├─ donation_date
├─ donation_time
└─ volume_collected_ml

TEST_RESULTS (NEW TABLE)
├─ test_id (PK)
├─ unit_id (FK)
├─ test_type
└─ test_result
Achievement: Each field contains atomic values; repeating groups separated into new tables.
________________________________________
Second Normal Form (2NF) - Eliminate Partial Dependencies
❌ BEFORE 2NF (Partial Dependencies Exist):
DONATION_DETAILS
├─ donation_id (PK, part 1)
├─ unit_number (PK, part 2) -- Composite Primary Key
├─ donor_name -- Depends only on donation_id (PARTIAL DEPENDENCY)
├─ donor_blood_type -- Depends only on donation_id (PARTIAL DEPENDENCY)
├─ facility_name -- Depends only on donation_id (PARTIAL DEPENDENCY)
├─ component_type -- Depends on full key
└─ volume_ml -- Depends on full key
Problem: Non-key attributes depend on only part of composite key.
✅ AFTER 2NF:
DONATIONS
├─ donation_id (PK)
├─ donor_id (FK) -- References DONORS
├─ facility_id (FK) -- References FACILITIES
├─ donation_date
└─ volume_collected_ml

BLOOD_UNITS (NEW TABLE)
├─ unit_id (PK)
├─ donation_id (FK)
├─ unit_number
├─ component_type
└─ volume_ml

DONORS
├─ donor_id (PK)
├─ first_name
├─ last_name
└─ blood_type

FACILITIES
├─ facility_id (PK)
└─ facility_name
Achievement: All non-key attributes fully depend on the entire primary key.
________________________________________
Third Normal Form (3NF) - Eliminate Transitive Dependencies
❌ BEFORE 3NF (Transitive Dependencies Exist):
BLOOD_UNITS
├─ unit_id (PK)
├─ donation_id (FK)
├─ blood_type
├─ component_type
├─ expiration_days -- Depends on component_type (TRANSITIVE)
├─ storage_temp_min -- Depends on component_type (TRANSITIVE)
├─ storage_temp_max -- Depends on component_type (TRANSITIVE)
├─ facility_id
├─ facility_name -- Depends on facility_id (TRANSITIVE)
├─ facility_city -- Depends on facility_id (TRANSITIVE)
└─ facility_capacity -- Depends on facility_id (TRANSITIVE)
Problem: Non-key attributes depend on other non-key attributes.
✅ AFTER 3NF:
BLOOD_UNITS
├─ unit_id (PK)
├─ donation_id (FK)
├─ blood_type
├─ component_type (FK) -- References COMPONENT_TYPES
├─ facility_id (FK) -- References FACILITIES
├─ collection_date
└─ status

COMPONENT_TYPES (NEW REFERENCE TABLE)
├─ component_type (PK)
├─ expiration_days
├─ storage_temp_min
├─ storage_temp_max
└─ description

FACILITIES
├─ facility_id (PK)
├─ facility_name
├─ city
├─ district
└─ storage_capacity_units
Achievement: All non-key attributes depend only on the primary key, eliminating transitive dependencies.
________________________________________
NORMALIZATION JUSTIFICATION
Normal Form	What It Achieves	Why Important for Blood Bank System
1NF	Atomic values, no repeating groups	Ensures each donation, test result, and unit is tracked separately for accurate inventory and audit trails
2NF	No partial dependencies	Prevents data redundancy when tracking multiple components from single donation; maintains data integrity
3NF	No transitive dependencies	Eliminates update anomalies; changing facility details doesn't require updating multiple blood unit records
Additional Considerations:
•	Boyce-Codd Normal Form (BCNF): System achieves BCNF as all determinants are candidate keys
•	4NF: No multi-valued dependencies exist in the design
•	Denormalization for BI: Some strategic denormalization in dimension tables (see BI section)
________________________________________
3. COMPLETE DATA DICTIONARY
TABLE 1: DONORS
Purpose: Store information about blood donors
Column Name	Data Type	Size	Constraints	Description
donor_id	VARCHAR	20	PK, NOT NULL	Unique donor identifier (format: DNR-YYYYNNNN)
national_id	VARCHAR	16	UNIQUE, NOT NULL	National ID number
first_name	VARCHAR	50	NOT NULL	Donor's first name
last_name	VARCHAR	50	NOT NULL	Donor's last name
date_of_birth	DATE	-	NOT NULL, CHECK (age >= 18 AND age <= 65)	Donor's birth date
gender	CHAR	1	NOT NULL, CHECK (gender IN ('M','F','O'))	Gender (M=Male, F=Female, O=Other)
blood_type	VARCHAR	3	NOT NULL, CHECK (blood_type IN ('A','B','AB','O'))	ABO blood type
rh_factor	VARCHAR	1	NOT NULL, CHECK (rh_factor IN ('+','-'))	Rh factor (positive/negative)
weight_kg	DECIMAL	5,2	NOT NULL, CHECK (weight_kg >= 50)	Weight in kilograms
phone_number	VARCHAR	15	UNIQUE, NOT NULL	Primary contact number
email	VARCHAR	100	UNIQUE	Email address
address	VARCHAR	200	NOT NULL	Street address
city	VARCHAR	50	NOT NULL	City name
district	VARCHAR	50	NOT NULL	District/Province
emergency_contact_name	VARCHAR	100	NOT NULL	Emergency contact person
emergency_contact_phone	VARCHAR	15	NOT NULL	Emergency contact number
total_donations	INTEGER	-	DEFAULT 0, CHECK (total_donations >= 0)	Lifetime donation count
last_donation_date	DATE	-	NULL	Date of most recent donation
status	VARCHAR	20	NOT NULL, DEFAULT 'Active', CHECK (status IN ('Active','Deferred','Inactive'))	Current donor status
is_active	BOOLEAN	-	NOT NULL, DEFAULT TRUE	Active flag
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: donor_id
•	UNIQUE: national_id, phone_number, email
•	INDEX: blood_type, rh_factor, status, last_donation_date
________________________________________
TABLE 2: DONATIONS
Purpose: Record each donation session
Column Name	Data Type	Size	Constraints	Description
donation_id	VARCHAR	20	PK, NOT NULL	Unique donation identifier (format: DON-YYYYNNNNNN)
donor_id	VARCHAR	20	FK, NOT NULL	References DONORS(donor_id)
facility_id	VARCHAR	20	FK, NOT NULL	References FACILITIES(facility_id)
donation_date	DATE	-	NOT NULL	Date of donation
donation_time	TIME	-	NOT NULL	Time of donation
donation_type	VARCHAR	20	NOT NULL, CHECK (donation_type IN ('Whole Blood','Apheresis','Platelet','Plasma'))	Type of donation
donation_number	INTEGER	-	NOT NULL, CHECK (donation_number > 0)	Sequential donation number for donor
hemoglobin_level	DECIMAL	4,1	NOT NULL, CHECK (hemoglobin_level >= 12.0 AND hemoglobin_level <= 20.0)	Hb level (g/dL)
systolic_bp	INTEGER	-	NOT NULL, CHECK (systolic_bp BETWEEN 90 AND 180)	Systolic blood pressure (mmHg)
diastolic_bp	INTEGER	-	NOT NULL, CHECK (diastolic_bp BETWEEN 60 AND 100)	Diastolic blood pressure (mmHg)
pulse_rate	INTEGER	-	NOT NULL, CHECK (pulse_rate BETWEEN 50 AND 100)	Pulse rate (beats/min)
temperature	DECIMAL	4,1	NOT NULL, CHECK (temperature BETWEEN 36.0 AND 37.5)	Body temperature (°C)
volume_collected_ml	DECIMAL	6,2	NOT NULL, CHECK (volume_collected_ml BETWEEN 400 AND 500)	Volume collected (ml)
collection_bag_number	VARCHAR	30	UNIQUE, NOT NULL	Unique collection bag identifier
phlebotomist_id	VARCHAR	20	FK, NULL	References FACILITY_STAFF(staff_id)
status	VARCHAR	20	NOT NULL, DEFAULT 'Completed', CHECK (status IN ('Completed','Incomplete','Adverse Event'))	Donation status
notes	TEXT	-	NULL	Additional notes
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: donation_id
•	FOREIGN KEY: donor_id, facility_id, phlebotomist_id
•	UNIQUE: collection_bag_number
•	INDEX: donation_date, status, donor_id
Business Rules:
•	Donation date cannot be in the future
•	Minimum 56 days between whole blood donations
•	Minimum 7 days between platelet donations
________________________________________
TABLE 3: BLOOD_UNITS
Purpose: Track individual blood units and components
Column Name	Data Type	Size	Constraints	Description
unit_id	VARCHAR	20	PK, NOT NULL	Unique unit identifier (format: UNIT-YYYYNNNNNN)
donation_id	VARCHAR	20	FK, NOT NULL	References DONATIONS(donation_id)
facility_id	VARCHAR	20	FK, NOT NULL	Current storage facility
blood_type	VARCHAR	3	NOT NULL, CHECK (blood_type IN ('A','B','AB','O'))	ABO blood type
rh_factor	VARCHAR	1	NOT NULL, CHECK (rh_factor IN ('+','-'))	Rh factor
component_type	VARCHAR	30	NOT NULL, CHECK (component_type IN ('Whole Blood','Packed RBCs','Platelets','Fresh Frozen Plasma','Cryoprecipitate'))	Blood component type
volume_ml	DECIMAL	6,2	NOT NULL, CHECK (volume_ml > 0)	Volume in milliliters
unit_number	VARCHAR	30	UNIQUE, NOT NULL	Barcode/ISBT number
collection_date	DATE	-	NOT NULL	Date of collection
expiration_date	DATE	-	NOT NULL, CHECK (expiration_date > collection_date)	Expiration date
status	VARCHAR	20	NOT NULL, DEFAULT 'Quarantine', CHECK (status IN ('Quarantine','Available','Reserved','Distributed','Expired','Discarded','Testing'))	Current status
is_quarantined	BOOLEAN	-	NOT NULL, DEFAULT TRUE	Quarantine flag
storage_temperature	DECIMAL	4,1	NULL	Current storage temp (°C)
storage_location	VARCHAR	50	NULL	Storage location code
test_completion_date	DATE	-	NULL	Date all tests completed
allocated_request_id	VARCHAR	20	FK, NULL	References REQUESTS(request_id) if reserved
notes	TEXT	-	NULL	Additional notes
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: unit_id
•	FOREIGN KEY: donation_id, facility_id, allocated_request_id
•	UNIQUE: unit_number
•	INDEX: blood_type, rh_factor, component_type, status, expiration_date, facility_id
Business Rules:
•	Cannot distribute unit with status 'Quarantine' or 'Testing'
•	Must have negative test results before status changes to 'Available'
•	Expiration date based on component type: 
o	Whole Blood: 35-42 days
o	Packed RBCs: 42 days
o	Platelets: 5-7 days
o	Fresh Frozen Plasma: 1 year (frozen)
o	Cryoprecipitate: 1 year (frozen)
________________________________________
TABLE 4: TEST_RESULTS
Purpose: Store laboratory test results for blood units
Column Name	Data Type	Size	Constraints	Description
test_id	VARCHAR	20	PK, NOT NULL	Unique test identifier (format: TST-YYYYNNNNNN)
unit_id	VARCHAR	20	FK, NOT NULL	References BLOOD_UNITS(unit_id)
test_type	VARCHAR	50	NOT NULL, CHECK (test_type IN ('HIV-1/2','HBsAg','Anti-HCV','Syphilis','Malaria','HTLV','Blood Typing','Antibody Screen'))	Type of test
test_result	VARCHAR	20	NOT NULL, CHECK (test_result IN ('Negative','Positive','Indeterminate','Reactive','Non-Reactive'))	Test result
test_date	DATE	-	NOT NULL	Date test performed
tested_by	VARCHAR	20	FK, NULL	References FACILITY_STAFF(staff_id)
equipment_id	VARCHAR	20	FK, NULL	References EQUIPMENT(equipment_id)
laboratory_id	VARCHAR	20	FK, NOT NULL	References FACILITIES(facility_id)
is_confirmed	BOOLEAN	-	NOT NULL, DEFAULT FALSE	Confirmation test flag
remarks	TEXT	-	NULL	Test notes and observations
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
Indexes:
•	PRIMARY KEY: test_id
•	FOREIGN KEY: unit_id, tested_by, equipment_id, laboratory_id
•	INDEX: unit_id, test_type, test_result, test_date
Business Rules:
•	All mandatory tests must be completed before unit can be distributed
•	Positive/Reactive results require confirmation testing
•	Test results are immutable (cannot be updated, only new test records created)
________________________________________
TABLE 5: FACILITIES
Purpose: Store information about blood banks, hospitals, and labs
Column Name	Data Type	Size	Constraints	Description
facility_id	VARCHAR	20	PK, NOT NULL	Unique facility identifier (format: FAC-NNNN)
facility_name	VARCHAR	100	NOT NULL	Facility name
facility_type	VARCHAR	30	NOT NULL, CHECK (facility_type IN ('Blood Bank','Hospital','Donation Center','Laboratory','Mobile Unit'))	Type of facility
license_number	VARCHAR	50	UNIQUE, NOT NULL	Regulatory license number
address	VARCHAR	200	NOT NULL	Street address
city	VARCHAR	50	NOT NULL	City name
district	VARCHAR	50	NOT NULL	District/Province
latitude	DECIMAL	10,8	NULL	GPS latitude
longitude	DECIMAL	11,8	NULL	GPS longitude
phone_number	VARCHAR	15	NOT NULL	Contact phone
email	VARCHAR	100	NULL	Contact email
storage_capacity_units	INTEGER	-	NOT NULL, CHECK (storage_capacity_units > 0)	Maximum storage capacity
operating_hours	VARCHAR	100	NULL	Operating hours description
accreditation_status	VARCHAR	30	NOT NULL, CHECK (accreditation_status IN ('Accredited','Pending','Expired','Suspended'))	Accreditation status
accreditation_expiry	DATE	-	NULL	Accreditation expiry date
is_active	BOOLEAN	-	NOT NULL, DEFAULT TRUE	Active facility flag
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: facility_id
•	UNIQUE: license_number
•	INDEX: facility_type, city, district, is_active
________________________________________
TABLE 6: REQUESTS
Purpose: Track blood requests from facilities
Column Name	Data Type	Size	Constraints	Description
request_id	VARCHAR	20	PK, NOT NULL	Unique request identifier (format: REQ-YYYYNNNNNN)
requesting_facility_id	VARCHAR	20	FK, NOT NULL	Facility making request
fulfilling_facility_id	VARCHAR	20	FK, NULL	Facility fulfilling request
request_date	DATE	-	NOT NULL	Date of request
request_time	TIME	-	NOT NULL	Time of request
blood_type	VARCHAR	3	NOT NULL, CHECK (blood_type IN ('A','B','AB','O'))	Required blood type
rh_factor	VARCHAR	1	NOT NULL, CHECK (rh_factor IN ('+','-'))	Required Rh factor
component_type	VARCHAR	30	NOT NULL	Required component
quantity_requested	INTEGER	-	NOT NULL, CHECK (quantity_requested > 0)	Number of units requested
quantity_fulfilled	INTEGER	-	DEFAULT 0, CHECK (quantity_fulfilled >= 0)	Number of units fulfilled
urgency_level	VARCHAR	20	NOT NULL, CHECK (urgency_level IN ('Emergency','Urgent','Routine'))	Request urgency
patient_id	VARCHAR	30	NULL	Patient identifier (anonymized)
patient_name	VARCHAR	100	NULL	Patient name (encrypted)
patient_age	INTEGER	-	NULL, CHECK (patient_age > 0 AND patient_age <= 120)	Patient age
patient_weight	DECIMAL	5,2	NULL, CHECK (patient_weight > 0)	Patient weight (kg)
medical_condition	VARCHAR	200	NULL	Medical indication
status	VARCHAR	20	NOT NULL, DEFAULT 'Pending', CHECK (status IN ('Pending','Approved','Fulfilled','Partially Fulfilled','Cancelled','Rejected'))	Request status
required_by_date	DATE	-	NOT NULL	Required by date
required_by_time	TIME	-	NOT NULL	Required by time
fulfilled_date	DATE	-	NULL	Actual fulfillment date
approved_by	VARCHAR	20	FK, NULL	References FACILITY_STAFF(staff_id)
notes	TEXT	-	NULL	Additional notes
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: request_id
•	FOREIGN KEY: requesting_facility_id, fulfilling_facility_id, approved_by
•	INDEX: blood_type, rh_factor, urgency_level, status, request_date
Business Rules:
•	Emergency requests must be fulfilled within 1 hour
•	Urgent requests within 4 hours
•	Routine requests within 24 hours
•	quantity_fulfilled cannot exceed quantity_requested
________________________________________
TABLE 7: REQUEST_ITEMS
Purpose: Link specific blood units to requests
Column Name	Data Type	Size	Constraints	Description
request_item_id	VARCHAR	20	PK, NOT NULL	Unique identifier
request_id	VARCHAR	20	FK, NOT NULL	References REQUESTS(request_id)
unit_id	VARCHAR	20	FK, NOT NULL	References BLOOD_UNITS(unit_id)
blood_type	VARCHAR	3	NOT NULL	Blood type
component_type	VARCHAR	30	NOT NULL	Component type
quantity	INTEGER	-	NOT NULL, DEFAULT 1	Quantity (usually 1)
status	VARCHAR	20	NOT NULL, CHECK (status IN ('Allocated','Issued','Cancelled'))	Item status
allocated_date	DATE	-	NOT NULL	Date allocated
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
Indexes:
•	PRIMARY KEY: request_item_id
•	FOREIGN KEY: request_id, unit_id
•	UNIQUE: (request_id, unit_id)
•	INDEX: request_id, unit_id, status
________________________________________
TABLE 8: TRANSFERS
Purpose: Record movement of blood units between facilities
Column Name	Data Type	Size	Constraints	Description
transfer_id	VARCHAR	20	PK, NOT NULL	Unique transfer identifier (format: TRF-YYYYNNNNNN)
source_facility_id	VARCHAR	20	FK, NOT NULL	Originating facility
destination_facility_id	VARCHAR	20	FK, NOT NULL	Receiving facility
request_id	VARCHAR	20	FK, NULL	Associated request if any
transfer_date	DATE	-	NOT NULL	Date of transfer
transfer_time	TIME	-	NOT NULL	Time of transfer
courier_name	VARCHAR	100	NULL	Courier/driver name
vehicle_number	VARCHAR	20	NULL	Vehicle registration
transport_method	VARCHAR	30	NOT NULL, CHECK (transport_method IN ('Ambulance','Refrigerated Van','Motorcycle','Courier Service','Air Transport'))	Transport method
estimated_duration_hours	DECIMAL	4,2	NOT NULL, CHECK (estimated_duration_hours > 0)	Estimated travel time
expected_arrival_date	DATE	-	NOT NULL	Expected arrival date
expected_arrival_time	TIME	-	NOT NULL	Expected arrival time
actual_arrival_date	DATE	-	NULL	Actual arrival date
actual_arrival_time	TIME	-	NULL	Actual arrival time
status	VARCHAR	20	NOT NULL, DEFAULT 'Scheduled', CHECK (status IN ('Scheduled','In Transit','Delivered','Cancelled','Delayed'))	Transfer status
temperature_maintained	BOOLEAN	-	NULL	Cold chain maintained flag
avg_temperature	DECIMAL	4,1	NULL	Average temperature (°C)
sent_by	VARCHAR	20	FK, NULL	References FACILITY_STAFF(staff_id)
received_by	VARCHAR	20	FK, NULL	References FACILITY_STAFF(staff_id)
notes	TEXT	-	NULL	Additional notes
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: transfer_id
•	FOREIGN KEY: source_facility_id, destination_facility_id, request_id, sent_by, received_by
•	INDEX: transfer_date, status, source_facility_id, destination_facility_id
Business Rules:
•	source_facility_id cannot equal destination_facility_id
•	Temperature must be maintained between 2-10°C during transport
•	Transfer must complete within 24 hours
________________________________________
TABLE 9: TRANSFER_ITEMS
Purpose: List individual units in each transfer
Column Name	Data Type	Size	Constraints	Description
transfer_item_id	VARCHAR	20	PK, NOT NULL	Unique identifier
transfer_id	VARCHAR	20	FK, NOT NULL	References TRANSFERS(transfer_id)
unit_id	VARCHAR	20	FK, NOT NULL	References BLOOD_UNITS(unit_id)
blood_type	VARCHAR	3	NOT NULL	Blood type
component_type	VARCHAR	30	NOT NULL	Component type
condition_on_departure	VARCHAR	50	NOT NULL, CHECK (condition_on_departure IN ('Good','Acceptable','Damaged'))	Condition when sent
condition_on_arrival	VARCHAR	50	NULL, CHECK (condition_on_arrival IN ('Good','Acceptable','Damaged'))	Condition when received
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
Indexes:
•	PRIMARY KEY: transfer_item_id
•	FOREIGN KEY: transfer_id, unit_id
•	UNIQUE: (transfer_id, unit_id)
•	INDEX: transfer_id, unit_id
________________________________________
TABLE 10: ELIGIBILITY_CHECKS
Purpose: Record pre-donation eligibility screenings
Column Name	Data Type	Size	Constraints	Description
check_id	VARCHAR	20	PK, NOT NULL	Unique check identifier
donor_id	VARCHAR	20	FK, NOT NULL	References DONORS(donor_id)
facility_id	VARCHAR	20	FK, NOT NULL	References FACILITIES(facility_id)
check_date	DATE	-	NOT NULL	Date of screening
check_time	TIME	-	NOT NULL	Time of screening
is_eligible	BOOLEAN	-	NOT NULL	Eligibility result
deferral_reason	VARCHAR	200	NULL	Reason if deferred
deferral_until	DATE	-	NULL	Deferral end date
weight_kg	DECIMAL	5,2	NOT NULL, CHECK (weight_kg > 0)	Weight at screening
hemoglobin_level	DECIMAL	4,1	NOT NULL	Hemoglobin level
systolic_bp	INTEGER	-	NOT NULL	Systolic BP
diastolic_bp	INTEGER	-	NOT NULL	Diastolic BP
pulse_rate	INTEGER	-	NOT NULL	Pulse rate
temperature	DECIMAL	4,1	NOT NULL	Temperature
recent_travel	BOOLEAN	-	NOT NULL	Travel to endemic areas
on_medication	BOOLEAN	-	NOT NULL	Currently on medication
recent_vaccination	BOOLEAN	-	NOT NULL	Recent vaccination
recent_surgery	BOOLEAN	-	NOT NULL	Recent surgery
medical_history_notes	TEXT	-	NULL	Medical history notes
screened_by	VARCHAR	20	FK, NULL	References FACILITY_STAFF(staff_id)
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
Indexes:
•	PRIMARY KEY: check_id
•	FOREIGN KEY: donor_id, facility_id, screened_by
•	INDEX: donor_id, check_date, is_eligible
________________________________________
TABLE 11: APPOINTMENTS
Purpose: Manage scheduled donation appointments
Column Name	Data Type	Size	Constraints	Description
appointment_id	VARCHAR	20	PK, NOT NULL	Unique appointment identifier
donor_id	VARCHAR	20	FK, NOT NULL	References DONORS(donor_id)
facility_id	VARCHAR	20	FK, NOT NULL	References FACILITIES(facility_id)
appointment_date	DATE	-	NOT NULL	Scheduled date
appointment_time	TIME	-	NOT NULL	Scheduled time
appointment_type	VARCHAR	30	NOT NULL, CHECK (appointment_type IN ('First Time','Regular','Apheresis','Emergency'))	Appointment type
status	VARCHAR	20	NOT NULL, DEFAULT 'Scheduled', CHECK (status IN ('Scheduled','Confirmed','Completed','Cancelled','No Show'))	Appointment status
scheduled_date	DATE	-	NOT NULL	Date appointment was made
scheduled_by	VARCHAR	20	FK, NULL	Who scheduled (staff/donor)
cancelled_date	DATE	-	NULL	Cancellation date
cancelled_ by	 VARCHAR             	20	   FK, NULL	Who cancelled
cancellation_reason | TEXT | - |   NULL |                                                       Cancellation reason | created_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Record                                                                                                                                                                                                                                                                                |                                                                                                                           creation timestamp       updated_at | TIMESTAMP | - | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Last update timestamp |
Indexes:
•	PRIMARY KEY: appointment_id
•	FOREIGN KEY: donor_id, facility_id, scheduled_by, cancelled_by
•	INDEX: donor_id, appointment_date, status
________________________________________
TABLE 12: INVENTORY
Purpose: Track current stock levels by facility and blood type
Column Name	Data Type	Size	Constraints	Description
inventory_id	VARCHAR	20	PK, NOT NULL	Unique inventory record ID
facility_id	VARCHAR	20	FK, NOT NULL	References FACILITIES(facility_id)
blood_type	VARCHAR	3	NOT NULL	Blood type
rh_factor	VARCHAR	1	NOT NULL	Rh factor
component_type	VARCHAR	30	NOT NULL	Component type
quantity_available	INTEGER	-	NOT NULL, DEFAULT 0, CHECK (quantity_available >= 0)	Available units
quantity_reserved	INTEGER	-	NOT NULL, DEFAULT 0, CHECK (quantity_reserved >= 0)	Reserved units
quantity_expired	INTEGER	-	NOT NULL, DEFAULT 0, CHECK (quantity_expired >= 0)	Expired units (last 30 days)
last_updated	DATE	-	NOT NULL	Last inventory update
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: inventory_id
•	FOREIGN KEY: facility_id
•	UNIQUE: (facility_id, blood_type, rh_factor, component_type)
•	INDEX: facility_id, blood_type, rh_factor
Business Rules:
•	Inventory updated real-time when units added/removed
•	Negative quantities not allowed
•	Daily reconciliation with actual physical count
________________________________________
TABLE 13: DONOR_DEFERRALS
Purpose: Track donor deferrals (temporary or permanent)
Column Name	Data Type	Size	Constraints	Description
deferral_id	VARCHAR	20	PK, NOT NULL	Unique deferral identifier
donor_id	VARCHAR	20	FK, NOT NULL	References DONORS(donor_id)
deferral_type	VARCHAR	30	NOT NULL, CHECK (deferral_type IN ('Medical','Behavioral','Test Result','Administrative'))	Deferral category
reason	VARCHAR	200	NOT NULL	Specific deferral reason
deferred_date	DATE	-	NOT NULL	Date of deferral
deferred_until	DATE	-	NULL	Deferral end date (NULL if permanent)
deferred_by	VARCHAR	20	FK, NOT NULL	References FACILITY_STAFF(staff_id)
is_permanent	BOOLEAN	-	NOT NULL, DEFAULT FALSE	Permanent deferral flag
notes	TEXT	-	NULL	Additional notes
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
Indexes:
•	PRIMARY KEY: deferral_id
•	FOREIGN KEY: donor_id, deferred_by
•	INDEX: donor_id, deferred_date, is_permanent
________________________________________
TABLE 14: BLOOD_UNIT_HISTORY
Purpose: Audit trail for blood unit status changes (for compliance)
Column Name	Data Type	Size	Constraints	Description
history_id	VARCHAR	20	PK, NOT NULL	Unique history record ID
unit_id	VARCHAR	20	FK, NOT NULL	References BLOOD_UNITS(unit_id)
event_type	VARCHAR	50	NOT NULL	Type of event
old_status	VARCHAR	20	NULL	Previous status
new_status	VARCHAR	20	NOT NULL	New status
old_location	VARCHAR	20	NULL	Previous facility
new_location	VARCHAR	20	NULL	New facility
event_date	DATE	-	NOT NULL	Date of event
event_time	TIME	-	NOT NULL	Time of event
performed_by	VARCHAR	20	FK, NULL	References FACILITY_STAFF(staff_id)
notes	TEXT	-	NULL	Event notes
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
Indexes:
•	PRIMARY KEY: history_id
•	FOREIGN KEY: unit_id, performed_by
•	INDEX: unit_id, event_date, event_type
Business Rules:
•	History records are immutable (INSERT only, no UPDATE/DELETE)
•	All status changes must be logged
________________________________________
TABLE 15: DONATION_ADVERSE_EVENTS
Purpose: Track adverse reactions during donation
Column Name	Data Type	Size	Constraints	Description
event_id	VARCHAR	20	PK, NOT NULL	Unique event identifier
donation_id	VARCHAR	20	FK, NOT NULL	References DONATIONS(donation_id)
event_type	VARCHAR	50	NOT NULL, CHECK (event_type IN ('Vasovagal Reaction','Hematoma','Nerve Injury','Arterial Puncture','Allergic Reaction','Other'))	Type of adverse event
severity	VARCHAR	20	NOT NULL, CHECK (severity IN ('Mild','Moderate','Severe'))	Severity level
description	TEXT	-	NOT NULL	Event description
treatment_given	VARCHAR	200	NULL	Treatment provided
reported_by	VARCHAR	20	FK, NOT NULL	References FACILITY_STAFF(staff_id)
event_date	DATE	-	NOT NULL	Date of event
event_time	TIME	-	NOT NULL	Time of event
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
Indexes:
•	PRIMARY KEY: event_id
•	FOREIGN KEY: donation_id, reported_by
•	INDEX: donation_id, event_type, severity
________________________________________
TABLE 16: FACILITY_STAFF
Purpose: Store information about facility personnel
Column Name	Data Type	Size	Constraints	Description
staff_id	VARCHAR	20	PK, NOT NULL	Unique staff identifier
facility_id	VARCHAR	20	FK, NOT NULL	References FACILITIES(facility_id)
first_name	VARCHAR	50	NOT NULL	First name
last_name	VARCHAR	50	NOT NULL	Last name
role	VARCHAR	50	NOT NULL, CHECK (role IN ('Phlebotomist','Lab Technician','Nurse','Doctor','Administrator','Manager'))	Job role
qualification	VARCHAR	100	NOT NULL	Professional qualification
license_number	VARCHAR	50	UNIQUE, NULL	Professional license number
license_expiry	DATE	-	NULL	License expiry date
phone_number	VARCHAR	15	NOT NULL	Contact phone
email	VARCHAR	100	NULL	Email address
is_active	BOOLEAN	-	NOT NULL, DEFAULT TRUE	Active staff flag
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: staff_id
•	FOREIGN KEY: facility_id
•	UNIQUE: license_number
•	INDEX: facility_id, role, is_active
________________________________________
TABLE 17: EQUIPMENT
Purpose: Track medical equipment and maintenance
Column Name	Data Type	Size	Constraints	Description
equipment_id	VARCHAR	20	PK, NOT NULL	Unique equipment identifier
facility_id	VARCHAR	20	FK, NOT NULL	References FACILITIES(facility_id)
equipment_name	VARCHAR	100	NOT NULL	Equipment name
equipment_type	VARCHAR	50	NOT NULL, CHECK (equipment_type IN ('Centrifuge','Refrigerator','Freezer','Blood Mixer','Testing Equipment','Sterilizer'))	Equipment category
serial_number	VARCHAR	50	UNIQUE, NOT NULL	Manufacturer serial number
purchase_date	DATE	-	NOT NULL	Date of purchase
last_calibration_date	DATE	-	NULL	Last calibration date
next_calibration_date	DATE	-	NULL	Next calibration due
status	VARCHAR	20	NOT NULL, CHECK (status IN ('Operational','Maintenance','Out of Service','Retired'))	Equipment status
manufacturer	VARCHAR	100	NOT NULL	Manufacturer name
notes	TEXT	-	NULL	Additional notes
created_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Record creation timestamp
updated_at	TIMESTAMP	-	NOT NULL, DEFAULT CURRENT_TIMESTAMP	Last update timestamp
Indexes:
•	PRIMARY KEY: equipment_id
•	FOREIGN KEY: facility_id
•	UNIQUE: serial_number
•	INDEX: facility_id, equipment_type, status
________________________________________
4. BUSINESS INTELLIGENCE CONSIDERATIONS
4.1 FACT vs DIMENSION TABLES
FACT TABLES (Measures - What happened?)
FACT_DONATIONS
CREATE TABLE FACT_DONATIONS (
    donation_fact_id VARCHAR(20) PRIMARY KEY,
    donation_date_key INTEGER,  -- FK to DIM_DATE
    donor_key VARCHAR(20),       -- FK to DIM_DONOR
    facility_key VARCHAR(20),    -- FK to DIM_FACILITY
    staff_key VARCHAR(20),       -- FK to DIM_STAFF
    
    -- Measures (Quantitative data)
    volume_collected_ml DECIMAL(6,2),
    hemoglobin_level DECIMAL(4,1),
    systolic_bp INTEGER,
    diastolic_bp INTEGER,
    pulse_rate INTEGER,
    temperature DECIMAL(4,1),
    donation_duration_minutes INTEGER,
    
    -- Counts
    units_produced INTEGER,
    adverse_events_count INTEGER,
    
    -- Flags (Degenerate Dimensions)
    donation_type VARCHAR(20),
    donation_status VARCHAR(20),
    is_first_time BOOLEAN,
    is_repeat BOOLEAN,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
FACT_BLOOD_UNITS
CREATE TABLE FACT_BLOOD_UNITS (
    unit_fact_id VARCHAR(20) PRIMARY KEY,
    collection_date_key INTEGER,  -- FK to DIM_DATE
    expiration_date_key INTEGER,  -- FK to DIM_DATE
    blood_type_key VARCHAR(20),   -- FK to DIM_BLOOD_TYPE
    facility_key VARCHAR(20),     -- FK to DIM_FACILITY
    donor_key VARCHAR(20),        -- FK to DIM_DONOR
    
    -- Measures
    volume_ml DECIMAL(6,2),
    days_until_expiration INTEGER,
    storage_temperature DECIMAL(4,1),
    storage_duration_days INTEGER,
    
    -- Counts
    test_count INTEGER,
    transfer_count INTEGER,
    
    -- Flags
    component_type VARCHAR(30),
    final_status VARCHAR(20),
    is_expired BOOLEAN,
    is_used BOOLEAN,
    is_wasted BOOLEAN,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
FACT_REQUESTS
CREATE TABLE FACT_REQUESTS (
    request_fact_id VARCHAR(20) PRIMARY KEY,
    request_date_key INTEGER,      -- FK to DIM_DATE
    required_date_key INTEGER,      -- FK to DIM_DATE
    fulfilled_date_key INTEGER,     -- FK to DIM_DATE
    requesting_facility_key VARCHAR(20),  -- FK to DIM_FACILITY
    fulfilling_facility_key VARCHAR(20),  -- FK to DIM_FACILITY
    blood_type_key VARCHAR(20),     -- FK to DIM_BLOOD_TYPE
    
    -- Measures
    quantity_requested INTEGER,
    quantity_fulfilled INTEGER,
    fulfillment_percentage DECIMAL(5,2),
    response_time_hours DECIMAL(6,2),
    patient_age INTEGER,
    patient_weight DECIMAL(5,2),
    
    -- Flags
    urgency_level VARCHAR(20),
    request_status VARCHAR(20),
    is_fulfilled BOOLEAN,
    is_partial BOOLEAN,
    is_emergency BOOLEAN,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
FACT_TRANSFERS
CREATE TABLE FACT_TRANSFERS (
    transfer_fact_id VARCHAR(20) PRIMARY KEY,
    transfer_date_key INTEGER,     -- FK to DIM_DATE
    arrival_date_key INTEGER,      -- FK to DIM_DATE
    source_facility_key VARCHAR(20),  -- FK to DIM_FACILITY
    dest_facility_key VARCHAR(20),    -- FK to DIM_FACILITY
    
    -- Measures
    units_transferred INTEGER,
    estimated_duration_hours DECIMAL(4,2),
    actual_duration_hours DECIMAL(4,2),
    delay_hours DECIMAL(4,2),
    avg_temperature DECIMAL(4,1),
    distance_km DECIMAL(6,2),
    
    -- Flags
    transport_method VARCHAR(30),
    transfer_status VARCHAR(20),
    temperature_maintained BOOLEAN,
    is_delayed BOOLEAN,
    is_emergency BOOLEAN,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
________________________________________
DIMENSION TABLES (Context - Who, What, Where, When?)
DIM_DATE (Time Dimension - Critical for all temporal analysis)
CREATE TABLE DIM_DATE (
    date_key INTEGER PRIMARY KEY,  -- Format: YYYYMMDD
    full_date DATE NOT NULL UNIQUE,
    day_of_week INTEGER,            -- 1=Sunday, 7=Saturday
    day_name VARCHAR(10),           -- 'Monday', 'Tuesday', etc.
    day_of_month INTEGER,
    day_of_year INTEGER,
    week_of_year INTEGER,
    month INTEGER,
    month_name VARCHAR(10),
    quarter INTEGER,
    year INTEGER,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    holiday_name VARCHAR(100),
    is_working_day BOOLEAN,
    fiscal_year INTEGER,
    fiscal_quarter INTEGER,
    season VARCHAR(10)              -- 'Spring', 'Summer', etc.
);
DIM_DONOR (Type 2 SCD - Track changes over time)
CREATE TABLE DIM_DONOR (
    donor_key VARCHAR(20) PRIMARY KEY,  -- Surrogate key
    donor_id VARCHAR(20),                -- Natural key
    national_id VARCHAR(16),
    full_name VARCHAR(100),
    date_of_birth DATE,
    age INTEGER,
    age_group VARCHAR(20),               -- '18-25', '26-35', etc.
    gender CHAR(1),
    blood_type VARCHAR(3),
    rh_factor VARCHAR(1),
    full_blood_type VARCHAR(5),          -- e.g., 'A+'
    weight_kg DECIMAL(5,2),
    weight_category VARCHAR(20),         -- 'Normal', 'Overweight', etc.
    city VARCHAR(50),
    district VARCHAR(50),
    donor_segment VARCHAR(30),           -- 'New', 'Regular', 'VIP', 'Lapsed'
    total_donations INTEGER,
    first_donation_date DATE,
    last_donation_date DATE,
    donor_status VARCHAR(20),
    
    -- SCD Type 2 fields
    effective_date DATE,
    expiration_date DATE,
    is_current BOOLEAN,
    version INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DIM_FACILITY (Type 2 SCD)
CREATE TABLE DIM_FACILITY (
    facility_key VARCHAR(20) PRIMARY KEY,  -- Surrogate key
    facility_id VARCHAR(20),                -- Natural key
    facility_name VARCHAR(100),
    facility_type VARCHAR(30),
    city VARCHAR(50),
    district VARCHAR(50),
    region VARCHAR(50),                     -- Derived from district
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    storage_capacity_units INTEGER,
    capacity_category VARCHAR(20),          -- 'Small', 'Medium', 'Large'
    accreditation_status VARCHAR(30),
    is_rural BOOLEAN,
    is_urban BOOLEAN,
    
    -- SCD Type 2 fields
    effective_date DATE,
    expiration_date DATE,
    is_current BOOLEAN,
    version INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DIM_BLOOD_TYPE
CREATE TABLE DIM_BLOOD_TYPE (
    blood_type_key VARCHAR(20) PRIMARY KEY,
    blood_type VARCHAR(3),
    rh_factor VARCHAR(1),
    full_blood_type VARCHAR(5),        -- 'A+', 'O-', etc.
    blood_group_category VARCHAR(20),  -- 'Universal Donor', 'Universal Recipient'
    rarity_level VARCHAR(20),          -- 'Common', 'Rare', 'Very Rare'
    population_percentage DECIMAL(5,2),
    compatible_donors TEXT,            -- List of compatible types
    compatible_recipients TEXT,
    is_universal_donor BOOLEAN,
    is_universal_recipient BOOLEAN
);
DIM_STAFF (Type 2 SCD)
CREATE TABLE DIM_STAFF (
    staff_key VARCHAR(20) PRIMARY KEY,
    staff_id VARCHAR(20),
    full_name VARCHAR(100),
    role VARCHAR(50),
    role_category VARCHAR(30),         -- 'Clinical', 'Laboratory', 'Administrative'
    qualification VARCHAR(100),
    experience_years INTEGER,
    experience_category VARCHAR(20),   -- 'Junior', 'Mid-level', 'Senior'
    facility_key VARCHAR(20),          -- FK to DIM_FACILITY
    is_licensed BOOLEAN,
    
    -- SCD Type 2 fields
    effective_date DATE,
    expiration_date DATE,
    is_current BOOLEAN,
    version INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
________________________________________
4.2 SLOWLY CHANGING DIMENSIONS (SCD) STRATEGY
Type 0: Retain Original (No Changes)
•	DIM_DATE
•	DIM_BLOOD_TYPE
•	Static reference tables
Type 1: Overwrite (No History)
•	EQUIPMENT table
•	Minor corrections (typos, phone numbers)
Type 2: Add New Row (Full History) ✅ RECOMMENDED
Implementation Example for DIM_DONOR:
-- Initial insert (Version 1)
INSERT INTO DIM_DONOR (
    donor_key, donor_id, full_name, blood_type, 
    city, donor_segment, effective_date, 
    expiration_date, is_current, version
) VALUES (
    'DKEY-001-V1', 'DNR-2024-0001', 'John Doe', 'O', 
    'Kigali', 'New', '2024-01-15', 
    '9999-12-31', TRUE, 1
);

-- When donor moves to new city (Version 2)
-- Step 1: Close old record
UPDATE DIM_DONOR 
SET expiration_date = '2024-06-30',
    is_current = FALSE
WHERE donor_key = 'DKEY-001-V1';

-- Step 2: Insert new record
INSERT INTO DIM_DONOR (
    donor_key, donor_id, full_name, blood_type, 
    city, donor_segment, effective_date, 
    expiration_date, is_current, version
) VALUES (
    'DKEY-001-V2', 'DNR-2024-0001', 'John Doe', 'O', 
    'Musanze', 'Regular', '2024-07-01', 
    '9999-12-31', TRUE, 2
);
Benefits:
•	Complete historical analysis
•	Track donor behavior changes
•	Audit compliance
•	Trend analysis by location/segment
________________________________________
4.3 AGGREGATION LEVELS
Pre-Aggregated Summary Tables for Performance
AGG_DAILY_INVENTORY
CREATE TABLE AGG_DAILY_INVENTORY (
    agg_id VARCHAR(20) PRIMARY KEY,
    date_key INTEGER,              -- FK to DIM_DATE
    facility_key VARCHAR(20),      -- FK to DIM_FACILITY
    blood_type_key VARCHAR(20),    -- FK to DIM_BLOOD_TYPE
    component_type VARCHAR(30),
    
    -- Aggregated Measures
    opening_balance INTEGER,
    donations_received INTEGER,
    units_distributed INTEGER,
    units_transferred_out INTEGER,
    units_transferred_in INTEGER,
    units_expired INTEGER,
    units_discarded INTEGER,
    closing_balance INTEGER,
    
    -- Calculated Metrics
    days_of_supply DECIMAL(5,2),
    turnover_rate DECIMAL(5,2),
    wastage_rate DECIMAL(5,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
AGG_MONTHLY_DONOR_STATS
CREATE TABLE AGG_MONTHLY_DONOR_STATS (
    agg_id VARCHAR(20) PRIMARY KEY,
    year_month INTEGER,            -- Format: YYYYMM
    facility_key VARCHAR(20),
    
    -- Donor Counts
    total_donors INTEGER,
    new_donors INTEGER,
    repeat_donors INTEGER,
    lapsed_donors INTEGER,
    
    -- Donation Counts
    total_donations INTEGER,
    first_time_donations INTEGER,
    repeat_donations INTEGER,
    
    -- Adverse Events
    adverse_events_count INTEGER,
    adverse_event_rate DECIMAL(5,2),
    
    -- Deferrals
    deferrals_count INTEGER,
    deferral_rate DECIMAL(5,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
AGG_FACILITY_PERFORMANCE
CREATE TABLE AGG_FACILITY_PERFORMANCE (
    agg_id VARCHAR(20) PRIMARY KEY,
    year_month INTEGER,
    facility_key VARCHAR(20),
    
    -- Collection Metrics
    units_collected INTEGER,
    avg_volume_collected DECIMAL(6,2),
    collection_efficiency DECIMAL(5,2),
    
    -- Distribution Metrics
    requests_received INTEGER,
    requests_fulfilled INTEGER,
    fulfillment_rate DECIMAL(5,2),
    avg_response_time_hours DECIMAL(6,2),
    
    -- Quality Metrics
    units_wasted INTEGER,
    wastage_rate DECIMAL(5,2),
    positive_test_rate DECIMAL(5,2),
    
    -- Financial Metrics (if available)
    cost_per_unit DECIMAL(10,2),
    revenue_generated DECIMAL(12,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
Aggregation Refresh Strategy:
•	Daily: Overnight batch job (2 AM)
•	Monthly: On 1st of month
•	Real-time: Update on transaction (for critical metrics)
________________________________________
4.4 AUDIT TRAILS
Comprehensive Audit Table
AUDIT_LOG
CREATE TABLE AUDIT_LOG (
    audit_id VARCHAR(20) PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id VARCHAR(20) NOT NULL,
    operation_type VARCHAR(10) NOT NULL CHECK (operation_type IN ('INSERT','UPDATE','DELETE')),
    
    -- Who, When, Where
    user_id VARCHAR(20),           -- Who performed the action
    user_role VARCHAR(50),
    facility_id VARCHAR(20),       -- Where it happened
    ip_address VARCHAR(45),        -- IPv4 or IPv6
    session_id VARCHAR(100),
    
    -- What Changed
    old_values TEXT,               -- JSON format
    new_values TEXT,               -- JSON format
    changed_columns TEXT,          -- Comma-separated list
    
    -- Context
    reason TEXT,                   -- Why the change was made
    transaction_id VARCHAR(50),    -- Link related changes
    
    -- Timestamps
    operation_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Compliance
    is_regulatory_change BOOLEAN DEFAULT FALSE,
    requires_approval BOOLEAN DEFAULT FALSE,
    approval_status VARCHAR(20),
    approved_by VARCHAR(20),
    approval_date TIMESTAMP
);

CREATE INDEX idx_audit_table_record ON AUDIT_LOG(table_name, record_id);
CREATE INDEX idx_audit_timestamp ON AUDIT_LOG(operation_timestamp);
CREATE INDEX idx_audit_user ON AUDIT_LOG(user_id);
Database Triggers for Automatic Auditing:
-- Example trigger for BLOOD_UNITS table
CREATE OR REPLACE FUNCTION audit_blood_units()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO AUDIT_LOG (
            audit_id, table_name, record_id, operation_type,
            user_id, old_values, new_values, operation_timestamp
        ) VALUES (
            'AUD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') || '-' || NEXTVAL('audit_seq'),
            'BLOOD_UNITS',
            NEW.unit_id,
            'UPDATE',
            CURRENT_USER,
            ROW_TO_JSON(OLD),
            ROW_TO_JSON(NEW),
            CURRENT_TIMESTAMP
        );
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO AUDIT_LOG (
            audit_id, table_name, record_id, operation_type,
            user_id, old_values, operation_timestamp
        ) VALUES (
            'AUD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') || '-' || NEXTVAL('audit_seq'),
            'BLOOD_UNITS',
            OLD.unit_id,
            'DELETE',
            CURRENT_USER,
            ROW_TO_JSON(OLD),
            CURRENT_TIMESTAMP
        );
        RETURN OLD;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO AUDIT_LOG (
            audit_id, table_name, record_id, operation_type,
            user_id, new_values, operation_timestamp
        ) VALUES (
            'AUD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') || '-' || NEXTVAL('audit_seq'),
            'BLOOD_UNITS',
            NEW.unit_id,
            'INSERT',
            CURRENT_USER,
            ROW_TO_JSON(NEW),
            CURRENT_TIMESTAMP
        );
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_blood_units
AFTER INSERT OR UPDATE OR DELETE ON BLOOD_UNITS
FOR EACH ROW EXECUTE FUNCTION audit_blood_units();
Audit Retention Policy:
•	Active audit logs: 7 years (regulatory requirement)
•	Archived audit logs: Indefinite (compressed storage)
•	Audit log access: Restricted to authorized personnel only
________________________________________
5. ASSUMPTIONS AND CONSTRAINTS
5.1 BUSINESS ASSUMPTIONS
1.	Donor Eligibility:
o	Age range: 18-65 years
o	Minimum weight: 50 kg
o	Minimum hemoglobin: 12.5 g/dL (women), 13.0 g/dL (men)
o	56-day waiting period between whole blood donations
o	7-day waiting period between platelet donations
2.	Blood Unit Specifications:
o	Whole blood donation volume: 450 ml ± 10%
o	One whole blood donation produces: 1-3 components
o	Component separation within 8 hours of collection
o	All units quarantined until test results complete
3.	Testing Requirements:
o	Mandatory tests: HIV-1/2, HBsAg, Anti-HCV, Syphilis
o	Additional tests: Malaria (endemic areas), HTLV, Blood typing
o	Test results must be negative for distribution
o	Positive results require confirmation testing
4.	Inventory Management:
o	FEFO (First-Expire-First-Out) allocation
o	7-day warning for near-expiry units
o	Daily inventory reconciliation
o	Emergency stock level: 3 days supply
5.	Request Fulfillment:
o	Emergency: <1 hour response time
o	Urgent: <4 hours response time
o	Routine: <24 hours response time
o	Cross-matching required before transfusion
6.	Transfer Requirements:
o	Cold chain maintained (2-10°C)
o	Maximum transfer time: 24 hours
o	Temperature monitoring during transit
o	Sign-off required at both ends
________________________________________
5.2 TECHNICAL CONSTRAINTS
1.	Database Platform:
o	PostgreSQL 13+ (open-source, enterprise-ready)
o	UTF-8 character encoding
o	ACID compliance for all transactions
2.	Data Types:
o	VARCHAR for flexible text fields
o	DECIMAL for precise monetary/measurement values
o	DATE for dates without time
o	TIME for time without date
o	TIMESTAMP for audit trails
o	BOOLEAN for flags
o	TEXT for long-form notes
3.	Naming Conventions:
o	Tables: UPPER_CASE_SNAKE_CASE
o	Columns: lower_case_snake_case
o	Primary Keys: {table}_id or {table}_key
o	Foreign Keys: referenced_{table}_id
o	Indexes: idx_{table}_{columns}
o	Constraints: chk_{table}_{column}
4.	Key Constraints:
o	Primary Keys: NOT NULL, UNIQUE
o	Foreign Keys: Referential integrity enforced
o	Check Constraints: Value validation
o	Unique Constraints: Business key uniqueness
o	Default Values: Sensible defaults where applicable
5.	Performance Considerations:
o	Indexes on frequently queried columns
o	Partitioning for large tables (by date)
o	Materialized views for complex aggregations
o	Query optimization (EXPLAIN ANALYZE)
o	Connection pooling (max 100 connections)
________________________________________
5.3 REGULATORY CONSTRAINTS
1.	Data Retention:
o	Donor records: 10 years after last donation
o	Blood unit records: 10 years after expiration
o	Test results: Permanent (regulatory requirement)
o	Audit logs: 7 years minimum
o	Adverse event reports: Permanent
2.	Privacy & Security:
o	GDPR compliance (if applicable)
o	HIPAA compliance (patient data)
o	Data encryption at rest and in transit
o	Role-based access control (RBAC)
o	Audit trail for all data access
o	Anonymization for research data
3.	Quality Standards:
o	ISO 9001:2015 (Quality Management)
o	ISO 15189 (Medical Laboratories)
o	AABB Standards (Blood Banking)
o	WHO Guidelines (Blood Safety)
o	National regulatory requirements
4.	Traceability:
o	Complete chain of custody
o	Donor to recipient traceability
o	Equipment calibration records
o	Staff qualification verification
o	Batch/lot tracking
________________________________________
5.4 OPERATIONAL CONSTRAINTS
1.	Business Hours: 
o	Standard operations: 8 AM - 5 PM (weekdays)
o	Emergency operations: 24/7
•	Mobile units: Scheduled events 
o	Maintenance windows: 2-4 AM Sunday
2.	Geographic Limitations:
o	Service area: National coverage
o	Urban centers: 2-hour response time
o	Rural areas: 24-hour response time
o	Cross-border: Regulatory approval required
3.	Capacity Limits:
o	Blood bank storage: 500-10,000 units (varies by facility)
o	Donation center capacity: 50-200 donations/day
o	Laboratory capacity: 200-1000 tests/day
o	Transfer capacity: 50-500 units/day
4.	Resource Availability:
o	Qualified staff: Certified phlebotomists, lab techs
o	Equipment: Calibrated and maintained
o	Supplies: Collection kits, test reagents, storage bags
o	Transport: Refrigerated vehicles
________________________________________
5.5 DATA QUALITY ASSUMPTIONS
1.	Accuracy:
o	Donor information verified against national ID
o	Test results double-checked (QC protocol)
o	Inventory counts reconciled daily
o	GPS coordinates accurate within 100 meters
2.	Completeness:
o	Mandatory fields must be populated
o	NULL values only for optional fields
o	Historical data available from 2020 onwards
o	Missing data flagged for investigation
3.	Consistency:
o	Data validated at entry point
o	Referential integrity enforced
o	Cross-table validation (e.g., donor age vs. donation date)
o	Standardized codes and classifications
4.	Timeliness:
o	Real-time updates for critical operations
o	Batch updates for analytics (daily)
o	Data latency <5 minutes for operational systems
o	Historical data loads: Weekly
________________________________________
6. DELIVERABLE SUMMARY
GitHub Submission Checklist:
✅ ER Diagram (Mermaid format in markdown)
•	All 17 entities included
•	Cardinalities clearly marked
•	Primary and Foreign Keys identified
•	Relationships properly connected
✅ Data Dictionary (Complete)
•	Table 1-17: Full specifications
•	Column names, data types, sizes
•	Constraints documented
•	Business rules included
•	Indexes specified
✅ Normalization Documentation
•	1NF: Repeating groups eliminated
•	2NF: Partial dependencies removed
•	3NF: Transitive dependencies eliminated
•	Justification provided
✅ BI Considerations
•	Fact vs. Dimension tables designed
•	SCD Type 2 strategy defined
•	Aggregation levels planned
•	Audit trails implemented
✅ Assumptions Document
•	Business assumptions listed
•	Technical constraints specified
•	Regulatory requirements noted
•	Operational constraints documented
•	Data quality assumptions stated
________________________________________
7. CONCLUSION
This logical data model provides a comprehensive foundation for the Blood Donation and Distribution Management System. The design adheres to 3rd Normal Form, ensuring data integrity while supporting complex business operations and analytics.
Key Strengths:
1.	Comprehensive Coverage: All aspects of blood donation lifecycle
2.	Data Integrity: Strong constraints and referential integrity
3.	Audit Compliance: Complete audit trails for regulatory requirements
4.	BI-Ready: Star schema design for analytics and reporting
5.	Scalability: Supports future expansion and modifications
6.	Flexibility: Accommodates various facility types and processes
Next Steps:
•	Physical database implementation (DDL scripts)
•	Sample data generation for testing
•	Query optimization and indexing
•	ETL processes for BI warehouse
•	Application development and integration
END OF PHASE III: LOGICAL MODEL DESIGN
