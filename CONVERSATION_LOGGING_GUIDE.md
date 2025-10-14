# Fluent Smart Shop - Conversation Logging Guide

## Overview
The Fluent Smart Shop now automatically logs all user interactions with the Fluent AI assistant to Salesforce for authenticated users. This provides valuable insights into user behavior, preferences, and engagement.

---

## Architecture

### 1. Custom Object: `Fluent_Conversation__c`
Stores conversation data with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| **Conversation Number** | Auto Number | Unique identifier (CONV-XXXXXXX) |
| **Session ID** | Text(100) | Unique session identifier for grouping conversations |
| **User** | Lookup(User) | Reference to the logged-in user |
| **Contact** | Lookup(Contact) | Reference to the contact (if user is a community user) |
| **User Email** | Email | User's email address |
| **User Question** | Long Text Area | The question asked by the user |
| **AI Response** | Long Text Area | The response provided by Fluent AI |
| **Interaction Type** | Picklist | Voice or Text |
| **Interaction Timestamp** | DateTime | When the interaction occurred |
| **Video** | Lookup(Ad_Video__c) | The video being watched during interaction |
| **Video Name** | Text(255) | Name of the video for quick reference |
| **Product** | Lookup(E_Cart_Product__c) | Product being discussed (if applicable) |
| **Product Name** | Text(255) | Name of the product for quick reference |
| **Response Time (ms)** | Number | Time taken to generate the response |
| **Was Voice Used** | Formula(Checkbox) | TRUE if interaction type is Voice |

---

## Implementation Details

### 2. Apex Controller: `FluentConversationController`

#### Methods:

**`logConversation(Map<String, Object> conversationData)`**
- Logs a single conversation interaction
- Automatically captures user information
- Links to video and product context
- Returns the created record ID

**`getConversationHistory(String sessionId, Integer limitRecords)`**
- Retrieves conversation history for the current user
- Can filter by session ID
- Default limit: 50 records

**`getUserConversationStats()`**
- Returns analytics for the current user:
  - Total conversations
  - Voice vs Text breakdown
  - Last session information

---

### 3. LWC Integration: `conversationalAdPlayer`

#### Key Features:

**Session Tracking**
```javascript
// Unique session ID generated per component load
sessionId = this.generateSessionId();
// Format: session-{timestamp}-{random}
```

