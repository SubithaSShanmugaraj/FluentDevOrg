/**
 * @description Controller class for managing Fluent Conversation data in Lightning Web Components
 * Provides methods to log and retrieve conversation history with security enforcement
 */
public with sharing class FluentConversationController {
    
    /**
     * @description Log a conversation interaction to Salesforce
     * @param conversationData Map containing conversation details (sessionId, question, response, interactionType, videoId, responseTime)
     * @return String The ID of the created Fluent_Conversation__c record
     * @throws AuraHandledException if there's an error during conversation logging
     */
    @AuraEnabled
    public static String logConversation(Map<String, Object> conversationData) {
        try {
            // Check CRUD/FLS permissions before querying and inserting
            validateConversationCreatePermissions();
            
            // Get current user info
            User currentUser = [
                SELECT Id, Email, ContactId 
                FROM User 
                WHERE Id = :UserInfo.getUserId() 
                WITH USER_MODE
                LIMIT 1
            ];
            
            Fluent_Conversation__c conversation = new Fluent_Conversation__c();
            
            // Basic conversation data
            conversation.Session_ID__c = (String)conversationData.get('sessionId');
            conversation.User_Question__c = (String)conversationData.get('question');
            conversation.AI_Response__c = (String)conversationData.get('response');
            conversation.Interaction_Timestamp__c = DateTime.now();
            conversation.Interaction_Type__c = (String)conversationData.get('interactionType');
            
            // User identification
            conversation.User__c = currentUser.Id;
            conversation.User_Email__c = currentUser.Email;
            
            // Contact linkage (if user is associated with a Contact)
            if (currentUser.ContactId != null) {
                conversation.Contact__c = currentUser.ContactId;
            }
            
            // Video context
            String videoId = (String)conversationData.get('videoId');
            
            if (String.isNotBlank(videoId)) {
                conversation.Video__c = videoId;
            }
            
            // Response time (optional)
            if (conversationData.containsKey('responseTime')) {
                conversation.Response_Time_Ms__c = (Decimal)conversationData.get('responseTime');
            }
            
            insert conversation;
            
            System.debug('Conversation logged successfully: ' + conversation.Id);
            return conversation.Id;
            
        } catch (Exception e) {
            System.debug('Error logging conversation: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error logging conversation: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get conversation history for the current user
     * @param sessionId Optional session ID to filter by
     * @param limitRecords Number of records to return (default 50, max 200)
     * @return List<Fluent_Conversation__c> List of conversation records ordered by timestamp
     * @throws AuraHandledException if there's an error during query execution
     */
    @AuraEnabled(cacheable=true)
    public static List<Fluent_Conversation__c> getConversationHistory(String sessionId, Integer limitRecords) {
        try {
            // Check CRUD/FLS permissions
            validateConversationReadPermissions();
            
            Integer recordLimit = (limitRecords != null && limitRecords > 0) ? Math.min(limitRecords, 200) : 50;
            Id currentUserId = UserInfo.getUserId();
            
            String queryString = 'SELECT Id, User_Question__c, AI_Response__c, Interaction_Timestamp__c, ' +
                          'Interaction_Type__c, Session_ID__c ' +
                          'FROM Fluent_Conversation__c ' +
                          'WHERE User__c = :currentUserId ';
            
            if (String.isNotBlank(sessionId)) {
                queryString += 'AND Session_ID__c = :sessionId ';
            }
            
            queryString += 'WITH USER_MODE ORDER BY Interaction_Timestamp__c DESC LIMIT :recordLimit';
            
            return Database.query(queryString);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving conversation history: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get conversation analytics for the current user
     * @return Map<String, Object> Map containing analytics data (totalConversations, voiceCount, textCount, lastSessionId, lastInteractionTime)
     * @throws AuraHandledException if there's an error during analytics calculation
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUserConversationStats() {
        try {
            // Check CRUD/FLS permissions
            validateConversationReadPermissions();
            
            Id userId = UserInfo.getUserId();
            
            // Total conversations
            Integer totalConversations = [
                SELECT COUNT() 
                FROM Fluent_Conversation__c 
                WHERE User__c = :userId
                WITH USER_MODE
            ];
            
            // Voice vs Text breakdown
            List<AggregateResult> interactionTypes = [
                SELECT Interaction_Type__c, COUNT(Id) total
                FROM Fluent_Conversation__c
                WHERE User__c = :userId
                WITH USER_MODE
                GROUP BY Interaction_Type__c
            ];
            
            Map<String, Integer> typeBreakdown = new Map<String, Integer>();
            for (AggregateResult ar : interactionTypes) {
                String interactionType = (String)ar.get('Interaction_Type__c');
                Integer count = (Integer)ar.get('total');
                typeBreakdown.put(interactionType, count);
            }
            
            // Most recent session
            List<Fluent_Conversation__c> recentConversations = [
                SELECT Session_ID__c, Interaction_Timestamp__c
                FROM Fluent_Conversation__c
                WHERE User__c = :userId
                WITH USER_MODE
                ORDER BY Interaction_Timestamp__c DESC
                LIMIT 1
            ];
            
            String lastSessionId = '';
            DateTime lastInteractionTime = null;
            
            if (!recentConversations.isEmpty()) {
                lastSessionId = recentConversations[0].Session_ID__c;
                lastInteractionTime = recentConversations[0].Interaction_Timestamp__c;
            }
            
            return new Map<String, Object>{
                'totalConversations' => totalConversations,
                'voiceCount' => typeBreakdown.get('Voice') != null ? typeBreakdown.get('Voice') : 0,
                'textCount' => typeBreakdown.get('Text') != null ? typeBreakdown.get('Text') : 0,
                'lastSessionId' => lastSessionId,
                'lastInteractionTime' => lastInteractionTime
            };
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving conversation stats: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validates that the current user has create access to Fluent_Conversation__c and its fields
     * @throws AuraHandledException if the user lacks necessary permissions
     */
    private static void validateConversationCreatePermissions() {
        if (!Schema.sObjectType.Fluent_Conversation__c.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create conversation records');
        }
        
        if (!Schema.sObjectType.Fluent_Conversation__c.fields.Session_ID__c.isCreateable() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.User_Question__c.isCreateable() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.AI_Response__c.isCreateable() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.Interaction_Timestamp__c.isCreateable() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.Interaction_Type__c.isCreateable() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.User__c.isCreateable() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.User_Email__c.isCreateable()) {
            throw new AuraHandledException('Insufficient field-level permissions to create conversation records');
        }
    }
    
    /**
     * @description Validates that the current user has read access to Fluent_Conversation__c and its fields
     * @throws AuraHandledException if the user lacks necessary permissions
     */
    private static void validateConversationReadPermissions() {
        if (!Schema.sObjectType.Fluent_Conversation__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access conversation records');
        }
        
        if (!Schema.sObjectType.Fluent_Conversation__c.fields.User_Question__c.isAccessible() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.AI_Response__c.isAccessible() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.Interaction_Timestamp__c.isAccessible() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.Interaction_Type__c.isAccessible() ||
            !Schema.sObjectType.Fluent_Conversation__c.fields.Session_ID__c.isAccessible()) {
            throw new AuraHandledException('Insufficient field-level permissions to access conversation fields');
        }
    }
}