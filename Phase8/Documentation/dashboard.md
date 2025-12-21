# Dashboard Specifications & Mockups
## Blood Bank Management System

---

## Dashboard 1: Executive Summary Dashboard

### Overview
**Purpose:** Provide high-level overview of blood bank operations for executive decision-making  
**Users:** Director, Senior Management, Board Members  
**Update Frequency:** Real-time with 5-minute refresh  
**Screen Layout:** 1920x1080 responsive design

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ BLOOD BANK MANAGEMENT SYSTEM - EXECUTIVE DASHBOARD             │
│ Last Updated: 2024-12-21 10:45:32                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐│
│ │ 10,234   │ │  2,847   │ │   143    │ │   95.2%  │ │   12   ││
│ │ Active   │ │Available │ │ Today's  │ │Fulfillment│ │Pending ││
│ │ Donors   │ │  Units   │ │Donations │ │   Rate   │ │Requests││
│ │ ↑ 2.3%   │ │ ⚠ -5.1% │ │ ↑ 8.5%   │ │ ↑ 1.2%   │ │ → 0%   ││
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘ └────────┘│
│                                                                  │
│ ┌───────────────────────────────┐ ┌───────────────────────────┐│
│ │ DONATION TRENDS (12 MONTHS)   │ │ BLOOD TYPE DISTRIBUTION   ││
│ │                               │ │                           ││
│ │  200┤                    ▄▄▄  │ │    O+ ████████████ 35%   ││
│ │  150┤              ▄▄▄▄▄▀   ▀ │ │    A+ ████████ 28%       ││
│ │  100┤        ▄▄▄▄▀▀           │ │    B+ █████ 18%          ││
│ │   50┤  ▄▄▄▄▀                  │ │    O- ███ 10%            ││
│ │    0└──────────────────────── │ │    AB+ ██ 6%             ││
│ │     Jan Feb Mar ... Nov Dec   │ │    A- ▌ 2%               ││
│ │     ─ Actual ─ Target         │ │    B- ▌ 1%               ││
│ └───────────────────────────────┘ │    AB- ▌ <1%             ││
│                                    └───────────────────────────┘│
│ ┌───────────────────────────────┐ ┌───────────────────────────┐│
│ │ TOP 5 FACILITIES              │ │ CRITICAL ALERTS           ││
│ │                               │ │                           ││
│ │ 1. Kigali Central █████ 342   │ │ ⚠ Low Stock: O- (8 units)││
│ │ 2. King Faisal    ████  198   │ │ ⚠ Expiring: 15 units     ││
│ │ 3. Rwanda Military ███  156   │ │ ⚠ Pending Emergency: 2   ││
│ │ 4. Butare Teaching ██   112   │ │ ✓ All licenses valid     ││
│ │ 5. Ruhengeri      █    89     │ │ ✓ Equipment calibrated   ││
│ │                               │ │                           ││
│ └───────────────────────────────┘ └───────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Component Details

#### 1. KPI Cards (Top Row)
**Active Donors Card:**
- Primary Value: 10,234 (large, bold)
- Label: "Active Donors"
- Trend: ↑ 2.3% (green, vs. last month)
- Color: Green border if ≥ 10,000, Yellow if 8,000-9,999, Red if < 8,000

**Available Units Card:**
- Primary Value: 2,847
- Label: "Available Units"
- Trend: ⚠ -5.1% (yellow warning icon)
- Color: Yellow border (warning threshold)
- Click Action: Navigate to Inventory Dashboard

**Today's Donations Card:**
- Primary Value: 143
- Label: "Today's Donations"
- Trend: ↑ 8.5% (green, vs. yesterday)
- Progress Bar: 143/150 (daily target)

**Fulfillment Rate Card:**
- Primary Value: 95.2%
- Label: "Fulfillment Rate"
- Trend: ↑ 1.2%
- Target Line: 95% threshold marked

**Pending Requests Card:**
- Primary Value: 12
- Label: "Pending Requests"
- Aging Indicator: 2 urgent (> 4 hours)
- Click Action: View request details

#### 2. Donation Trends Chart (Left Middle)
**Chart Type:** Line chart with area fill  
**Time Range:** Last 12 months  
**Data Series:**
- Actual Donations (blue line, area fill)
- Target Line (dashed red)
- 3-Month Moving Average (dotted green)

**Features:**
- Hover tooltips with exact values
- Click to drill down to daily view
- Export to CSV button

#### 3. Blood Type Distribution (Right Middle)
**Chart Type:** Horizontal bar chart  
**Data:** Percentage of available units by blood type  
**Color Coding:**
- Green: Stock level good
- Yellow: Stock level low
- Red: Stock level critical

**Interactive:**
- Click bar to see component breakdown
- Hover for exact count and percentage

