# 🛍️ E-Cart Page - Experience Builder Step-by-Step Guide

## ✅ Prerequisites (COMPLETED)
- ✅ 12 Products successfully created in Salesforce
- ✅ Draggable video carousel component ready
- ✅ All necessary permissions configured

---

## 📋 Step-by-Step Instructions

### **Step 1: Open Experience Builder**

1. Navigate to: `https://orgfarm-90da26143e-dev-ed.develop.builder.salesforce-experience.com/`
2. Or go to **Setup** → **All Sites** → Click on **Fluent** → **Builder**

---

### **Step 2: Create or Edit the Shop Page**

#### Option A: Create New Page
1. In Experience Builder, click **Pages** (left sidebar)
2. Click **+ New Page**
3. Select **Standard Page**
4. Set:
   - **Page Name**: `Shop`
   - **Page URL**: `shop`
5. Click **Create**

#### Option B: Edit Existing Page
1. If you already have a "Shop" page, click on it to edit
2. Clear any existing content if needed

---

### **Step 3: Set Page Layout**

1. With the Shop page open, look at the **Page Structure** panel (left side)
2. Select the **Page** itself (topmost element)
3. In **Properties** (right panel):
   - **Page Background**: White or Light Gray (`#f5f7fa`)
   - **Page Width**: Full Width or Standard (your preference)

---

### **Step 4: Add Page Header**

Experience Builder's available components depend on your template. Try one of these options:

#### **Option A: Use HTML Editor Component**
1. Drag **"HTML Editor"** component to the page
2. In the editor, paste this code:
   ```html
   <h1 style="text-align: center; font-size: 36px; font-weight: bold; color: #181818; margin: 40px 0 20px 0;">
       Our Products
   </h1>
   ```
3. Click **Save**

#### **Option B: Use Title Component**
1. Look for **"Title"** or **"Heading"** component
2. Drag it to the page
3. Set text to `Our Products`
4. Configure alignment to Center

#### **Option C: Use Paragraph Component**
1. If you see **"Paragraph"** component, drag it to the page
2. Type `Our Products`
3. Select the text and format as Heading using the toolbar
4. Center align

#### **Option D: Skip the Header (Simplest)**
If none of these work, you can skip the page header for now and just start with the Record List. We can add styling later via HTML Editor.

---

### **Step 5: Add Product Grid (Record List Component)**

This is the main component that will display your products!

1. **Drag "Record List" component** onto the page (below the Headline)

2. **Configure Basic Settings**:
   - **Object**: `E-Cart Product` (select from dropdown)
   - **Display As**: Grid (not List)
   - **Max Records to Display**: 12
   - **Show "View All" Link**: Off (optional)

3. **Configure Grid Layout**:
   - **Desktop**: 3 columns
   - **Tablet**: 2 columns
   - **Mobile**: 1 column
   - **Spacing**: 24px

4. **Select Fields to Display**:
   Click **"Edit Fields"** and select these fields in this order:
   - ☑️ **Image** (use `Image_URL__c` field)
   - ☑️ **Name**
   - ☑️ **Description__c**
   - ☑️ **Price__c**

5. **Configure Field Display**:
   - **Image**:
     - Height: 200px
     - Fit: Cover
     - Position: Top
   - **Name**:
     - Font Size: 18px
     - Font Weight: 600 (Semibold)
   - **Description**:
     - Font Size: 14px
     - Max Lines: 2 (truncate)
   - **Price**:
     - Font Size: 20px
     - Font Weight: 700 (Bold)
     - Color: `#007bff` (Blue)
     - Prefix: `$` (if not already formatted)

