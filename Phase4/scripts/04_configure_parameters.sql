-- ============================================================================
-- Script: 04_configure_memory_parameters.sql
-- Purpose: Configure SGA, PGA, and other memory parameters
-- Author: Benjamin (Student ID: 26979)
-- Date: December 19, 2025
-- ============================================================================


SET ECHO ON
SET SERVEROUTPUT ON
SPOOL configure_memory.log

PROMPT ============================================================
PROMPT Configuring Memory Parameters for Blood Donation System
PROMPT ============================================================

-- ============================================================================
-- STEP 1: DISPLAY CURRENT MEMORY CONFIGURATION
-- ============================================================================

PROMPT ============================================================
PROMPT Current Memory Configuration
PROMPT ============================================================

SELECT 
    NAME,
    VALUE,
    DISPLAY_VALUE,
    ISDEFAULT,
    ISMODIFIED
FROM V$PARAMETER
WHERE NAME IN (
    'memory_target',
    'memory_max_target',
    'sga_target',
    'sga_max_size',
    'pga_aggregate_target',
    'pga_aggregate_limit',
    'db_cache_size',
    'shared_pool_size',
    'large_pool_size',
    'java_pool_size',
    'streams_pool_size'
)
ORDER BY NAME;

-- Display current SGA components
PROMPT ============================================================
PROMPT Current SGA Components
PROMPT ============================================================

SELECT 
    NAME,
    ROUND(VALUE/1024/1024, 2) AS SIZE_MB
FROM V$SGA
ORDER BY NAME;

SELECT 
    COMPONENT,
    ROUND(CURRENT_SIZE/1024/1024, 2) AS CURRENT_SIZE_MB,
    ROUND(MIN_SIZE/1024/1024, 2) AS MIN_SIZE_MB,
    ROUND(MAX_SIZE/1024/1024, 2) AS MAX_SIZE_MB
FROM V$SGA_DYNAMIC_COMPONENTS
WHERE CURRENT_SIZE > 0
ORDER BY CURRENT_SIZE DESC;

-- ============================================================================
-- STEP 2: CALCULATE OPTIMAL MEMORY SETTINGS
-- ============================================================================

PROMPT ============================================================
PROMPT Calculating Optimal Memory Settings
PROMPT ============================================================

-- Get available physical memory
SELECT 
    'Physical Memory (GB)' AS PARAMETER,
    ROUND(VALUE/1024/1024/1024, 2) AS VALUE
FROM V$OSSTAT
WHERE STAT_NAME = 'PHYSICAL_MEMORY_BYTES';

-- Recommended settings based on 4GB RAM system:
-- Total Memory: 4GB
-- Oracle Database: 2.5GB (60% of total)
-- SGA Target: 1.8GB (70% of Oracle memory)
-- PGA Target: 700MB (30% of Oracle memory)

-- ============================================================================
-- STEP 3: CONFIGURE AUTOMATIC MEMORY MANAGEMENT (AMM)
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Automatic Memory Management
PROMPT ============================================================

-- Set MEMORY_MAX_TARGET (static parameter - requires restart)
-- This is the maximum memory Oracle can use
ALTER SYSTEM SET MEMORY_MAX_TARGET = 2560M SCOPE=SPFILE;

-- Set MEMORY_TARGET (dynamic parameter)
-- This is the current memory target
ALTER SYSTEM SET MEMORY_TARGET = 2560M SCOPE=SPFILE;

PROMPT Automatic Memory Management configured (requires restart)

-- ============================================================================
-- STEP 4: CONFIGURE SGA PARAMETERS (Alternative to AMM)
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring SGA Parameters
PROMPT ============================================================

-- If AMM is not used, configure SGA manually
-- Set SGA_MAX_SIZE (static - requires restart)
ALTER SYSTEM SET SGA_MAX_SIZE = 1856M SCOPE=SPFILE;

-- Set SGA_TARGET (dynamic within SGA_MAX_SIZE)
ALTER SYSTEM SET SGA_TARGET = 1856M SCOPE=BOTH;

-- Configure individual SGA components (optional - for fine-tuning)
-- Database Buffer Cache (for data blocks)
ALTER SYSTEM SET DB_CACHE_SIZE = 768M SCOPE=SPFILE;

-- Shared Pool (for SQL statements, PL/SQL code, data dictionary)
ALTER SYSTEM SET SHARED_POOL_SIZE = 512M SCOPE=SPFILE;

-- Large Pool (for backup/restore, parallel execution)
ALTER SYSTEM SET LARGE_POOL_SIZE = 256M SCOPE=SPFILE;

-- Java Pool (if using Java stored procedures)
ALTER SYSTEM SET JAVA_POOL_SIZE = 64M SCOPE=SPFILE;

