-- ============================================================================
-- Script: 02_CREATE_TABLESPACES.sql
-- Purpose: Create tablespaces for Blood Donation Database
-- Author: Benjamin (Student ID: 26979)
-- Group: Thursday (thur)
-- Database: thur_26979_benjamin_blooddonation_db
-- ============================================================================

-- Connect to the PDB
CONNECT sys/oracle@localhost:1521/thur_26979_benjamin_blooddonation_db AS SYSDBA

SET ECHO ON
SET SERVEROUTPUT ON
SET TIMING ON

SPOOL create_tablespaces.log

PROMPT ============================================================
PROMPT Creating Tablespaces for thur_26979_benjamin_blooddonation_db
PROMPT ============================================================

-- ============================================================================
-- TABLESPACE 1: BLOOD_BANK_DATA (Primary data)
-- ============================================================================

PROMPT Creating BLOOD_BANK_DATA tablespace...

CREATE TABLESPACE BLOOD_BANK_DATA
DATAFILE '/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_data01.dbf'
SIZE 500M
AUTOEXTEND ON 
NEXT 100M 
MAXSIZE 10G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

-- Add second datafile for I/O distribution
ALTER TABLESPACE BLOOD_BANK_DATA ADD DATAFILE
'/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_data02.dbf'
SIZE 500M
AUTOEXTEND ON 
NEXT 100M 
MAXSIZE 10G;

PROMPT ✓ BLOOD_BANK_DATA created

-- ============================================================================
-- TABLESPACE 2: BLOOD_BANK_INDEXES (Indexes)
-- ============================================================================

PROMPT Creating BLOOD_BANK_INDEXES tablespace...

CREATE TABLESPACE BLOOD_BANK_INDEXES
DATAFILE '/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_indexes01.dbf'
SIZE 300M
AUTOEXTEND ON 
NEXT 50M 
MAXSIZE 5G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

PROMPT ✓ BLOOD_BANK_INDEXES created

-- ============================================================================
-- TABLESPACE 3: BLOOD_BANK_LOB (Large objects)
-- ============================================================================

PROMPT Creating BLOOD_BANK_LOB tablespace...

CREATE TABLESPACE BLOOD_BANK_LOB
DATAFILE '/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_lob01.dbf'
SIZE 200M
AUTOEXTEND ON 
NEXT 50M 
MAXSIZE 3G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

PROMPT ✓ BLOOD_BANK_LOB created

-- ============================================================================
-- TABLESPACE 4: BLOOD_BANK_TEMP (Temporary)
-- ============================================================================

PROMPT Creating BLOOD_BANK_TEMP temporary tablespace...

CREATE TEMPORARY TABLESPACE BLOOD_BANK_TEMP
TEMPFILE '/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_temp01.dbf'
SIZE 300M
AUTOEXTEND ON 
NEXT 100M 
MAXSIZE 5G
EXTENT MANAGEMENT LOCAL
UNIFORM SIZE 1M;

PROMPT ✓ BLOOD_BANK_TEMP created

-- ============================================================================
-- TABLESPACE 5: BLOOD_BANK_UNDO (Undo)
-- ============================================================================

PROMPT Creating BLOOD_BANK_UNDO undo tablespace...

CREATE UNDO TABLESPACE BLOOD_BANK_UNDO
DATAFILE '/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_undo01.dbf'
SIZE 200M
AUTOEXTEND ON 
NEXT 50M 
MAXSIZE 2G
RETENTION GUARANTEE;

-- Set as default undo tablespace
ALTER SYSTEM SET UNDO_TABLESPACE = BLOOD_BANK_UNDO SCOPE=BOTH;

PROMPT ✓ BLOOD_BANK_UNDO created

-- ============================================================================
-- TABLESPACE 6: BLOOD_BANK_ARCHIVE (Historical data)
-- ============================================================================

PROMPT Creating BLOOD_BANK_ARCHIVE tablespace...

CREATE TABLESPACE BLOOD_BANK_ARCHIVE
DATAFILE '/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_archive01.dbf'
SIZE 500M
AUTOEXTEND ON 
NEXT 100M 
MAXSIZE 10G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