6. **Configure Card Styling**:
   - **Background**: White
   - **Border**: None or Light Gray (1px solid #e0e0e0)
   - **Border Radius**: 12px
   - **Shadow**: Medium (or Custom: `0 4px 12px rgba(0,0,0,0.1)`)
   - **Padding**: 0px (image should be full-width)
   - **Content Padding**: 16px (for text area)

7. **Enable Hover Effect** (if available):
   - Hover Shadow: Large
   - Hover Transform: Slight lift (-4px)

---

### **Step 6: Add Spacing Section**

1. Drag a **"Section"** component below the Record List
2. Set height: 100px (to give space for the floating video)
3. Background: Transparent

---

### **Step 7: Add Floating Video Carousel**

1. **Drag your "conversationalAdPlayer"** LWC component onto the page
   - It should appear in the components list under "Custom Components"
   - If you don't see it, check that it's exposed for Experience Cloud

2. **Place it at the bottom** of the page structure (it will float automatically due to CSS)

3. **Configure Component Properties**:
   - **Campaign Record ID**: `701gK00000NyCAkQAN` (your current campaign)
   
   > **Note**: The component is already configured to float in the bottom-right corner. You don't need to add any additional CSS or positioning!

---

### **Step 8: Optional - Add Navigation Menu**

1. Drag **"Navigation Menu"** component to the very top of the page
2. Configure menu items:
   - Home (`/`)
   - Shop (`/shop`)
   - About (`/about`)
   - Contact (`/contact`)
3. Style: Horizontal, Center aligned

---

### **Step 9: Optional - Add Footer**

1. Drag a **"Section"** to the bottom
2. Inside it, drag a **"Text"** component
3. Set text: `© 2024 Fluent Shop. All rights reserved.`
4. Style:
   - Alignment: Center
   - Font Size: 12px
   - Color: Gray (#666)
   - Padding: 20px

---

### **Step 10: Configure Guest User Permissions**

Since this is an Experience Site, we need to ensure guest users can see the products:

1. Go to **Setup** → **Users** → **Profiles**
2. Find **Guest License User** profile (or your site's guest profile)
3. Click **Edit**
4. Under **Custom Object Permissions**, find **E-Cart Product**:
   - ☑️ Read
   - ☑️ View All (optional)
5. Under **Field-Level Security** for E-Cart Product:
   - Name: ☑️ Read
   - Description__c: ☑️ Read
   - Price__c: ☑️ Read
   - Image_URL__c: ☑️ Read
6. Click **Save**

**OR** create a Sharing Rule:

1. Go to **Setup** → **Sharing Settings**
2. Under **E-Cart Product Sharing Rules**, click **New**
3. Set:
   - Rule Name: `Guest User Access`
   - Rule Type: Guest user access, based on criteria
   - Criteria: All records
   - Share with: Guest Users
   - Access Level: Read Only
4. Click **Save**

---

### **Step 11: Publish the Site**

1. In Experience Builder, click **Publish** (top-right corner)
2. Confirm the publish action
3. Wait for "Successfully Published" message

---

### **Step 12: Test Your E-Cart Page**

1. Open your browser in **Incognito/Private mode**
2. Navigate to: `https://orgfarm-90da26143e-dev-ed.develop.my.site.com/fluent/shop`

3. **Verify**:
   - ✅ 12 products display in a grid (3 columns on desktop)
   - ✅ Each product shows: Image, Name, Description, Price
   - ✅ Cards have shadows and hover effects
   - ✅ Video carousel floats in bottom-right corner
   - ✅ Video carousel is draggable
   - ✅ Chat button works ("Ask Fluent anything!")
   - ✅ Suggestion buttons appear in chat
   - ✅ Navigating videos resets chat

---

## 🎨 Advanced Styling (Optional)

If you want more custom styling beyond what Record List offers, you can add a **Theme Layout Component** or **HTML Editor**:

### Add Custom CSS

1. Drag **"HTML Editor"** component to the top of the page
2. Add this CSS:

```html
<style>
/* Make images fully responsive */
.record-list img {
    width: 100%;
    height: 200px;
    object-fit: cover;
    border-radius: 12px 12px 0 0;
}

/* Product card styling */
.record-list .slds-tile {
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
    overflow: hidden;
    height: 100%;
}

.record-list .slds-tile:hover {
    transform: translateY(-8px);
    box-shadow: 0 12px 24px rgba(0,0,0,0.15);
}

/* Product name */
.record-list .slds-tile__title {
    font-size: 18px;
    font-weight: 600;
    color: #181818;
    margin: 12px 0 8px 0;
}

/* Product description */
.record-list .slds-tile__detail {
    font-size: 14px;
    color: #666;
    line-height: 1.5;
    margin-bottom: 12px;
}

/* Product price */
.record-list .slds-text-title {
    font-size: 20px;
    font-weight: 700;
    color: #007bff;
}

/* Grid spacing */
.record-list .slds-grid {
    gap: 24px;
}

/* Page background */
.community-page {
    background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf2 100%);
}
</style>
```

3. **Save** and **Publish**

---

## 🚨 Troubleshooting

### Products Not Showing

**Problem**: Record List is empty  
**Solution**:
1. Check if products were created (run query in Developer Console):
   ```sql
   SELECT Id, Name, Price__c FROM E_Cart_Product__c
   ```
2. Check Guest User permissions (Step 10)
3. Create Sharing Rule for Guest Users

### Images Not Loading

**Problem**: Broken image icons  
**Solution**:
1. Check if `Image_URL__c` field is populated
2. Add Unsplash domain to CSP Trusted Sites:
   - Setup → CSP Trusted Sites → New
   - Name: `Unsplash`
   - URL: `https://images.unsplash.com`
   - Active: ☑️

### Video Carousel Not Visible

**Problem**: Video component doesn't appear  
**Solution**:
1. Check component is deployed
2. Check `conversationalAdPlayer.js-meta.xml` has:
   ```xml
   <isExposed>true</isExposed>
   <targets>
       <target>lightningCommunity__Page</target>
   </targets>
   ```
3. Redeploy the component

### Video Not Draggable

**Problem**: Can't move the video window  
**Solution**:
1. Hard refresh browser (Ctrl+Shift+R)
2. Try clicking on the video itself (not buttons)
3. Check console for errors (F12)

---

## ✅ Final Checklist

Before considering the page complete:

- [ ] 12 products visible in grid layout
- [ ] Images load correctly
- [ ] Prices formatted correctly ($XX.XX)
- [ ] Descriptions truncated nicely
- [ ] Hover effects work on product cards
- [ ] Video carousel floats in bottom-right
- [ ] Video carousel is draggable
- [ ] Chat opens when clicking "Ask Fluent anything!"
- [ ] Suggestion questions appear
- [ ] Chat resets when changing videos
- [ ] Page works in incognito mode (guest user test)
- [ ] Mobile responsive (test on different screen sizes)

---

## 🎉 You're Done!

Your e-cart page is now ready with:
- ✅ Beautiful product grid with 12 items
- ✅ Draggable AI-powered video carousel
- ✅ Interactive chat with suggestions
- ✅ Fully responsive design
- ✅ Guest user access

### Next Steps (Optional Enhancements):

1. **Add "Add to Cart" functionality**
2. **Create Shopping Cart page**
3. **Implement checkout flow**
4. **Add product filtering/search**
5. **Connect with Salesforce Commerce Cloud**

Let me know if you need help with any of these enhancements! 🚀

