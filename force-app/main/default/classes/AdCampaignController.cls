/**
 * @description Controller class for managing Ad Campaign video data in Lightning Web Components
 * Provides methods to retrieve video content associated with campaigns
 */
public with sharing class AdCampaignController {
    
    /**
     * @description Retrieves Ad_Video__c records associated with a specific campaign
     * Uses WITHOUT SHARING internally to allow external users to query by Campaign lookup
     * @param campaignId The ID of the Campaign to retrieve videos for
     * @return List<Ad_Video__c> List of video records ordered by Order__c field
     */
    @AuraEnabled(cacheable=true)
    public static List<Ad_Video__c> getCampaignVideos(Id campaignId) {
        return new AdCampaignQueryHelper().queryCampaignVideos(campaignId);
    }
    
    /**
     * @description Inner class to handle queries without sharing restrictions
     * This allows external users to filter by Campaign lookup field
     */
    private without sharing class AdCampaignQueryHelper {
        /**
         * @description Queries Ad_Video__c records without sharing restrictions
         * @param campaignId The ID of the Campaign to retrieve videos for
         * @return List<Ad_Video__c> List of video records ordered by Order__c field
         */
        public List<Ad_Video__c> queryCampaignVideos(Id campaignId) {
            return [
                SELECT 
                    Id, 
                    Product_Name__c, 
                    Product_Code__c,
                    Video_Id__c, 
                    Order__c,
                    Video_Source_Type__c,
                    Video_URL__c,
                    Suggestion_Questions__c
                FROM Ad_Video__c
                WHERE Ad_Campaign__c = :campaignId
                ORDER BY Order__c ASC
                LIMIT 5
            ];
        }
    }
}