# Fluent Lead Intelligence Dashboard - Setup Guide

This guide will help you create a comprehensive dashboard for monitoring and acting on your lead generation data.

---

## 🎯 Dashboard Overview

**Name**: Fluent Lead Intelligence Dashboard  
**Purpose**: Centralized view of lead generation performance, hot leads, and conversation insights  
**Audience**: Sales Managers, Sales Reps, Marketing Team  

---

## 📋 Prerequisites

✅ Complete the reports setup (see LEAD_GENERATION_REPORTS_GUIDE.md)  
✅ Have all 6 reports created and saved in "Fluent Analytics" folder  
✅ Have "Dashboard Builder" permissions  

---

## 🛠️ Step-by-Step Dashboard Creation

### Step 1: Create New Dashboard

1. Navigate to **Dashboards** tab
2. Click **New Dashboard**
3. Choose **Start from Blank**
4. Click **Create**

### Step 2: Dashboard Settings

```
Dashboard Name: Fluent Lead Intelligence Dashboard
Dashboard Unique Name: Fluent_Lead_Intelligence_Dashboard
Folder: Fluent Analytics
Description: Real-time lead intelligence from Fluent Smart Shop conversations
```

### Step 3: Select Layout

- Choose **3-column layout**
- This allows for optimal component arrangement

---

## 🔧 How to Add Widgets to Dashboard

### Adding a Widget (Step-by-Step):

1. **Click "+ Widget" Button**
   - Located at the top of the dashboard
   - A popup titled "Add Widget" will appear

2. **Select Report**
   - In the "Report" field, search for or select your report
   - Example: "All Fluent Leads by Intent Level"
   - The report name will appear in the search box

3. **Configure Display Type**
   - Click the checkbox "Use chart settings from report" if you want to use the report's existing chart settings
   - **Display As**: Choose your visualization type from the icons:
     - 📋 **Table** (list icon)
     - 📊 **Vertical Bar Chart** (bar icon)
     - 🔵 **Donut/Pie Chart** (donut icon)
     - 📈 **Line Chart** (line icon)
     - 🔢 **Metric** (number "123" icon - highlighted in blue in your screenshot)
     - 🌡️ **Gauge Chart** (gauge icon)
     - 📉 **Funnel Chart** (funnel icon)
     - 🔶 **Horizontal Bar** (horizontal bar icon)
     - ⚡ **Lightning Table** (table grid icon)

4. **Configure Measure**
   - In the "Measure" field, select what to display
   - Example: "Total leads per rating"
   - This determines what metric the widget shows

5. **Configure Display Units**
   - Select how numbers should be formatted:
     - **Shortened Number** (e.g., 1K, 1M)
     - **Full Number** (e.g., 1,000)
     - **Percentage** (e.g., 50%)
   - Check "Show Range" if you want to display value ranges

6. **Set Ranges (Optional)**
   - If you want color-coded ranges, configure the threshold values:
     - **First box**: Low threshold (e.g., 33) - shown in Red
     - **Second box**: Mid threshold (e.g., 67) - shown in Orange/Yellow
     - **Third box**: High threshold (e.g., 100+) - shown in Green
   - You can drag the color sliders to adjust thresholds visually

7. **Configure Decimal Places**
   - Select "Automatic" or specify the number of decimal places
   - Recommended: "Automatic" for whole numbers

8. **Add Custom Link (Optional)**
   - Add a URL if you want the widget to link to an external page
   - Leave blank to use the default "View Report" link

9. **Set Title and Subtitle**
   - **Title**: Main heading for your widget
     - Example: "Total Leads Generated"
   - **Subtitle**: Description or context
     - Example: "All-time from Fluent Smart Shop"

10. **Add Footer (Optional)**
    - Add any additional context or notes
    - Leave blank if not needed

11. **Choose Widget Theme**
    - Select "Light (Dashboard default)" or "Dark"
    - Recommended: Light for consistency

12. **Preview and Confirm**
    - The right panel shows a live preview of your widget
    - Shows the current value (e.g., "2" in your screenshot)
    - Shows "View Report" link at the bottom
    - Click **"Add"** button to add the widget to dashboard
    - Click **"Cancel"** to discard

