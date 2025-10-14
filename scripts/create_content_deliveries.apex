/**
 * Script to create Content Deliveries and update E_Cart_Product__c with public URLs
 * Run this AFTER uploading your Chromecast images to Salesforce Files
 */

// Step 1: Find uploaded Chromecast images
List<ContentVersion> chromecastImages = [
    SELECT Id, Title, ContentDocumentId
    FROM ContentVersion
    WHERE Title LIKE '%Chromecast%'
    AND IsLatest = true
    ORDER BY Title
];

if (chromecastImages.isEmpty()) {
    System.debug('❌ No Chromecast images found in Files');
    System.debug('Please upload your images to Salesforce Files first');
} else {
    System.debug('✅ Found ' + chromecastImages.size() + ' Chromecast image(s)');
    
    // Step 2: Create Content Deliveries for each image
    List<ContentDistribution> newDistributions = new List<ContentDistribution>();
    
    for (ContentVersion cv : chromecastImages) {
        // Check if distribution already exists
        List<ContentDistribution> existingDist = [
            SELECT Id 
            FROM ContentDistribution 
            WHERE ContentVersionId = :cv.Id 
            LIMIT 1
        ];
        
        if (existingDist.isEmpty()) {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title + ' - Public';
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            cd.PreferencesPasswordRequired = false;
            newDistributions.add(cd);
        } else {
            System.debug('Distribution already exists for: ' + cv.Title);
        }
    }
    
    if (!newDistributions.isEmpty()) {
        insert newDistributions;
        System.debug('✅ Created ' + newDistributions.size() + ' Content Distribution(s)');
    }
    
    // Step 3: Wait a moment for URLs to generate, then fetch them
    // Note: In real execution, URLs are available immediately after insert
    
    // Step 4: Get all distributions with public URLs
    List<ContentDistribution> allDistributions = [
        SELECT Id, ContentVersionId, DistributionPublicUrl, Name,
               ContentVersion.Title
        FROM ContentDistribution
        WHERE ContentVersion.Title LIKE '%Chromecast%'
    ];
    
    System.debug('\n=== Content Deliveries Created ===');
    Map<String, String> imageMap = new Map<String, String>();
    
    for (ContentDistribution cd : allDistributions) {
        System.debug('File: ' + cd.ContentVersion.Title);
        System.debug('✅ Public URL: ' + cd.DistributionPublicUrl);
        System.debug('---');
        
        // Map product names to URLs for automatic update
        String title = cd.ContentVersion.Title.toLowerCase();
        if (title.contains('3rd') || title.contains('gen')) {
            imageMap.put('CHROMECAST-3GEN', cd.DistributionPublicUrl);
        } else if (title.contains('google tv') || title.contains('gtv')) {
            imageMap.put('CHROMECAST-GTV-4K', cd.DistributionPublicUrl);
        } else if (title.contains('ultra')) {
            imageMap.put('CHROMECAST-ULTRA', cd.DistributionPublicUrl);
        }
    }
    
    // Step 5: Update product records with public URLs
    if (!imageMap.isEmpty()) {
        List<E_Cart_Product__c> productsToUpdate = [
            SELECT Id, Product_Code__c, Name
            FROM E_Cart_Product__c
            WHERE Product_Code__c IN :imageMap.keySet()
        ];
        
        for (E_Cart_Product__c prod : productsToUpdate) {
            if (imageMap.containsKey(prod.Product_Code__c)) {
                prod.Image_URL__c = imageMap.get(prod.Product_Code__c);
                System.debug('Updating ' + prod.Name + ' with public URL');
            }
        }
        
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
            System.debug('\n✅ Updated ' + productsToUpdate.size() + ' product(s) with public URLs');
        }
    }
    
    System.debug('\n=== DONE ===');
    System.debug('Your product images should now display on the Experience Site!');
}

