# How to Create Fluent Analytics Dashboard

## Prerequisites
✅ All 7 reports have been created in the "Fluent Analytics" folder
✅ Reports have been saved and are accessible

---

## Step 1: Navigate to Dashboards

1. In Salesforce, click on the **App Launcher** (grid icon in top-left)
2. Search for and select **"Dashboards"**
3. Click **"New Dashboard"** button

---

## Step 2: Create the Dashboard

### Basic Information:
1. **Dashboard Name**: `Fluent Conversation Insights`
2. **Dashboard Folder**: Create a new folder called `Fluent Analytics` (or select existing)
3. Click **"Create"**

---

## Step 3: Add Components to Dashboard

You'll now add each of your 7 reports as components. Here's the layout:

---

### Component 1: Daily Conversation Volume (Top Left)
**Position**: Row 1, Column 1-2 (Wide)

1. Click **"+ Component"**
2. **Data Source**: Select report `Daily Conversation Volume`
3. **Display As**: 
   - **Component Type**: Line Chart
   - **Title**: Daily Conversation Trends
   - **Subtitle**: Last 30 Days
4. **Component Size**: 
   - Width: 6 columns
   - Height: 4 rows
5. Click **"Add"**

---

### Component 2: Interaction Type Breakdown (Top Right)
**Position**: Row 1, Column 3 (Medium)

1. Click **"+ Component"**
2. **Data Source**: Select report `Interaction Type Breakdown`
3. **Display As**:
   - **Component Type**: Donut Chart
   - **Title**: Voice vs Text Usage
   - **Subtitle**: Interaction Distribution
4. **Component Size**:
   - Width: 6 columns
   - Height: 4 rows
5. Click **"Add"**

---

### Component 3: Most Popular Ad Videos (Middle Left)
**Position**: Row 2, Column 1 (Medium)

1. Click **"+ Component"**
2. **Data Source**: Select report `Most Popular Ad Videos`
3. **Display As**:
   - **Component Type**: Horizontal Bar Chart
   - **Title**: Top 10 Most Engaged Videos
   - **Subtitle**: By Conversation Count
   - **Max Values Displayed**: 10
4. **Component Size**:
   - Width: 6 columns
   - Height: 5 rows
5. Click **"Add"**

---

### Component 4: User Engagement Summary (Middle Right)
**Position**: Row 2, Column 2 (Medium)

1. Click **"+ Component"**
2. **Data Source**: Select report `User Engagement Summary`
3. **Display As**:
   - **Component Type**: Table
   - **Title**: Top Active Users
   - **Subtitle**: Engagement Metrics
   - **Max Rows**: 15
   - **Sort By**: Total Conversations (Descending)
4. **Component Size**:
   - Width: 6 columns
   - Height: 5 rows
5. Click **"Add"**

---

### Component 5: Average Response Time (Bottom Left)
**Position**: Row 3, Column 1 (Small)

1. Click **"+ Component"**
2. **Data Source**: Select report `Average Response Time`
3. **Display As**:
   - **Component Type**: Metric
   - **Title**: Average Response Time
   - **Subtitle**: Overall Performance
   - **Metric Label**: milliseconds (ms)
4. **Component Size**:
   - Width: 4 columns
   - Height: 3 rows
5. Click **"Add"**

---

### Component 6: Questions per Session (Bottom Middle)
**Position**: Row 3, Column 2 (Small)

1. Click **"+ Component"**
2. **Data Source**: Select report `Questions per Session`
3. **Display As**:
   - **Component Type**: Vertical Bar Chart
   - **Title**: Questions per Session
   - **Subtitle**: Session Depth Analysis
4. **Component Size**:
   - Width: 4 columns
   - Height: 3 rows
5. Click **"Add"**

---

### Component 7: Hourly Activity Heatmap (Bottom Right)
**Position**: Row 3, Column 3 (Small)

1. Click **"+ Component"**
2. **Data Source**: Select report `Hourly Activity Heatmap`
3. **Display As**:
   - **Component Type**: Stacked Vertical Column Chart
   - **Title**: Activity by Hour
   - **Subtitle**: Last 7 Days
4. **Component Size**:
   - Width: 4 columns
   - Height: 3 rows
5. Click **"Add"**

---

## Step 4: Arrange and Customize Layout

