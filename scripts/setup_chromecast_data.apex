/**
 * Chromecast Product & Video Setup Script
 * Run this in Developer Console > Debug > Open Execute Anonymous Window
 */

// Step 1: Create Chromecast Products
List<E_Cart_Product__c> products = new List<E_Cart_Product__c>();

products.add(new E_Cart_Product__c(
    Name = 'Chromecast (3rd Generation)',
    Description__c = 'Stream entertainment to your TV in up to 1080p Full HD. Supports 800+ apps including Netflix, YouTube, Spotify, and more. Easy setup with Google Home app.',
    Price__c = 29.99,
    Image_URL__c = 'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=400&h=400&fit=crop',
    Product_Code__c = 'CHROMECAST-3GEN'
));

products.add(new E_Cart_Product__c(
    Name = 'Chromecast with Google TV (4K)',
    Description__c = '4K HDR streaming with Google TV interface, voice remote, and personalized recommendations. Includes remote control for easy navigation.',
    Price__c = 49.99,
    Image_URL__c = 'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=400&h=400&fit=crop',
    Product_Code__c = 'CHROMECAST-GTV-4K'
));

products.add(new E_Cart_Product__c(
    Name = 'Chromecast Ultra',
    Description__c = 'Premium 4K HDR streaming with Ethernet port for stable connection. Best for gaming with Google Stadia and high-quality content streaming.',
    Price__c = 69.99,
    Image_URL__c = 'https://images.unsplash.com/photo-1593640495253-23196b27a87f?w=400&h=400&fit=crop',
    Product_Code__c = 'CHROMECAST-ULTRA'
));

products.add(new E_Cart_Product__c(
    Name = 'Chromecast + Nest Mini Bundle',
    Description__c = 'Chromecast 3rd Gen + Google Nest Mini smart speaker. Control your TV with voice commands through Google Assistant.',
    Price__c = 59.99,
    Image_URL__c = 'https://images.unsplash.com/photo-1558089687-e1380f5d8cb5?w=400&h=400&fit=crop',
    Product_Code__c = 'BUNDLE-CHROMECAST-NEST'
));

products.add(new E_Cart_Product__c(
    Name = 'Chromecast Ethernet Adapter',
    Description__c = 'Wired network connection for stable streaming. Compatible with Chromecast (3rd Gen) and Chromecast with Google TV.',
    Price__c = 14.99,
    Image_URL__c = 'https://images.unsplash.com/photo-1625948515291-69613efd103f?w=400&h=400&fit=crop',
    Product_Code__c = 'ACC-ETHERNET-ADAPTER'
));

products.add(new E_Cart_Product__c(
    Name = 'Google Stadia Controller',
    Description__c = 'Wireless gaming controller for Stadia on Chromecast Ultra. Low latency, WiFi connected, rechargeable battery.',
    Price__c = 69.99,
    Image_URL__c = 'https://images.unsplash.com/photo-1592840496694-26d035b52b48?w=400&h=400&fit=crop',
    Product_Code__c = 'ACC-STADIA-CONTROLLER'
));

insert products;
System.debug('✅ Created ' + products.size() + ' Chromecast products');

// Step 2: Update Ad_Video__c records
List<Ad_Video__c> videos = [SELECT Id, Video_URL__c FROM Ad_Video__c WHERE Video_URL__c LIKE '%commondatastorage.googleapis.com%'];

for (Ad_Video__c video : videos) {
    if (video.Video_URL__c.contains('ForBiggerEscapes')) {
        video.Product_Name__c = 'Chromecast (3rd Generation)';
        video.Product_Code__c = 'CHROMECAST-3GEN';
        video.Suggestion_Questions__c = 'What is Chromecast and how does it work?;Can I stream Netflix and YouTube on Chromecast?;What\'s the difference between Chromecast and Chromecast Ultra?;Do you have Chromecast compatible TVs?;What streaming services work with Chromecast?';
    } else if (video.Video_URL__c.contains('ForBiggerJoyrides')) {
        video.Product_Name__c = 'Chromecast with Google TV (4K)';
        video.Product_Code__c = 'CHROMECAST-GTV-4K';
        video.Suggestion_Questions__c = 'Can I use Chromecast while traveling?;How do I cast from my phone to my TV?;What mobile apps work with Chromecast?;Tell me about portable Chromecast setup;Can I cast music and videos from my car?';
    } else if (video.Video_URL__c.contains('ForBiggerFun')) {
        video.Product_Name__c = 'Chromecast Ultra';
        video.Product_Code__c = 'CHROMECAST-ULTRA';
        video.Suggestion_Questions__c = 'Can I play games on Chromecast?;What are the best Chromecast apps for entertainment?;How do I set up Chromecast for family viewing?;Tell me about Chromecast with Google TV;Can I mirror my phone screen to Chromecast?';
    }
}

update videos;
System.debug('✅ Updated ' + videos.size() + ' video records with Chromecast content');

System.debug('\n========================================');
System.debug('🎉 Chromecast Setup Complete!');
System.debug('========================================');
System.debug('✅ ' + products.size() + ' products created');
System.debug('✅ ' + videos.size() + ' videos updated');
System.debug('\nNext Steps:');
System.debug('1. Configure Agent Knowledge Base');
System.debug('2. Set up Agent Topics & Utterances');
System.debug('3. Test conversation flows on Experience Site');
System.debug('========================================\n');