#### 4. Top 5 Facilities (Left Bottom)
**Chart Type:** Horizontal bar chart with values  
**Metric:** Total donations this month  
**Features:**
- Facility name
- Visual bar (proportional)
- Exact count
- Click to view facility details

#### 5. Critical Alerts Panel (Right Bottom)
**Alert Types:**
- ⚠ Warning (yellow icon)
- 🔴 Critical (red icon)
- ✓ All Clear (green icon)

**Displayed Information:**
- Alert type and icon
- Description
- Count (if applicable)
- Time stamp
- Action button (if required)

---

## Dashboard 2: Audit & Compliance Dashboard

### Overview
**Purpose:** Monitor security, access control, and regulatory compliance  
**Users:** Compliance Officer, System Admin, Auditors  
**Update Frequency:** Real-time  
**Screen Layout:** 1920x1080

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ AUDIT & COMPLIANCE DASHBOARD                                    │
│ Real-Time Monitoring | Last Event: 2 seconds ago               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│ │   100%   │ │   287    │ │    45    │ │   100%   │           │
│ │  Audit   │ │Operations │ │ Denied   │ │Compliance│           │
│ │ Complete │ │  Today   │ │Operations │ │   Rate   │           │
│ │ ✓        │ │ ↑ 12%    │ │ ⚠ +8     │ │ ✓        │           │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
│                                                                  │
│ ┌───────────────────────────────────────────────────────────┐  │
│ │ OPERATIONS BY DAY OF WEEK (LAST 30 DAYS)                  │  │
│ │                                                            │  │
│ │      │ Allowed  Denied                                    │  │
│ │ Mon  │ ░░░░░    ████████████ 42 denied                   │  │
│ │ Tue  │ ░░░      █████████ 35 denied                      │  │
│ │ Wed  │ ░░       ███████ 28 denied                        │  │
│ │ Thu  │ ░░░      ████████ 32 denied                       │  │
│ │ Fri  │ ░░       ██████ 24 denied                         │  │
│ │ Sat  │ ████████ ░░ 2 denied (attempts)                   │  │
│ │ Sun  │ █████    ░░ 3 denied (attempts)                   │  │
│ └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│ ┌────────────────────────────┐ ┌────────────────────────────┐ │
│ │ RECENT VIOLATIONS          │ │ USER ACTIVITY SUMMARY      │ │
│ │                            │ │                            │ │
│ │ 10:43 AM - INSERT DENIED   │ │ User: admin_001            │ │
│ │ Table: DONORS              │ │ Operations: 48 (today)     │ │
│ │ Reason: Weekday restriction│ │ Denied: 0                  │ │
│ │ User: jdoe                 │ │ Last Activity: 2 min ago   │ │
│ │ ─────────────────────────  │ │ ───────────────────────    │ │
│ │ 09:15 AM - UPDATE DENIED   │ │ User: lab_tech_05          │ │
│ │ Table: BLOOD_UNITS         │ │ Operations: 23 (today)     │ │
│ │ Reason: Weekday restriction│ │ Denied: 3                  │ │
│ │ User: msmith               │ │ Last Activity: 15 min ago  │ │
│ │ ─────────────────────────  │ │ ───────────────────────    │ │
│ │ 08:02 AM - DELETE DENIED   │ │ User: nurse_12             │ │
│ │ Table: DONATIONS           │ │ Operations: 12 (today)     │ │
│ │ Reason: Weekday restriction│ │ Denied: 1                  │ │
│ │ [View All Violations →]    │ │ [View All Users →]         │ │
│ └────────────────────────────┘ └────────────────────────────┘ │
│                                                                  │
│ ┌───────────────────────────────────────────────────────────┐  │
│ │ COMPLIANCE CHECKLIST                                      │  │
│ │ ✓ All facilities licensed (15/15)                         │  │
│ │ ✓ All equipment calibrated (42/42)                        │  │
│ │ ✓ Audit trail 100% complete                               │  │
│ │ ✓ Restriction rules enforced                              │  │
│ │ ⚠ 2 licenses expiring in 30 days (Action required)        │  │
│ └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Component Details

#### 1. Compliance KPI Cards
Real-time metrics with status indicators

#### 2. Operations by Day of Week
**Chart Type:** Stacked horizontal bar chart  
**Purpose:** Visualize restriction enforcement  
**Expected Pattern:** High denials on weekdays, low on weekends

#### 3. Recent Violations Panel
**Update:** Real-time stream  
**Display:** Last 10 violations  
**Information:** Timestamp, operation, table, reason, user

#### 4. User Activity Summary
**Purpose:** Monitor individual user behavior  
**Metrics:** Operations today, denial count, last activity  
**Alert:** Flag users with high denial rates

