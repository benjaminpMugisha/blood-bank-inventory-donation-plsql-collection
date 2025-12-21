
# Blood Bank Management System - Complete Documentation

## Project Overview

**Student Name: MUGISHA Prince Benjamin
**Student # ID: 26979
**Project:** Blood Bank Management System Database  
**Institution:** Adventist University of Central Africa (AUCA)  
**Course:** Database Development with PL/SQL (INSY 8311)  
**Completion Date:** December 7, 2025

---

## Problem Statement

Rwanda's blood donation system faces challenges in efficiently managing blood inventory, tracking donors, coordinating between facilities, and ensuring blood safety. This system addresses critical needs including:

- **Donor Management:** Centralized tracking of donor eligibility, history, and appointments
- **Inventory Control:** Real-time monitoring of blood units across facilities
- **Request Fulfillment:** Efficient processing of blood requests from hospitals
- **Safety & Compliance:** Comprehensive testing, auditing, and regulatory compliance
- **Analytics:** Data-driven insights for supply chain optimization

---

## Key Objectives

1. ✅ Create production-ready Oracle database with 17+ normalized tables
2. ✅ Implement comprehensive PL/SQL procedures, functions, and packages
3. ✅ Establish strict business rules with trigger-based enforcement
4. ✅ Build audit trail for security and compliance
5. ✅ Develop Business Intelligence dashboards and analytics
6. ✅ Ensure data integrity through constraints and validation

---

## Database Architecture

### Entity-Relationship Overview

The system consists of 17 interconnected tables organized into logical domains:

#### Core Entities
- **DONORS** - Donor profiles and blood type information
- **FACILITIES** - Blood banks, hospitals, collection centers
- **DONATIONS** - Individual donation records
- **BLOOD_UNITS** - Processed blood components

#### Supporting Entities
- **ELIGIBILITY_CHECKS** - Pre-donation screening
- **APPOINTMENTS** - Scheduled donation appointments
- **DONOR_DEFERRALS** - Temporary/permanent deferral tracking
- **TEST_RESULTS** - Blood testing (HIV, Hepatitis, etc.)
- **DONATION_ADVERSE_EVENTS** - Safety incident tracking

#### Inventory & Distribution
- **INVENTORY** - Real-time stock levels by facility
- **REQUESTS** - Blood requests from hospitals
- **REQUEST_ITEMS** - Line items for requests
- **TRANSFERS** - Inter-facility blood transfers
- **TRANSFER_ITEMS** - Transfer line items

#### Operational Support
- **BLOOD_UNIT_HISTORY** - Complete lifecycle tracking
- **FACILITY_STAFF** - Personnel management
- **EQUIPMENT** - Medical equipment tracking
- **PUBLIC_HOLIDAYS** - Holiday calendar for restrictions
- **AUDIT_LOG** - Complete audit trail

---

## Technical Implementation

### Phase V: Table Creation & Data Population

**Tables Created:** 17 main entities  
**Data Volume:**
- 150+ donors with diverse demographics
- 200+ donation records
- 300+ blood units across multiple components
- 250+ appointments
- 180+ eligibility checks
- 15+ facilities (blood banks, hospitals, collection centers)

**Key Features:**
- Comprehensive constraints (PK, FK, CHECK, UNIQUE)
- Optimized indexes for query performance
- Data validation at database level
- Realistic test data representing actual use cases

### Phase VI: PL/SQL Development

#### Stored Procedures (5+)
1. **sp_register_donor** - New donor registration with validation
2. **sp_schedule_appointment** - Appointment scheduling with eligibility checks
3. **sp_record_donation** - Complete donation recording workflow
4. **sp_update_blood_unit_status** - Status management with history tracking
5. **sp_process_blood_request** - Request processing and inventory allocation

#### Functions (5+)
1. **fn_calculate_eligibility_score** - Donor suitability scoring (0-100)
2. **fn_get_compatible_donors** - Blood type compatibility matching
3. **fn_days_to_expiry** - Blood unit expiration calculation
4. **fn_get_inventory_status** - Real-time inventory status
5. **fn_validate_donor_donation** - Comprehensive donor validation

#### Package: pkg_blood_bank_mgmt
- Encapsulates common operations
- Provides consistent interface
- Includes constants for business rules
- Error handling and validation

#### Cursors
- Explicit cursors for batch processing
- Expiring units management
- Statistical report generation
- Bulk operations optimization

### Phase VII: Advanced Programming

#### Business Rule: Weekday & Holiday Restrictions

**CRITICAL REQUIREMENT:** Employees CANNOT perform INSERT/UPDATE/DELETE operations on:
- Weekdays (Monday-Friday)
- Public Holidays (upcoming month)

**Implementation Components:**

