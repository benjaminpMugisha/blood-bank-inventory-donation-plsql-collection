# Blood Bank Management System - Phase V
## Table Implementation & Data Insertion

---

## 📋 Project Overview

This project implements a comprehensive Blood Bank Management System database with realistic test data for the Rwandan healthcare context. The system tracks blood donations, inventory management, facility operations, and transfusion requests across multiple healthcare facilities.

---


---

## 🎯 Phase V Requirements Met

### ✅ Table Creation
- **17 tables** implemented with proper Oracle data types
- **Primary Keys (PK)** enforced on all tables
- **Foreign Keys (FK)** established with referential integrity
- **Indexes** created on frequently queried columns
- **Constraints** implemented:
  - `NOT NULL` on critical fields
  - `UNIQUE` constraints on business keys
  - `CHECK` constraints for data validation
  - `DEFAULT` values for optional fields

### ✅ Data Insertion
| Table | Records | Description |
|-------|---------|-------------|
| FACILITIES | 50 | Blood banks, hospitals, collection centers |
| DONORS | 500 | Diverse demographic distribution |
| FACILITY_STAFF | 200 | Phlebotomists, technicians, doctors, administrators |
| EQUIPMENT | 120 | Refrigerators, freezers, analyzers, centrifuges |
| ELIGIBILITY_CHECKS | 300 | Pre-donation screening records |
| APPOINTMENTS | 400 | Scheduled, completed, cancelled appointments |
| DONATIONS | 350 | Blood donation events |
| DONOR_DEFERRALS | 80 | Temporary and permanent deferrals |
| BLOOD_UNITS | 450 | Processed blood components |
| DONATION_ADVERSE_EVENTS | 40 | Side effects and complications |
| TEST_RESULTS | 900 | HIV, Hepatitis, blood typing tests |
| BLOOD_UNIT_HISTORY | 1,200+ | Complete audit trail |
| INVENTORY | 400 | Real-time stock levels by facility |
| REQUESTS | 150 | Blood requests from facilities |
| REQUEST_ITEMS | 300 | Individual unit allocations |
| TRANSFERS | 80 | Inter-facility blood transfers |
| TRANSFER_ITEMS | 200 | Units in transit |
| **TOTAL** | **5,380+** | **Comprehensive test dataset** |

### ✅ Data Characteristics
- **Realistic data**: Rwandan names, locations, phone numbers
- **Edge cases**: NULL values, expired units, failed tests
- **Demographic mix**: Gender, age, blood type distributions
- **Business scenarios**: Emergency requests, transfers, deferrals
- **Temporal variety**: Historical data spanning 0-365 days

### ✅ Data Integrity Verification
- Foreign key relationship validation
- NULL value checks on critical fields
- Constraint enforcement verification
- Data completeness reporting
- Orphaned record detection

### ✅ Testing Queries (25+ Queries)
1. **Basic Retrieval**: SELECT * from each table
2. **Joins**: Multi-table queries (5 examples)
3. **Aggregations**: GROUP BY queries (6 examples)
4. **Subqueries**: Nested queries (5 examples)
5. **Business Rules**: Validation queries (4 examples)
6. **Performance**: Summary statistics and dashboards

---

## 🚀 Installation Instructions

### Prerequisites
- Oracle Database 11g or higher
- SQL*Plus, SQL Developer, or similar Oracle client
- Sufficient tablespace (minimum 100MB recommended)

### Step 1: Create Tables
```sql
-- Run the DDL script
@01_DDL_CREATE_TABLES.sql
```

** Output**: 17 tables created successfully with all constraints and indexes.

### Step 2: Insert Data (Part 1)
```sql
-- Run main data insertion
@02_DML_INSERT_DATA_PART1.sql
```

** Output**: 
- 50 Facilities
- 500 Donors
- 200 Staff
- 120 Equipment
- 300 Eligibility Checks
- 400 Appointments
- 350 Donations
- 80 Deferrals
- 450 Blood Units

**Execution Time**: ~2-5 minutes

### Step 3: Insert Data (Part 2)
```sql
-- Run additional data insertion
@03_DML_INSERT_DATA_PART2.sql
```

** Output**:
- 40 Adverse Events
- 900 Test Results
- 1,200+ History Records
- 400 Inventory Records
- 150 Requests
- 300 Request Items
- 80 Transfers
- 200 Transfer Items

**Execution Time**: ~3-7 minutes

### Step 4: Run Validation
```sql
-- Validate data integrity and run test queries
@04_VALIDATION_QUERIES.sql
```

** Output**: 25+ query results demonstrating:
- Data completeness
- Foreign key integrity
- Business rule compliance
- Aggregation capabilities
- Complex join operations

---

## 📊 Key Features

### 1. Comprehensive Blood Type Coverage
- All ABO blood types: O, A, B, AB
- Rh factors: Positive (+) and Negative (-)
- Realistic distribution matching population demographics

### 2. Multi-Facility Operations
- 50 facilities across Rwanda
- Blood banks, hospitals, collection centers, mobile units
- Geographic distribution: Kigali, Huye, Musanze, etc.

### 3. Complete Donation Lifecycle
```
Donor Registration → Eligibility Check → Appointment → Donation → 
Blood Unit Creation → Testing → Storage → Allocation → Transfer → Transfusion
```

### 4. Inventory Management
- Real-time stock tracking
- Expiration date monitoring
- Component-level tracking (Whole Blood, RBC, Plasma, Platelets)
- Multi-facility inventory balancing

### 5. Request & Transfer System
- Urgent, emergency, routine request handling
- Inter-facility blood transfers
- Temperature monitoring
- Delivery tracking