#### 5. Compliance Checklist
**Items:** Critical compliance checkpoints  
**Status:** ✓ Compliant, ⚠ Action needed, 🔴 Critical

---

## Dashboard 3: Inventory Management Dashboard

### Overview
**Purpose:** Real-time blood inventory monitoring and management  
**Users:** Medical Officers, Lab Technicians, Facility Managers  
**Update Frequency:** Every 15 minutes  
**Screen Layout:** 1920x1080

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ INVENTORY MANAGEMENT DASHBOARD                                  │
│ Last Updated: 10:45 AM | Next Refresh: 11:00 AM                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ BLOOD TYPE INVENTORY STATUS                                     │
│ ┌────────┬────────┬────────┬────────┬────────┬────────┬───────┐│
│ │   A+   │   A-   │   B+   │   B-   │  AB+   │  AB-   │  O+  ││
│ │  342   │   45   │  198   │   28   │   78   │   12   │  456 ││
│ │ 🟢GOOD │ 🟡LOW  │ 🟢GOOD │ 🟡LOW  │ 🟢GOOD │ 🔴CRIT │ 🟢GOOD││
│ │ Avail  │ Avail  │ Avail  │ Avail  │ Avail  │ Avail  │ Avail││
│ │ 23 Res │  3 Res │ 12 Res │  2 Res │  5 Res │  1 Res │ 34 Res│
│ │ 2 Exp  │  1 Exp │  3 Exp │  0 Exp │  1 Exp │  0 Exp │ 4 Exp││
│ └────────┴────────┴────────┴────────┴────────┴────────┴───────┘│
│ │   O-   │                                                      │
│ │   89   │                                                      │
│ │ 🟡LOW  │                                                      │
│ │ Avail  │                                                      │
│ │  6 Res │                                                      │
│ │  1 Exp │                                                      │
│ └────────┘                                                      │
│                                                                  │
│ ┌────────────────────────────┐ ┌─────────────────────────────┐ │
│ │ COMPONENT DISTRIBUTION     │ │ EXPIRING UNITS (7 DAYS)     │ │
│ │                            │ │                             │ │
│ │ Whole Blood  ████████ 42%  │ │ Today      ▓▓ 2 units       │ │
│ │ Red Cells    ███████  35%  │ │ Tomorrow   ▓▓▓ 3 units      │ │
│ │ Plasma       ████     18%  │ │ Day +2     ▓ 1 unit         │ │
│ │ Platelets    ██       3%   │ │ Day +3     ▓▓▓▓ 4 units     │ │
│ │ Cryoprecip   ▌        2%   │ │ Day +4     ▓▓ 2 units       │ │
│ │                            │ │ Day +5     ▓ 1 unit         │ │
│ │ [View Details →]           │ │ Day +6     ▓▓▓ 3 units      │ │
│ └────────────────────────────┘ │ Total: 16 units            │ │
│                                 │ [Take Action →]            │ │
│ ┌────────────────────────────┐ └─────────────────────────────┘ │
│ │ FACILITY STOCK LEVELS      │ ┌─────────────────────────────┐ │
│ │                            │ │ DEMAND FORECAST (30 DAYS)   │ │
│ │ Kigali Central   ████ 842  │ │                             │ │
│ │ King Faisal      ███  456  │ │  500┤         ▄▄▄           │ │
│ │ Rwanda Military  ██   298  │ │  400┤    ▄▄▄▀   ▀▄▄▄        │ │
│ │ Butare Teaching  ██   234  │ │  300┤ ▄▄▀           ▀▄▄     │ │
│ │ Ruhengeri        █    156  │ │  200┤▀                 ▀▄   │ │
│ │ [View All →]               │ │    0└───────────────────────│ │
│ └────────────────────────────┘ │  ─ Forecast ─ Current Stock│ │
│                                 └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Component Details

#### 1. Blood Type Cards (8 cards)
**Status Indicators:**
- 🟢 GOOD: > 50 units
- 🟡 LOW: 20-50 units
- 🔴 CRITICAL: < 20 units

**Information Displayed:**
- Blood type (large)
- Available count (large number)
- Status (colored icon + text)
- Reserved count
- Expiring soon count
- Click: Drill down to unit details

#### 2. Component Distribution
**Chart Type:** Horizontal bar chart with percentages  
**Purpose:** Show mix of blood components  
**Action:** Adjust collection strategy based on demand

#### 3. Expiring Units Calendar
**View:** Next 7 days with unit counts  
**Color:** Gradient from yellow (later) to red (urgent)  
**Action Button:** "Take Action" - opens unit management

#### 4. Facility Stock Levels
**Chart Type:** Horizontal bar chart  
**Sorted By:** Total inventory (descending)  
**Alert:** Highlight facilities with low stock

