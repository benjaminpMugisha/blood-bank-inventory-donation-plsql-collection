# System Architecture
## Blood Bank Management System

---

## 1. Architecture Overview

### 1.1 System Purpose
The Blood Bank Management System is a comprehensive database solution designed to manage blood donation, inventory, distribution, and compliance operations across Rwanda's blood banking network.

### 1.2 Architectural Pattern
**Pattern:** Three-Tier Architecture  
**Tiers:**
1. **Data Tier:** Oracle 19c Database (PDB)
2. **Business Logic Tier:** PL/SQL (Procedures, Functions, Packages, Triggers)
3. **Presentation Tier:** SQL Developer / Oracle APEX / Custom Web Interface

---

## 2. Database Architecture

### 2.1 Physical Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORACLE CONTAINER DATABASE (CDB)              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  PLUGGABLE DATABASE (PDB)                                  │ │
│  │  Name: mon_12121_eric_bloodbank_db                         │ │
│  │                                                             │ │
│  │  ┌──────────────────┐  ┌──────────────────┐               │ │
│  │  │   TABLESPACES    │  │   MEMORY CONFIG  │               │ │
│  │  │                  │  │                  │               │ │
│  │  │  • BBMS_DATA     │  │  • SGA: 1GB      │               │ │
│  │  │  • BBMS_INDEX    │  │  • PGA: 512MB    │               │ │
│  │  │  • TEMP          │  │  • Shared Pool   │               │ │
│  │  │  • UNDO          │  │  • Buffer Cache  │               │ │
│  │  └──────────────────┘  └──────────────────┘               │ │
│  │                                                             │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │         SCHEMA: BLOODBANK_ADMIN                      │  │ │
│  │  │                                                       │  │ │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │  │ │
│  │  │  │  TABLES  │  │ PROCEDURES│  │ TRIGGERS │          │  │ │
│  │  │  │  (17)    │  │ FUNCTIONS │  │  (6+)    │          │  │ │
│  │  │  │          │  │ PACKAGES  │  │          │          │  │ │
│  │  │  └──────────┘  └──────────┘  └──────────┘          │  │ │
│  │  │                                                       │  │ │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │  │ │
│  │  │  │ INDEXES  │  │ SEQUENCES│  │  VIEWS   │          │  │ │
│  │  │  │  (25+)   │  │   (5)    │  │  (10+)   │          │  │ │
│  │  │  └──────────┘  └──────────┘  └──────────┘          │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                   ARCHIVE LOGS (ENABLED)                    │ │
│  │  • Recovery: ARCHIVELOG mode                                │ │
│  │  • Backup Strategy: Daily incremental + Weekly full         │ │
│  │  • Retention: 30 days                                       │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Tablespace Configuration

| Tablespace | Purpose | Initial Size | Autoextend | Max Size |
|------------|---------|--------------|------------|----------|
| BBMS_DATA | Table data | 500MB | Yes (+100MB) | 10GB |
| BBMS_INDEX | Index storage | 200MB | Yes (+50MB) | 5GB |
| TEMP | Temporary operations | 100MB | Yes (+50MB) | 2GB |
| UNDO | Transaction rollback | 100MB | Yes (+50MB) | 2GB |

### 2.3 Memory Configuration

```sql
-- System Global Area (SGA)
SGA_TARGET = 1GB
SGA_MAX_SIZE = 2GB
SHARED_POOL_SIZE = 300MB
DB_CACHE_SIZE = 500MB
LOG_BUFFER = 10MB

-- Program Global Area (PGA)
PGA_AGGREGATE_TARGET = 512MB
PGA_AGGREGATE_LIMIT = 1GB
```

---

## 3. Data Architecture

### 3.1 Entity Relationship Model

