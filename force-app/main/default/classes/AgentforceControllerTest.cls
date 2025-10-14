/**
 * @description Test class for AgentforceController
 * Tests OAuth authentication, session management, and Einstein Agent API integration
 */
@isTest
private class AgentforceControllerTest {
    
    private static final String TEST_AGENT_ID = 'test-agent-123';
    private static final String TEST_CONSUMER_KEY = 'test-consumer-key';
    private static final String TEST_CONSUMER_SECRET = 'test-consumer-secret';
    private static final String TEST_CAMPAIGN_ID = 'test-campaign-id';
    private static final String TEST_PRODUCT_CODE = 'TEST-PRODUCT';
    private static final String TEST_SESSION_ID = 'test-session-123';
    private static final String TEST_ACCESS_TOKEN = 'test-access-token-abc123';
    
    /**
     * @description Mock class for OAuth token responses
     */
    private class MockHttpResponseToken implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseToken(Integer code, String body) {
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
     * @description Mock class for Agent API responses with multi-call support
     */
    private class MockHttpResponseMultiCall implements HttpCalloutMock {
        private Map<String, MockResponse> endpointResponses;
        
        public MockHttpResponseMultiCall(Map<String, MockResponse> responses) {
            this.endpointResponses = responses;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            // Check which endpoint was called
            String endpoint = req.getEndpoint();
            
            if (endpoint.contains('/oauth2/token')) {
                // OAuth token request
                MockResponse mockRes = endpointResponses.get('token');
                res.setStatusCode(mockRes != null ? mockRes.statusCode : 200);
                res.setBody(mockRes != null ? mockRes.body : '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}');
            } else if (endpoint.contains('/sessions') && req.getMethod() == 'POST') {
                // Session initialization
                MockResponse mockRes = endpointResponses.get('session');
                res.setStatusCode(mockRes != null ? mockRes.statusCode : 201);
                res.setBody(mockRes != null ? mockRes.body : '{"sessionId":"' + TEST_SESSION_ID + '"}');
            } else if (endpoint.contains('/messages')) {
                // Message exchange
                MockResponse mockRes = endpointResponses.get('message');
                res.setStatusCode(mockRes != null ? mockRes.statusCode : 200);
                res.setBody(mockRes != null ? mockRes.body : '{"messages":[{"message":"Test response"}]}');
            } else if (endpoint.contains('/sessions') && req.getMethod() == 'DELETE') {
                // Session termination
                MockResponse mockRes = endpointResponses.get('end');
                res.setStatusCode(mockRes != null ? mockRes.statusCode : 204);
                res.setBody(mockRes != null ? mockRes.body : '');
            } else {
                res.setStatusCode(404);
                res.setBody('{"error":"Not Found"}');
            }
            
            return res;
        }
    }
    
    /**
     * @description Helper class to define mock responses
     */
    private class MockResponse {
        public Integer statusCode;
        public String body;
        
        public MockResponse(Integer code, String responseBody) {
            this.statusCode = code;
            this.body = responseBody;
        }
    }
    
    /**
     * @description Test getting org domain
     */
    @isTest
    static void testGetOrgDomain() {
        Test.startTest();
        String orgDomain = AgentforceController.getOrgDomain();
        Test.stopTest();
        
        System.assertNotEquals(null, orgDomain, 'Org domain should not be null');
        System.assert(orgDomain.contains('salesforce.com') || orgDomain.contains('my.site.com'), 
                     'Org domain should contain salesforce.com or my.site.com');
    }
    
    /**
     * @description Test successful session initialization
     */
    @isTest
    static void testInitializeAgentSessionSuccess() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'session' => new MockResponse(201, '{"sessionId":"' + TEST_SESSION_ID + '"}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        String sessionId = AgentforceController.initializeAgentSession(
            TEST_AGENT_ID, 
            TEST_CONSUMER_KEY, 
            TEST_CONSUMER_SECRET, 
            TEST_CAMPAIGN_ID, 
            TEST_PRODUCT_CODE
        );
        Test.stopTest();
        
        System.assertEquals(TEST_SESSION_ID, sessionId, 'Session ID should match');
    }
    
