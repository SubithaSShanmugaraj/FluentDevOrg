/**
 * @description Trigger handler for Fluent_Conversation__c
 * Manages lead scoring and automated lead creation with bulkification
 */
public with sharing class FluentConversationTriggerHandler {
    
    // Track processed users to avoid duplicate processing in same transaction
    private static Set<Id> processedUsers = new Set<Id>();
    
    /**
     * Handle after insert and after update events
     * @param newConversations List of new/updated conversation records
     */
    public static void handleAfterInsertUpdate(List<Fluent_Conversation__c> newConversations) {
        // Collect unique user IDs from this batch
        Set<Id> userIds = new Set<Id>();
        
        for (Fluent_Conversation__c conv : newConversations) {
            if (conv.User__c != null && !processedUsers.contains(conv.User__c)) {
                userIds.add(conv.User__c);
                processedUsers.add(conv.User__c);
            }
        }
        
        if (userIds.isEmpty()) {
            return;
        }
        
        // Process each user asynchronously to avoid governor limits
        if (!System.isBatch() && !System.isFuture()) {
            processUsersAsync(userIds);
        } else {
            // If already in async context, process synchronously
            processUsers(userIds);
        }
    }
    
    /**
     * Process users asynchronously
     * @param userIds Set of user IDs to process
     */
    @future
    private static void processUsersAsync(Set<Id> userIds) {
        processUsers(userIds);
    }
    
    /**
     * Process users for lead scoring and creation
     * @param userIds Set of user IDs to process
     */
    private static void processUsers(Set<Id> userIds) {
        List<Fluent_Conversation__c> conversationsToUpdate = new List<Fluent_Conversation__c>();
        List<Lead> leadsToUpsert = new List<Lead>();
        Map<Id, Lead> userIdToLead = new Map<Id, Lead>();
        
        for (Id userId : userIds) {
            try {
                // Calculate lead score
                FluentLeadScoringService.LeadScoringResult scoring = 
                    FluentLeadScoringService.calculateUserLeadScore(userId);
                
                // Update all conversations for this user with the score
                List<Fluent_Conversation__c> userConversations = [
                    SELECT Id, Lead_Score__c, Intent_Level__c
                    FROM Fluent_Conversation__c
                    WHERE User__c = :userId
                ];
                
                for (Fluent_Conversation__c conv : userConversations) {
                    conv.Lead_Score__c = scoring.score;
                    conv.Intent_Level__c = scoring.intentLevel;
                    conversationsToUpdate.add(conv);
                }
                
                // Create/update lead if user qualifies
                if (scoring.qualifiesForLead) {
                    Lead createdLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(userId);
                    if (createdLead != null) {
                        userIdToLead.put(userId, createdLead);
                    }
                }
                
            } catch (Exception e) {
                System.debug('Error processing user ' + userId + ': ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
                // Continue processing other users even if one fails
            }
        }
        
        // Bulk update conversations
        if (!conversationsToUpdate.isEmpty()) {
            try {
                update conversationsToUpdate;
                System.debug('Updated ' + conversationsToUpdate.size() + ' conversations with lead scores');
            } catch (Exception e) {
                System.debug('Error updating conversations: ' + e.getMessage());
            }
        }
        
        if (!userIdToLead.isEmpty()) {
            System.debug('Created/Updated ' + userIdToLead.size() + ' leads');
        }
    }
    
    /**
     * Manual method to recalculate all lead scores
     * Can be called from developer console or scheduled job
     */
    public static void recalculateAllLeadScores() {
        // Get all unique users
        List<AggregateResult> userAggregates = [
            SELECT User__c
            FROM Fluent_Conversation__c
            WHERE User__c != NULL
            GROUP BY User__c
        ];
        
        Set<Id> allUserIds = new Set<Id>();
        for (AggregateResult ar : userAggregates) {
            allUserIds.add((Id)ar.get('User__c'));
        }
        
        processUsers(allUserIds);
        System.debug('Recalculated lead scores for ' + allUserIds.size() + ' users');
    }
}