PROMPT ✓ BLOOD_BANK_ARCHIVE created

-- ============================================================================
-- TABLESPACE 7: BLOOD_BANK_BI (Business Intelligence)
-- ============================================================================

PROMPT Creating BLOOD_BANK_BI tablespace...

CREATE TABLESPACE BLOOD_BANK_BI
DATAFILE '/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_bi01.dbf'
SIZE 1G
AUTOEXTEND ON 
NEXT 200M 
MAXSIZE 20G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

-- Add second datafile
ALTER TABLESPACE BLOOD_BANK_BI ADD DATAFILE
'/u01/app/oracle/oradata/ORCL/thur_26979_benjamin_blooddonation_db/blood_bank_bi02.dbf'
SIZE 1G
AUTOEXTEND ON 
NEXT 200M 
MAXSIZE 20G;

PROMPT ✓ BLOOD_BANK_BI created

-- ============================================================================
-- SET DEFAULT TABLESPACES
-- ============================================================================

PROMPT Setting default tablespaces...

ALTER DATABASE DEFAULT TABLESPACE BLOOD_BANK_DATA;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE BLOOD_BANK_TEMP;

PROMPT ✓ Default tablespaces set

-- ============================================================================
-- VERIFY CREATION
-- ============================================================================

PROMPT
PROMPT ============================================================
PROMPT Verifying Tablespace Creation
PROMPT ============================================================

SELECT 
    TABLESPACE_NAME,
    STATUS,
    CONTENTS,
    EXTENT_MANAGEMENT,
    SEGMENT_SPACE_MANAGEMENT,
    BIGFILE
FROM DBA_TABLESPACES
WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%'
ORDER BY TABLESPACE_NAME;

PROMPT
PROMPT Datafile Information:
PROMPT

SELECT 
    TABLESPACE_NAME,
    FILE_NAME,
    ROUND(BYTES/1024/1024, 2) AS SIZE_MB,
    ROUND(MAXBYTES/1024/1024, 2) AS MAX_MB,
    AUTOEXTENSIBLE,
    STATUS
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%'
UNION ALL
SELECT 
    TABLESPACE_NAME,
    FILE_NAME,
    ROUND(BYTES/1024/1024, 2) AS SIZE_MB,
    ROUND(MAXBYTES/1024/1024, 2) AS MAX_MB,
    AUTOEXTENSIBLE,
    STATUS
FROM DBA_TEMP_FILES
WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%'
ORDER BY TABLESPACE_NAME, FILE_NAME;

-- Summary
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(DISTINCT TABLESPACE_NAME) INTO v_count
    FROM DBA_TABLESPACES
    WHERE TABLESPACE_NAME LIKE 'BLOOD_BANK%';
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('╔════════════════════════════════════════════════════════╗');
    DBMS_OUTPUT.PUT_LINE('║     TABLESPACE CREATION COMPLETED SUCCESSFULLY!        ║');
    DBMS_OUTPUT.PUT_LINE('╚════════════════════════════════════════════════════════╝');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('✅ Total Tablespaces Created: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Created Tablespaces:');
    DBMS_OUTPUT.PUT_LINE('  1. BLOOD_BANK_DATA (Primary data - 1GB initial)');
    DBMS_OUTPUT.PUT_LINE('  2. BLOOD_BANK_INDEXES (Indexes - 300MB initial)');
    DBMS_OUTPUT.PUT_LINE('  3. BLOOD_BANK_LOB (Large objects - 200MB initial)');
    DBMS_OUTPUT.PUT_LINE('  4. BLOOD_BANK_TEMP (Temporary - 300MB initial)');
    DBMS_OUTPUT.PUT_LINE('  5. BLOOD_BANK_UNDO (Undo - 200MB initial)');
    DBMS_OUTPUT.PUT_LINE('  6. BLOOD_BANK_ARCHIVE (Archive - 500MB initial)');
    DBMS_OUTPUT.PUT_LINE('  7. BLOOD_BANK_BI (Business Intelligence - 2GB initial)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Next Step: Run 03_CREATE_USERS.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

SPOOL OFF;
EXIT;