---

## 📊 Dashboard Components Layout

### **Column 1 (Left) - High Priority Alerts**

#### Component 1: Hot Leads Requiring Action

**What It Shows**: A table of high-priority leads that need immediate sales contact

**Step-by-Step Setup**:

1. **Click "+ Widget"** button at the top of the dashboard

2. **Select Report**:
   - In the "Report" field, type and select: **"Hot Leads - Fluent Smart Shop"**

3. **Configure Display Type**:
   - ☐ Leave "Use chart settings from report" **unchecked**
   - **Display As**: Click the **📋 Table icon** (list icon, first one)

4. **Configure Table Settings**:
   - **Display**: Select **"Show Details"** (this shows all rows with full data)
   - **Max Rows**: Enter **10**
   - **Sorting**: 
     - Group by: None (leave blank)
     - Sort by: **Created Date**
     - Order: **Descending** (Most Recent First)

5. **Set Title and Subtitle**:
   - **Title**: `🔥 Hot Leads - Action Required`
   - **Subtitle**: `Leads with score 80+ requiring immediate contact`

6. **Widget Theme**:
   - Select **"Light (Dashboard default)"**

7. **Preview**: 
   - Check the preview panel on the right - you should see a table with your hot leads

8. **Click "Add"** to add the widget to your dashboard

9. **Position the Widget**:
   - Drag the widget to **Column 1 (Left side)** of your dashboard
   - Resize to **6 rows tall** by dragging the bottom edge