-- Streams Pool (for data replication)
ALTER SYSTEM SET STREAMS_POOL_SIZE = 64M SCOPE=SPFILE;

PROMPT SGA parameters configured

-- ============================================================================
-- STEP 5: CONFIGURE PGA PARAMETERS
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring PGA Parameters
PROMPT ============================================================

-- Set PGA_AGGREGATE_TARGET
-- Recommended: 20-30% of total Oracle memory
ALTER SYSTEM SET PGA_AGGREGATE_TARGET = 704M SCOPE=BOTH;

-- Set PGA_AGGREGATE_LIMIT (maximum PGA that can be used)
-- Recommended: 2-3 times PGA_AGGREGATE_TARGET
ALTER SYSTEM SET PGA_AGGREGATE_LIMIT = 2G SCOPE=BOTH;

-- Configure workarea size policy
ALTER SYSTEM SET WORKAREA_SIZE_POLICY = AUTO SCOPE=BOTH;

PROMPT PGA parameters configured

-- ============================================================================
-- STEP 6: CONFIGURE ADDITIONAL MEMORY PARAMETERS
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Additional Memory Parameters
PROMPT ============================================================

-- Sort Area Size (for sorting operations)
ALTER SYSTEM SET SORT_AREA_SIZE = 524288 SCOPE=SPFILE;

-- Hash Area Size (for hash joins)
ALTER SYSTEM SET HASH_AREA_SIZE = 524288 SCOPE=SPFILE;

-- Bitmap Merge Area Size (for bitmap index operations)
ALTER SYSTEM SET BITMAP_MERGE_AREA_SIZE = 1048576 SCOPE=SPFILE;

-- Create Bitmap Area Size (for creating bitmap indexes)
ALTER SYSTEM SET CREATE_BITMAP_AREA_SIZE = 8388608 SCOPE=SPFILE;

-- Result Cache
ALTER SYSTEM SET RESULT_CACHE_MAX_SIZE = 64M SCOPE=BOTH;
ALTER SYSTEM SET RESULT_CACHE_MODE = MANUAL SCOPE=BOTH;

-- Client Result Cache
ALTER SYSTEM SET CLIENT_RESULT_CACHE_SIZE = 32M SCOPE=SPFILE;

PROMPT Additional memory parameters configured

-- ============================================================================
-- STEP 7: CONFIGURE SESSION AND CURSOR PARAMETERS
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Session and Cursor Parameters
PROMPT ============================================================

-- Maximum number of sessions
ALTER SYSTEM SET SESSIONS = 500 SCOPE=SPFILE;

-- Number of processes
ALTER SYSTEM SET PROCESSES = 300 SCOPE=SPFILE;

-- Open cursors per session
ALTER SYSTEM SET OPEN_CURSORS = 300 SCOPE=BOTH;

-- Session cached cursors
ALTER SYSTEM SET SESSION_CACHED_CURSORS = 50 SCOPE=SPFILE;

-- Cursor sharing mode
ALTER SYSTEM SET CURSOR_SHARING = EXACT SCOPE=BOTH;

PROMPT Session and cursor parameters configured

-- ============================================================================
-- STEP 8: CONFIGURE OPTIMIZER PARAMETERS
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Optimizer Parameters
PROMPT ============================================================

-- Optimizer mode
ALTER SYSTEM SET OPTIMIZER_MODE = ALL_ROWS SCOPE=BOTH;

-- Optimizer features enable
ALTER SYSTEM SET OPTIMIZER_FEATURES_ENABLE = '19.1.0' SCOPE=BOTH;

-- Query optimizer index caching
ALTER SYSTEM SET OPTIMIZER_INDEX_CACHING = 0 SCOPE=BOTH;

-- Query optimizer index cost adjustment
ALTER SYSTEM SET OPTIMIZER_INDEX_COST_ADJ = 100 SCOPE=BOTH;

-- Statistics level
ALTER SYSTEM SET STATISTICS_LEVEL = TYPICAL SCOPE=BOTH;

PROMPT Optimizer parameters configured

-- ============================================================================
-- STEP 9: CONFIGURE PARALLEL EXECUTION PARAMETERS
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Parallel Execution Parameters
PROMPT ============================================================

-- Parallel max servers
ALTER SYSTEM SET PARALLEL_MAX_SERVERS = 20 SCOPE=BOTH;

-- Parallel min servers
ALTER SYSTEM SET PARALLEL_MIN_SERVERS = 0 SCOPE=BOTH;

-- Parallel execution message size
ALTER SYSTEM SET PARALLEL_EXECUTION_MESSAGE_SIZE = 16384 SCOPE=SPFILE;

