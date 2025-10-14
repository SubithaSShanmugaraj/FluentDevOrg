/**
 * @description Test class for FluentLeadScoringService
 */
@isTest
private class FluentLeadScoringServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test user
        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Create test video
        Ad_Video__c video = new Ad_Video__c(
            Video_URL__c = 'https://test.com/video.mp4',
            Video_Id__c = 'test-video-123',
            Product_Name__c = 'Test Product'
        );
        insert video;
        
        // Create conversations with different intent levels
        List<Fluent_Conversation__c> conversations = new List<Fluent_Conversation__c>();
        
        // High intent conversations
        conversations.add(new Fluent_Conversation__c(
            Session_ID__c = 'session-1',
            User__c = testUser.Id,
            User_Email__c = testUser.Email,
            User_Question__c = 'What is the price of this product?',
            AI_Response__c = 'The price is $99.99',
            Interaction_Type__c = 'Voice',
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        ));
        
        conversations.add(new Fluent_Conversation__c(
            Session_ID__c = 'session-1',
            User__c = testUser.Id,
            User_Email__c = testUser.Email,
            User_Question__c = 'Do you ship internationally?',
            AI_Response__c = 'Yes, we ship worldwide',
            Interaction_Type__c = 'Text',
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        ));
        
        conversations.add(new Fluent_Conversation__c(
            Session_ID__c = 'session-2',
            User__c = testUser.Id,
            User_Email__c = testUser.Email,
            User_Question__c = 'When can I get it delivered?',
            AI_Response__c = 'Delivery takes 3-5 business days',
            Interaction_Type__c = 'Voice',
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        ));
        
        insert conversations;
    }
    
    @isTest
    static void testCalculateUserLeadScore_HighIntent() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        FluentLeadScoringService.LeadScoringResult result = 
            FluentLeadScoringService.calculateUserLeadScore(testUser.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.score > 0, 'Score should be greater than 0');
        System.assertEquals(3, result.totalInteractions, 'Should have 3 interactions');
        System.assertEquals(2, result.uniqueSessions, 'Should have 2 unique sessions');
        System.assert(result.highIntentQuestions > 0, 'Should have high intent questions');
        System.assertEquals(true, result.qualifiesForLead, 'Should qualify for lead');
        System.assertNotEquals('None', result.intentLevel, 'Intent level should not be None');
    }
    
    @isTest
    static void testCalculateUserLeadScore_NoConversations() {
        // Create a new user with no conversations
        User newUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Delete all conversations for this test
        delete [SELECT Id FROM Fluent_Conversation__c WHERE User__c = :newUser.Id];
        
        Test.startTest();
        FluentLeadScoringService.LeadScoringResult result = 
            FluentLeadScoringService.calculateUserLeadScore(newUser.Id);
        Test.stopTest();
        
        System.assertEquals(0, result.score, 'Score should be 0');
        System.assertEquals('None', result.intentLevel, 'Intent level should be None');
        System.assertEquals(false, result.qualifiesForLead, 'Should not qualify for lead');
    }
    
    @isTest
    static void testDetermineIntentLevel() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        FluentLeadScoringService.LeadScoringResult result = 
            FluentLeadScoringService.calculateUserLeadScore(testUser.Id);
        Test.stopTest();
        
        // Intent level should be set based on score
        if (result.score >= 80) {
            System.assertEquals('Hot', result.intentLevel);
        } else if (result.score >= 60) {
            System.assertEquals('Warm', result.intentLevel);
        } else if (result.score >= 40) {
            System.assertEquals('Cold', result.intentLevel);
        } else {
            System.assertEquals('Low', result.intentLevel);
        }
    }
    
    @isTest
    static void testKeywordDetection() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        FluentLeadScoringService.LeadScoringResult result = 
            FluentLeadScoringService.calculateUserLeadScore(testUser.Id);
        Test.stopTest();
        
        // Should detect price, shipping keywords
        System.assert(
            String.isNotBlank(result.detectedKeywords), 
            'Should detect keywords'
        );
        System.assert(
            result.detectedKeywords.contains('price') || 
            result.detectedKeywords.contains('ship'), 
            'Should detect price or shipping keywords'
        );
    }
    
    @isTest
    static void testMultipleSessionsBonus() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        FluentLeadScoringService.LeadScoringResult result = 
            FluentLeadScoringService.calculateUserLeadScore(testUser.Id);
        Test.stopTest();
        
        // Should have multiple sessions bonus
        System.assertEquals(2, result.uniqueSessions, 'Should have 2 sessions');
        // Score should reflect multiple session bonus
        System.assert(result.score > 50, 'Score should be boosted by multiple sessions');
    }
    
    @isTest
    static void testUpdateAllLeadScores() {
        Test.startTest();
        FluentLeadScoringService.updateAllLeadScores();
        Test.stopTest();
        
        // Verify conversations were updated with scores
        List<Fluent_Conversation__c> updatedConversations = [
            SELECT Id, Lead_Score__c, Intent_Level__c
            FROM Fluent_Conversation__c
            WHERE User__c = :UserInfo.getUserId()
        ];
        
        System.assert(!updatedConversations.isEmpty(), 'Should have conversations');
        for (Fluent_Conversation__c conv : updatedConversations) {
            System.assertNotEquals(null, conv.Lead_Score__c, 'Lead score should be set');
            System.assertNotEquals(null, conv.Intent_Level__c, 'Intent level should be set');
        }
    }
}