/**
 * @description Service class for Einstein Agentforce AI integration (Legacy)
 * Provides AI response functionality with video and product context
 * Note: This is an earlier implementation. Primary integration is through AgentforceController
 */
public with sharing class AgentforceService {
    
    /**
     * @description Call Agentforce to get AI response for user questions
     * @param question The user's question
     * @param videoId The current video ID for context
     * @param productName The current product name for context
     * @return String AI generated response
     * @throws AuraHandledException if AI response fails
     */
    @AuraEnabled
    public static String getAgentforceResponse(String question, String videoId, String productName) {
        try {
            // Get video context for better responses
            String context = buildContext(videoId, productName);
            
            // Call Einstein Agentforce API
            String response = callAgentforce(question, context);
            
            return response;
            
        } catch (Exception e) {
            System.debug('Error calling Agentforce: ' + e.getMessage());
            throw new AuraHandledException('Unable to get AI response: ' + e.getMessage());
        }
    }
    
    /**
     * @description Build context from video and product information
     * @param videoId The Ad_Video__c record ID
     * @param productName Fallback product name if video not found
     * @return String Formatted context string with product and campaign info
     */
    private static String buildContext(String videoId, String productName) {
        try {
            // Validate read permissions
            if (!Schema.sObjectType.Ad_Video__c.isAccessible() ||
                !Schema.sObjectType.Ad_Video__c.fields.Product_Name__c.isAccessible() ||
                !Schema.sObjectType.Ad_Video__c.fields.Video_Id__c.isAccessible() ||
                !Schema.sObjectType.Ad_Video__c.fields.Suggestion_Questions__c.isAccessible()) {
                System.debug('Insufficient permissions to read Ad_Video__c fields');
                return 'Product: ' + productName;
            }
            
            Ad_Video__c video = [
                SELECT 
                    Id,
                    Product_Name__c,
                    Video_Id__c,
                    Suggestion_Questions__c,
                    Ad_Campaign__r.Name
                FROM Ad_Video__c
                WHERE Id = :videoId
                WITH USER_MODE
                LIMIT 1
            ];
            
            String context = 'Product: ' + (video.Product_Name__c != null ? video.Product_Name__c : productName);
            context += '\nCampaign: ' + video.Ad_Campaign__r.Name;
            
            return context;
            
        } catch (Exception e) {
            System.debug('Error building context: ' + e.getMessage());
            return 'Product: ' + productName;
        }
    }
    
    /**
     * @description Call Einstein Agentforce REST API via Named Credential
     * @param question The user's question text
     * @param context Additional context information (product, campaign)
     * @return String The AI generated response
     * @throws CalloutException if API call fails
     */
    private static String callAgentforce(String question, String context) {
        // Construct the API endpoint
        String endpoint = '/services/data/v64.0/einstein/ai/agent/conversation';
        
        // Build request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'agentName' => 'Fluent_Product_Assistant', // Your agent's API name
            'message' => question,
            'context' => context,
            'sessionId' => generateSessionId()
        };
        
        // Make HTTP callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Salesforce_Org' + endpoint); // Using Named Credential
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(120000); // 120 seconds timeout
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            // Parse response
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            // Extract the AI response
            if (responseMap.containsKey('message')) {
                return (String) responseMap.get('message');
            } else if (responseMap.containsKey('response')) {
                return (String) responseMap.get('response');
            }
            
            return 'Thank you for your question! Our AI assistant is learning to provide better responses.';
            
        } else {
            System.debug('Agentforce API Error: ' + res.getStatus() + ' - ' + res.getBody());
            throw new CalloutException('Agentforce API returned status: ' + res.getStatusCode());
        }
    }
    
    /**
     * @description Generate a unique session ID for conversation tracking
     * @return String Unique session identifier combining user ID and timestamp
     */
    private static String generateSessionId() {
        return UserInfo.getUserId() + '_' + String.valueOf(Datetime.now().getTime());
    }
    
    /**
     * @description Test method to verify Agentforce API is accessible
     * @return Boolean True if connection successful, false otherwise
     */
    @AuraEnabled
    public static Boolean testAgentforceConnection() {
        try {
            // Simple test call
            String testResponse = getAgentforceResponse(
                'Hello', 
                null, 
                'Test Product'
            );
            return testResponse != null;
        } catch (Exception e) {
            System.debug('Agentforce connection test failed: ' + e.getMessage());
            return false;
        }
    }
}