-- Parallel degree policy
ALTER SYSTEM SET PARALLEL_DEGREE_POLICY = MANUAL SCOPE=BOTH;

PROMPT Parallel execution parameters configured

-- ============================================================================
-- STEP 10: CONFIGURE UNDO PARAMETERS
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Undo Parameters
PROMPT ============================================================

-- Undo management
ALTER SYSTEM SET UNDO_MANAGEMENT = AUTO SCOPE=BOTH;

-- Undo tablespace
ALTER SYSTEM SET UNDO_TABLESPACE = BLOOD_BANK_UNDO SCOPE=BOTH;

-- Undo retention (in seconds) - 15 minutes
ALTER SYSTEM SET UNDO_RETENTION = 900 SCOPE=BOTH;

-- Undo retention guarantee
-- ALTER TABLESPACE BLOOD_BANK_UNDO RETENTION GUARANTEE;

PROMPT Undo parameters configured

-- ============================================================================
-- STEP 11: CONFIGURE DATABASE CACHE ADVICE
-- ============================================================================

PROMPT ============================================================
PROMPT Configuring Database Cache Advice
PROMPT ============================================================

-- Enable DB cache advice
ALTER SYSTEM SET DB_CACHE_ADVICE = ON SCOPE=BOTH;

-- Enable buffer cache advice
ALTER SYSTEM SET DB_16K_CACHE_SIZE = 0 SCOPE=SPFILE;
ALTER SYSTEM SET DB_32K_CACHE_SIZE = 0 SCOPE=SPFILE;

PROMPT Cache advice configured

-- ============================================================================
-- STEP 12: VERIFY CONFIGURATION
-- ============================================================================

PROMPT ============================================================
PROMPT Verifying Memory Configuration
PROMPT ============================================================

-- Display configured parameters (SPFILE)
SELECT 
    NAME,
    VALUE,
    DISPLAY_VALUE
FROM V$SPPARAMETER
WHERE NAME IN (
    'memory_target',
    'memory_max_target',
    'sga_target',
    'sga_max_size',
    'pga_aggregate_target',
    'pga_aggregate_limit',
    'db_cache_size',
    'shared_pool_size',
    'large_pool_size',
    'processes',
    'sessions',
    'open_cursors'
)
AND VALUE IS NOT NULL
ORDER BY NAME;

-- Calculate total configured memory
SELECT 
    'Configured Memory Summary' AS INFO,
    ROUND(SUM(
        CASE 
            WHEN NAME = 'memory_target' THEN TO_NUMBER(VALUE)
            WHEN NAME = 'sga_target' AND NOT EXISTS (
                SELECT 1 FROM V$SPPARAMETER WHERE NAME = 'memory_target' AND VALUE IS NOT NULL
            ) THEN TO_NUMBER(VALUE)
            ELSE 0
        END
    )/1024/1024, 2) AS TOTAL_MEMORY_MB
FROM V$SPPARAMETER
WHERE NAME IN ('memory_target', 'sga_target');

-- Memory allocation advice
PROMPT ============================================================
PROMPT Memory Allocation Advice
PROMPT ============================================================

SELECT 
    'Recommended Configuration for 4GB System' AS ADVICE,
    '2.5GB Total Oracle Memory' AS RECOMMENDATION
FROM DUAL
UNION ALL
SELECT 
    'SGA Target' AS ADVICE,
    '1.8GB (70% of Oracle Memory)' AS RECOMMENDATION
FROM DUAL
UNION ALL
SELECT 
    'PGA Target' AS ADVICE,
    '700MB (30% of Oracle Memory)' AS RECOMMENDATION
FROM DUAL
UNION ALL
SELECT 
    'Buffer Cache' AS ADVICE,
    '768MB (monitoring required)' AS RECOMMENDATION
FROM DUAL
UNION ALL
SELECT 
    'Shared Pool' AS ADVICE,
    '512MB (adjust based on workload)' AS RECOMMENDATION
FROM DUAL;

-- ============================================================================
-- SCRIPT COMPLETION
-- ============================================================================

PROMPT ============================================================
PROMPT Memory Configuration Completed!
PROMPT 
PROMPT IMPORTANT: Database restart required for some parameters to take effect
PROMPT 
PROMPT To restart the database:
PROMPT   1. SHUTDOWN IMMEDIATE;
PROMPT   2. STARTUP;
PROMPT 
PROMPT Configured Parameters:
PROMPT   - Memory Target: 2.5GB
PROMPT   - SGA Target: 1.8GB
PROMPT   - PGA Target: 700MB
PROMPT   - Processes: 300
PROMPT   - Sessions: 500
PROMPT   - Open Cursors: 300
PROMPT ============================================================

SPOOL OFF;
EXIT;