1. **PUBLIC_HOLIDAYS Table**
   - Stores holiday calendar
   - Supports upcoming month validation
   - Easy maintenance and updates

2. **AUDIT_LOG Table**
   - Captures ALL operation attempts
   - Records: user, timestamp, operation, status
   - Provides complete security trail

3. **fn_log_audit Function**
   - Autonomous transaction for logging
   - Never fails parent transaction
   - Captures session information

4. **fn_check_operation_allowed Function**
   - Validates day of week
   - Checks public holiday calendar
   - Returns denial reason or NULL

5. **Row-Level Triggers (5+)**
   - DONORS: INSERT, UPDATE, DELETE
   - DONATIONS: INSERT
   - BLOOD_UNITS: DELETE
   - Each logs attempts and blocks if restricted

6. **Compound Trigger**
   - FACILITIES table comprehensive auditing
   - BEFORE/AFTER STATEMENT and ROW sections
   - Batch operation tracking
   - Performance optimized

**Testing Results:**
- ✅ Blocks operations on weekdays (Monday-Friday)
- ✅ Allows operations on weekends (Saturday-Sunday)
- ✅ Blocks operations on public holidays
- ✅ Logs all attempts to AUDIT_LOG
- ✅ Provides clear error messages

### Phase VIII: Business Intelligence

#### Executive Dashboard KPIs

1. **System Overview Metrics**
   - Total active donors
   - Donations (last 30 days)
   - Available blood units
   - Pending requests
   - Active facilities

2. **Blood Inventory Status**
   - By blood type (A, B, AB, O)
   - By Rh factor (+/-)
   - By component (Whole Blood, RBC, Plasma, Platelets)
   - Availability percentage

3. **Donation Trends**
   - Monthly donation volumes
   - 3-month moving average
   - Month-over-month change
   - Year-over-year comparison

4. **Facility Performance Rankings**
   - RANK() by donation volume
   - DENSE_RANK() by fulfillment rate
   - Performance metrics

#### Analytics Categories

**Donor Analytics:**
- Demographics (age, gender, blood type)
- Hero donors (top 50 by donations)
- Retention analysis
- Engagement scoring

**Inventory Analytics:**
- Blood unit lifecycle
- Critical inventory alerts
- Expiration management
- Supply chain optimization

**Operational Metrics:**
- Request fulfillment performance
- Appointment completion rates
- Adverse events analysis
- Geographic distribution

**Audit & Compliance:**
- Security audit summary
- Restriction compliance report
- User activity tracking
- Violation patterns

**Predictive Analytics:**
- Demand forecasting (3-month moving average)
- Donor engagement predictions
- Geographic expansion opportunities

#### Window Functions Showcase

- **ROW_NUMBER()** - Unique sequential numbering
- **RANK() / DENSE_RANK()** - Performance rankings
- **LAG() / LEAD()** - Time series comparisons
- **NTILE()** - Quartile analysis
- **PARTITION BY** - Group-wise calculations
- **Running Totals** - Cumulative metrics
- **Moving Averages** - Trend smoothing
- **PERCENTILE_CONT** - Distribution analysis

---

## Quick Start Guide

### Prerequisites
```sql
-- Oracle Database 19c or higher
-- SQL Developer or SQLcl
-- Minimum 500MB tablespace
```

### Installation Steps

1. **Create Pluggable Database**
```sql
-- Run Phase 4 database creation script
-- Format: GrpName_StudentId_FirstName_ProjectName_DB
```

2. **Create Tables**
```sql
-- Run Phase 5 DDL script
@PHASE5_TABLE_CREATION.sql
```

3. **Insert Test Data**
```sql
-- Run Phase 5 data insertion script
@PHASE5_DATA_INSERTION.sql
```

4. **Deploy PL/SQL Objects**
```sql
-- Run Phase 6 script
@PHASE6_PLSQL_DEVELOPMENT.sql
```

5. **Enable Triggers & Auditing**
```sql
-- Run Phase 7 script
@PHASE7_TRIGGERS_AUDITING.sql
```

6. **Test BI Queries**
```sql
-- Run Phase 8 analytics script
@PHASE8_BI_ANALYTICS.sql
```

---

## Key Features

### 🔒 Security & Compliance
- Row-level security triggers
- Comprehensive audit logging
- Business rule enforcement
- Data encryption ready

### 📊 Business Intelligence
- 14+ analytical dashboards
- Real-time KPI tracking
- Predictive analytics
- Geographic analysis

### ⚡ Performance
- Strategic indexing
- Optimized queries
- Bulk operations support
- Query plan optimization

### 🎯 Data Quality
- Referential integrity enforced
- CHECK constraints validation
- Custom validation functions
- Automated data cleansing

---

## Testing Evidence

### Unit Testing
- ✅ All procedures tested with valid/invalid inputs
- ✅ All functions return expected values
- ✅ Constraints prevent invalid data
- ✅ Triggers fire correctly

