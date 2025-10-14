/**
 * Script to check and fix E_Cart_Product__c image URLs
 * Run this in Developer Console > Debug > Open Execute Anonymous Window
 */

// Step 1: Check current product image URLs
List<E_Cart_Product__c> products = [
    SELECT Id, Name, Image_URL__c, Product_Code__c
    FROM E_Cart_Product__c
    WHERE Product_Code__c LIKE 'CHROMECAST%'
];

System.debug('=== Current Product Image URLs ===');
for (E_Cart_Product__c prod : products) {
    System.debug('Product: ' + prod.Name);
    System.debug('Current Image URL: ' + prod.Image_URL__c);
    System.debug('---');
}

// Step 2: Check if there are ContentVersion records (uploaded files)
List<ContentVersion> contentVersions = [
    SELECT Id, Title, FileType, ContentUrl, VersionData, 
           DistributeUrl__c, ContentDocumentId
    FROM ContentVersion
    WHERE Title LIKE '%Chromecast%'
    AND IsLatest = true
    LIMIT 10
];

System.debug('\n=== Found Uploaded Files ===');
if (contentVersions.isEmpty()) {
    System.debug('❌ No Chromecast images found in Files');
    System.debug('Please upload images to Salesforce Files first');
} else {
    for (ContentVersion cv : contentVersions) {
        System.debug('File: ' + cv.Title);
        System.debug('File Type: ' + cv.FileType);
        System.debug('Content Version ID: ' + cv.Id);
        System.debug('Content Document ID: ' + cv.ContentDocumentId);
        
        // The URL format you're seeing
        String internalUrl = '/sfc/servlet.shepherd/version/download/' + cv.Id;
        System.debug('Internal URL: ' + internalUrl);
        System.debug('⚠️ This URL requires authentication and won\'t work on Experience Sites');
        System.debug('---');
    }
}

// Step 3: Check for Content Deliveries (public URLs)
List<ContentDistribution> distributions = [
    SELECT Id, ContentVersionId, Name, DistributionPublicUrl
    FROM ContentDistribution
    WHERE ContentVersion.Title LIKE '%Chromecast%'
    LIMIT 10
];

System.debug('\n=== Content Deliveries (Public URLs) ===');
if (distributions.isEmpty()) {
    System.debug('❌ No Content Deliveries found');
    System.debug('💡 You need to create Content Deliveries for your images');
    System.debug('💡 Go to Setup > Content Deliveries > New');
} else {
    for (ContentDistribution cd : distributions) {
        System.debug('Distribution Name: ' + cd.Name);
        System.debug('✅ Public URL: ' + cd.DistributionPublicUrl);
        System.debug('Content Version ID: ' + cd.ContentVersionId);
        System.debug('---');
    }
}

// Step 4: Instructions
System.debug('\n=== NEXT STEPS ===');
System.debug('1. If you see "No Content Deliveries found":');
System.debug('   - Go to Setup > Quick Find > "Content Deliveries"');
System.debug('   - Click "New"');
System.debug('   - Select your Chromecast image file');
System.debug('   - Click Save');
System.debug('   - Copy the "Public URL"');
System.debug('');
System.debug('2. Update your product records:');
System.debug('   - Use the Public URL from Content Delivery');
System.debug('   - Or use external image hosting (Unsplash, Imgur, etc.)');
System.debug('');
System.debug('3. Alternative: Use the Unsplash URLs that already work:');
System.debug('   - These are already in your setup script');
System.debug('   - They display reliably on Experience Sites');

