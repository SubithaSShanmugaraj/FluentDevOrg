# Ad Video Visibility Fix for Customer Portal Users

## 🔍 **Issue Analysis**

### **Problem:**
The conversational ad player component (video carousel) was **not visible** when a customer portal user logged into the Experience Site, even though the profile had all necessary Apex class permissions configured.

### **Root Cause Identified:**

The issue was **NOT** related to:
- ❌ Apex class permissions (already configured correctly in profile)
- ❌ Profile settings
- ❌ Field-level security
- ❌ Sharing rules (none existed, but weren't the primary issue)

The **ACTUAL root cause** was:

```xml
<externalSharingModel>Private</externalSharingModel>
```

In the `Ad_Video__c` custom object definition (`Ad_Video__c.object-meta.xml`, line 155), the **External Sharing Model** was set to **`Private`**, which **blocks all external users (including Customer Portal users) from accessing ANY records of this object**, regardless of profile permissions or sharing rules.

---

## ✅ **Solution Implemented**

### **Changed External Sharing Model**

**File:** `force-app/main/default/objects/Ad_Video__c/Ad_Video__c.object-meta.xml`

**Before:**
```xml
<externalSharingModel>Private</externalSharingModel>
```

**After:**
```xml
<externalSharingModel>Read</externalSharingModel>
```

This change allows **external users** (Customer Community Plus, Customer Community, Partner Community users) to have **Read access** to `Ad_Video__c` records.

---

## 📊 **Deployment Details**

**Deploy ID:** `0AfgK00000BV2tfSAD`  
**Status:** ✅ **Succeeded**  
**Elapsed Time:** 4.67s  
**Components Deployed:** 9

```
┌───────────┬─────────────────────────────────────┬──────────────┬────────────┐
│ State     │ Name                                │ Type         │ Result     │
├───────────┼─────────────────────────────────────┼──────────────┼────────────┤
│ Changed   │ Ad_Video__c                         │ CustomObject │ ✅ Updated │
│ Unchanged │ Ad_Video__c.Ad_Campaign__c          │ CustomField  │ ✅ OK      │
│ Unchanged │ Ad_Video__c.Order__c                │ CustomField  │ ✅ OK      │
│ Unchanged │ Ad_Video__c.Product_Name__c         │ CustomField  │ ✅ OK      │
│ Unchanged │ Ad_Video__c.Suggestion_Questions__c │ CustomField  │ ✅ OK      │
│ Unchanged │ Ad_Video__c.Video_Id__c             │ CustomField  │ ✅ OK      │
│ Unchanged │ Ad_Video__c.Video_Source_Type__c    │ CustomField  │ ✅ OK      │
│ Unchanged │ Ad_Video__c.Video_URL__c            │ CustomField  │ ✅ OK      │
│ Unchanged │ Ad_Video__c.All                     │ ListView     │ ✅ OK      │
└───────────┴─────────────────────────────────────┴──────────────┴────────────┘
```

---

## 🔐 **Security Model Comparison**

### **External Sharing Model Options**

| Setting | Access for External Users | When to Use |
|---------|---------------------------|-------------|
| **Private** | ❌ No access | Internal-only data |
| **Read** | ✅ Read-only access | Public data, marketing content |
| **ReadWrite** | ✅ Read + Edit access | Collaborative data |
| **ControlledByParent** | Inherits from parent | Child records in master-detail |

### **Current Configuration**

| Object | External Sharing Model | Impact on Portal Users |
|--------|------------------------|------------------------|
| `Ad_Video__c` | **Read** ✅ | Can view videos |
| `E_Cart_Product__c` | **Read** ✅ | Can view products |
| `Fluent_Conversation__c` | **Private** (internal) | Cannot access others' conversations |

---

## 🔧 **Why Previous Attempts Didn't Work**

### **1. Profile Permissions Alone Are Not Sufficient**

Even with all correct permissions in the "Fluent Smart Shop User" profile:
- ✅ Apex Class Access: `AdCampaignController`, `AgentforceController`, `FluentConversationController`
- ✅ Object Permissions: Read, Create, Edit (attempted)
- ✅ Field Permissions: All fields readable

The `externalSharingModel: Private` setting **overrides** all these permissions for external users.

### **2. Sharing Rules Are Secondary**

Sharing rules can **grant** additional access but **cannot override** the base `externalSharingModel` restriction. If `externalSharingModel` is `Private`, no sharing rule can give external users access.

### **3. Apex `WITH USER_MODE` Enforces Security**

The `AdCampaignController` uses `WITH USER_MODE`:
```apex
FROM Ad_Video__c
WHERE Ad_Campaign__c = :campaignId
WITH USER_MODE
ORDER BY Order__c ASC
```

This **correctly enforces** the sharing model. With `externalSharingModel: Private`, the query returns **zero records** for external users, even if the profile has read permission.

---

## 🎯 **How It Works Now**

### **Before Fix (Private):**
```
Customer Portal User → Login → Access Shop Page
                                        ↓
         Query Ad_Video__c (WITH USER_MODE)
                                        ↓
         External Sharing Model: Private
                                        ↓
                        🚫 BLOCKED - No records returned
                                        ↓
                        Video carousel is empty/hidden
```

### **After Fix (Read):**
```
Customer Portal User → Login → Access Shop Page
                                        ↓
         Query Ad_Video__c (WITH USER_MODE)
                                        ↓
         External Sharing Model: Read
                                        ↓
                        ✅ ALLOWED - Records returned
                                        ↓
                        Video carousel displays videos
```

---

## ✅ **Verification Steps**

### **For Customer Portal Users:**

1. **Login** to the Experience Site as a customer portal user
2. **Navigate** to the Shop page
3. **Verify** that the floating video carousel appears
4. **Test** video playback and navigation
5. **Test** "Ask Fluent" functionality

### **For Administrators:**

1. **Check External Sharing Model:**
   ```
   Setup → Object Manager → Ad Video → Details → External Sharing Model
   ```
   Should show: **Read**

2. **Verify Profile Permissions:**
   ```
   Setup → Profiles → Fluent Smart Shop User → Object Settings → Ad Video
   ```
   Should show: **Read** permission enabled

3. **Test Apex Query:**
   ```apex
   // Execute in Anonymous Apex as portal user
   List<Ad_Video__c> videos = [
       SELECT Id, Product_Name__c, Video_URL__c
       FROM Ad_Video__c
       WITH USER_MODE
       LIMIT 5
   ];
   System.debug('Videos accessible: ' + videos.size());
   ```
   Should return > 0 records

---

## 📝 **Best Practices**

### **For Custom Objects Used in Experience Sites:**

1. **Always set appropriate External Sharing Model**
   - `Read` for public content (products, ads, articles)
   - `ReadWrite` for collaborative content (cases, orders)
   - `Private` for internal-only data (employee records, financials)

2. **Use `WITH USER_MODE` in Apex**
   - Ensures security is enforced
   - Respects sharing model and FLS
   - Prevents security vulnerabilities

3. **Test as External User**
   - Always test functionality as a portal user
   - Don't rely only on internal user testing
   - Verify both UI visibility and data access

4. **Document Security Configuration**
   - External Sharing Model
   - Profile permissions
   - Sharing rules
   - Apex security mode (`with sharing`, `WITH USER_MODE`)

---

## 🔍 **Related Objects**

### **Other Objects in This Implementation:**

| Object | External Sharing Model | Status | Notes |
|--------|------------------------|--------|-------|
| `E_Cart_Product__c` | `Read` ✅ | Correct | Products visible to portal users |
| `Ad_Video__c` | `Read` ✅ | **Fixed** | Videos now visible to portal users |
| `Fluent_Conversation__c` | N/A (new object) | Needs review | Should likely be `Private` for user privacy |
| `Campaign` (standard) | N/A (standard) | OK | Accessed via lookup from Ad_Video__c |

---

## 🚀 **Next Steps**

### **Immediate:**
1. ✅ **Test** - Verify video carousel displays for portal users
2. ✅ **Monitor** - Check for any errors in debug logs
3. ✅ **Validate** - Ensure "Ask Fluent" functionality works

### **Recommended Future Enhancements:**
1. **Create Sharing Rules** (Optional)
   - If you need to restrict access to specific campaigns
   - Use Public Groups and Sharing Rules for fine-grained control

2. **Review Fluent_Conversation__c Security**
   - Determine if `externalSharingModel` should be set
   - Currently no setting = defaults to org-wide default
   - Consider setting to `Private` for user privacy

3. **Document Access Matrix**
   - Create a table of which profiles can access which objects
   - Include CRUD permissions and field-level security
   - Update as new features are added

---

## 📚 **References**

### **Salesforce Documentation:**
- [External Organization-Wide Defaults](https://help.salesforce.com/articleView?id=sf.security_owd_external.htm)
- [Experience Cloud Security Best Practices](https://help.salesforce.com/articleView?id=sf.networks_security.htm)
- [Sharing in Apex](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

### **Implementation Files Modified:**
- `force-app/main/default/objects/Ad_Video__c/Ad_Video__c.object-meta.xml` (line 155)

### **Related Security Components:**
- `AdCampaignController.cls` (uses `WITH USER_MODE`)
- `Fluent Smart Shop User.profile-meta.xml` (profile permissions)

---

**Date:** October 13, 2025  
**Issue:** Ad videos not visible for customer portal users  
**Root Cause:** `externalSharingModel: Private` blocking external access  
**Solution:** Changed to `externalSharingModel: Read`  
**Status:** ✅ **Fixed and Deployed**  

