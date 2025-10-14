# E-Cart Shop - Experience Builder Setup Guide

This guide shows you how to build an e-commerce page in Salesforce Experience Builder using **standard components** with your video carousel as a floating window.

## 📋 Table of Contents

1. [Setup Product Data](#step-1-setup-product-data)
2. [Create Experience Cloud Page](#step-2-create-experience-cloud-page)
3. [Add Floating Video Carousel](#step-3-add-floating-video-carousel)
4. [Build Product Grid](#step-4-build-product-grid)
5. [Add Shopping Cart](#step-5-add-shopping-cart)
6. [Style & Customize](#step-6-style--customize)

---

## Step 1: Setup Product Data

### Deploy Product Object

```bash
sf project deploy start --source-dir force-app/main/default/objects/E_Cart_Product__c
```

### Create Sample Products

1. Go to **App Launcher** → **E-Cart Products**
2. Click **New** and create products:

| Product Name | Price | Image URL |
|-------------|-------|-----------|
| Wireless Headphones | $79.99 | https://via.placeholder.com/300x200?text=Headphones |
| Smart Watch | $199.99 | https://via.placeholder.com/300x200?text=Watch |
| Laptop Stand | $49.99 | https://via.placeholder.com/300x200?text=Stand |
| USB-C Cable | $14.99 | https://via.placeholder.com/300x200?text=Cable |
| Mechanical Keyboard | $129.99 | https://via.placeholder.com/300x200?text=Keyboard |
| Wireless Mouse | $39.99 | https://via.placeholder.com/300x200?text=Mouse |

---

## Step 2: Create Experience Cloud Page

### 2.1 Create New Page

1. Go to **Experience Builder**
2. Click **New Page**
3. Select **Standard Page**
4. Name: `Shop`
5. URL: `/shop`

### 2.2 Set Page Layout

1. Click **Page Properties** (gear icon)
2. Set **Layout**: `Header, 1 Column, Footer`
3. **Page Width**: `Full Width`

---

## Step 3: Add Floating Video Carousel

### 3.1 Add Custom Component

1. In Experience Builder, click **Components** (+ icon)
2. Search for **"Custom"** → Find your `conversationalAdPlayer`
3. Drag to the **page canvas**
4. **Don't add it to the main layout yet** - we'll make it floating

### 3.2 Make It Floating with CSS

Since Experience Builder doesn't allow direct CSS on custom components, we'll use the **HTML Editor Component** (found under Custom components):

1. Add **HTML Editor** component **above** your video carousel
2. Paste this CSS:

```html
<style>
.floating-video-carousel {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 1000;
    width: 400px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
    border-radius: 12px;
    overflow: hidden;
}

@media (max-width: 768px) {
    .floating-video-carousel {
        width: 90%;
        right: 5%;
        bottom: 10px;
    }
}
</style>
```

4. **Important**: Add a **Section** component with CSS class `floating-video-carousel`
5. Put your `conversationalAdPlayer` inside this section

### 3.3 Alternative: Use Experience Builder's Custom CSS

1. Click **Settings** → **Advanced** → **Head Markup**
2. Add the same CSS wrapped in `<style>` tags
3. In your component's wrapper section, add CSS class: `floating-video-carousel`

---

## Step 4: Build Product Grid with Standard Components

### 4.1 Add Hero Section (Top Banner)

1. Add **Section** component
2. Inside section, add **Headline** component:
   - **Heading Level**: H1
   - **Text**: `🛒 E-Cart Shop`
   - **Alignment**: Center
   - **Font Size**: 48px (adjust in styling)

Alternatively, use **HTML Editor** component:
```html
<h1 style="text-align: center; font-size: 48px; margin: 40px 0;">
    🛒 E-Cart Shop
</h1>
```

### 4.2 Add Product Grid Header

1. Add **Headline** component:
   - **Heading Level**: H2
   - **Text**: `Featured Products`
   - **Font Size**: 32px

### 4.3 Use Record List Component

Since Experience Builder's standard components are limited for product grids, here are your best options:

#### **Option A: CMS Collection (Recommended)**

1. Go to **Setup** → **CMS Workspaces**
2. Create workspace: `E-Cart CMS`
3. Add **CMS Collection**: `Products`
4. Link to `E_Cart_Product__c` records

5. In Experience Builder:
   - Add **CMS Collection** component
   - Select your Products collection
   - Choose **Tile Layout** (Grid view)
   - Set columns: **3** (desktop), **2** (tablet), **1** (mobile)

#### **Option B: Record List Component**

1. Add **Record List** component
2. Configure:
   - **Object**: `E_Cart_Product__c`
   - **Layout**: `Tile`
   - **Number of Records**: `12`
   - **Columns**: `3`
   - **Show Images**: ✓ Checked
   - **Image Field**: `Image_URL__c`
   - **Title Field**: `Name`
   - **Description Field**: `Description__c`

3. Add **Custom Button** to each tile (in record detail):
   - Label: `Add to Cart`
   - Action: `Navigate to URL` → `/cart?productId={!recordId}`

#### **Option C: Tile Component (Manual)**

For complete control, use **Tile** components manually:

1. Add **3-Column Section**
2. In each column, add **Tile** component:
   - **Image Source**: Static or Dynamic (from Image_URL__c)
   - **Title**: Product Name
   - **Description**: Price
   - **Button**: "Add to Cart"
   - **Button Action**: Navigate to `/cart` or Fire Event

3. Repeat for 12 products (4 rows × 3 columns)

---

## Step 5: Add Shopping Cart Functionality

Since standard Experience Builder doesn't have built-in cart, you have options:

### Option A: Use Commerce Cloud (Best for Full E-Commerce)

1. Enable **B2B/B2C Commerce**
2. Use **Commerce Components**:
   - `Commerce Product List`
   - `Commerce Cart`
   - `Commerce Checkout`

### Option B: Create Simple Cart Component

1. Create a new LWC: `simpleCartIcon`
2. Shows cart count in header
3. Clicking opens cart modal

### Option C: Use URL Parameters (Quick & Simple)

1. When user clicks "Add to Cart":
   - Navigate to `/cart?products=prod1,prod2,prod3`
   - Cart page reads URL parameters
   - Display selected products

---

## Step 6: Style & Customize

### 6.1 Theme Settings

1. Go to **Settings** → **Theme**
2. Configure:
   - **Primary Color**: `#007bff`
   - **Secondary Color**: `#6c757d`
   - **Font**: `Inter` or `Salesforce Sans`

### 6.2 Header with Cart Icon

1. Click **Header** in Experience Builder
2. Add **Navigation Menu** (standard component)
3. Add **HTML Editor** component for cart icon:

```html
<div style="position: absolute; top: 20px; right: 20px;">
    <a href="/cart" style="text-decoration: none; font-size: 24px;">
        🛍️ <span style="background: red; color: white; border-radius: 50%; padding: 2px 8px; font-size: 14px;">0</span>
    </a>
</div>
```

OR use **Button** + **Text** components positioned with flexbox.

### 6.3 Footer

1. Click **Footer** in Experience Builder
2. Add **Text** component:
   - Content: `© 2025 E-Cart Shop. All vibes reserved! 🎉`
   - Alignment: Center
   
OR use **HTML Editor**:
```html
<p style="text-align: center; padding: 20px; color: #666;">
    © 2025 E-Cart Shop. All vibes reserved! 🎉
</p>
```

---

## Step 7: Make Video Carousel Floating

Since we can't directly modify component CSS in Experience Builder, here's the workaround:

### Method 1: Wrapper Section with Custom CSS

1. Add this to **Site Settings** → **Advanced** → **Head Markup**:

```html
<style>
/* Floating Video Carousel */
.floating-video-wrapper {
    position: fixed !important;
    bottom: 20px !important;
    right: 20px !important;
    z-index: 9999 !important;
    width: 450px !important;
    max-width: 90vw !important;
}

.floating-video-wrapper .slds-card {
    box-shadow: 0 10px 40px rgba(0,0,0,0.3) !important;
    border-radius: 12px !important;
}

/* Hide on mobile if needed */
@media (max-width: 768px) {
    .floating-video-wrapper {
        width: calc(100% - 40px) !important;
        right: 20px !important;
    }
}
</style>
```

2. Add your `conversationalAdPlayer` component
3. In the component's **CSS Classes** property, add: `floating-video-wrapper`

### Method 2: Update Component CSS

Update your `conversationalAdPlayer.css` to make it floating by default:

```css
:host {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 9999;
    width: 450px;
    max-width: 90vw;
}
```

---

## Step 8: Alternative Simple Layout (No Custom Components)

If you want to avoid custom components entirely:

### Product Cards with Standard Components Only

```
Page Layout:
├── Header (Navigation Menu + Cart Icon)
├── Hero Section (Rich Text with Title)
├── Product Grid Section
│   ├── Row 1
│   │   ├── Tile 1 (Wireless Headphones)
│   │   ├── Tile 2 (Smart Watch)
│   │   └── Tile 3 (Laptop Stand)
│   ├── Row 2
│   │   ├── Tile 4 (USB-C Cable)
│   │   ├── Tile 5 (Mechanical Keyboard)
│   │   └── Tile 6 (Wireless Mouse)
│   └── ... (more rows)
└── Footer (Rich Text with Copyright)
```

Each Tile Component:
- **Image**: Product image
- **Heading**: Product name
- **Body**: Price
- **Button**: "Add to Cart"
- **Button Action**: Navigate or Fire Event

---

## Step 9: Connect Video Carousel to Products

To make video ads contextual to products:

1. Add `Product__c` lookup field to `Ad_Video__c`:

```xml
<CustomField>
    <fullName>Product__c</fullName>
    <label>Related Product</label>
    <type>Lookup</type>
    <referenceTo>E_Cart_Product__c</referenceTo>
</CustomField>
```

2. When video shows, display related product info
3. Add "Buy Now" button in video carousel chat
4. Clicking "Buy Now" adds product to cart

---

## Complete Page Structure

```
┌─────────────────────────────────────────┐
│ HEADER (Navigation + Cart Icon)         │
├─────────────────────────────────────────┤
│                                         │
│        🛒 E-Cart Shop (Hero)            │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│     Featured Products (Heading)         │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐     │
│  │Product │ │Product │ │Product │     │
│  │   1    │ │   2    │ │   3    │     │
│  └────────┘ └────────┘ └────────┘     │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐     │
│  │Product │ │Product │ │Product │     │
│  │   4    │ │   5    │ │   6    │     │
│  └────────┘ └────────┘ └────────┘     │
│                                         │
├─────────────────────────────────────────┤
│  FOOTER (Copyright)                     │
└─────────────────────────────────────────┘
                                    ┌──────────┐
                                    │  Video   │
                                    │ Carousel │
                                    │ (Float)  │
                                    └──────────┘
```

---

## Testing Checklist

- [ ] Products display in grid (3 columns)
- [ ] Product images load correctly
- [ ] Prices display properly
- [ ] "Add to Cart" buttons work
- [ ] Video carousel floats on right side
- [ ] Video carousel doesn't block products
- [ ] Cart icon shows in header
- [ ] Mobile responsive (video resizes)
- [ ] Footer displays correctly

---

## Tips & Best Practices

1. **Use CMS Collections** for dynamic product management
2. **Enable Guest User Access** to objects and fields
3. **Optimize Images** - use CDN or Salesforce Files
4. **Test Mobile View** - floating video should resize
5. **Consider Performance** - lazy load products if many
6. **Use Sharing Rules** for public access
7. **Cache Settings** - enable caching for better performance

---

## Troubleshooting

### Video Carousel Not Floating

- Check if CSS class is applied
- Verify Head Markup CSS is added
- Check z-index isn't being overridden
- Try `!important` on position properties

### Products Not Showing

- Check Guest User profile permissions
- Verify sharing rules for `E_Cart_Product__c`
- Check record list component filters

### Cart Not Working

- Verify URL parameters are passing
- Check navigation actions are configured
- Ensure cart page exists and is published

---

## Next Steps

1. **Deploy Product Object**: `sf project deploy start`
2. **Create Products**: Add 12 sample products
3. **Build Page**: Follow steps in Experience Builder
4. **Add Video Carousel**: Make it floating
5. **Test**: Verify all functionality
6. **Publish**: Make site live

---

**Need Help?** Check Salesforce Experience Builder documentation or Trailhead modules on Experience Cloud!

