# Fluent Lead Generation System - Deployment Guide

This guide will walk you through deploying the complete lead generation system.

---

## 📦 What's Being Deployed

### Apex Classes (6):
1. **FluentLeadScoringService** - Calculates lead scores based on engagement
2. **FluentLeadScoringServiceTest** - Test coverage for scoring service
3. **FluentLeadCreationService** - Automates lead creation
4. **FluentLeadCreationServiceTest** - Test coverage for lead creation
5. **FluentConversationTriggerHandler** - Handles trigger logic
6. **FluentConversationTrigger** - Trigger on Fluent_Conversation__c

### Custom Fields (2):
1. **Lead_Score__c** - Number field (0-100) on Fluent_Conversation__c
2. **Intent_Level__c** - Picklist field (Hot/Warm/Cold/Low/None) on Fluent_Conversation__c

### Report Type (1):
1. **Fluent_Lead_Intelligence** - Custom report type for Leads

### Documentation (3):
1. **LEAD_GENERATION_REPORTS_GUIDE.md** - How to create reports
2. **LEAD_GENERATION_DASHBOARD_GUIDE.md** - How to create dashboard
3. **This file** - Deployment instructions

---

## ⚙️ Deployment Steps

### Step 1: Validate Your Org

Before deploying, ensure:
- ✅ You have System Administrator or similar permissions
- ✅ Salesforce CLI is installed and authenticated
- ✅ The Fluent_Conversation__c object exists
- ✅ Standard Lead object is accessible

### Step 2: Deploy All Components

Run the deployment command:

```bash
sf project deploy start --source-dir force-app/main/default
```

Wait for deployment to complete. This will deploy:
- All Apex classes
- Test classes
- Trigger and handler
- Custom fields
- Report type

### Step 3: Verify Deployment

Check deployment success:

```bash
# Check if classes deployed
sf apex list class --json | grep Fluent

# Or via UI:
Setup → Apex Classes → Search for "Fluent"
```

You should see all 5 Apex classes listed.

### Step 4: Run Tests

Verify test coverage:

```bash
sf apex run test --test-level RunSpecifiedTests --class-names FluentLeadScoringServiceTest,FluentLeadCreationServiceTest --result-format human --code-coverage
```

Expected results:
- ✅ All tests passing
- ✅ Code coverage > 75%

---

## 🔧 Post-Deployment Configuration

### 1. Add "Fluent Smart Shop" to Lead Source Picklist

**Via UI:**
1. Go to **Setup** → **Object Manager** → **Lead**
2. Click **Fields & Relationships**
3. Click **Lead Source**
4. Click **New** in Picklist Values section
5. Add value: **Fluent Smart Shop**
6. Save

**Via Salesforce CLI:**
```bash
# This is done via metadata, but can be added manually as shown above
```

### 2. Verify Custom Fields on Fluent_Conversation__c

1. Go to **Setup** → **Object Manager** → **Fluent Conversation**
2. Click **Fields & Relationships**
3. Verify these fields exist:
   - ✅ Lead_Score__c (Number)
   - ✅ Intent_Level__c (Picklist)

### 3. Test the Trigger

Create a test conversation in Developer Console:

```apex
// Get current user
User currentUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

// Get a test video
Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];

// Create high-intent conversation
Fluent_Conversation__c testConv = new Fluent_Conversation__c(
    Session_ID__c = 'test-session-001',
    User__c = currentUser.Id,
    User_Email__c = currentUser.Email,
    User_Question__c = 'What is the price? I want to buy it now!',
    AI_Response__c = 'The price is $99.99. You can order online.',
    Interaction_Type__c = 'Voice',
    Video__c = video.Id,
    Interaction_Timestamp__c = DateTime.now()
);

insert testConv;

// Wait a few seconds, then check if Lead_Score__c and Intent_Level__c are populated
testConv = [SELECT Id, Lead_Score__c, Intent_Level__c FROM Fluent_Conversation__c WHERE Id = :testConv.Id];
System.debug('Lead Score: ' + testConv.Lead_Score__c);
System.debug('Intent Level: ' + testConv.Intent_Level__c);

// Check if lead was created
List<Lead> leads = [SELECT Id, Email, Rating, Description FROM Lead WHERE Email = :currentUser.Email];
if (!leads.isEmpty()) {
    System.debug('Lead created! Rating: ' + leads[0].Rating);
    System.debug('Description: ' + leads[0].Description);
}
```

