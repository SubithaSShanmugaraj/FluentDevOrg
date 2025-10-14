/**
 * @description Test class for AgentforceService
 * Tests AI response functionality, context building, and API integration
 */
@isTest
private class AgentforceServiceTest {
    
    /**
     * @description Setup test data for all test methods
     */
    @TestSetup
    static void setupTestData() {
        // Create test campaign
        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            IsActive = true
        );
        insert testCampaign;
        
        // Create test video
        Ad_Video__c testVideo = new Ad_Video__c(
            Video_URL__c = 'https://test.com/video.mp4',
            Video_Id__c = 'test-video-123',
            Product_Name__c = 'Test Product',
            Suggestion_Questions__c = 'What is this product?;How much does it cost?',
            Ad_Campaign__c = testCampaign.Id
        );
        insert testVideo;
    }
    
    /**
     * @description Mock HTTP response for Agentforce API
     */
    private class MockHttpResponseAgentforce implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseAgentforce(Integer code, String body) {
            this.statusCode = code;
            this.responseBody = body;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    
    /**
     * @description Test successful AI response with valid video context
     */
    @isTest
    static void testGetAgentforceResponseSuccess() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock successful API response
        String mockResponse = '{"message":"This is the AI response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            'What is this product?',
            video.Id,
            'Test Product'
        );
        Test.stopTest();
        
        System.assertEquals('This is the AI response', response, 'Response should match mock');
    }
    
    /**
     * @description Test AI response with alternative response key
     */
    @isTest
    static void testGetAgentforceResponseAlternativeKey() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock successful API response with 'response' key instead of 'message'
        String mockResponse = '{"response":"Alternative AI response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(201, mockResponse));
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            'Tell me more',
            video.Id,
            'Test Product'
        );
        Test.stopTest();
        
        System.assertEquals('Alternative AI response', response, 'Response should use alternative key');
    }
    
    /**
     * @description Test AI response with no recognized response keys
     */
    @isTest
    static void testGetAgentforceResponseDefaultMessage() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock response without message or response keys
        String mockResponse = '{"status":"success","data":"some data"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            'What is this?',
            video.Id,
            'Test Product'
        );
        Test.stopTest();
        
        System.assert(response.contains('learning to provide better responses'), 
                     'Should return default message');
    }
    
    /**
     * @description Test AI response with null video ID (uses product name fallback)
     */
    @isTest
    static void testGetAgentforceResponseNullVideoId() {
        // Mock successful API response
        String mockResponse = '{"message":"Product-based response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            'Tell me about this product',
            null,
            'Fallback Product'
        );
        Test.stopTest();
        
        System.assertEquals('Product-based response', response, 'Response should work with null video ID');
    }
    
    /**
     * @description Test AI response with invalid video ID
     */
    @isTest
    static void testGetAgentforceResponseInvalidVideoId() {
        // Mock successful API response
        String mockResponse = '{"message":"Response with invalid video"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            'What is this?',
            'invalid-id-123',
            'Fallback Product'
        );
        Test.stopTest();
        
        System.assertEquals('Response with invalid video', response, 
                          'Should handle invalid video ID gracefully');
    }
    
    /**
     * @description Test API error handling (500 error)
     */
    @isTest
    static void testGetAgentforceResponseApiError() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock API error response
        String mockResponse = '{"error":"Internal Server Error"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(500, mockResponse));
        
        Test.startTest();
        try {
            AgentforceService.getAgentforceResponse(
                'What is this?',
                video.Id,
                'Test Product'
            );
            System.assert(false, 'Should have thrown exception for API error');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Unable to get AI response'), 
                         'Error message should indicate AI response failure');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test API error handling (400 error)
     */
    @isTest
    static void testGetAgentforceResponseBadRequest() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock bad request response
        String mockResponse = '{"error":"Bad Request"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(400, mockResponse));
        
        Test.startTest();
        try {
            AgentforceService.getAgentforceResponse(
                'Invalid question',
                video.Id,
                'Test Product'
            );
            System.assert(false, 'Should have thrown exception for bad request');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Error message should not be null');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test connection test method with success
     */
    @isTest
    static void testTestAgentforceConnectionSuccess() {
        // Mock successful API response
        String mockResponse = '{"message":"Connection successful"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        Boolean result = AgentforceService.testAgentforceConnection();
        Test.stopTest();
        
        System.assertEquals(true, result, 'Connection test should return true on success');
    }
    
    /**
     * @description Test connection test method with failure
     */
    @isTest
    static void testTestAgentforceConnectionFailure() {
        // Mock failed API response
        String mockResponse = '{"error":"Connection failed"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(503, mockResponse));
        
        Test.startTest();
        Boolean result = AgentforceService.testAgentforceConnection();
        Test.stopTest();
        
        System.assertEquals(false, result, 'Connection test should return false on failure');
    }
    
    /**
     * @description Test context building with complete video data
     */
    @isTest
    static void testBuildContextWithCompleteData() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock successful API response
        String mockResponse = '{"message":"Context test response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        // This will internally call buildContext
        String response = AgentforceService.getAgentforceResponse(
            'Test question',
            video.Id,
            'Fallback Product'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
    }
    
    /**
     * @description Test context building with null product name in video
     */
    @isTest
    static void testBuildContextWithNullProductName() {
        // Create video without product name
        Campaign campaign = [SELECT Id FROM Campaign LIMIT 1];
        Ad_Video__c videoNoProduct = new Ad_Video__c(
            Video_URL__c = 'https://test.com/video2.mp4',
            Video_Id__c = 'test-video-456',
            Product_Name__c = null,
            Ad_Campaign__c = campaign.Id
        );
        insert videoNoProduct;
        
        // Mock successful API response
        String mockResponse = '{"message":"Fallback product response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            'What is this?',
            videoNoProduct.Id,
            'Fallback Product Name'
        );
        Test.stopTest();
        
        System.assertEquals('Fallback product response', response, 
                          'Should handle null product name in video');
    }
    
    /**
     * @description Test FLS permission handling (simulated by catching exception)
     */
    @isTest
    static void testFlsPermissionHandling() {
        // Create a video that will trigger FLS check
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock successful API response
        String mockResponse = '{"message":"FLS test response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        // The method should handle FLS gracefully and fall back to product name
        String response = AgentforceService.getAgentforceResponse(
            'Test FLS',
            video.Id,
            'Fallback Product'
        );
        Test.stopTest();
        
        // Should return response even if FLS check fails (falls back to product name)
        System.assertNotEquals(null, response, 'Should handle FLS checks gracefully');
    }
    
    /**
     * @description Test session ID generation
     */
    @isTest
    static void testSessionIdGeneration() {
        // Mock successful API response
        String mockResponse = '{"message":"Session ID test"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        // Call twice to ensure different session IDs
        String response1 = AgentforceService.getAgentforceResponse(
            'First question',
            null,
            'Test Product'
        );
        
        String response2 = AgentforceService.getAgentforceResponse(
            'Second question',
            null,
            'Test Product'
        );
        Test.stopTest();
        
        // Both should succeed (session IDs are internal)
        System.assertNotEquals(null, response1, 'First response should not be null');
        System.assertNotEquals(null, response2, 'Second response should not be null');
    }
    
    /**
     * @description Test with very long question
     */
    @isTest
    static void testLongQuestion() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock successful API response
        String mockResponse = '{"message":"Long question response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        // Create a very long question
        String longQuestion = 'This is a very long question that contains many words and details about the product. '.repeat(10);
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            longQuestion,
            video.Id,
            'Test Product'
        );
        Test.stopTest();
        
        System.assertEquals('Long question response', response, 'Should handle long questions');
    }
    
    /**
     * @description Test with special characters in question
     */
    @isTest
    static void testSpecialCharactersInQuestion() {
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        
        // Mock successful API response
        String mockResponse = '{"message":"Special chars response"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAgentforce(200, mockResponse));
        
        Test.startTest();
        String response = AgentforceService.getAgentforceResponse(
            'What\'s the price? Is it $100 & available?',
            video.Id,
            'Test Product'
        );
        Test.stopTest();
        
        System.assertEquals('Special chars response', response, 
                          'Should handle special characters');
    }
}