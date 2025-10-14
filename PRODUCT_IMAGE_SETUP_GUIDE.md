# Product Image Setup Guide for Experience Sites

## 🚨 Problem: Images Not Displaying

When you upload images to Salesforce Files and use internal URLs like:
```
/sfc/servlet.shepherd/version/download/068gK000004T5N0QAK
```

**These URLs DON'T work on Experience Sites** because they require authentication.

---

## ✅ Solution: Create Content Deliveries (Public URLs)

Content Deliveries create publicly accessible, CDN-hosted URLs that work on Experience Sites.

---

## 📋 Method 1: Automatic Script (Fastest)

### Step 1: Upload Your Images
1. Go to **Files** tab in Salesforce
2. Click **Upload Files**
3. Upload your Chromecast product images
4. Name them clearly (e.g., "Chromecast 3rd Gen", "Chromecast Ultra", etc.)

### Step 2: Run the Diagnostic Script
1. Open **Developer Console** (Gear icon → Developer Console)
2. Go to **Debug** → **Open Execute Anonymous Window**
3. Copy and paste the content from `scripts/fix_product_images.apex`
4. Click **Execute**
5. Check the debug log to see current status

### Step 3: Create Content Deliveries & Update Products
1. In **Developer Console** → **Debug** → **Open Execute Anonymous Window**
2. Copy and paste the content from `scripts/create_content_deliveries.apex`
3. Click **Execute**
4. The script will:
   - ✅ Create Content Deliveries for all Chromecast images
   - ✅ Get public URLs
   - ✅ Automatically update E_Cart_Product__c records
   - ✅ Display all public URLs in the debug log

### Step 4: Verify
1. Go to your **E_Cart_Product__c** records
2. Check that **Image_URL__c** field now contains URLs starting with:
   ```
   https://[your-domain].my.salesforce-sites.com/...
   ```
3. Visit your Experience Site and check if images display

---

## 📋 Method 2: Manual Setup (UI-Based)

### Step 1: Upload Your Images
1. Go to **Files** tab
2. Click **Upload Files**
3. Upload Chromecast product images

### Step 2: Create Content Delivery for Each Image
1. Go to **Setup** → Quick Find → Search **"Content Deliveries"**
2. Click **New**
3. **Search and Select** your uploaded image file
4. Configure:
   - **Name**: "Chromecast 3rd Gen - Public" (or similar)
   - ☑️ **Allow viewers to download content as a file**
   - ☑️ **Allow view in browser**
   - ☐ **Password required** (leave unchecked)
5. Click **Save**
6. Copy the **Public URL** (it will look like):
   ```
   https://orgfarm-90da26143e--c.documentforce.com/sfc/dist/version/...
   ```

### Step 3: Update Product Records
1. Go to **E-Cart Products** tab
2. Find your Chromecast product (e.g., "Chromecast (3rd Generation)")
3. Click **Edit**
4. Paste the **Public URL** into the **Image URL** field
5. Click **Save**
6. Repeat for all products

### Step 4: Verify
1. Visit your Experience Site
2. Check if product images now display correctly

---

## 🔍 Troubleshooting

### Issue: Images still not displaying

**Check 1: URL Format**
- ❌ BAD: `/sfc/servlet.shepherd/version/download/...`
- ✅ GOOD: `https://[domain].my.salesforce-sites.com/...`

**Check 2: Content Delivery Settings**
```apex
// Run this to verify your Content Deliveries:
List<ContentDistribution> cds = [
    SELECT Name, DistributionPublicUrl, 
           PreferencesAllowViewInBrowser,
           PreferencesPasswordRequired
    FROM ContentDistribution
    WHERE ContentVersion.Title LIKE '%Chromecast%'
];

for (ContentDistribution cd : cds) {
    System.debug('Name: ' + cd.Name);
    System.debug('URL: ' + cd.DistributionPublicUrl);
    System.debug('View in Browser: ' + cd.PreferencesAllowViewInBrowser);
    System.debug('Password Required: ' + cd.PreferencesPasswordRequired);
}
```

**Check 3: Experience Site Permissions**
1. Go to **Experience Builder** → Your site
2. Go to **Settings** → **General**
3. Ensure **Allow Public Access** is enabled (if using as guest)

**Check 4: Test URL Directly**
- Copy the public URL from your product record
- Paste it directly in a browser
- If it doesn't open, the Content Delivery isn't configured correctly

---

## 🎯 Alternative: Use External Image Hosting

If Content Deliveries don't work for your use case, use external hosting:

### Option 1: Unsplash (Already in setup script)
```apex
// These work out-of-the-box:
Image_URL__c = 'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=400&h=400&fit=crop'
```

### Option 2: Imgur
1. Go to [imgur.com](https://imgur.com)
2. Upload your Chromecast images
3. Right-click → **Copy Image Address**
4. Use that URL in your product records

### Option 3: Cloudinary (Free tier)
1. Sign up at [cloudinary.com](https://cloudinary.com)
2. Upload images
3. Get public URLs
4. Use in product records

---

## 📊 Current Product Setup

Based on your screenshot, here's what needs to be updated:

| Product | Current URL | Status | Solution |
|---------|-------------|--------|----------|
| Chromecast (3rd Gen) | `/sfc/servlet.shepherd/version/download/068gK000004T5N0QAK` | ❌ Not displaying | Create Content Delivery |
| Chromecast Google TV | TBD | ❌ Not displaying | Create Content Delivery |
| Chromecast Ultra | TBD | ❌ Not displaying | Create Content Delivery |

---

## 🚀 Quick Commands

### View Current Product URLs:
```apex
List<E_Cart_Product__c> products = [
    SELECT Name, Image_URL__c, Product_Code__c
    FROM E_Cart_Product__c
    WHERE Product_Code__c LIKE 'CHROMECAST%'
];

for (E_Cart_Product__c p : products) {
    System.debug(p.Name + ': ' + p.Image_URL__c);
}
```

### Delete All Content Deliveries (if you need to start over):
```apex
List<ContentDistribution> cds = [
    SELECT Id 
    FROM ContentDistribution 
    WHERE ContentVersion.Title LIKE '%Chromecast%'
];
delete cds;
System.debug('Deleted ' + cds.size() + ' Content Deliveries');
```

---

## ✅ Success Checklist

- [ ] Uploaded Chromecast images to Salesforce Files
- [ ] Created Content Deliveries for each image
- [ ] Copied public URLs from Content Deliveries
- [ ] Updated E_Cart_Product__c Image_URL__c fields with public URLs
- [ ] Verified URLs start with `https://` not `/sfc/`
- [ ] Tested image URLs directly in browser
- [ ] Checked images display on Experience Site
- [ ] Checked images display on product detail pages

---

Need help? Run the diagnostic script (`fix_product_images.apex`) to see exactly what's configured!