    /**
     * @description Test session initialization with blank agent ID
     */
    @isTest
    static void testInitializeAgentSessionBlankAgentId() {
        Test.startTest();
        try {
            AgentforceController.initializeAgentSession('', TEST_CONSUMER_KEY, TEST_CONSUMER_SECRET, null, null);
            System.assert(false, 'Should have thrown exception for blank agent ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Agent ID'), 'Error should mention Agent ID');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test session initialization with blank consumer key
     */
    @isTest
    static void testInitializeAgentSessionBlankCredentials() {
        Test.startTest();
        try {
            AgentforceController.initializeAgentSession(TEST_AGENT_ID, '', '', null, null);
            System.assert(false, 'Should have thrown exception for blank credentials');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Consumer Key'), 'Error should mention Consumer Key');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test session initialization with OAuth failure
     */
    @isTest
    static void testInitializeAgentSessionOAuthFailure() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(401, '{"error":"invalid_client"}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        try {
            AgentforceController.initializeAgentSession(
                TEST_AGENT_ID, 
                TEST_CONSUMER_KEY, 
                TEST_CONSUMER_SECRET, 
                null, 
                null
            );
            System.assert(false, 'Should have thrown exception for OAuth failure');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('authentication'), 'Error should mention authentication');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test session initialization with API failure
     */
    @isTest
    static void testInitializeAgentSessionApiFailure() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'session' => new MockResponse(404, '{"error":"Agent not found"}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        try {
            AgentforceController.initializeAgentSession(
                TEST_AGENT_ID, 
                TEST_CONSUMER_KEY, 
                TEST_CONSUMER_SECRET, 
                null, 
                null
            );
            System.assert(false, 'Should have thrown exception for API failure');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Agent not found'), 'Error should mention agent not found');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test successful message exchange
     */
    @isTest
    static void testGetAgentRecommendationSuccess() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'message' => new MockResponse(200, '{"messages":[{"message":"This is the AI response"}]}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        String response = AgentforceController.getAgentRecommendation(
            TEST_SESSION_ID, 
            'Test question', 
            TEST_CONSUMER_KEY, 
            TEST_CONSUMER_SECRET
        );
        Test.stopTest();
        
        System.assertEquals('This is the AI response', response, 'Response should match');
    }
    
    /**
     * @description Test message exchange with blank session ID
     */
    @isTest
    static void testGetAgentRecommendationBlankSessionId() {
        Test.startTest();
        try {
            AgentforceController.getAgentRecommendation('', 'Test message', TEST_CONSUMER_KEY, TEST_CONSUMER_SECRET);
            System.assert(false, 'Should have thrown exception for blank session ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Session ID'), 'Error should mention Session ID');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test message exchange with blank message
     */
    @isTest
    static void testGetAgentRecommendationBlankMessage() {
        Test.startTest();
        try {
            AgentforceController.getAgentRecommendation(TEST_SESSION_ID, '', TEST_CONSUMER_KEY, TEST_CONSUMER_SECRET);
            System.assert(false, 'Should have thrown exception for blank message');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('message'), 'Error should mention message');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test message exchange with API failure
     */
    @isTest
    static void testGetAgentRecommendationApiFailure() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'message' => new MockResponse(500, '{"error":"Internal Server Error"}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        try {
            AgentforceController.getAgentRecommendation(
                TEST_SESSION_ID, 
                'Test question', 
                TEST_CONSUMER_KEY, 
                TEST_CONSUMER_SECRET
            );
            System.assert(false, 'Should have thrown exception for API failure');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('failed'), 'Error should mention failure');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test successful session termination
     */
    @isTest
    static void testEndAgentSessionSuccess() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'end' => new MockResponse(204, '')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        String result = AgentforceController.endAgentSession(
            TEST_SESSION_ID, 
            TEST_CONSUMER_KEY, 
            TEST_CONSUMER_SECRET
        );
        Test.stopTest();
        
        System.assertEquals('Session ended', result, 'Result should indicate session ended');
    }
    
    /**
     * @description Test session termination with blank session ID
     */
    @isTest
    static void testEndAgentSessionBlankSessionId() {
        Test.startTest();
        try {
            AgentforceController.endAgentSession('', TEST_CONSUMER_KEY, TEST_CONSUMER_SECRET);
            System.assert(false, 'Should have thrown exception for blank session ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Session ID'), 'Error should mention Session ID');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test session termination with API failure
     */
    @isTest
    static void testEndAgentSessionApiFailure() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'end' => new MockResponse(500, '{"error":"Internal Server Error"}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        String result = AgentforceController.endAgentSession(
            TEST_SESSION_ID, 
            TEST_CONSUMER_KEY, 
            TEST_CONSUMER_SECRET
        );
        Test.stopTest();
        
        System.assert(result.contains('error'), 'Result should contain error');
    }
    
    /**
     * @description Test OAuth token caching
     */
    @isTest
    static void testOAuthTokenCaching() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'session' => new MockResponse(201, '{"sessionId":"session1"}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        // First call should get token
        String sessionId1 = AgentforceController.initializeAgentSession(
            TEST_AGENT_ID, 
            TEST_CONSUMER_KEY, 
            TEST_CONSUMER_SECRET, 
            null, 
            null
        );
        
        // Second call should use cached token
        String sessionId2 = AgentforceController.initializeAgentSession(
            TEST_AGENT_ID, 
            TEST_CONSUMER_KEY, 
            TEST_CONSUMER_SECRET, 
            null, 
            null
        );
        Test.stopTest();
        
        System.assertNotEquals(null, sessionId1, 'First session should be created');
        System.assertNotEquals(null, sessionId2, 'Second session should be created');
    }
    
    /**
     * @description Test empty messages response
     */
    @isTest
    static void testGetAgentRecommendationEmptyMessages() {
        Map<String, MockResponse> responses = new Map<String, MockResponse>{
            'token' => new MockResponse(200, '{"access_token":"' + TEST_ACCESS_TOKEN + '","expires_in":3600}'),
            'message' => new MockResponse(200, '{"messages":[]}')
        };
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMultiCall(responses));
        
        Test.startTest();
        String response = AgentforceController.getAgentRecommendation(
            TEST_SESSION_ID, 
            'Test question', 
            TEST_CONSUMER_KEY, 
            TEST_CONSUMER_SECRET
        );
        Test.stopTest();
        
        System.assertEquals('', response, 'Empty messages should return empty string');
    }
}