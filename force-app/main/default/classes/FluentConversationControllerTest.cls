/**
 * @description Test class for FluentConversationController
 * Tests conversation logging, history retrieval, and analytics functionality
 */
@isTest
private class FluentConversationControllerTest {
    
    /**
     * @description Setup test data for all test methods
     */
    @TestSetup
    static void setupTestData() {
        // Create test product
        E_Cart_Product__c product = new E_Cart_Product__c(
            Name = 'Test Product',
            Price__c = 99.99,
            Description__c = 'Test Description'
        );
        insert product;
        
        // Create test video
        Ad_Video__c video = new Ad_Video__c(
            Video_URL__c = 'https://test.com/video.mp4',
            Video_Id__c = 'test-video-123',
            Product_Name__c = 'Test Product'
        );
        insert video;
    }
    
    /**
     * @description Test successful conversation logging with all fields
     */
    @isTest
    static void testLogConversation() {
        // Get test data
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Prepare conversation data
        Map<String, Object> conversationData = new Map<String, Object>{
            'sessionId' => 'test-session-123',
            'question' => 'What is the price of this product?',
            'response' => 'The price is $99.99',
            'interactionType' => 'Text',
            'videoId' => video.Id,
            'responseTime' => 1500
        };
        
        Test.startTest();
        String recordId = FluentConversationController.logConversation(conversationData);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, recordId, 'Record ID should not be null');
        
        Fluent_Conversation__c conversation = [
            SELECT Id, User_Question__c, AI_Response__c, Interaction_Type__c, 
                   User__c, Video__c
            FROM Fluent_Conversation__c 
            WHERE Id = :recordId
        ];
        
        System.assertEquals('What is the price of this product?', conversation.User_Question__c);
        System.assertEquals('The price is $99.99', conversation.AI_Response__c);
        System.assertEquals('Text', conversation.Interaction_Type__c);
        System.assertEquals(UserInfo.getUserId(), conversation.User__c);
        System.assertEquals(video.Id, conversation.Video__c);
    }
    
    /**
     * @description Test conversation logging without video or product context
     */
    @isTest
    static void testLogConversationWithoutVideoAndProduct() {
        // Prepare conversation data without video/product
        Map<String, Object> conversationData = new Map<String, Object>{
            'sessionId' => 'test-session-456',
            'question' => 'General question',
            'response' => 'General response',
            'interactionType' => 'Voice'
        };
        
        Test.startTest();
        String recordId = FluentConversationController.logConversation(conversationData);
        Test.stopTest();
        
        // Verify
        System.assertNotEquals(null, recordId, 'Record ID should not be null');
        
        Fluent_Conversation__c conversation = [
            SELECT Id, Interaction_Type__c, Video__c
            FROM Fluent_Conversation__c 
            WHERE Id = :recordId
        ];
        
        System.assertEquals('Voice', conversation.Interaction_Type__c);
        System.assertEquals(null, conversation.Video__c);
    }
    
    /**
     * @description Test retrieving conversation history for current user
     */
    @isTest
    static void testGetConversationHistory() {
        // Get test data
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Create test conversations
        List<Fluent_Conversation__c> conversations = new List<Fluent_Conversation__c>();
        for (Integer i = 0; i < 5; i++) {
            conversations.add(new Fluent_Conversation__c(
                Session_ID__c = 'test-session-' + i,
                User_Question__c = 'Question ' + i,
                AI_Response__c = 'Response ' + i,
                Interaction_Type__c = 'Text',
                User__c = UserInfo.getUserId(),
                Video__c = video.Id,
                Interaction_Timestamp__c = DateTime.now().addMinutes(-i)
            ));
        }
        insert conversations;
        
        Test.startTest();
        List<Fluent_Conversation__c> history = FluentConversationController.getConversationHistory(null, 10);
        Test.stopTest();
        
        System.assertEquals(5, history.size(), 'Should return 5 conversations');
        System.assertEquals('Question 0', history[0].User_Question__c, 'Most recent should be first');
    }
    
    /**
     * @description Test retrieving conversation history filtered by session ID
     */
    @isTest
    static void testGetConversationHistoryWithSessionFilter() {
        // Get test data
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Create test conversations with different sessions
        List<Fluent_Conversation__c> conversations = new List<Fluent_Conversation__c>();
        conversations.add(new Fluent_Conversation__c(
            Session_ID__c = 'target-session',
            User_Question__c = 'Target Question',
            AI_Response__c = 'Target Response',
            Interaction_Type__c = 'Text',
            User__c = UserInfo.getUserId(),
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        ));
        conversations.add(new Fluent_Conversation__c(
            Session_ID__c = 'other-session',
            User_Question__c = 'Other Question',
            AI_Response__c = 'Other Response',
            Interaction_Type__c = 'Text',
            User__c = UserInfo.getUserId(),
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        ));
        insert conversations;
        
        Test.startTest();
        List<Fluent_Conversation__c> history = FluentConversationController.getConversationHistory('target-session', 10);
        Test.stopTest();
        
        System.assertEquals(1, history.size(), 'Should return only 1 conversation for target session');
        System.assertEquals('Target Question', history[0].User_Question__c);
    }
    
    /**
     * @description Test retrieving conversation statistics with mixed interaction types
     */
    @isTest
    static void testGetUserConversationStats() {
        // Get test data
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Create mixed conversations
        List<Fluent_Conversation__c> conversations = new List<Fluent_Conversation__c>();
        conversations.add(new Fluent_Conversation__c(
            Session_ID__c = 'test-session-1',
            User_Question__c = 'Voice Question',
            AI_Response__c = 'Voice Response',
            Interaction_Type__c = 'Voice',
            User__c = UserInfo.getUserId(),
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        ));
        conversations.add(new Fluent_Conversation__c(
            Session_ID__c = 'test-session-2',
            User_Question__c = 'Text Question',
            AI_Response__c = 'Text Response',
            Interaction_Type__c = 'Text',
            User__c = UserInfo.getUserId(),
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        ));
        insert conversations;
        
        Test.startTest();
        Map<String, Object> stats = FluentConversationController.getUserConversationStats();
        Test.stopTest();
        
        System.assertEquals(2, stats.get('totalConversations'), 'Should have 2 total conversations');
        System.assertEquals(1, stats.get('voiceCount'), 'Should have 1 voice conversation');
        System.assertEquals(1, stats.get('textCount'), 'Should have 1 text conversation');
        System.assertNotEquals(null, stats.get('lastSessionId'), 'Should have last session ID');
        System.assertNotEquals(null, stats.get('lastInteractionTime'), 'Should have last interaction time');
    }
    
    /**
     * @description Test retrieving conversation statistics when no data exists
     */
    @isTest
    static void testGetUserConversationStatsNoData() {
        Test.startTest();
        Map<String, Object> stats = FluentConversationController.getUserConversationStats();
        Test.stopTest();
        
        System.assertEquals(0, stats.get('totalConversations'), 'Should have 0 total conversations');
        System.assertEquals(0, stats.get('voiceCount'), 'Should have 0 voice conversations');
        System.assertEquals(0, stats.get('textCount'), 'Should have 0 text conversations');
    }
    
    /**
     * @description Test error handling with invalid data
     */
    @isTest
    static void testErrorHandling() {
        // Test with invalid data
        Map<String, Object> invalidData = new Map<String, Object>{
            'sessionId' => null,
            'question' => null,
            'response' => null
        };
        
        Test.startTest();
        try {
            FluentConversationController.logConversation(invalidData);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error logging conversation'), 'Should throw appropriate error');
        }
        Test.stopTest();
    }
}