### Integration Testing
- ✅ Complete donation workflow
- ✅ Request fulfillment process
- ✅ Transfer operations
- ✅ Audit trail verification

### Business Rule Testing
- ✅ Weekday restrictions enforced
- ✅ Holiday restrictions enforced
- ✅ Weekend operations allowed
- ✅ All attempts logged

---

## Data Dictionary Sample

| Table | Column | Type | Constraints | Purpose |
|-------|--------|------|-------------|---------|
| DONORS | donor_id | VARCHAR2(20) | PK, NOT NULL | Unique donor identifier |
| DONORS | national_id | VARCHAR2(20) | UNIQUE, NOT NULL | National ID number |
| DONORS | blood_type | VARCHAR2(3) | CHECK (A/B/AB/O) | ABO blood type |
| DONORS | rh_factor | VARCHAR2(3) | CHECK (+/-) | Rh factor |
| DONORS | total_donations | NUMBER(4) | CHECK (>=0) | Lifetime donation count |
| BLOOD_UNITS | unit_id | VARCHAR2(20) | PK, NOT NULL | Unique unit identifier |
| BLOOD_UNITS | status | VARCHAR2(20) | CHECK (list) | Current unit status |
| BLOOD_UNITS | expiration_date | DATE | NOT NULL | Must expire after collection |
| REQUESTS | urgency_level | VARCHAR2(20) | CHECK (list) | Emergency/Urgent/Routine |
| AUDIT_LOG | is_allowed | CHAR(1) | CHECK (Y/N) | Operation allowed flag |

---

## Project Achievements

✅ **17 normalized tables** (3NF minimum)  
✅ **300+ realistic data records** per main table  
✅ **10+ stored procedures** with exception handling  
✅ **10+ functions** for business logic  
✅ **1 comprehensive package** for common operations  
✅ **6+ triggers** with restriction enforcement  
✅ **1 compound trigger** for advanced auditing  
✅ **Complete audit trail** with autonomous logging  
✅ **14+ BI analytical queries** with window functions  
✅ **Geographic analysis** across Rwanda  
✅ **Predictive analytics** for demand forecasting  
✅ **Performance optimization** with indexes

---

## Lessons Learned

1. **Database Design:** Proper normalization prevents data anomalies
2. **PL/SQL Development:** Exception handling is crucial for production code
3. **Trigger Design:** Autonomous transactions essential for audit logging
4. **Window Functions:** Powerful for analytical queries without subqueries
5. **Testing:** Comprehensive testing catches edge cases early
6. **Documentation:** Clear documentation enables maintenance and scaling

---

## Future Enhancements

- [ ] Mobile app integration for donors
- [ ] SMS/Email notification system
- [ ] Real-time dashboard web interface
- [ ] Machine learning for demand prediction
- [ ] Blockchain for supply chain tracking
- [ ] Integration with national health system

---

## GitHub Repository Structure

```
blood-bank-management-system/
├── README.md (this file)
├── database/
│   ├── Phase4_Database_Creation.sql
│   ├── Phase5_DDL_Tables.sql
│   ├── Phase5_DML_Data_Insertion.sql
│   ├── Phase5_Validation_Queries.sql
│   ├── Phase6_Procedures.sql
│   ├── Phase6_Functions.sql
│   ├── Phase6_Packages.sql
│   ├── Phase6_Cursors.sql
│   ├── Phase7_Triggers.sql
│   ├── Phase7_Audit_System.sql
│   └── Phase8_BI_Analytics.sql
├── documentation/
│   ├── ER_Diagram.png
│   ├── Data_Dictionary.md
│   ├── Business_Process_Model.png
│   ├── Architecture_Overview.md
│   └── Design_Decisions.md
├── screenshots/
│   ├── database_structure/
│   ├── sample_data/
│   ├── procedure_execution/
│   ├── trigger_testing/
│   └── bi_dashboards/
├── business_intelligence/
│   ├── KPI_Definitions.md
│   ├── Dashboard_Mockups/
│   └── Analytics_Requirements.md
└── tests/
    ├── unit_tests.sql
    ├── integration_tests.sql
    └── test_results.log
```

---

## Contact & Support

**Lecturer:** Eric Maniraguha  
**Email:** eric.maniraguha@auca.ac.rw  
**Institution:** Adventist University of Central Africa (AUCA)

---

## Biblical Inspiration

*"Whatever you do, work at it with all your heart, as working for the Lord, not for human masters."*  
— Colossians 3:23 (NIV)

---

## License

This project is submitted as academic coursework for INSY 8311 at AUCA.

---

**Project Status:** ✅ COMPLETE - All 8 Phases Implemented  
**Last Updated:** December 2025  
**Version:** 1.0.0