**Automatic Logging**
- Logs every interaction automatically
- Tracks interaction type (Voice/Text)
- Records response time
- Links to current video context
- Silent failure (doesn't disrupt user experience if logging fails)

**Data Captured**
```javascript
{
    sessionId: 'session-1234567890-abc123',
    question: 'What is the price of this product?',
    response: 'The price starts at $99.99...',
    interactionType: 'Voice' or 'Text',
    videoId: '001XXXXXXXXXXXX',
    productId: null,
    responseTime: 1500
}
```

---

## How It Works

### User Flow:
1. **User Logs In** → Session ID is generated
2. **User Watches Video** → Video context is captured
3. **User Asks Question** (Voice or Text) → Interaction type is tracked
4. **Fluent Responds** → Response time is measured
5. **Data is Logged** → Conversation record is created in Salesforce

### Console Logs:
Monitor the browser console for logging activity:
- `📊 Session ID generated: session-xxx-yyy`
- `📊 Logging conversation to Salesforce: {...}`
- `✅ Conversation logged successfully. Record ID: xxx`
- `❌ Error logging conversation to Salesforce: ...`

---

## Reports & Analytics

### Recommended Reports:

**1. User Engagement Report**
- Fields: User, Session ID, Interaction Timestamp, Interaction Type
- Group By: User
- Show: Total interactions per user

**2. Voice vs Text Usage**
- Fields: Interaction Type, COUNT(Id)
- Chart Type: Pie Chart
- Insight: Understand preferred interaction method

**3. Video Performance Report**
- Fields: Video Name, COUNT(Id), AVG(Response Time)
- Group By: Video
- Insight: Which videos drive most engagement

**4. Response Time Analysis**
- Fields: Response Time (ms), Interaction Type
- Chart Type: Line Chart
- Insight: Monitor AI performance

**5. Session Analysis**
- Fields: Session ID, User, COUNT(Id), Interaction Timestamp
- Group By: Session ID
- Insight: Average questions per session

---

## Configuration Steps

### 1. Object Permissions (Already Done)
✅ Custom object `Fluent_Conversation__c` created with all fields

### 2. Profile Setup (You Will Do)
- Create "Fluent Smart Shop Users" profile (or use existing)
- Grant permissions:
  - **Read**: Fluent_Conversation__c (Own)
  - **Create**: Fluent_Conversation__c
  - **View All**: Ad_Video__c
  - **View All**: E_Cart_Product__c

### 3. Experience Site Setup
- Enable login for Experience Site
- Assign users to "Fluent Smart Shop Users" profile
- Ensure Experience Site is published

### 4. Sharing Rules (Optional)
- Create sharing rule to allow users to see their own conversations
- OWD (Organization-Wide Default): Private
- Sharing Rule: Owner-based sharing

---

## Privacy & Compliance

### Data Captured:
- ✅ User questions and AI responses
- ✅ Interaction timestamps
- ✅ User identification
- ✅ Video/product context
- ✅ Technical metadata (response time, interaction type)

### Data NOT Captured:
- ❌ Personally identifiable information (beyond User record link)
- ❌ Payment information
- ❌ Browsing history outside conversations

### Compliance Considerations:
1. **Inform Users**: Add privacy notice in Experience Site terms
2. **Data Retention**: Set up data retention policies
3. **User Rights**: Provide mechanism for users to request data deletion
4. **Security**: All data respects Salesforce sharing rules

---

## Testing

### Test Scenarios:

**1. Voice Interaction**
- Click "Ask Fluent" button
- Speak a question
- Verify conversation is logged with `Interaction_Type__c = 'Voice'`

**2. Text Interaction**
- Type a question in text box
- Click send
- Verify conversation is logged with `Interaction_Type__c = 'Text'`

**3. Session Tracking**
- Ask multiple questions
- Verify all have the same `Session_ID__c`
- Refresh page
- Verify new session ID is generated

**4. Video Context**
- Navigate to different videos in carousel
- Ask questions on different videos
- Verify `Video__c` and `Video_Name__c` are captured correctly

---

## Troubleshooting

### Issue: Conversations Not Logging

**Possible Causes:**
1. **User Not Authenticated**
   - Solution: Ensure user is logged in
   - Check: `UserInfo.getUserId()` should return valid user ID

2. **Insufficient Permissions**
   - Solution: Verify profile has Create permission on `Fluent_Conversation__c`
   - Check: Object Settings → Fluent Conversation → Profile Permissions

3. **Apex Error**
   - Solution: Check Debug Logs in Setup → Debug Logs
   - Look for: `FluentConversationController` errors

4. **JavaScript Error**
   - Solution: Open Browser Console
   - Look for: Red error messages starting with `❌`

### Issue: Session ID Not Generating

**Solution:**
- Check browser console for `📊 Session ID generated: ...`
- Verify `generateSessionId()` method is called in `connectedCallback()`
- Clear browser cache and reload

### Issue: Response Time Always 0

**Solution:**
- Ensure `startTime` is captured before processing
- Verify `responseTime` calculation in `processQuestion()`

---

## Future Enhancements

### Recommended Features:

1. **Sentiment Analysis**
   - Add field: `Sentiment__c` (Positive/Neutral/Negative)
   - Analyze user satisfaction from questions

2. **Product Recommendations**
   - Track which products are frequently asked about
   - Generate "Trending Products" report

3. **Conversation Threading**
   - Link related conversations in a session
   - Build conversation context over time

4. **AI Model Improvements**
   - Use logged data to fine-tune AI responses
   - Identify common questions for FAQs

5. **User Feedback**
   - Add "Was this helpful?" rating
   - Track response quality

---

## Code Reference

### Key Files:

**Apex:**
- `force-app/main/default/classes/FluentConversationController.cls`
- `force-app/main/default/classes/FluentConversationControllerTest.cls`

**LWC:**
- `force-app/main/default/lwc/conversationalAdPlayer/conversationalAdPlayer.js`
  - Lines 35-36: Session tracking properties
  - Lines 57-58: Session ID generation
  - Lines 727-730: Voice interaction tracking
  - Lines 822-864: Question processing with logging
  - Lines 934-975: Helper methods for session & logging

**Custom Object:**
- `force-app/main/default/objects/Fluent_Conversation__c/`

---

## Support & Contact

For questions or issues with conversation logging:
1. Check Debug Logs in Salesforce Setup
2. Review Browser Console for JavaScript errors
3. Verify user permissions and profile settings
4. Check this guide for troubleshooting steps

---

**Last Updated:** October 11, 2025  
**Version:** 1.0  
**Status:** Production Ready ✅