```
┌────────────────────────────────────────────────────────────────────┐
│                     CORE DOMAIN ENTITIES                           │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐         ┌───────────┐         ┌──────────┐          │
│  │  DONORS  │◄───────►│ DONATIONS │◄───────►│FACILITIES│          │
│  │          │ 1    N  │           │ N    1  │          │          │
│  │ donor_id │         │donation_id│         │facility_id│         │
│  └──────────┘         └───────────┘         └──────────┘          │
│       │                    │                                       │
│       │                    │                                       │
│       │ 1                  │ 1                                     │
│       │                    │                                       │
│       │ N                  │ N                                     │
│       ▼                    ▼                                       │
│  ┌──────────┐         ┌───────────┐                               │
│  │ELIGIBILITY│        │BLOOD_UNITS│                               │
│  │  CHECKS  │         │           │                               │
│  │          │         │  unit_id  │                               │
│  └──────────┘         └───────────┘                               │
│                            │                                       │
│                            │ 1                                     │
│                            │                                       │
│                            │ N                                     │
│                            ▼                                       │
│                       ┌───────────┐                               │
│                       │   TEST    │                               │
│                       │  RESULTS  │                               │
│                       │           │                               │
│                       └───────────┘                               │
│                                                                     │
├────────────────────────────────────────────────────────────────────┤
│                   INVENTORY & DISTRIBUTION                         │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐         ┌───────────┐         ┌──────────┐          │
│  │INVENTORY │         │ REQUESTS  │◄───────►│TRANSFERS │          │
│  │          │         │           │         │          │          │
│  │facility_id         │request_id │         │transfer_id│         │
│  │blood_type│         │           │         │          │          │
│  └──────────┘         └───────────┘         └──────────┘          │
│                            │                     │                 │
│                            │ 1                   │ 1               │
│                            │                     │                 │
│                            │ N                   │ N               │
│                            ▼                     ▼                 │
│                       ┌───────────┐         ┌──────────┐          │
│                       │  REQUEST  │         │TRANSFER  │          │
│                       │   ITEMS   │         │  ITEMS   │          │
│                       └───────────┘         └──────────┘          │
│                                                                     │
├────────────────────────────────────────────────────────────────────┤
│                  OPERATIONAL SUPPORT                               │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    │
│  │FACILITY_ │    │EQUIPMENT │    │  PUBLIC  │    │  AUDIT   │    │
│  │  STAFF   │    │          │    │ HOLIDAYS │    │   LOG    │    │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘    │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

### 3.2 Normalization Strategy

**Level:** Third Normal Form (3NF) minimum

**1NF (First Normal Form):**
- Eliminated repeating groups
- Each cell contains atomic values
- Each row is unique (primary key enforced)

**2NF (Second Normal Form):**
- All non-key attributes fully dependent on primary key
- Eliminated partial dependencies
- Example: Separated donor information from donation details

**3NF (Third Normal Form):**
- Eliminated transitive dependencies
- No non-key attribute depends on another non-key attribute
- Example: Facility information in separate table, not in donations

**Denormalization Decisions:**
- INVENTORY table: Aggregated quantities for performance
- Justification: Real-time queries need fast access
- Trade-off: Storage vs. query performance (acceptable)

---

## 4. Security Architecture

### 4.1 Access Control Layers

```
┌───────────────────────────────────────────────────────────┐
│                    ACCESS CONTROL LAYERS                  │
├───────────────────────────────────────────────────────────┤
│                                                            │
│  Layer 1: Network Security                                │
│  ┌────────────────────────────────────────────────────┐   │
│  │ • Firewall rules (Port 1521)                       │   │
│  │ • VPN access for remote users                      │   │
│  │ • IP whitelisting                                  │   │
│  └────────────────────────────────────────────────────┘   │
│                          ▼                                 │
│  Layer 2: Database Authentication                         │
│  ┌────────────────────────────────────────────────────┐   │
│  │ • Username/Password (encrypted)                    │   │
│  │ • Account lockout after 3 failed attempts          │   │
│  │ • Password complexity requirements                 │   │
│  │ • 90-day password expiration                       │   │
│  └────────────────────────────────────────────────────┘   │
│                          ▼                                 │
│  Layer 3: Role-Based Access Control (RBAC)               │
│  ┌────────────────────────────────────────────────────┐   │
│  │ • ADMIN: Full access                               │   │
│  │ • MEDICAL_OFFICER: Read/Write operational data     │   │
│  │ • LAB_TECHNICIAN: Limited write, test results      │   │
│  │ • DONOR_COORDINATOR: Donor management only         │   │
│  │ • AUDITOR: Read-only, audit logs                   │   │
│  └────────────────────────────────────────────────────┘   │
│                          ▼                                 │
│  Layer 4: Object-Level Permissions                        │
│  ┌────────────────────────────────────────────────────┐   │
│  │ • GRANT SELECT, INSERT, UPDATE, DELETE             │   │
│  │ • EXECUTE permissions on procedures                │   │
│  │ • Row-level security (VPD - optional)              │   │
│  └────────────────────────────────────────────────────┘   │
│                          ▼                                 │
│  Layer 5: Trigger-Based Restrictions                      │
│  ┌────────────────────────────────────────────────────┐   │
│  │ • Weekday/weekend enforcement                      │   │
│  │ • Holiday restrictions                             │   │
│  │ • Business hours validation                        │   │
│  │ • Complete audit logging                           │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
└───────────────────────────────────────────────────────────┘
```

### 4.2 Audit Trail Architecture

```sql
-- Comprehensive Audit Logging
┌─────────────────────────────────────────────┐
│          AUDIT LOG SYSTEM                   │
├─────────────────────────────────────────────┤
│                                              │
│  Every DML Operation Logged:                │
│  • Who (username, IP, session)              │
│  • What (operation type, table)             │
│  • When (timestamp with milliseconds)       │
│  • Where (from which application/IP)        │
│  • Why (allowed or denied + reason)         │
│  • What Changed (old vs new values)         │
│                                              │
│  Autonomous Transaction:                    │
│  • Logs always committed                    │
│  • Independent of parent transaction        │
│  • Cannot be rolled back                    │
│  • Guaranteed audit trail                   │
│                                              │
│  Retention: 10 years (regulatory)           │
│  Backup: Daily to secure archive            │
│  Access: Read-only for auditors             │
│                                              │
└─────────────────────────────────────────────┘
```

---

## 5. Integration Architecture

### 5.1 System Integration Points

```
┌──────────────────────────────────────────────────────────────┐
│               BLOOD BANK MANAGEMENT SYSTEM                   │
│                      (Core Database)                         │
└────────────┬──────────────────────────────┬──────────────────┘
             │                              │
             │                              │
   ┌─────────▼────────┐         ┌──────────▼──────────┐
   │   ORACLE APEX    │         │   REST API LAYER    │
   │  (Web Interface) │         │  (Future Integration)│
   │                  │         │                      │
   │ • Dashboards     │         │ • JSON endpoints     │
   │ • Reports        │         │ • Authentication     │
   │ • Forms          │         │ • Rate limiting      │
   └──────────────────┘         └─────────┬────────────┘
                                          │
                              ┌───────────▼───────────┐
                              │  EXTERNAL SYSTEMS     │
                              │                       │
                              │ • Hospital EMR        │
                              │ • National Health DB  │
                              │ • SMS Gateway         │
                              │ • Email Server        │
                              │ • BI Tools (Power BI) │
                              └───────────────────────┘
