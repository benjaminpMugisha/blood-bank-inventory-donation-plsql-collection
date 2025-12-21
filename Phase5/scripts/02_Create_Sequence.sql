-- ============================================================================
-- Script: 02_CREATE_SEQUENCES.sql
-- Purpose: Create sequences for auto-generating IDs
-- Author: Benjamin (26979) | Group: Thursday
-- ============================================================================

CONNECT benjamin_admin/Benjamin@localhost:1521/thur_26979_benjamin_blooddonation_db

SET ECHO ON
SPOOL create_sequences.log

PROMPT ====================================================================
PROMPT Creating Sequences for ID Generation
PROMPT ====================================================================

-- Donor sequence
CREATE SEQUENCE seq_donor_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Facility sequence
CREATE SEQUENCE seq_facility_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Staff sequence
CREATE SEQUENCE seq_staff_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Donation sequence
CREATE SEQUENCE seq_donation_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Blood unit sequence
CREATE SEQUENCE seq_unit_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Test sequence
CREATE SEQUENCE seq_test_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Request sequence
CREATE SEQUENCE seq_request_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Request item sequence
CREATE SEQUENCE seq_request_item_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Transfer sequence
CREATE SEQUENCE seq_transfer_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Transfer item sequence
CREATE SEQUENCE seq_transfer_item_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Eligibility check sequence
CREATE SEQUENCE seq_check_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Appointment sequence
CREATE SEQUENCE seq_appointment_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Inventory sequence
CREATE SEQUENCE seq_inventory_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Deferral sequence
CREATE SEQUENCE seq_deferral_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- History sequence
CREATE SEQUENCE seq_history_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Event sequence
CREATE SEQUENCE seq_event_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- Equipment sequence
CREATE SEQUENCE seq_equipment_id
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

PROMPT ✓ All sequences created

-- Verify
SELECT SEQUENCE_NAME, LAST_NUMBER
FROM USER_SEQUENCES
ORDER BY SEQUENCE_NAME;

PROMPT
PROMPT ====================================================================
PROMPT ✓ SUCCESS! 17 Sequences Created
PROMPT Next: Run 03_INSERT_SAMPLE_DATA.sql
PROMPT ====================================================================

SPOOL OFF;
EXIT;
