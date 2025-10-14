@isTest
private class AdCampaignControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test campaigns
        Campaign activeCampaign = new Campaign(
            Name = 'Active Test Campaign',
            IsActive = true,
            StartDate = Date.today().addDays(-10),
            EndDate = Date.today().addDays(10)
        );
        insert activeCampaign;
        
        Campaign inactiveCampaign = new Campaign(
            Name = 'Inactive Test Campaign',
            IsActive = false
        );
        insert inactiveCampaign;
        
        // Create test videos for active campaign
        List<Ad_Video__c> videos = new List<Ad_Video__c>();
        videos.add(new Ad_Video__c(
            Product_Name__c = 'Product A',
            Video_Id__c = 'video123',
            Order__c = 1,
            Video_Source_Type__c = 'YouTube',
            Video_URL__c = 'https://youtube.com/watch?v=video123',
            Suggestion_Questions__c = 'What is this product?',
            Ad_Campaign__c = activeCampaign.Id
        ));
        videos.add(new Ad_Video__c(
            Product_Name__c = 'Product B',
            Video_Id__c = 'video456',
            Order__c = 2,
            Video_Source_Type__c = 'YouTube',
            Video_URL__c = 'https://youtube.com/watch?v=video456',
            Suggestion_Questions__c = 'How does it work?',
            Ad_Campaign__c = activeCampaign.Id
        ));
        
        // Create test video for inactive campaign
        videos.add(new Ad_Video__c(
            Product_Name__c = 'Product C',
            Video_Id__c = 'video789',
            Order__c = 1,
            Video_Source_Type__c = 'Static Resource',
            Video_URL__c = '/apex/TestVideo',
            Suggestion_Questions__c = 'Where to buy?',
            Ad_Campaign__c = inactiveCampaign.Id
        ));
        
        // Create test video without campaign
        videos.add(new Ad_Video__c(
            Product_Name__c = 'Product D',
            Video_Id__c = 'video000',
            Order__c = 3,
            Video_Source_Type__c = 'YouTube',
            Video_URL__c = 'https://youtube.com/watch?v=video000',
            Suggestion_Questions__c = 'Is it available?'
        ));
        
        insert videos;
    }
    
    @isTest
    static void testGetCampaignVideosWithCampaignId() {
        // Get the test campaign
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Active Test Campaign' LIMIT 1];
        
        Test.startTest();
        List<Ad_Video__c> results = AdCampaignController.getCampaignVideos(testCampaign.Id);
        Test.stopTest();
        
        // Verify we got the correct videos
        System.assertEquals(2, results.size(), 'Should return 2 videos for active campaign');
        System.assertEquals('Product A', results[0].Product_Name__c, 'First video should be Product A');
        System.assertEquals('Product B', results[1].Product_Name__c, 'Second video should be Product B');
    }
    
    @isTest
    static void testGetCampaignVideosOrderBy() {
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Active Test Campaign' LIMIT 1];
        
        Test.startTest();
        List<Ad_Video__c> results = AdCampaignController.getCampaignVideos(testCampaign.Id);
        Test.stopTest();
        
        // Verify videos are ordered correctly
        System.assertEquals(1, results[0].Order__c, 'First video should have Order 1');
        System.assertEquals(2, results[1].Order__c, 'Second video should have Order 2');
    }
    
    @isTest
    static void testGetCampaignVideosFieldAccess() {
        Campaign testCampaign = [SELECT Id FROM Campaign WHERE Name = 'Active Test Campaign' LIMIT 1];
        
        Test.startTest();
        List<Ad_Video__c> results = AdCampaignController.getCampaignVideos(testCampaign.Id);
        Test.stopTest();
        
        // Verify all required fields are accessible
        Ad_Video__c video = results[0];
        System.assertNotEquals(null, video.Id, 'Id should be accessible');
        System.assertNotEquals(null, video.Product_Name__c, 'Product_Name__c should be accessible');
        System.assertNotEquals(null, video.Product_Code__c, 'Product_Code__c should be accessible');
        System.assertNotEquals(null, video.Video_Id__c, 'Video_Id__c should be accessible');
        System.assertNotEquals(null, video.Order__c, 'Order__c should be accessible');
        System.assertNotEquals(null, video.Video_Source_Type__c, 'Video_Source_Type__c should be accessible');
        System.assertNotEquals(null, video.Video_URL__c, 'Video_URL__c should be accessible');
        System.assertNotEquals(null, video.Suggestion_Questions__c, 'Suggestion_Questions__c should be accessible');
    }
}