```

### 5.2 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA FLOW DIAGRAM                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User Input → Validation → Business Logic → Database        │
│     ▼            ▼              ▼                ▼           │
│  Web Form    PL/SQL Proc    Triggers         Tables         │
│              Exception      Audit Log                        │
│              Handling       Constraints                      │
│                                                              │
│  Query Request → Cache Check → Execute → Format → Display   │
│                      │            │         │                │
│                      │            │         │                │
│                   Hit?         Optimize  Transform           │
│                   Yes/No       Query     to JSON/HTML        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Performance Architecture

### 6.1 Indexing Strategy

**Primary Indexes (Automatic):**
- All Primary Key constraints
- All Unique constraints

**Strategic Secondary Indexes:**

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| DONORS | idx_donors_blood_type | blood_type, rh_factor | Inventory matching |
| DONORS | idx_donors_status | status, is_active | Active donor queries |
| DONATIONS | idx_donations_date | donation_date | Time-series queries |
| BLOOD_UNITS | idx_units_status | status, expiration_date | Availability queries |
| BLOOD_UNITS | idx_units_type | blood_type, rh_factor, component_type | Inventory lookups |
| REQUESTS | idx_requests_status | status, urgency_level | Pending requests |
| AUDIT_LOG | idx_audit_time | attempted_at, is_allowed | Audit queries |

### 6.2 Query Optimization

**Strategies Applied:**
1. **Indexed Columns in WHERE clauses**
2. **Avoid SELECT * (select specific columns)**
3. **Use EXISTS instead of IN for subqueries**
4. **Partition large tables (future: by year)**
5. **Materialized views for complex aggregations (future)**
6. **Query result caching for dashboards**

### 6.3 Caching Architecture

```
┌─────────────────────────────────────────────┐
│            CACHING LAYERS                   │
├─────────────────────────────────────────────┤
│                                              │
│  Level 1: Database Buffer Cache             │
│  • Most frequently accessed blocks          │
│  • Size: 500MB (configurable)               │
│  • LRU algorithm                            │
│                                              │
│  Level 2: Query Result Cache                │
│  • Recent query results                     │
│  • TTL: 15 minutes (dashboards)             │
│  • Invalidated on data change               │
│                                              │
│  Level 3: Application Cache (Future)        │
│  • Redis/Memcached                          │
│  • User sessions                            │
│  • Computed KPIs                            │
│                                              │
└─────────────────────────────────────────────┘
```

---

## 7. Backup & Recovery Architecture

### 7.1 Backup Strategy

```
┌──────────────────────────────────────────────────────────┐
│                 BACKUP ARCHITECTURE                       │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  Daily Incremental Backups                               │
│  ├─ Time: 2:00 AM (off-peak)                            │
│  ├─ Duration: ~15 minutes                               │
│  ├─ Storage: On-site NAS                                │
│  └─ Retention: 7 days                                   │
│                                                           │
│  Weekly Full Backups                                     │
│  ├─ Time: Sunday 1:00 AM                                │
│  ├─ Duration: ~2 hours                                  │
│  ├─ Storage: On-site + Off-site cloud                   │
│  └─ Retention: 12 weeks                                 │
│                                                           │
│  Monthly Archive Backups                                 │
│  ├─ Time: 1st of month                                  │
│  ├─ Duration: ~2 hours                                  │
│  ├─ Storage: Off-site cold storage                      │
│  └─ Retention: 7 years (regulatory)                     │
│                                                           │
│  Transaction Logs (Archive Logs)                         │
│  ├─ Mode: ARCHIVELOG                                    │
│  ├─ Frequency: Continuous                               │
│  ├─ Storage: On-site SAN                                │
│  └─ Retention: 30 days                                  │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 7.2 Recovery Objectives

