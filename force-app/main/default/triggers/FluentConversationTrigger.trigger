/**
 * @description Trigger for Fluent_Conversation__c object
 * Handles lead scoring and automated lead creation
 */
trigger FluentConversationTrigger on Fluent_Conversation__c (after insert, after update) {
    FluentConversationTriggerHandler.handleAfterInsertUpdate(Trigger.new);
}