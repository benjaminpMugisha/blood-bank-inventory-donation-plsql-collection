erDiagram
    DONORS ||--o{ DONATIONS : makes
    DONORS ||--o{ ELIGIBILITY_CHECKS : undergoes
    DONORS ||--o{ APPOINTMENTS : schedules
    DONORS ||--o{ DONOR_DEFERRALS : receives
    
    DONATIONS ||--|{ BLOOD_UNITS : produces
    DONATIONS ||--|| FACILITIES : "collected at"
    DONATIONS ||--o{ DONATION_ADVERSE_EVENTS : "may have"
    
    BLOOD_UNITS ||--o{ TEST_RESULTS : "tested by"
    BLOOD_UNITS ||--|| FACILITIES : "stored at"
    BLOOD_UNITS ||--o{ BLOOD_UNIT_HISTORY : tracks
    BLOOD_UNITS ||--o{ REQUEST_ITEMS : "allocated to"
    BLOOD_UNITS ||--o{ TRANSFER_ITEMS : "moved in"
    
    FACILITIES ||--o{ INVENTORY : maintains
    FACILITIES ||--o{ REQUESTS : "makes or receives"
    FACILITIES ||--o{ TRANSFERS : "sends or receives"
    FACILITIES ||--o{ FACILITY_STAFF : employs
    FACILITIES ||--o{ EQUIPMENT : owns
    
    REQUESTS ||--o{ REQUEST_ITEMS : contains
    REQUESTS ||--|| FACILITIES : "requested by"
    REQUESTS ||--o| TRANSFERS : triggers
    
    TRANSFERS ||--o{ TRANSFER_ITEMS : contains
    TRANSFERS ||--|| FACILITIES : "from source"
    TRANSFERS ||--|| FACILITIES : "to destination"
    
    DONORS {
        varchar donor_id PK
        varchar national_id UK
        varchar first_name
        varchar last_name
        date date_of_birth
        char gender
        varchar blood_type
        varchar rh_factor
        decimal weight_kg
        varchar phone_number UK
        varchar email UK
        varchar address
        varchar city
        varchar district
        varchar emergency_contact_name
        varchar emergency_contact_phone
        int total_donations
        date last_donation_date
        varchar status
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }
    
    DONATIONS {
        varchar donation_id PK
        varchar donor_id FK
        varchar facility_id FK
        date donation_date
        time donation_time
        varchar donation_type
        int donation_number
        decimal hemoglobin_level
        int systolic_bp
        int diastolic_bp
        int pulse_rate
        decimal temperature
        decimal volume_collected_ml
        varchar collection_bag_number UK
        varchar phlebotomist_id
        varchar status
        text notes
        timestamp created_at
        timestamp updated_at
    }
    
    BLOOD_UNITS {
        varchar unit_id PK
        varchar donation_id FK
        varchar facility_id FK
        varchar blood_type
        varchar rh_factor
        varchar component_type
        decimal volume_ml
        varchar unit_number UK
        date collection_date
        date expiration_date
        varchar status
        boolean is_quarantined
        decimal storage_temperature
        varchar storage_location
        date test_completion_date
        varchar allocated_request_id
        text notes
        timestamp created_at
        timestamp updated_at
    }
    
    TEST_RESULTS {
        varchar test_id PK
        varchar unit_id FK
        varchar test_type
        varchar test_result
        date test_date
        varchar tested_by
        varchar equipment_id
        varchar laboratory_id
        boolean is_confirmed
        text remarks
        timestamp created_at
    }
    
    FACILITIES {
        varchar facility_id PK
        varchar facility_name
        varchar facility_type
        varchar license_number UK
        varchar address
        varchar city
        varchar district
        decimal latitude
        decimal longitude
        varchar phone_number
        varchar email
        int storage_capacity_units
        varchar operating_hours
        varchar accreditation_status
        date accreditation_expiry
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }
    
    REQUESTS {
        varchar request_id PK
        varchar requesting_facility_id FK
        varchar fulfilling_facility_id FK
        date request_date
        time request_time
        varchar blood_type
        varchar rh_factor
        varchar component_type
        int quantity_requested
        int quantity_fulfilled
        varchar urgency_level
        varchar patient_id
        varchar patient_name
        int patient_age
        decimal patient_weight
        varchar medical_condition
        varchar status
        date required_by_date
        time required_by_time
        date fulfilled_date
        varchar approved_by
        text notes
        timestamp created_at
        timestamp updated_at
    }
    
    REQUEST_ITEMS {
        varchar request_item_id PK
        varchar request_id FK
        varchar unit_id FK
        varchar blood_type
        varchar component_type
        int quantity
        varchar status
        date allocated_date
        timestamp created_at
    }
    
    TRANSFERS {
        varchar transfer_id PK
        varchar source_facility_id FK
        varchar destination_facility_id FK
        varchar request_id FK
        date transfer_date
        time transfer_time
        varchar courier_name
        varchar vehicle_number
        varchar transport_method
        decimal estimated_duration_hours
        date expected_arrival_date
        time expected_arrival_time
        date actual_arrival_date
        time actual_arrival_time
        varchar status
        boolean temperature_maintained
        decimal avg_temperature
        varchar sent_by
        varchar received_by
        text notes
        timestamp created_at
        timestamp updated_at
    }
    
    TRANSFER_ITEMS {
        varchar transfer_item_id PK
        varchar transfer_id FK
        varchar unit_id FK
        varchar blood_type
        varchar component_type
        varchar condition_on_departure
        varchar condition_on_arrival
        timestamp created_at
    }
    
    ELIGIBILITY_CHECKS {
        varchar check_id PK
        varchar donor_id FK
        varchar facility_id FK
        date check_date
        time check_time
        boolean is_eligible
        varchar deferral_reason
        date deferral_until
        decimal weight_kg
        decimal hemoglobin_level
        int systolic_bp
        int diastolic_bp
        int pulse_rate
        decimal temperature
        boolean recent_travel
        boolean on_medication
        boolean recent_vaccination
        boolean recent_surgery
        text medical_history_notes
        varchar screened_by
        timestamp created_at
    }
    
    APPOINTMENTS {
        varchar appointment_id PK
        varchar donor_id FK
        varchar facility_id FK
        date appointment_date
        time appointment_time
        varchar appointment_type
        varchar status
        date scheduled_date
        varchar scheduled_by
        date cancelled_date
        varchar cancelled_by
        text cancellation_reason
        timestamp created_at
        timestamp updated_at
    }
    
    INVENTORY {
        varchar inventory_id PK
        varchar facility_id FK
        varchar blood_type
        varchar rh_factor
        varchar component_type
        int quantity_available
        int quantity_reserved
        int quantity_expired
        date last_updated
        timestamp created_at
        timestamp updated_at
    }
    
    DONOR_DEFERRALS {
        varchar deferral_id PK
        varchar donor_id FK
        varchar deferral_type
        varchar reason
        date deferred_date
        date deferred_until
        varchar deferred_by
        boolean is_permanent
        text notes
        timestamp created_at
    }
    
    BLOOD_UNIT_HISTORY {
        varchar history_id PK
        varchar unit_id FK
        varchar event_type
        varchar old_status
        varchar new_status
        varchar old_location
        varchar new_location
        date event_date
        time event_time
        varchar performed_by
        text notes
        timestamp created_at
    }
    
    DONATION_ADVERSE_EVENTS {
        varchar event_id PK
        varchar donation_id FK
        varchar event_type
        varchar severity
        text description
        varchar treatment_given
        varchar reported_by
        date event_date
        time event_time
        timestamp created_at
    }
    
    FACILITY_STAFF {
        varchar staff_id PK
        varchar facility_id FK
        varchar first_name
        varchar last_name
        varchar role
        varchar qualification
        varchar license_number UK
        date license_expiry
        varchar phone_number
        varchar email
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }
    
    EQUIPMENT {
        varchar equipment_id PK
        varchar facility_id FK
        varchar equipment_name
        varchar equipment_type
        varchar serial_number UK
        date purchase_date
        date last_calibration_date
        date next_calibration_date
        varchar status
        varchar manufacturer
        text notes
        timestamp created_at
        timestamp updated_at
    }