| Metric | Target | Maximum |
|--------|--------|---------|
| RPO (Recovery Point Objective) | 1 hour | 4 hours |
| RTO (Recovery Time Objective) | 2 hours | 8 hours |
| Data Loss Tolerance | < 1 hour | < 4 hours |

### 7.3 Disaster Recovery

**Scenarios:**
1. **Single Table Corruption:** Restore from incremental backup (< 30 min)
2. **Database Crash:** Point-in-time recovery using archive logs (< 2 hours)
3. **Complete Data Center Failure:** Restore from off-site backup (< 8 hours)
4. **Cyber Attack / Ransomware:** Restore from immutable backups (< 8 hours)

---

## 8. Scalability Architecture

### 8.1 Current Capacity

| Resource | Current | Projected (1 Year) | Scaling Strategy |
|----------|---------|-------------------|------------------|
| Donors | 10,000 | 50,000 | Horizontal (partition by region) |
| Donations/Month | 3,000 | 15,000 | Archive old data (> 2 years) |
| Blood Units | 3,000 | 10,000 | Partition by collection date |
| Requests/Day | 50 | 200 | Add application servers |
| Concurrent Users | 20 | 100 | Connection pooling |

### 8.2 Scaling Strategy

**Vertical Scaling (Short-term):**
- Increase RAM: 8GB → 16GB
- Faster storage: HDD → SSD
- More CPU cores

