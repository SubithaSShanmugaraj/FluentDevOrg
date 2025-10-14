/**
 * @description Service class for automated lead creation from Fluent Conversations
 * Creates leads when users show high purchase intent based on their engagement
 */
public with sharing class FluentLeadCreationService {
    
    /**
     * Create or update lead for a user based on their conversation data
     * @param userId The user ID to create/update lead for
     * @return Lead record (new or existing)
     */
    public static Lead createOrUpdateLeadFromConversations(Id userId) {
        // Calculate lead score first
        FluentLeadScoringService.LeadScoringResult scoring = 
            FluentLeadScoringService.calculateUserLeadScore(userId);
        
        // Only create lead if user qualifies
        if (!scoring.qualifiesForLead) {
            return null;
        }
        
        // Get user details
        User user = [
            SELECT Id, Email, FirstName, LastName, Phone, ContactId, CompanyName
            FROM User 
            WHERE Id = :userId 
            LIMIT 1
        ];
        
        // Check if lead already exists for this email
        List<Lead> existingLeads = [
            SELECT Id, Email, Status, LeadSource, Rating
            FROM Lead
            WHERE Email = :user.Email
            AND IsConverted = false
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        Lead leadToUpsert;
        Boolean isNewLead = existingLeads.isEmpty();
        
        if (isNewLead) {
            // Create new lead
            leadToUpsert = new Lead();
            leadToUpsert.Email = user.Email;
            leadToUpsert.FirstName = user.FirstName;
            leadToUpsert.LastName = user.LastName != null ? user.LastName : 'Unknown';
            leadToUpsert.Phone = user.Phone;
            leadToUpsert.Company = user.CompanyName != null ? user.CompanyName : user.Email;
            leadToUpsert.LeadSource = 'Fluent Smart Shop';
            leadToUpsert.Status = 'Open - Not Contacted';
        } else {
            // Update existing lead
            leadToUpsert = existingLeads[0];
        }
        
        // Set rating based on intent level
        leadToUpsert.Rating = mapIntentToRating(scoring.intentLevel);
        
        // Enrich lead with conversation insights
        leadToUpsert.Description = buildLeadDescription(scoring, isNewLead);
        
        // Custom fields (if you want to add them later)
        // leadToUpsert.Fluent_Lead_Score__c = scoring.score;
        // leadToUpsert.Intent_Level__c = scoring.intentLevel;
        
        upsert leadToUpsert;
        
        // Create lead notes with conversation intelligence
        createLeadNotes(leadToUpsert.Id, userId, scoring);
        
        return leadToUpsert;
    }
    
    /**
     * Map intent level to Lead Rating
     */
    private static String mapIntentToRating(String intentLevel) {
        switch on intentLevel {
            when 'Hot' {
                return 'Hot';
            }
            when 'Warm' {
                return 'Warm';
            }
            when else {
                return 'Cold';
            }
        }
    }
    
    /**
     * Build comprehensive lead description with insights
     */
    private static String buildLeadDescription(
        FluentLeadScoringService.LeadScoringResult scoring,
        Boolean isNewLead
    ) {
        String description = isNewLead ? 
            '=== FLUENT SMART SHOP LEAD ===\n\n' : 
            '\n\n=== UPDATED FLUENT INSIGHTS ===\n\n';
        
        description += 'Lead Score: ' + scoring.score + '/100\n';
        description += 'Intent Level: ' + scoring.intentLevel + '\n';
        description += 'Last Activity: ' + 
            (scoring.lastInteractionDate != null ? 
                scoring.lastInteractionDate.format('MM/dd/yyyy HH:mm') : 'N/A') + '\n\n';
        
        description += '--- Engagement Summary ---\n';
        description += 'Total Interactions: ' + scoring.totalInteractions + '\n';
        description += 'Unique Sessions: ' + scoring.uniqueSessions + '\n';
        description += 'Products Viewed: ' + scoring.uniqueProducts + '\n';
        description += 'Voice Interactions: ' + scoring.voiceInteractions + '\n';
        description += 'High Intent Questions: ' + scoring.highIntentQuestions + '\n';
        description += 'Medium Intent Questions: ' + scoring.mediumIntentQuestions + '\n\n';
        
        if (String.isNotBlank(scoring.detectedKeywords)) {
            description += '--- Detected Interests ---\n';
            description += 'Keywords: ' + scoring.detectedKeywords + '\n\n';
        }
        
        if (String.isNotBlank(scoring.mostRecentQuestion)) {
            description += '--- Most Recent Question ---\n';
            description += scoring.mostRecentQuestion + '\n\n';
        }
        
        description += '--- Recommended Action ---\n';
        if (scoring.intentLevel == 'Hot') {
            description += 'Priority: HIGH - Contact within 24 hours\n';
            description += 'Approach: Direct sales outreach, discuss pricing and availability\n';
        } else if (scoring.intentLevel == 'Warm') {
            description += 'Priority: MEDIUM - Contact within 48-72 hours\n';
            description += 'Approach: Educational follow-up, provide product information\n';
        } else {
            description += 'Priority: LOW - Add to nurture campaign\n';
            description += 'Approach: Send automated product recommendations\n';
        }
        
        return description;
    }
    
    /**
     * Create or update notes with full conversation history
     * Prevents duplicate files by checking for existing intelligence files
     */
    private static void createLeadNotes(Id leadId, Id userId, 
                                       FluentLeadScoringService.LeadScoringResult scoring) {
        // Get recent conversations
        List<Fluent_Conversation__c> recentConversations = [
            SELECT Id, User_Question__c, AI_Response__c, 
                   Interaction_Type__c, Interaction_Timestamp__c,
                   Video__c, Video__r.Name
            FROM Fluent_Conversation__c
            WHERE User__c = :userId
            ORDER BY Interaction_Timestamp__c DESC
            LIMIT 10
        ];
        
        if (recentConversations.isEmpty()) {
            return;
        }
        
        // Build the conversation history content
        String noteBody = '=== FLUENT CONVERSATION HISTORY ===\n\n';
        noteBody += 'Lead Score: ' + scoring.score + ' | Intent: ' + scoring.intentLevel + '\n';
        noteBody += 'Last Updated: ' + DateTime.now().format('MM/dd/yyyy HH:mm') + '\n';
        noteBody += 'Total Conversations: ' + recentConversations.size() + '\n\n';
        
        Integer count = 1;
        for (Fluent_Conversation__c conv : recentConversations) {
            noteBody += '--- Interaction #' + count + ' ---\n';
            noteBody += 'Date: ' + 
                (conv.Interaction_Timestamp__c != null ? 
                    conv.Interaction_Timestamp__c.format('MM/dd/yyyy HH:mm') : 'N/A') + '\n';
            noteBody += 'Type: ' + conv.Interaction_Type__c + '\n';
            
            if (conv.Video__c != null && conv.Video__r.Name != null) {
                noteBody += 'Product Video: ' + conv.Video__r.Name + '\n';
            }
            
            noteBody += 'Question: ' + 
                (String.isNotBlank(conv.User_Question__c) ? 
                    conv.User_Question__c : 'N/A') + '\n';
            noteBody += 'Response: ' + 
                (String.isNotBlank(conv.AI_Response__c) ? 
                    conv.AI_Response__c : 'N/A') + '\n\n';
            
            count++;
        }
        
        // Check if a conversation intelligence file already exists for this lead
        List<ContentDocumentLink> existingLinks = [
            SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :leadId
            AND ContentDocument.Title LIKE 'Fluent Conversation Intelligence%'
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
        ];
        
        ContentVersion contentVersion = new ContentVersion();
        
        if (!existingLinks.isEmpty()) {
            // Update existing file with new version
            contentVersion.ContentDocumentId = existingLinks[0].ContentDocumentId;
            contentVersion.Title = 'Fluent Conversation Intelligence';
            contentVersion.PathOnClient = 'ConversationIntelligence.txt';
            contentVersion.VersionData = Blob.valueOf(noteBody);
            contentVersion.IsMajorVersion = true;
            contentVersion.ReasonForChange = 'Updated with latest conversations';
            insert contentVersion;
            
            System.debug('Updated existing conversation intelligence file for Lead: ' + leadId);
        } else {
            // Create new file if none exists
            contentVersion.Title = 'Fluent Conversation Intelligence';
            contentVersion.PathOnClient = 'ConversationIntelligence.txt';
            contentVersion.VersionData = Blob.valueOf(noteBody);
            contentVersion.IsMajorVersion = true;
            insert contentVersion;
            
            // Link to Lead
            ContentVersion insertedVersion = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :contentVersion.Id
            ];
            
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.ContentDocumentId = insertedVersion.ContentDocumentId;
            contentLink.LinkedEntityId = leadId;
            contentLink.ShareType = 'V';
            contentLink.Visibility = 'AllUsers';
            insert contentLink;
            
            System.debug('Created new conversation intelligence file for Lead: ' + leadId);
        }
    }
    
    /**
     * Batch process to create leads for all qualifying users
     */
    public static void processAllQualifyingUsers() {
        // Get all unique users with conversations
        List<AggregateResult> userAggregates = [
            SELECT User__c
            FROM Fluent_Conversation__c
            WHERE User__c != NULL
            GROUP BY User__c
        ];
        
        List<Lead> createdLeads = new List<Lead>();
        
        for (AggregateResult ar : userAggregates) {
            Id userId = (Id)ar.get('User__c');
            Lead createdLead = createOrUpdateLeadFromConversations(userId);
            
            if (createdLead != null) {
                createdLeads.add(createdLead);
            }
        }
        
        System.debug('Processed ' + userAggregates.size() + ' users');
        System.debug('Created/Updated ' + createdLeads.size() + ' leads');
    }
}