---

## 🔍 Sample Queries and Use Cases

### Query 1: Find Available O-Negative Blood
```sql
SELECT bu.unit_id, bu.unit_number, f.facility_name, bu.expiration_date
FROM BLOOD_UNITS bu
JOIN FACILITIES f ON bu.facility_id = f.facility_id
WHERE bu.blood_type = 'O' 
  AND bu.rh_factor = '-' 
  AND bu.status = 'Available'
  AND bu.expiration_date > SYSDATE
ORDER BY bu.expiration_date;
```

### Query 2: Top Donors by Contribution
```sql
SELECT donor_id, first_name || ' ' || last_name AS name, 
       blood_type || rh_factor AS blood_group, total_donations
FROM DONORS
WHERE status = 'Active'
ORDER BY total_donations DESC
FETCH FIRST 10 ROWS ONLY;
```

### Query 3: Pending Emergency Requests
```sql
SELECT r.request_id, req.facility_name, r.blood_type || r.rh_factor AS blood_group,
       r.quantity_requested, r.medical_condition, r.required_by_date
FROM REQUESTS r
JOIN FACILITIES req ON r.requesting_facility_id = req.facility_id
WHERE r.urgency_level = 'Emergency' AND r.status = 'Pending'
ORDER BY r.required_by_date;
```

---

## ✅ Validation Results

### Data Integrity Checks
- ✓ All foreign keys valid (0 orphaned records)
- ✓ No NULL values in mandatory fields
- ✓ All constraints properly enforced
- ✓ Date ranges logical (no future birth dates)
- ✓ Numeric ranges valid (age, weight, vitals)

### Business Rule Compliance
- ✓ Minimum donor age: 18 years
- ✓ Minimum donor weight: 45kg (with exceptions documented)
- ✓ Donation intervals: 56 days for whole blood
- ✓ Blood unit expiration dates proper per component type
- ✓ Inventory quantities non-negative

### Test Coverage
- ✓ **Basic queries**: SELECT operations on all tables
- ✓ **Join queries**: 2-5 table joins tested
- ✓ **Aggregations**: COUNT, SUM, AVG, GROUP BY validated
- ✓ **Subqueries**: Correlated and non-correlated tested
- ✓ **Complex scenarios**: Multi-step business processes verified

---

## 📈 Database Statistics

```
Total Tables:        17
Total Records:       5,380+
Total Indexes:       45+
Total Constraints:   60+
Data Volume:         ~50MB
```

---

## 🎓 Learning Objectives Achieved

1. ✅ **DDL Mastery**: Created complex tables with proper Oracle data types
2. ✅ **DML Proficiency**: Inserted large datasets with PL/SQL loops
3. ✅ **Constraint Design**: Implemented business rules via CHECK, UNIQUE, FK
4. ✅ **Index Strategy**: Created indexes for query optimization
5. ✅ **Data Modeling**: Translated ER diagram to physical implementation
6. ✅ **Testing Skills**: Developed comprehensive validation queries
7. ✅ **Real-world Application**: Modeled actual blood bank operations

---

## 🐛 Known Issues & Notes

### Edge Cases Included
- Some donors have NULL last_donation_date (never donated)
- Some blood units marked as expired or discarded
- Some requests cannot be fulfilled (insufficient inventory)
- Some test results are positive/reactive (realistic scenarios)
- Some transfers delayed or cancelled

### Performance Considerations
- Indexes created on frequently queried columns
- COMMIT statements included in loops for large inserts
- ROWNUM used for sample data retrieval

---

## 🔮 Future Enhancements (Optional)

1. **Triggers**: Auto-update inventory on blood unit status change
2. **Views**: Create materialized views for reporting
3. **Procedures**: Stored procedures for common operations
4. **Auditing**: Enhanced audit trails with triggers
5. **Partitioning**: Partition large tables by date
6. **Security**: Implement row-level security

---

## 👥 Team Information

**Project**: Blood Bank Management System  
**Phase**: V - Table Implementation & Data Insertion  
**Database**: Oracle 11g+  
**Date**: December 2024  
**Location**: Rwanda  

---

## 📞 Support

For questions or issues:
1. Review the validation query results
2. Check constraint error messages
3. Verify Oracle version compatibility
4. Ensure sufficient privileges (CREATE TABLE, INSERT, SELECT)

---

## 🏆 Success Criteria

| Requirement | Status | Evidence |
|-------------|--------|----------|
| 17 tables created | ✅ | 01_DDL_CREATE_TABLES.sql |
| 100-500+ rows per main table | ✅ | Row count verification query |
| Realistic test data | ✅ | Rwandan context, varied scenarios |
| PKs and FKs enforced | ✅ | Constraint definitions in DDL |
| Indexes created | ✅ | 45+ indexes on key columns |
| Constraints set | ✅ | CHECK, NOT NULL, UNIQUE, DEFAULT |
| Edge cases included | ✅ | NULLs, expired units, failed tests |
| Data integrity verified | ✅ | 04_VALIDATION_QUERIES.sql |
| Testing queries | ✅ | 25+ queries covering all types |
| Documentation | ✅ | This README |

---

## 📝 Submission Checklist

- [x] DDL script with all CREATE TABLE statements
- [x] DML scripts with INSERT statements (2 parts)
- [x] Validation queries demonstrating functionality
- [x] README with installation instructions
- [x] Row count verification results
- [x] Sample query outputs
- [x] ER diagram reference
- [x] Business rules documented
- [x] Edge cases noted
- [x] Testing results included

---

**End of Phase V Documentation**