### Recommended Dashboard Layout:

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUENT CONVERSATION INSIGHTS             │
├────────────────────────────────┬────────────────────────────┤
│  Daily Conversation Trends     │   Voice vs Text Usage      │
│  (Line Chart - Wide)           │   (Donut Chart - Medium)   │
│                                │                            │
├────────────────────────────────┼────────────────────────────┤
│  Top 10 Most Engaged Videos    │   Top Active Users         │
│  (Horizontal Bar - Medium)     │   (Table - Medium)         │
│                                │                            │
│                                │                            │
├────────────────┬───────────────┼────────────────────────────┤
│ Avg Response   │  Questions    │   Activity by Hour         │
│ Time (Metric)  │  per Session  │   (Stacked Column - Small) │
│                │  (Bar - Small)│                            │
└────────────────┴───────────────┴────────────────────────────┘
```

### To Rearrange Components:
1. Click **"Edit"** on the dashboard
2. **Drag and drop** components to reposition them
3. **Resize** by dragging the corners
4. **Align** using the grid system

---

## Step 5: Add Dashboard Properties

### Dashboard Settings:
1. Click **"Edit"** → **"Properties"**
2. Configure:
   - **Refresh Frequency**: Daily at 6:00 AM
   - **Running User**: Select yourself or a system admin
   - **Description**: "Real-time insights into Fluent conversational AI interactions, user engagement, and video performance."

---

## Step 6: Add Filters (Optional)

Make your dashboard interactive by adding filters:

### Add Date Filter:
1. Click **"Edit"** → **"Add Filter"**
2. **Field**: `Interaction Timestamp`
3. **Filter Type**: Date Range
4. **Default Value**: Last 30 Days
5. **Apply to Components**: Select all components
6. Click **"Add"**

### Add Interaction Type Filter:
1. Click **"Add Filter"**
2. **Field**: `Interaction Type`
3. **Filter Type**: Picklist
4. **Default Value**: All
5. **Apply to Components**: Select relevant components
6. Click **"Add"**

### Add Video Filter:
1. Click **"Add Filter"**
2. **Field**: `Video Name`
3. **Filter Type**: Multi-Select Picklist
4. **Default Value**: All
5. **Apply to Components**: Select relevant components
6. Click **"Add"**

---

## Step 7: Subscribe to Dashboard Updates

Get automatic updates delivered to your inbox:

1. Click **"Subscribe"**
2. **Frequency**: Daily or Weekly
3. **Time**: Choose preferred time
4. **Format**: PDF or Excel
5. **Recipients**: Add your email
6. Click **"Save"**

---

## Step 8: Share the Dashboard

### Share with Your Team:
1. Click **"Share"**
2. **Share with**: 
   - Individual users
   - Public groups
   - Roles
3. **Access Level**:
   - **Viewer**: Can view only
   - **Editor**: Can edit dashboard
4. Click **"Share"**

---

## Step 9: Save and Test

1. Click **"Save"** to save your dashboard
2. Click **"Done"** to exit edit mode
3. **Refresh** the dashboard to ensure data loads correctly
4. **Test filters** to ensure they work as expected

---

## Dashboard Best Practices

### Visual Design:
✅ **Most important metrics at the top** (Daily trends, breakdowns)
✅ **Detailed analysis in the middle** (Videos, Users)
✅ **Supporting metrics at the bottom** (Response time, hourly activity)
✅ **Use color coding** for different interaction types
✅ **Keep it clean** - don't overcrowd the dashboard

### Performance:
✅ **Limit to 7-10 components** per dashboard
✅ **Use report filters** instead of dashboard filters when possible
✅ **Schedule refresh** during off-peak hours
✅ **Optimize reports** before adding to dashboard

### Maintenance:
✅ **Review weekly** for accuracy
✅ **Update filters** as business needs change
✅ **Archive old versions** before major changes
✅ **Document any customizations**

---

## Alternative: Lightning Dashboard

If you want a more modern, interactive dashboard:

### Create Lightning Dashboard:
1. Go to **Analytics Studio** (formerly Einstein Analytics)
2. Click **"Create"** → **"Dashboard"**
3. Choose **"Start from Blank"**
4. Use the **drag-and-drop builder**
5. Add your reports as data sources
6. Create more **interactive visualizations**

### Benefits:
- More visualization options
- Better interactivity
- Mobile-responsive
- Advanced filtering
- Real-time updates

---

## Troubleshooting

### Dashboard Not Loading:
- Check report permissions
- Verify "Running User" has access to all reports
- Refresh the browser cache

### Components Showing Errors:
- Verify the underlying report runs successfully
- Check filter compatibility
- Ensure data exists for the time period

### Slow Performance:
- Reduce number of components
- Optimize report queries
- Use summary reports instead of detail reports
- Schedule refresh instead of real-time

---

## Next Steps

1. ✅ Create the dashboard following steps above
2. ✅ Test all components load correctly
3. ✅ Share with stakeholders
4. ✅ Set up email subscriptions
5. ✅ Review dashboard weekly
6. ✅ Iterate based on feedback

---

## Additional Dashboard Ideas

### Future Enhancements:
- **Product Performance Dashboard**: Focus on which products get the most questions
- **User Journey Dashboard**: Track user paths through videos
- **AI Performance Dashboard**: Track response accuracy and user satisfaction
- **Regional Analytics Dashboard**: If you expand to multiple locations

---

## Need Help?

If you encounter any issues:
1. Check the Salesforce Trailhead module: "Reports & Dashboards for Lightning Experience"
2. Review report data sources
3. Verify security settings
4. Contact Salesforce support if needed

---

**Happy Dashboard Building!** 🎉📊

Let me know once you've created the dashboard and I can help with any refinements!

