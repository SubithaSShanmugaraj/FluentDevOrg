# How to Create Fluent Analytics Reports

## Prerequisites
✅ Custom Report Type "Fluent Conversations" has been deployed successfully!
✅ **Hour of Day** formula field has been created (calculates hour from timestamp: 0-23)

Now you can create reports through the Salesforce UI. Here's the step-by-step guide:

---

## Important Note on Time Grouping

⚠️ **Salesforce does not support "Hourly" grouping in reports.**

Instead, we've created a **"Hour of Day"** formula field that extracts the hour (0-23) from the timestamp. Use this field when you need to group conversations by hour.

---

## Step 1: Create Report Folder

1. **Go to Reports tab** in Salesforce
2. Click **"New Folder"**
3. Name: `Fluent Analytics`
4. Access: Public
5. Click **"Save"**

---

## Report 1: Daily Conversation Volume

### Create the Report:
1. Click **"New Report"**
2. Search for and select: **"Fluent Conversations"**
3. Click **"Start Report"**

### Configure:
**Outline**
- Group Rows by: `Interaction Timestamp` → Change to **Daily**
- Show: Details

**Filters**
- Interaction Timestamp equals **LAST 30 DAYS**

**Columns** (Add these):
- Conversation Number
- User Question
- Interaction Type
- Video Name

**Chart**
- Click **"Add Chart"**
- Chart Type: **Line Chart**
- X-Axis: Interaction Timestamp
- Y-Axis: Record Count
- Position: Top

**Save**
- Report Name: `Daily Conversation Volume`
- Report Folder: `Fluent Analytics`
- Report Description: `Track daily conversation volume over time`

---

## Report 2: Voice vs Text Usage

### Create the Report:
1. Click **"New Report"**
2. Select: **"Fluent Conversations"**

### Configure:
**Outline**
- Group Rows by: `Interaction Type`
- Show: Details

**Filters**
- Interaction Timestamp equals **LAST 30 DAYS**

**Columns**:
- User Question
- User
- Interaction Timestamp
- Video Name

**Chart**
- Chart Type: **Donut Chart**
- Display: Record Count by Interaction Type
- Show Percentages: Yes
- Position: Top

**Save**
- Report Name: `Voice vs Text Usage`
- Report Folder: `Fluent Analytics`

---

## Report 3: Top Videos by Engagement

### Create the Report:
1. Click **"New Report"**
2. Select: **"Fluent Conversations"**

### Configure:
**Outline**
- Group Rows by: `Video Name`
- Show: Details
- Sort by: Record Count (Descending)

**Filters**
- Video Name not equal to [blank]

**Columns**:
- User Question
- Interaction Type
- Interaction Timestamp
- User

**Chart**
- Chart Type: **Horizontal Bar Chart**
- X-Axis: Record Count
- Y-Axis: Video Name
- Position: Top

**Save**
- Report Name: `Top Videos by Engagement`
- Report Folder: `Fluent Analytics`

---

## Report 4: Average Response Time

### Create the Report:
1. Click **"New Report"**
2. Select: **"Fluent Conversations"**

### Configure:
**Outline**
- Group Rows by: `Interaction Type`
- Show: Details

**Filters**
- Response Time (ms) greater than **0**

**Columns**:
- Video Name
- User Question
- Interaction Timestamp
- Response Time (ms)

**Summary Formulas** (Click "Add Summary Formula"):
- Field: Response Time (ms)
- Summarize: **AVERAGE**
- Display: Show at group level

**Chart**
- Chart Type: **Vertical Column Chart**
- X-Axis: Interaction Type
- Y-Axis: AVG Response Time (ms)
- Position: Top

**Save**
- Report Name: `Average Response Time`
- Report Folder: `Fluent Analytics`

---

## Report 5: Most Active Users

### Create the Report:
1. Click **"New Report"**
2. Select: **"Fluent Conversations"**

### Configure:
**Outline**
- Group Rows by: `User`
- Show: Details
- Sort by: Record Count (Descending)

**Columns**:
- User Question
- Interaction Type
- Interaction Timestamp
- Video Name

**Chart**
- Chart Type: **Vertical Column Chart**
- X-Axis: User
- Y-Axis: Record Count
- Show: Top 10
- Position: Top

**Save**
- Report Name: `Most Active Users`
- Report Folder: `Fluent Analytics`

---

## Report 6: Questions per Session

### Create the Report:
1. Click **"New Report"**
2. Select: **"Fluent Conversations"**

### Configure:
**Outline**
- Group Rows by: `Session ID`
- Show: Details
- Sort by: Record Count (Descending)

**Filters**
- Session ID not equal to [blank]

**Columns**:
- User
- User Question
- Video Name
- Interaction Timestamp

**Chart**
- Chart Type: **Vertical Column Chart**
- X-Axis: Session ID (hide labels for cleaner look)
- Y-Axis: Record Count
- Position: Top

**Save**
- Report Name: `Questions per Session`
- Report Folder: `Fluent Analytics`

---

## Report 7: Hourly Activity Heatmap

### Create the Report:
1. Click **"New Report"**
2. Select: **"Fluent Conversations"**

### Configure:
**Outline**
- Group Rows by: `Hour of Day` (this is a new formula field we just created)
- Group Columns by: `Interaction Type`
- Show: Totals only (hide details)

**Filters**
- Interaction Timestamp equals **LAST 7 DAYS**

**Chart**
- Chart Type: **Grouped Vertical Column Chart**
- X-Axis: Hour
- Y-Axis: Record Count
- Group By: Interaction Type
- Position: Top

**Save**
- Report Name: `Hourly Activity Heatmap`
- Report Folder: `Fluent Analytics`

---

## Quick Tips

### Navigating Report Builder:
- **Filters**: Top-left panel
- **Outline**: Left panel (grouping)
- **Columns**: Right panel
- **Chart**: Click "Add Chart" button (top-right)
- **Preview**: Click "Run" button

### Common Actions:
- **Add Column**: Click "+ Add" in Columns panel
- **Group Rows**: Drag field to "Group Rows" area
- **Add Formula**: Click "Add" → "Summary Formula"
- **Change Date Grouping**: Click on date field → Select grouping level

### Best Practices:
- Always add filters to improve performance
- Use meaningful chart titles
- Show details for drill-down capability
- Save frequently while building

---

## After Creating All Reports

### Verify Reports:
1. Go to **Reports** tab
2. Open **Fluent Analytics** folder
3. You should see all 7 reports

### Test Each Report:
1. Click **"Run"** on each report
2. Verify data displays correctly
3. Check charts render properly

---

## Next Step: Create Dashboard

Once all reports are created, proceed to:
**Dashboard Creation Guide** (see DASHBOARD_CREATION_GUIDE.md)

Or manually create a dashboard:
1. Go to **Dashboards** tab
2. Click **"New Dashboard"**
3. Name: "Fluent AI Insights"
4. Add components using the reports you just created

---

## Troubleshooting

### "Report Type not found"
- Wait a few minutes for the report type to propagate
- Refresh your browser
- Log out and log back in

### "No data showing"
- Verify you have conversation records (go to Fluent Conversations tab)
- Check report filters (especially date filters)
- Run the report (click "Run" button)

### "Chart not rendering"
- Make sure you've added grouping (Group Rows by field)
- Verify summary fields are selected
- Try different chart types

---

## Estimated Time
- Creating all 7 reports: **15-20 minutes**
- Each report takes approximately 2-3 minutes

**Good luck! Let me know if you need any clarification! 🚀**

