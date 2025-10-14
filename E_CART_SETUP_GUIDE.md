# E-Cart Page Setup Guide

## ✅ Part 1: Create Sample Product Data (Manual Entry)

Since automated import is having issues with field-level security, let's manually create a few sample products:

### Option A: Quick Create via Salesforce UI

1. **Go to Salesforce Setup** → Object Manager → E-Cart Product → New

2. **Create these 3 products** (copy-paste the values):

**Product 1:**
- Name: `Wireless Headphones`
- Description: `Premium noise-cancelling wireless headphones with 30-hour battery life. Perfect for music lovers and professionals.`
- Price: `299.99`
- Image URL: `https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400`

**Product 2:**
- Name: `Smart Watch`
- Description: `Fitness tracking smartwatch with heart rate monitor, GPS, and water resistance. Stay connected on the go.`
- Price: `399.99`
- Image URL: `https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400`

**Product 3:**
- Name: `Laptop Backpack`
- Description: `Durable travel backpack with padded laptop compartment, USB charging port, and water-resistant material.`
- Price: `79.99`
- Image URL: `https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400`

### Option B: Use Data Import Wizard (Recommended for bulk)

1. Download the CSV file from: `sample-data/E_Cart_Products.csv`
2. Go to **Setup** → **Data Import Wizard**
3. Select **Custom Objects** → **E-Cart Products**
4. Upload the CSV file
5. Map fields: Name → Name, Description__c → Description, Price__c → Price, Image_URL__c → Image URL
6. Click **Start Import**

---

## ✅ Part 2: Build E-Cart Page in Experience Builder

### Step 1: Open Experience Builder

1. Navigate to your **Fluent Experience Site**
2. Click **Builder** (or go to Experience Builder)
3. Click **+ New Page** or edit the existing "Shop" page

### Step 2: Set Page Layout

1. **Page Name**: Shop (or E-Cart)
2. **Page URL**: /shop
3. **Choose Layout**: `Standard` or `Full Width`

### Step 3: Add Page Title

1. Drag **Headline** component to the top
2. Set text: `Our Products`
3. Style: Heading 1, Center aligned
4. Padding: Top 40px, Bottom 20px

### Step 4: Add Product Grid using Record List

1. **Drag "Record List" component** onto the page
2. Configure:
   - **Object**: E-Cart Product
   - **Layout**: Tiles
   - **Number of Records**: 12
   - **Columns**: 3 (Desktop), 2 (Tablet), 1 (Mobile)
   - **Display As**: Grid
   - **Sort By**: Name (Ascending)

3. **Customize Tile Display**:
   - Click **Configure Tiles**
   - Enable these fields to display:
     - Image (use Image_URL__c)
     - Name
     - Description__c
     - Price__c
   - Set **Image Height**: 200px
   - Enable **Hover Effects**

### Step 5: Style the Product Tiles

Since Experience Builder Record List has limited styling, let's add a custom CSS via HTML Editor:

1. **Drag "HTML Editor" component** above or below the Record List
2. Add this styling code:

```html
<style>
/* Product Grid Container */
.slds-grid {
    gap: 24px;
    padding: 20px;
}

/* Product Tiles */
.tile {
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    overflow: hidden;
}

.tile:hover {
    transform: translateY(-8px);
    box-shadow: 0 12px 24px rgba(0,0,0,0.15);
}

/* Product Images */
.tile img {
    width: 100%;
    height: 200px;
    object-fit: cover;
}

/* Product Info */
.tile-body {
    padding: 16px;
}

.tile-title {
    font-size: 18px;
    font-weight: 600;
    color: #181818;
    margin-bottom: 8px;
}

.tile-description {
    font-size: 14px;
    color: #666;
    line-height: 1.5;
    margin-bottom: 12px;
}

.tile-price {
    font-size: 20px;
    font-weight: 700;
    color: #007bff;
}

/* Page Background */
body {
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
```

### Step 6: Add the Floating Video Carousel

1. **Drag "conversationalAdPlayer" LWC component** onto the page
2. **Place it at the bottom** of the page structure (it will float automatically)
3. **Set Campaign ID** in component properties:
   - Campaign ID: `701gK00000NyCAkQAN` (your current campaign)

**Note**: The video carousel is already configured to float in the bottom-right corner. You don't need any additional CSS!

### Step 7: Add Navigation (Optional)

1. Drag **"Navigation Menu"** component to the top
2. Add menu items:
   - Home
   - Shop
   - About
   - Contact

### Step 8: Add Footer (Optional)

1. Drag **"Text"** component to the bottom
2. Add copyright text: `© 2024 Fluent Shop. All rights reserved.`
3. Center align, small font size

---

## ✅ Part 3: Alternative Approach - Custom Product Display

If you want more control over the product display, let's create a custom LWC:

### Create Product Card LWC

I can help you build a custom `productGrid` LWC component that:
- Fetches E-Cart Products via Apex
- Displays them in a responsive grid
- Has beautiful hover effects
- Works seamlessly with the floating video carousel

Would you like me to create this custom component instead?

---

## ✅ Part 4: Publish and Test

1. Click **Publish** in Experience Builder
2. Navigate to:  
   `https://orgfarm-90da26143e-dev-ed.develop.my.site.com/fluent/shop`

3. **Test**:
   - Products should display in a grid
   - Video carousel should float in bottom-right
   - Video should be draggable
   - Click "Ask Fluent anything!" to test chat

---

## 🎨 Styling Tips

### Make it Look Like the Demo

The demo (https://rodeo-vibes-600-2a892294423b.herokuapp.com/) has:
- Clean white background
- Centered product grid
- Large product images
- Hover effects with elevation
- Floating video in corner

To match this:
1. Use the HTML Editor CSS above
2. Adjust colors to match your brand
3. Set page background to white or light gradient
4. Enable hover effects on tiles

---

## 📝 Quick Reference: Component Locations

- **Headline**: For page titles
- **Text**: For descriptions
- **HTML Editor**: For custom HTML/CSS
- **Record List**: For displaying Salesforce records in grid/list
- **conversationalAdPlayer**: Your floating video carousel (already deployed)
- **Button**: For "Add to Cart" actions (if needed)
- **Tile**: Alternative to Record List for custom layouts

---

## 🚀 Next Steps

After setting up the basic page:

1. **Add "Add to Cart" functionality** (if needed)
2. **Create a Cart page** to show selected items
3. **Add checkout flow**
4. **Connect with Salesforce Commerce** (optional)

Let me know which approach you'd like to take, and I'll help you implement it!

