# Fluent Lead Generation - Reports Setup Guide

This guide will help you create the essential reports for your lead generation system.

## Prerequisites
✅ Deploy all Apex classes and custom fields first
✅ Ensure you have "Report Builder" access
✅ The custom report type "Fluent Lead Intelligence" must be deployed

---

## 📊 Report 1: Hot Leads Dashboard

**Purpose**: Identify high-intent leads that need immediate attention

### Steps to Create:
1. Navigate to **Reports** tab
2. Click **New Report**
3. Select Report Type: **Leads** (Standard)
4. Click **Continue**

### Configure Columns:
- Lead Owner
- Name
- Email
- Phone
- Company
- Status
- Rating
- Lead Source
- Created Date
- Description (shows Fluent insights)

### Add Filters:
```
Filter 1: Lead Source equals "Fluent Smart Shop"
Filter 2: Rating equals "Hot"
Filter 3: Status NOT equal to "Converted"
Filter 4: Status NOT equal to "Unqualified"
```

### Grouping:
- **Group Rows By**: Lead Owner
- **Sort By**: Created Date (Descending)

### Chart:
- **Chart Type**: Donut Chart
- **Display**: Count of Leads by Rating

### Save Settings:
- **Report Name**: Hot Leads - Fluent Smart Shop
- **Report Unique Name**: Hot_Leads_Fluent_Smart_Shop
- **Report Folder**: Fluent Analytics (create if doesn't exist)
- **Description**: High-intent leads from Fluent Smart Shop requiring immediate follow-up

---

## 📊 Report 2: All Fluent Leads by Intent

**Purpose**: View all leads generated from Fluent Smart Shop, segmented by intent level

### Steps to Create:
1. Navigate to **Reports** tab
2. Click **New Report**
3. Select Report Type: **Leads**
4. Click **Continue**

### Configure Columns:
- Lead Owner
- Name
- Email
- Phone
- Rating
- Status
- Created Date
- Last Activity Date

### Add Filters:
```
Filter 1: Lead Source equals "Fluent Smart Shop"
Filter 2: Status NOT equal to "Converted"
```

### Grouping:
- **Group Rows By**: Rating
- **Sort By**: Created Date (Descending)

### Summary Formula:
- Add Row Count to show total leads per rating

### Chart:
- **Chart Type**: Horizontal Bar Chart
- **Y-Axis**: Rating
- **X-Axis**: Count of Leads

### Save Settings:
- **Report Name**: All Fluent Leads by Intent Level
- **Report Unique Name**: All_Fluent_Leads_by_Intent
- **Report Folder**: Fluent Analytics
- **Description**: Complete view of all Fluent-generated leads segmented by purchase intent

---

## 📊 Report 3: Lead Conversion Funnel

**Purpose**: Track lead progression through sales stages

### Steps to Create:
1. Navigate to **Reports** tab
2. Click **New Report**
3. Select Report Type: **Leads**
4. Click **Continue**

### Configure Columns:
- Name
- Email
- Company
- Rating
- Status
- Created Date
- Last Modified Date
- Converted Date

### Add Filters:
```
Filter 1: Lead Source equals "Fluent Smart Shop"
Filter 2: Created Date equals "THIS_MONTH" (or adjust as needed)
```

### Grouping:
- **Group Rows By**: Status
- **Sort By**: Status

### Summary Fields:
- Add **Row Count** for each status

### Chart:
- **Chart Type**: Funnel Chart
- **Stages**: Status
- **Values**: Count of Leads

### Save Settings:
- **Report Name**: Fluent Lead Conversion Funnel
- **Report Unique Name**: Fluent_Lead_Conversion_Funnel
- **Report Folder**: Fluent Analytics
- **Description**: Tracks lead progression from creation to conversion

---

## 📊 Report 4: Lead Age and Follow-up Analysis

**Purpose**: Monitor lead age and ensure timely follow-up

### Steps to Create:
1. Navigate to **Reports** tab
2. Click **New Report**
3. Select Report Type: **Leads** (Standard)
4. Click **Continue**

### Configure Columns:
- Lead Owner
- Name
- Email
- Company
- Rating
- Status
- Created Date
- Last Activity Date
- Last Modified Date

### Add Filters:
```
Filter 1: Lead Source equals "Fluent Smart Shop"
Filter 2: Created Date equals "LAST_N_DAYS:30"
Filter 3: Status NOT equal to "Converted"
```

### Grouping:
- **Group Rows By**: Lead Owner
- **Sort By**: Created Date (Descending)

### Add Row-Level Formula (Optional - for Lead Age calculation):
If you want to calculate lead age in days, you can add a formula column:
1. Click **Add Column** → **Add Formula Column**
2. **Column Name**: Lead Age (Days)
3. **Formula**: `TODAY() - DATEVALUE(Lead.CreatedDate)`
4. This will show the number of days since the lead was created

### Conditional Highlighting (Recommended):
Set up conditional highlighting to visually identify leads by age:

**Where to Find It:**
1. At the bottom right of your report, click the **Conditional Formatting** link
2. OR look for the paintbrush/color palette icon in the report toolbar
3. A popup window titled "Add Conditional Formatting Rule" will appear

**How to Set It Up:**
The conditional formatting UI will show:
- **Apply Conditional Formatting to**: Select **"Sum of Lead Age (Days)"** from dropdown
- Three rows for conditions with operators: `<= *`, `> to *`, and `>`
- Background Color selectors for each row

**Configure the Rules:**

**Rule 1 - Red (0-1 Days - URGENT):**
- Operator: `<= *`
- Enter Number: **1**
- Background Color: Click the red color box (already selected)
- This will highlight leads 0-1 days old in RED

**Rule 2 - Orange/Yellow (2-3 Days - Follow Up Soon):**
- First box: Leave empty or enter **1**
- Operator: `> to *`
- Second box: Enter **3**
- Background Color: Click the orange/yellow color box
- This will highlight leads 2-3 days old in ORANGE

**Rule 3 - Green (4+ Days - Recently Created):**
- Operator: `>`
- Enter Number: **3**
- Background Color: Click the green color box
- This will highlight leads 4+ days old in GREEN

**Final Steps:**
1. Click **Done** button to save your rules
2. Click **Save & Run** to apply the formatting to your report

**Result:** Your report rows will be color-coded:
- 🔴 **Red** = Brand new leads (0-1 days) - Drop everything and contact now!
- 🟧 **Orange** = Recent leads (2-3 days) - Contact today
- 🟢 **Green** = Older leads (4+ days) - Follow up soon

**Note:** Make sure you've added the "Lead Age (Days)" formula column first, as the conditional formatting works on that calculated field, not on Created Date directly.

### Note:
- Use the **Created Date** column and sort descending to see newest leads first
- The **Last Activity Date** shows when the lead was last engaged
- **Last Modified Date** shows when the record was last updated by sales team

For advanced lead age tracking with bucketing, you would need to create a custom formula field on the Lead object that calculates age in days, then use that field in the report.

### Save Settings:
- **Report Name**: Lead Age and Follow-up - Fluent
- **Report Unique Name**: Lead_Age_Followup_Fluent
- **Report Folder**: Fluent Analytics
- **Description**: Tracks lead age and last activity to ensure timely follow-up on Fluent leads

---

## 📊 Report 5: Weekly Lead Generation Summary

**Purpose**: Executive summary of lead generation performance

### Steps to Create:
1. Navigate to **Reports** tab
2. Click **New Report**
3. Select Report Type: **Leads**
4. Click **Continue**

### Configure Columns:
- Name
- Email
- Rating
- Status
- Created Date
- Lead Owner

### Add Filters:
```
Filter 1: Lead Source equals "Fluent Smart Shop"
Filter 2: Created Date equals "THIS_WEEK"
```

### Grouping:
- **Primary Grouping**: Created Date (by Day)
- **Secondary Grouping**: Rating

### Summary Fields:
- Row Count (leads per day per rating)

### Chart:
- **Chart Type**: Stacked Column Chart
- **X-Axis**: Created Date
- **Y-Axis**: Count of Leads
- **Stacked By**: Rating

### Save Settings:
- **Report Name**: Weekly Lead Generation - Fluent
- **Report Unique Name**: Weekly_Lead_Generation_Fluent
- **Report Folder**: Fluent Analytics
- **Description**: Weekly summary of lead generation from Fluent Smart Shop

---

## 📊 Report 6: Lead Intelligence with Conversation Insights

**Purpose**: View leads with conversation intelligence in the Description field

### Steps to Create:
1. Navigate to **Reports** tab
2. Click **New Report**
3. Select Report Type: **Leads** (Standard)
4. Click **Continue**

### Configure Columns:
- Lead Owner
- Full Name
- Email
- Phone
- Company
- Rating
- Status
- Lead Source
- Created Date
- **Description** (contains conversation intelligence)
- Last Activity Date

### Add Filters:
```
Filter 1: Lead Source equals "Fluent Smart Shop"
Filter 2: Created Date equals "LAST_N_DAYS:30"
Filter 3: Description NOT equal to "" (shows only leads with conversation data)
```

### Grouping:
- **Group Rows By**: Rating (Hot, Warm, Cold)
- **Sort By**: Created Date (Descending)

### Column Width Adjustment:
Make the **Description** column wider so you can read the full conversation intelligence:
1. Hover over the Description column header
2. Drag the column border to make it wider
3. The Description field contains the conversation summary that was written to the Lead

### What You'll See in Description Field:
The Description field contains the conversation intelligence that was automatically populated when the Lead was created, including:
- What questions the prospect asked
- Their level of interest
- Products they showed interest in
- Interaction context for sales follow-up

### Note:
Since there's no direct lookup from Leads to Fluent Conversations in the data model, the conversation intelligence is stored in the Lead's Description field when the lead is automatically created. For a full conversation history report, use the "Fluent Conversations" report type instead (Report available in Fluent Analytics section).

### Save Settings:
- **Report Name**: Lead Intelligence with Conversations - Fluent
- **Report Unique Name**: Lead_Intelligence_Conversations_Fluent
- **Report Folder**: Fluent Analytics
- **Description**: Shows leads with conversation intelligence from Fluent Smart Shop

---

## 🔧 Report Folder Structure

Create the following folder structure in Reports:

```
📁 Fluent Analytics
   ├── 📄 Hot Leads - Fluent Smart Shop
   ├── 📄 All Fluent Leads by Intent Level
   ├── 📄 Fluent Lead Conversion Funnel
   ├── 📄 Lead Age and Follow-up - Fluent
   ├── 📄 Weekly Lead Generation - Fluent
   └── 📄 Lead Conversation Intelligence - Fluent
```

---

## 📧 Email Subscriptions (Recommended)

Set up email subscriptions for key reports:

### For Sales Managers:
- **Report**: Hot Leads - Fluent Smart Shop
- **Frequency**: Daily at 8:00 AM
- **Condition**: When new rows are added

### For Sales Team:
- **Report**: All Fluent Leads by Intent Level
- **Frequency**: Weekly on Monday
- **Condition**: Always send

### For Executives:
- **Report**: Weekly Lead Generation - Fluent
- **Frequency**: Weekly on Monday
- **Condition**: Always send

---

## 🎯 Quick Tips

1. **Subscribe to Hot Leads Report**: Set up daily email alerts so you never miss a hot lead
2. **Dashboard Integration**: Add these reports to your dashboard (see dashboard guide)
3. **Export Options**: Use "Export" to download lead lists for calling campaigns
4. **Conditional Formatting**: Use colors to highlight Hot (Red), Warm (Orange), Cold (Blue)
5. **Refresh Schedule**: Reports refresh in real-time when viewed

---

## 🚀 Next Steps

After creating these reports:
1. ✅ Review the data quality
2. ✅ Create the Lead Intelligence Dashboard (see LEAD_GENERATION_DASHBOARD_GUIDE.md)
3. ✅ Set up email subscriptions for your sales team
4. ✅ Train your sales team on how to use the conversation intelligence data

---

## ❓ Troubleshooting

**Problem**: Can't find "Fluent Smart Shop" in Lead Source
- **Solution**: Create lead source value in Setup → Lead → Lead Source picklist

**Problem**: No data showing in reports
- **Solution**: Ensure leads have been created. Run: `FluentLeadCreationService.processAllQualifyingUsers()` from Developer Console

**Problem**: Custom report type not available
- **Solution**: Deploy the `Fluent_Lead_Intelligence` report type first

---

Need help? Check the main documentation or reach out to your Salesforce admin!