Expected result:
- Lead_Score__c should be populated (e.g., 75)
- Intent_Level__c should be set (e.g., "Warm")
- If score is high enough, a Lead should be created

---

## 📊 Create Reports & Dashboard

### Step 1: Create Reports

Follow the detailed guide in **LEAD_GENERATION_REPORTS_GUIDE.md** to create these 6 reports:

1. Hot Leads - Fluent Smart Shop
2. All Fluent Leads by Intent Level
3. Fluent Lead Conversion Funnel
4. Lead Response Time - Fluent
5. Weekly Lead Generation - Fluent
6. Product Interest Analysis - Fluent

### Step 2: Create Dashboard

Follow the detailed guide in **LEAD_GENERATION_DASHBOARD_GUIDE.md** to create the dashboard with 7 components.

---

## 🚀 Process Existing Data

If you have existing conversations that need lead scoring:

### Option A: Recalculate All Lead Scores (Developer Console)

```apex
FluentConversationTriggerHandler.recalculateAllLeadScores();
```

This will:
- Calculate scores for all users with conversations
- Update Lead_Score__c and Intent_Level__c on all conversations
- Create leads for qualifying users

### Option B: Process All Qualifying Users for Lead Creation

```apex
FluentLeadCreationService.processAllQualifyingUsers();
```

This will:
- Create leads for all users who qualify
- Skip users who don't meet the threshold

### Option C: Process Specific User

```apex
// Replace with actual user ID
Id userId = '005...'; 

// Calculate score
FluentLeadScoringService.LeadScoringResult result = 
    FluentLeadScoringService.calculateUserLeadScore(userId);

System.debug('Score: ' + result.score);
System.debug('Intent: ' + result.intentLevel);
System.debug('Qualifies: ' + result.qualifiesForLead);

// Create lead if qualifies
if (result.qualifiesForLead) {
    Lead createdLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(userId);
    System.debug('Lead created: ' + createdLead.Id);
}
```

---

## 🎯 Lead Scoring Algorithm Explained

### Scoring Breakdown:

| Factor | Points | Trigger |
|--------|--------|---------|
| Voice Interaction | 15 | Each voice interaction |
| Text Interaction | 10 | Each text interaction |
| High Intent Keyword | 20 | "price", "buy", "purchase", "order", "shipping", etc. |
| Medium Intent Keyword | 10 | "features", "compare", "reviews", etc. |
| Multiple Sessions | 15-30 | 2 sessions = 15 pts, 3+ = 30 pts |
| Focused Product Interest | 20 | Multiple questions about same product |
| Recent Activity | 10 | Activity within last 7 days |

**Maximum Score**: 100 (capped)

### Intent Levels:

| Score Range | Intent Level | Lead Rating | Priority |
|-------------|--------------|-------------|----------|
| 80-100 | Hot | Hot | Contact within 24 hours |
| 60-79 | Warm | Warm | Contact within 48-72 hours |
| 40-59 | Cold | Cold | Add to nurture campaign |
| 0-39 | Low | Cold | Monitor for future engagement |

### Lead Creation Criteria:

A lead is created when **any** of these conditions are met:
1. Lead Score ≥ 60 (Warm or Hot)
2. 2+ High Intent Questions (price, buy, shipping, etc.)
3. 2+ Sessions focused on same product

---

## 🔍 Monitoring & Maintenance

### Daily Tasks:
- Review Hot Leads report
- Check for any trigger errors in Debug Logs

### Weekly Tasks:
- Review dashboard metrics
- Analyze lead conversion rates
- Adjust scoring thresholds if needed

### Monthly Tasks:
- Review test coverage
- Update documentation
- Gather feedback from sales team

---

## 🛠️ Customization Options

### Adjust Scoring Weights:

Edit `FluentLeadScoringService.cls` lines 13-20:

```apex
private static final Integer VOICE_INTERACTION_POINTS = 15; // Change as needed
private static final Integer TEXT_INTERACTION_POINTS = 10;
private static final Integer HIGH_INTENT_KEYWORD_POINTS = 20;
// ... etc
```

### Add/Remove Keywords:

Edit `FluentLeadScoringService.cls` lines 23-34:

```apex
private static final Set<String> HIGH_INTENT_KEYWORDS = new Set<String>{
    'price', 'cost', 'buy', 'purchase', 'order', 'payment',
    // Add your keywords here
};
```

### Change Lead Qualification Criteria:

Edit `FluentLeadScoringService.cls` method `shouldCreateLead()` (lines 134-143):

```apex
private static Boolean shouldCreateLead(LeadScoringResult result) {
    return result.score >= 60 || 
           result.highIntentQuestions >= 2 ||
           (result.uniqueSessions >= 2 && result.uniqueProducts == 1);
}
```

---

## 📧 Set Up Email Alerts (Optional)

### Create Email Alert for Hot Leads:

1. Go to **Setup** → **Process Builder** or **Flow Builder**
2. Create new process/flow triggered when:
   - Object: Lead
   - Trigger: Created or Updated
   - Criteria: Rating = "Hot" AND LeadSource = "Fluent Smart Shop"
3. Action: Send Email
   - To: Lead Owner
   - Template: Hot Lead Alert (create custom template)

### Example Email Template:

```
Subject: 🔥 New Hot Lead from Fluent Smart Shop

Hi {!Lead.Owner},

A new hot lead has been generated from Fluent Smart Shop!

Lead Details:
Name: {!Lead.Name}
Email: {!Lead.Email}
Phone: {!Lead.Phone}
Rating: {!Lead.Rating}

Conversation Insights:
{!Lead.Description}

Action Required: Contact this lead within 24 hours for best results.

View Lead: {Lead URL}
```

---

## ⚠️ Troubleshooting

### Issue: Trigger not firing
**Solution**: Check if trigger is active. Go to Setup → Apex Triggers → FluentConversationTrigger → Ensure "Active" is checked.

### Issue: Lead scores not updating
**Solution**: Run manual recalculation:
```apex
FluentConversationTriggerHandler.recalculateAllLeadScores();
```

### Issue: No leads being created
**Solution**: Check if users meet qualification criteria. Lower the threshold in `shouldCreateLead()` method if needed.

### Issue: Test failures
**Solution**: Ensure Ad_Video__c test data exists. Check if User object has required fields (Email, FirstName, LastName).

### Issue: Governor Limits Hit
**Solution**: The trigger uses @future for async processing. If still hitting limits, consider:
1. Batch processing for bulk operations
2. Queueable Apex for chaining

---

## 📚 Additional Resources

- **Salesforce Trailhead**: [Lead Management](https://trailhead.salesforce.com/en/content/learn/modules/leads_opportunities_lightning_experience)
- **Apex Developer Guide**: [Triggers](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers.htm)
- **Report Builder Guide**: [Creating Reports](https://help.salesforce.com/s/articleView?id=sf.reports_builder_create.htm)

---

## ✅ Deployment Checklist

Before go-live, ensure:

- [ ] All Apex classes deployed successfully
- [ ] Test classes have > 75% coverage
- [ ] Custom fields visible on Fluent_Conversation__c
- [ ] "Fluent Smart Shop" added to Lead Source picklist
- [ ] Trigger is active
- [ ] Manual test completed successfully
- [ ] Existing conversations processed
- [ ] All 6 reports created
- [ ] Dashboard created and shared
- [ ] Email alerts configured (optional)
- [ ] Sales team trained
- [ ] Documentation distributed

---

## 🎓 Training Your Sales Team

Key talking points for training session:

1. **What's New**: Automatic lead generation from Fluent Smart Shop
2. **How It Works**: AI analyzes conversations and creates qualified leads
3. **Lead Ratings**: Hot/Warm/Cold based on purchase intent
4. **Conversation Intelligence**: Each lead has full conversation history
5. **Priority Actions**: Hot leads require contact within 24 hours
6. **Dashboard**: How to use the new Fluent Lead Intelligence Dashboard

---

## 🚀 Launch Timeline

**Week 1**: Deploy and test in sandbox
**Week 2**: Deploy to production, process existing data
**Week 3**: Create reports and dashboard
**Week 4**: Train sales team and go live
**Week 5+**: Monitor, gather feedback, optimize

---

Congratulations! Your Fluent Lead Generation System is ready to transform conversations into sales opportunities! 🎉