**Horizontal Scaling (Long-term):**
- Database partitioning by region
- Read replicas for reporting
- Oracle RAC (Real Application Clusters)
- Sharding strategy for multi-facility

---

## 9. Technology Stack

### 9.1 Core Technologies

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Database | Oracle Database | 19c Enterprise | Core RDBMS |
| Language | PL/SQL | Oracle 19c | Business logic |
| Management | SQL Developer | Latest | Development/Admin |
| Version Control | Git/GitHub | - | Code versioning |
| BI Tool | Oracle APEX | 23.x | Dashboards (future) |
| Backup | RMAN | Oracle 19c | Backup/Recovery |

### 9.2 Development Tools

- **IDE:** Oracle SQL Developer
- **Modeling:** Oracle SQL Developer Data Modeler
- **Version Control:** Git + GitHub
- **Testing:** Oracle SQL Developer Unit Tests
- **Documentation:** Markdown + Mermaid diagrams
- **CI/CD:** GitHub Actions (future)

---

## 10. Deployment Architecture

### 10.1 Environment Strategy

```
┌────────────────────────────────────────────┐
│         DEPLOYMENT ENVIRONMENTS            │
├────────────────────────────────────────────┤
│                                             │
│  Development (DEV)                         │
│  ├─ Purpose: Active development            │
│  ├─ Data: Synthetic test data              │
│  ├─ Users: Developers                      │
│  └─ Uptime: 8AM-6PM weekdays               │
│                                             │
│  Testing (TEST/QA)                         │
│  ├─ Purpose: Quality assurance             │
│  ├─ Data: Sanitized production copy        │
│  ├─ Users: QA team                         │
│  └─ Uptime: 24/7                           │
│                                             │
│  Staging (STAGE)                           │
│  ├─ Purpose: Pre-production validation     │
│  ├─ Data: Recent production snapshot       │
│  ├─ Users: Stakeholders                    │
│  └─ Uptime: 24/7                           │
│                                             │
│  Production (PROD)                         │
│  ├─ Purpose: Live system                   │
│  ├─ Data: Real operational data            │
│  ├─ Users: All end users                   │
│  └─ Uptime: 99.9% SLA (24/7)               │
│                                             │
└────────────────────────────────────────────┘
```

---

## 11. Monitoring Architecture

### 11.1 Monitoring Components

**Database Monitoring:**
- Oracle Enterprise Manager (OEM)
- Alert logs monitoring
- Performance metrics (AWR reports)
- Tablespace usage
- Session monitoring

**Application Monitoring:**
- Procedure execution times
- Error rates
- Transaction volumes
- User activity

**Infrastructure Monitoring:**
- Server CPU/RAM usage
- Disk I/O
- Network latency
- Backup job status

### 11.2 Alerting Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Tablespace Usage | 75% | 90% |
| CPU Usage | 70% | 85% |
| Response Time | > 2s | > 5s |
| Failed Logins | 5/hour | 10/hour |
| Backup Failure | Any | - |

---

## 12. Future Architecture Enhancements

### 12.1 Planned Improvements (Year 1)

1. **Mobile Application Integration**
   - REST API layer
   - Mobile app for donors
   - SMS notifications

2. **Advanced Analytics**
   - Machine learning for demand forecasting
   - Predictive donor churn analysis
   - Automated inventory optimization

3. **Enhanced BI**
   - Oracle APEX dashboards
   - Power BI integration
   - Real-time streaming analytics

### 12.2 Long-term Vision (Years 2-3)

1. **Microservices Architecture**
   - Decompose monolithic PL/SQL
   - Independent services
   - API gateway

2. **Cloud Migration**
   - Oracle Autonomous Database
   - Cloud-native deployment
   - Global scalability

3. **Blockchain Integration**
   - Immutable audit trail
   - Supply chain transparency
   - Cross-border tracking

---

## Appendices

### A. Network Diagram
See `/documentation/network_diagram.png`

### B. Detailed ER Diagram
See `/documentation/er_diagram_detailed.pdf`

### C. Security Policies
See `/documentation/security_policies.md`

### D. Performance Tuning Guide
See `/documentation/performance_tuning.md`