#### 5. Demand Forecast
**Chart Type:** Line chart with forecast  
**Data:** Historical usage + projected demand  
**Purpose:** Proactive inventory management

---

## Dashboard 4: Donor Engagement Dashboard

### Overview
**Purpose:** Track donor behavior, retention, and engagement  
**Users:** Donor Coordinators, Marketing Team  
**Update Frequency:** Daily at midnight  
**Screen Layout:** 1920x1080

### Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ DONOR ENGAGEMENT DASHBOARD                                      │
│ Updated: Daily | Data through: 2024-12-21                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ ┌────────────────────┐ ┌────────────────────┐ ┌───────────────┐│
│ │ DONOR SEGMENTS     │ │ RETENTION FUNNEL   │ │ THIS MONTH    ││
│ │                    │ │                    │ │               ││
│ │ Hero (10+ donates) │ │ 10,234 Registered  │ │ 523 New       ││
│ │ ██████ 12% (1,228) │ │   ↓ 85%           │ │ 412 1st Time  ││
│ │                    │ │ 8,699 First-time   │ │ 298 Repeat    ││
│ │ Regular (6-10)     │ │   ↓ 70%           │ │               ││
│ │ █████ 10% (1,023)  │ │ 6,089 Repeat (2+)  │ │ Retention:    ││
│ │                    │ │   ↓ 65%           │ │ 72.3% ↑       ││
│ │ Moderate (3-5)     │ │ 3,958 Regular (6+) │ └───────────────┘│
│ │ ████████ 18% (1,842││                    │                   │
│ │                    │ └────────────────────┘                   │
│ │ Occasional (2)     │                                          │
│ │ ██████ 15% (1,535) │ ┌─────────────────────────────────────┐ │
│ │                    │ │ TOP 20 HERO DONORS                  │ │
│ │ First-time (1)     │ │                                     │ │
│ │ ████████ 18% (1,842││ Rank | Name        | Type | Donations││
│ │                    │ │  1.  Jean Uwimana   O+     24       ││
│ │ At Risk (inactive) │ │  2.  Marie Mugisha  A+     22       ││
│ │ ████████ 27% (2,764││  3.  Claude Nizey   B+     21       ││
│ └────────────────────┘ │  4.  Diana Habimana AB+    20       ││
│                         │  5.  Patrick Munyi  O+     19       ││
│ ┌────────────────────┐ │  ... [View All Hero Donors →]       ││
│ │ AGE DISTRIBUTION   │ └─────────────────────────────────────┘ │
│ │                    │                                          │
│ │ 500┤      ▄▄▄       │ ┌─────────────────────────────────────┐│
│ │ 400┤    ▄▀   ▀▄     │ │ ENGAGEMENT ACTIONS                  ││
│ │ 300┤  ▄▀       ▀▄   │ │                                     ││
│ │ 200┤▄▀            ▀▄ │ │ 🎯 2,764 donors need reactivation   ││
│ │   0└────────────────││ │    → Send reminder campaigns        ││
│ │    18-25 ... 56+   │ │                                     ││
│ └────────────────────┘ │ │ 📧 1,842 eligible for 2nd donation  ││
│                         │ │    → Schedule follow-up calls       ││
│                         │ │                                     ││
│                         │ │ 🏆 1,228 hero donors to recognize   ││
│                         │ │    → Send thank-you certificates    ││
│                         │ └─────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## Dashboard 5: Performance Dashboard

### Overview
**Purpose:** Monitor operational efficiency and resource utilization  
**Users:** Facility Managers, Operations Team  
**Update Frequency:** Hourly  
**Screen Layout:** 1920x1080

*[Similar detailed layout would be provided]*

---

## Screenshot Guidelines

#### 6. BI Query Results
**Tool:** SQL Developer  
**Steps:**
1. Run KPI query (from bi_analytics.sql)
2. Screenshot results showing:
   - Query header
   - Result set with metrics
   - Charts (if using Oracle APEX)

---

## Creating Dashboard Mockups

### Option 1: Using PowerPoint
1. Create slides with dashboard layouts
2. Use shapes for cards/charts
3. Add sample data
4. Export as images

### Option 2: Using draw.io
1. Go to https://app.diagrams.net/
2. Use templates for dashboards
3. Add components
4. Export as PNG

### Option 3: Using Figma (Free)
1. Sign up at https://figma.com
2. Create dashboard frames
3. Use plugins for charts
4. Export high-res images

---

## Next Steps

1. ✅ Run all test scripts
2. ✅ Capture required screenshots
3. ✅ Create dashboard mockups
4. ✅ Organize in folders
5. ✅ Reference in presentation

All dashboard SQL queries are in `/queries/dashboard_queries.sql`