10. **Apply Conditional Formatting** (After adding to dashboard):
    - Click on the widget to select it
    - Click the **⚙️ Edit** button (gear icon)
    - Navigate to **Formatting** tab
    - Click **"Add Conditional Highlighting"**
    - Set rule: 
      - **Column**: Rating
      - **Operator**: Equals
      - **Value**: Hot
      - **Background Color**: Red (#D32F2F)
    - Click **Done**

**Expected Result**: A red-highlighted table showing your hottest leads at the top of the left column.

#### Component 2: Lead Conversion Funnel

**What It Shows**: Visual funnel showing how leads progress through sales stages

**Step-by-Step Setup**:

1. **Click "+ Widget"** button

2. **Select Report**:
   - Type and select: **"Fluent Lead Conversion Funnel"**

3. **Configure Display Type**:
   - ☐ Leave "Use chart settings from report" **unchecked**
   - **Display As**: Click the **📉 Funnel Chart icon**

4. **Configure Funnel Settings**:
   - **Group by**: Lead Status (or Stage)
   - **Measure**: Count of Leads
   - **Show values on chart**: ☑️ Check this box
   - **Show percentages**: ☑️ Check this box

5. **Set Title and Subtitle**:
   - **Title**: `📊 Lead Conversion Funnel`
   - **Subtitle**: `Track lead progression through sales stages`

6. **Widget Theme**: Select **"Light (Dashboard default)"**

7. **Click "Add"**

8. **Position the Widget**:
   - Drag to **Column 1 (Left side)**, below Component 1
   - Resize to **4 rows tall**

**Expected Result**: A funnel chart showing lead conversion from top (most leads) to bottom (converted leads).

---

### **Column 2 (Center) - Performance Metrics**

#### Component 3: Leads by Intent Level

**What It Shows**: Distribution of leads by quality rating (Hot/Warm/Cold)

**Step-by-Step Setup**:

1. **Click "+ Widget"** button

2. **Select Report**:
   - Type and select: **"All Fluent Leads by Intent Level"**

3. **Configure Display Type**:
   - ☐ Leave "Use chart settings from report" **unchecked**
   - **Display As**: Click the **🔵 Donut Chart icon** (pie/donut icon)

4. **Configure Chart Settings**:
   - **Group by**: Rating
   - **Measure**: Record Count
   - **Show legend**: ☑️ Check this box
   - **Show values**: ☑️ Check this box

5. **Set Colors** (Optional - if available in widget settings):
   - Hot: Red (#D32F2F)
   - Warm: Orange (#F57C00)
   - Cold: Blue (#1976D2)
   - *Note: If color settings aren't available in widget config, they may inherit from report settings*

6. **Set Title and Subtitle**:
   - **Title**: `🎯 Leads by Intent Level`
   - **Subtitle**: `Distribution of lead quality`

7. **Widget Theme**: Select **"Light (Dashboard default)"**

8. **Click "Add"**

9. **Position the Widget**:
   - Drag to **Column 2 (Center)** at the top
   - Resize to **4 rows tall**

**Expected Result**: A colorful donut chart showing the proportion of Hot (red), Warm (orange), and Cold (blue) leads.

#### Component 4: Weekly Lead Generation Trend

**What It Shows**: Daily trend of new leads created over the past week

**Step-by-Step Setup**:

1. **Click "+ Widget"** button

2. **Select Report**:
   - Type and select: **"Weekly Lead Generation - Fluent"**

3. **Configure Display Type**:
   - ☐ Leave "Use chart settings from report" **unchecked**
   - **Display As**: Click the **📊 Vertical Bar Chart icon** (stacked column)

4. **Configure Chart Settings**:
   - **X-Axis (Grouping)**: Created Date
   - **Date Grouping**: Calendar Day
   - **Y-Axis (Measure)**: Record Count
   - **Stacked by**: Rating
   - **Show cumulative**: ☑️ Check if you want running totals

5. **Set Title and Subtitle**:
   - **Title**: `📈 Weekly Lead Generation Trend`
   - **Subtitle**: `New leads generated this week`

6. **Widget Theme**: Select **"Light (Dashboard default)"**

7. **Click "Add"**

8. **Position the Widget**:
   - Drag to **Column 2 (Center)**, below Component 3
   - Resize to **4 rows tall**

**Expected Result**: A stacked bar chart showing daily lead volume with color-coded ratings.

---

#### Component 5: Total Leads Summary

**What It Shows**: Big number metric showing total lead count (This is the widget type you saw in your screenshot!)

**Step-by-Step Setup**:

1. **Click "+ Widget"** button

2. **Select Report**:
   - Type and select: **"All Fluent Leads by Intent Level"**

3. **Configure Display Type**:
   - ☐ Leave "Use chart settings from report" **unchecked**
   - **Display As**: Click the **🔢 Metric icon** (the "123" icon - exactly like your screenshot!)

4. **Configure Metric Settings**:
   - **Measure**: Select **"Total leads per rating"** or **"Record Count"**
   - **Display Units**: Select **"Shortened Number"** (formats as 1K, 1M, etc.)
   - **Decimal Places**: Select **"Automatic"**

5. **Set Ranges** (Optional - for color-coded backgrounds):
   - Leave blank for now (or set thresholds if desired)
   - **Show Range**: ☐ Leave unchecked

6. **Set Title and Subtitle**:
   - **Title**: `💼 Total Leads Generated`
   - **Subtitle**: `All-time from Fluent Smart Shop`

7. **Widget Theme**: Select **"Light (Dashboard default)"**

8. **Preview**: 
   - You should see a large number (like "2" in your screenshot) in the preview panel

9. **Click "Add"**

10. **Position the Widget**:
    - Drag to **Column 2 (Center)**, below Component 4
    - Resize to **2 rows tall** (compact metric display)

**Expected Result**: A large, prominent number showing your total lead count - exactly like your screenshot!

---

### **Column 3 (Right) - Team Performance**

#### Component 6: Leads by Owner

**What It Shows**: Distribution of leads across your sales team

**Step-by-Step Setup**:

1. **Click "+ Widget"** button

2. **Select Report**:
   - Type and select: **"All Fluent Leads by Intent Level"**

3. **Configure Display Type**:
   - ☐ Leave "Use chart settings from report" **unchecked**
   - **Display As**: Click the **🔶 Horizontal Bar Chart icon**

4. **Configure Chart Settings**:
   - **Group by**: Lead Owner: Full Name
   - **Measure**: Record Count
   - **Show values**: ☑️ Check this box
   - **Max groups**: Enter **10** (shows top 10 owners)
   - **Sort by**: Values
   - **Sort order**: Descending (highest to lowest)

5. **Set Title and Subtitle**:
   - **Title**: `👥 Leads by Owner`
   - **Subtitle**: `Lead distribution across sales team`

6. **Widget Theme**: Select **"Light (Dashboard default)"**

7. **Click "Add"**

8. **Position the Widget**:
   - Drag to **Column 3 (Right side)** at the top
   - Resize to **5 rows tall**

**Expected Result**: Horizontal bars showing which sales reps have the most leads assigned to them.

---

#### Component 7: Lead Response Time

**What It Shows**: How quickly each sales rep responds to new leads

**Step-by-Step Setup**:

1. **Click "+ Widget"** button

2. **Select Report**:
   - Type and select: **"Lead Response Time - Fluent"**
   - *Note: This requires the Lead Age report with response tracking*

3. **Configure Display Type**:
   - ☐ Leave "Use chart settings from report" **unchecked**
   - **Display As**: Click the **📋 Table icon**

4. **Configure Table Settings**:
   - **Display**: Select **"Summary Only"** (shows aggregated data, not individual rows)
   - **Columns to Show**: 
     - Lead Owner: Full Name
     - Average Response Time (calculated field)
   - **Max Rows**: Enter **8**
   - **Sort by**: Average Response Time
   - **Sort order**: Ascending (Fastest First)

5. **Set Title and Subtitle**:
   - **Title**: `⚡ Lead Response Time`
   - **Subtitle**: `Average time to first contact`

6. **Widget Theme**: Select **"Light (Dashboard default)"**

7. **Click "Add"**

8. **Position the Widget**:
   - Drag to **Column 3 (Right side)**, below Component 6
   - Resize to **5 rows tall**

**Expected Result**: A table showing which sales reps respond fastest to new leads, helping you identify top performers.

**Troubleshooting**: If you don't have response time data yet:
- Ensure your sales team is logging activities on leads
- The "Last Activity Date" field on Lead tracks first contact
- Response time = (Last Activity Date - Created Date)

---

## 📋 Quick Reference: All 7 Components Summary

| # | Component Name | Type | Report Source | Column | Rows | Key Purpose |
|---|---------------|------|---------------|---------|------|-------------|
| 1 | Hot Leads - Action Required | 📋 Table | Hot Leads - Fluent Smart Shop | Left (1) | 6 | Shows high-priority leads needing immediate contact |
| 2 | Lead Conversion Funnel | 📉 Funnel | Fluent Lead Conversion Funnel | Left (1) | 4 | Tracks lead progression through sales stages |
| 3 | Leads by Intent Level | 🔵 Donut | All Fluent Leads by Intent Level | Center (2) | 4 | Distribution of lead quality (Hot/Warm/Cold) |
| 4 | Weekly Lead Generation Trend | 📊 Bar Chart | Weekly Lead Generation - Fluent | Center (2) | 4 | Daily trend of new leads over the past week |
| 5 | Total Leads Generated | 🔢 Metric | All Fluent Leads by Intent Level | Center (2) | 2 | Big number showing total lead count |
| 6 | Leads by Owner | 🔶 Horizontal Bar | All Fluent Leads by Intent Level | Right (3) | 5 | Distribution across sales team |
| 7 | Lead Response Time | 📋 Table | Lead Response Time - Fluent | Right (3) | 5 | Average time to first contact by rep |

### Dashboard Layout Visual:

```
┌─────────────────┬─────────────────┬─────────────────┐
│   COLUMN 1      │   COLUMN 2      │   COLUMN 3      │
│   (Left)        │   (Center)      │   (Right)       │
├─────────────────┼─────────────────┼─────────────────┤
│                 │                 │                 │
│  [1] Hot Leads  │  [3] Intent     │  [6] Leads by   │
│      Table      │      Donut      │      Owner      │
│   (6 rows)      │   (4 rows)      │   (5 rows)      │
│                 │                 │                 │
│─────────────────│─────────────────│─────────────────│
│                 │                 │                 │
│  [2] Funnel     │  [4] Weekly     │  [7] Response   │
│      Chart      │      Trend      │      Time       │
│   (4 rows)      │   (4 rows)      │   (5 rows)      │
│                 │                 │                 │
│                 │─────────────────│                 │
│                 │                 │                 │
│                 │  [5] Total      │                 │
│                 │      Metric     │                 │
│                 │   (2 rows)      │                 │
│                 │                 │                 │
└─────────────────┴─────────────────┴─────────────────┘
```

### Color Code Reference:
- 🔴 **Red** = Hot Leads (Urgent - Contact Now!)
- 🟧 **Orange** = Warm Leads (Contact Today)
- 🔵 **Blue** = Cold Leads (Follow Up Soon)

---

## 🎨 Dashboard Formatting & Style

### Theme Settings:
```
Background Color: #F5F5F5 (Light Gray)
Component Background: #FFFFFF (White)
Border Color: #E0E0E0 (Gray)
Border Radius: 8px
Shadow: Subtle
```

### Component Spacing:
- **Padding**: 16px between components
- **Margin**: 12px around dashboard edges

### Typography:
- **Title Font**: Bold, 16px
- **Subtitle Font**: Regular, 12px, #666666
- **Metric Font**: Bold, 32px

---

## 🔔 Dashboard Filters (Optional)

Add these filters at the top of the dashboard for dynamic filtering:

### Filter 1: Date Range
```
Field: Lead.CreatedDate
Type: Date Range
Options: Today, This Week, This Month, Last 30 Days, Custom
Default: This Month
```

### Filter 2: Lead Owner
```
Field: Lead.Owner
Type: Multi-select Picklist
Options: All Users (default), or specific users
Default: All
```

### Filter 3: Rating
```
Field: Lead.Rating
Type: Multi-select Picklist
Options: Hot, Warm, Cold
Default: All selected
```

---

## 🚀 Advanced Features

### 1. Scheduled Refresh
```
Settings → Schedule Refresh
Frequency: Every morning at 7:00 AM
Timezone: Your local timezone
Recipients: Sales team email list
```

### 2. Dashboard Subscriptions
```
Subscribe users to receive daily/weekly dashboard snapshots:
- Sales Manager: Daily at 8:00 AM
- Sales Reps: Weekly on Monday
- Marketing Team: Weekly on Monday
```

### 3. Mobile Optimization
```
Enable mobile view for on-the-go access:
☑ Enable mobile dashboard
☑ Optimize components for mobile
☑ Show top 3 components only on mobile
```

---

## 📱 Mobile Dashboard Layout

For mobile users, prioritize these components:

1. **Hot Leads Requiring Action** (Top priority)
2. **Total Leads Summary** (Quick metric)
3. **Leads by Intent Level** (Overview)

---

## 🎯 Dashboard Best Practices

### For Sales Managers:
1. **Start Your Day**: Review Hot Leads component
2. **Check Team Performance**: Monitor Leads by Owner and Response Time
3. **Identify Trends**: Look at Weekly Generation Trend

### For Sales Reps:
1. **Filter by Your Name**: Use Lead Owner filter
2. **Prioritize Hot Leads**: Focus on red-highlighted leads
3. **Review Conversation Notes**: Click through to see Fluent intelligence

### For Marketing Team:
1. **Track Performance**: Monitor Total Leads and Weekly Trends
2. **Analyze Product Interest**: Use Product Interest report
3. **Optimize Campaigns**: Identify which videos drive most leads

---

## 🔧 Maintenance & Updates

### Weekly Tasks:
- [ ] Review dashboard accuracy
- [ ] Check for any broken components
- [ ] Update filters as needed

### Monthly Tasks:
- [ ] Archive old dashboard versions
- [ ] Add new components based on feedback
- [ ] Update color schemes if needed

---

## 💡 Sample Dashboard Queries

### For Developer Console (Anonymous Apex):

#### Check Total Leads Generated:
```apex
Integer totalLeads = [SELECT COUNT() FROM Lead WHERE LeadSource = 'Fluent Smart Shop'];
System.debug('Total Fluent Leads: ' + totalLeads);
```

#### Get Hot Leads Count:
```apex
Integer hotLeads = [
    SELECT COUNT() 
    FROM Lead 
    WHERE LeadSource = 'Fluent Smart Shop' 
    AND Rating = 'Hot'
    AND IsConverted = false
];
System.debug('Hot Leads: ' + hotLeads);
```

#### Manually Trigger Lead Creation for All Users:
```apex
FluentLeadCreationService.processAllQualifyingUsers();
```

#### Recalculate All Lead Scores:
```apex
FluentConversationTriggerHandler.recalculateAllLeadScores();
```

---

## 📊 Dashboard Metrics Explanation

### Key Metrics to Track:

1. **Total Leads Generated**
   - Measures: Overall lead generation success
   - Target: Consistent growth week-over-week

2. **Hot Lead Percentage**
   - Formula: (Hot Leads / Total Leads) × 100
   - Target: 30%+ of leads should be Hot or Warm

3. **Average Response Time**
   - Measures: Speed of sales follow-up
   - Target: < 4 hours for Hot leads, < 24 hours for others

4. **Conversion Rate**
   - Formula: (Converted Leads / Total Leads) × 100
   - Target: Industry standard is 2-5%, aim for 5%+

---

## 🎨 Alternative Dashboard Layouts

### Option A: Executive View (Simplified)
- 2-column layout
- Focus on high-level metrics
- Less detailed tables

### Option B: Sales Rep View (Action-Oriented)
- Single column layout
- Prioritize hot leads and tasks
- Show only assigned leads

### Option C: Marketing Analytics View
- Focus on product performance
- Engagement metrics
- Conversation keyword analysis

---

## 🚨 Alerts & Notifications

### Recommended Alert Setup:

#### Alert 1: New Hot Lead
```
Trigger: When Hot Lead is created
Action: Send email to assigned sales rep
Include: Lead name, email, conversation summary
```

#### Alert 2: Uncontacted Hot Leads
```
Trigger: Hot Lead older than 24 hours with no activity
Action: Send email to sales manager
Include: Lead details and assigned owner
```

#### Alert 3: Weekly Performance Summary
```
Trigger: Every Monday at 9:00 AM
Action: Send dashboard snapshot to team
Include: Previous week's metrics and goals
```

---

## ✅ Dashboard Launch Checklist

Before sharing dashboard with team:

- [ ] All components load without errors
- [ ] Data is accurate and up-to-date
- [ ] Filters work correctly
- [ ] Mobile view is optimized
- [ ] Permissions are set correctly
- [ ] Email subscriptions are configured
- [ ] Training materials are ready
- [ ] Feedback mechanism is in place

---

## 📚 Next Steps

After creating the dashboard:

1. **Train Your Team**: Schedule a demo session
2. **Gather Feedback**: Survey users after 1 week
3. **Iterate**: Make improvements based on feedback
4. **Scale**: Create role-specific dashboard versions
5. **Integrate**: Connect with sales automation tools

---

## 🆘 Troubleshooting

**Issue**: Components not loading
- **Solution**: Check report permissions and sharing settings

**Issue**: Data seems outdated
- **Solution**: Force manual refresh or adjust auto-refresh schedule

**Issue**: Mobile view looks broken
- **Solution**: Reduce number of components or simplify layout

**Issue**: Users can't see dashboard
- **Solution**: Check folder sharing settings in "Fluent Analytics"

---

## 🎓 Training Resources

### For Your Sales Team:
1. **Dashboard Overview Video** (create a quick Loom video)
2. **Quick Reference Card** (PDF with key features)
3. **FAQ Document** (common questions and answers)

### Sample Training Script:
```
"Welcome to your new Fluent Lead Intelligence Dashboard!

This dashboard helps you:
✓ Identify hot leads instantly (red highlights)
✓ See conversation history and insights
✓ Track your team's performance
✓ Monitor response times

Top tip: Start each day by checking the 'Hot Leads - Action Required' 
component. These are your highest-priority contacts!"
```

---

Need help? Check the deployment guide or contact your Salesforce administrator!

