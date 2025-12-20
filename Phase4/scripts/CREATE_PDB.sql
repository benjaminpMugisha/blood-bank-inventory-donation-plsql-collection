-- ============================================================================
-- SIMPLE PDB CREATION SCRIPT - GUARANTEED TO WORK
-- Student: Benjamin (26979) | Group: Thursday (thur)
-- Database: thur_26979_benjamin_blooddonation_db
-- ============================================================================

SET ECHO ON
SET SERVEROUTPUT ON
SPOOL simple_pdb_creation.log

PROMPT ====================================================================
PROMPT CREATING PDB: thur_26979_benjamin_blooddonation_db
PROMPT ====================================================================

-- Step 1: Drop existing PDB if it exists
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM CDB_PDBS
    WHERE PDB_NAME = 'THUR_26979_BENJAMIN_BLOODDONATION_DB';
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Dropping existing PDB...');
        EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE thur_26979_benjamin_blooddonation_db CLOSE IMMEDIATE';
        EXECUTE IMMEDIATE 'DROP PLUGGABLE DATABASE thur_26979_benjamin_blooddonation_db INCLUDING DATAFILES';
        DBMS_OUTPUT.PUT_LINE('Existing PDB dropped');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No existing PDB found');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Note: ' || SQLERRM);
END;
/

-- Step 2: Create new PDB
PROMPT Creating new PDB...

CREATE PLUGGABLE DATABASE thur_26979_benjamin_blooddonation_db
ADMIN USER benjamin_admin IDENTIFIED BY Benjamin
FILE_NAME_CONVERT = ('pdbseed', 'thur_26979_benjamin_blooddonation_db');

PROMPT PDB created successfully!

-- Step 3: Open the PDB
ALTER PLUGGABLE DATABASE thur_26979_benjamin_blooddonation_db OPEN;
PROMPT PDB opened!

-- Step 4: Save state for auto-open
ALTER PLUGGABLE DATABASE thur_26979_benjamin_blooddonation_db SAVE STATE;
PROMPT PDB state saved!

-- Step 5: Verify creation
PROMPT
PROMPT ====================================================================
PROMPT VERIFICATION
PROMPT ====================================================================

SELECT 
    PDB_NAME,
    STATUS,
    CON_ID
FROM CDB_PDBS
WHERE PDB_NAME = 'THUR_26979_BENJAMIN_BLOODDONATION_DB';

PROMPT
PROMPT ====================================================================
PROMPT SUCCESS! PDB Created: thur_26979_benjamin_blooddonation_db
PROMPT Next: Connect and create tablespaces
PROMPT ====================================================================

SPOOL OFF;
EXIT;
