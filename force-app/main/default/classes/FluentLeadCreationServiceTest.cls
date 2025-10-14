/**
 * @description Test class for FluentLeadCreationService
 */
@isTest
private class FluentLeadCreationServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test user with required fields
        User testUser = [SELECT Id, Email, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Create test video
        Ad_Video__c video = new Ad_Video__c(
            Video_URL__c = 'https://test.com/video.mp4',
            Video_Id__c = 'test-video-123',
            Product_Name__c = 'Smart Watch Pro'
        );
        insert video;
        
        // Create high-intent conversations to qualify for lead creation
        List<Fluent_Conversation__c> conversations = new List<Fluent_Conversation__c>();
        
        for (Integer i = 0; i < 5; i++) {
            conversations.add(new Fluent_Conversation__c(
                Session_ID__c = 'session-' + i,
                User__c = testUser.Id,
                User_Email__c = testUser.Email,
                User_Question__c = 'What is the price? Do you ship internationally?',
                AI_Response__c = 'Price is $99.99. Yes, we ship worldwide.',
                Interaction_Type__c = i < 2 ? 'Voice' : 'Text',
                Video__c = video.Id,
                Interaction_Timestamp__c = DateTime.now()
            ));
        }
        
        insert conversations;
    }
    
    @isTest
    static void testCreateLeadFromConversations() {
        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Verify no lead exists initially
        Integer initialLeadCount = [SELECT COUNT() FROM Lead WHERE Email = :testUser.Email];
        
        Test.startTest();
        Lead createdLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(testUser.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, createdLead, 'Lead should be created');
        System.assertEquals(testUser.Email, createdLead.Email, 'Email should match');
        System.assertEquals('Fluent Smart Shop', createdLead.LeadSource, 'Lead source should be set');
        System.assertNotEquals(null, createdLead.Rating, 'Rating should be set');
        System.assert(
            String.isNotBlank(createdLead.Description), 
            'Description should contain insights'
        );
        
        // Verify lead was actually inserted
        Integer finalLeadCount = [SELECT COUNT() FROM Lead WHERE Email = :testUser.Email];
        System.assertEquals(initialLeadCount + 1, finalLeadCount, 'Lead count should increase by 1');
    }
    
    @isTest
    static void testUpdateExistingLead() {
        User testUser = [SELECT Id, Email, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Create initial lead
        Lead existingLead = new Lead(
            Email = testUser.Email,
            FirstName = testUser.FirstName,
            LastName = testUser.LastName != null ? testUser.LastName : 'Test',
            Company = 'Test Company',
            LeadSource = 'Website',
            Status = 'Open - Not Contacted'
        );
        insert existingLead;
        
        Test.startTest();
        Lead updatedLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(testUser.Id);
        Test.stopTest();
        
        // Should update existing lead, not create new one
        System.assertEquals(existingLead.Id, updatedLead.Id, 'Should update same lead');
        System.assertEquals('Fluent Smart Shop', updatedLead.LeadSource, 'Lead source should be updated');
        
        // Verify only one lead exists
        Integer leadCount = [SELECT COUNT() FROM Lead WHERE Email = :testUser.Email];
        System.assertEquals(1, leadCount, 'Should have only one lead');
    }
    
    @isTest
    static void testLeadRatingMapping() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        Lead createdLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(testUser.Id);
        Test.stopTest();
        
        // Rating should be set based on intent level
        System.assert(
            createdLead.Rating == 'Hot' || 
            createdLead.Rating == 'Warm' || 
            createdLead.Rating == 'Cold',
            'Rating should be valid value'
        );
    }
    
    @isTest
    static void testLeadDescriptionContent() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        Lead createdLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(testUser.Id);
        Test.stopTest();
        
        // Description should contain key information
        System.assert(
            createdLead.Description.contains('FLUENT SMART SHOP LEAD'),
            'Description should have header'
        );
        System.assert(
            createdLead.Description.contains('Lead Score:'),
            'Description should include score'
        );
        System.assert(
            createdLead.Description.contains('Intent Level:'),
            'Description should include intent level'
        );
        System.assert(
            createdLead.Description.contains('Engagement Summary'),
            'Description should include engagement summary'
        );
    }
    
    @isTest
    static void testLeadNotesCreation() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        Lead createdLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(testUser.Id);
        Test.stopTest();
        
        // Verify ContentNote was created and linked to lead
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :createdLead.Id
        ];
        
        System.assert(!links.isEmpty(), 'Should have content note linked to lead');
        
        // Verify content
        ContentVersion version = [
            SELECT Title, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :links[0].ContentDocumentId
            AND IsLatest = true
            LIMIT 1
        ];
        
        System.assert(
            version.Title.contains('Fluent Conversation Intelligence'),
            'Note should have correct title'
        );
        
        String noteContent = version.VersionData.toString();
        System.assert(
            noteContent.contains('FLUENT CONVERSATION HISTORY'),
            'Note should contain conversation history'
        );
    }
    
    @isTest
    static void testNoLeadForLowIntent() {
        // Create a low-intent user
        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Delete existing high-intent conversations
        delete [SELECT Id FROM Fluent_Conversation__c WHERE User__c = :testUser.Id];
        
        // Create low-intent conversation
        Ad_Video__c video = [SELECT Id FROM Ad_Video__c LIMIT 1];
        Fluent_Conversation__c lowIntentConv = new Fluent_Conversation__c(
            Session_ID__c = 'session-low',
            User__c = testUser.Id,
            User_Email__c = testUser.Email,
            User_Question__c = 'What is this?',
            AI_Response__c = 'This is a product.',
            Interaction_Type__c = 'Text',
            Video__c = video.Id,
            Interaction_Timestamp__c = DateTime.now()
        );
        insert lowIntentConv;
        
        Test.startTest();
        Lead createdLead = FluentLeadCreationService.createOrUpdateLeadFromConversations(testUser.Id);
        Test.stopTest();
        
        // Should not create lead for low intent
        System.assertEquals(null, createdLead, 'Should not create lead for low intent user');
    }
    
    @isTest
    static void testProcessAllQualifyingUsers() {
        Test.startTest();
        FluentLeadCreationService.processAllQualifyingUsers();
        Test.stopTest();
        
        // Verify lead was created
        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<Lead> createdLeads = [
            SELECT Id, Email, LeadSource
            FROM Lead
            WHERE Email = :testUser.Email
            AND LeadSource = 'Fluent Smart Shop'
        ];
        
        System.assert(!createdLeads.isEmpty(), 'Should create lead for qualifying user');
    }
}