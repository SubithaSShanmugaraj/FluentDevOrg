/**
 * @description Controller class for managing E-Commerce product data in Lightning Web Components
 * Provides methods to retrieve product information with sharing rules enforced
 */
public with sharing class ProductController {
    
    /**
     * @description Retrieves a list of E_Cart_Product__c records with a configurable limit
     * @param maxRecords Maximum number of records to return (defaults to 12 if null or invalid)
     * @return List<E_Cart_Product__c> List of product records ordered by Name
     * @throws AuraHandledException if there's an error during query execution
     */
    @AuraEnabled(cacheable=true)
    public static List<E_Cart_Product__c> getProducts(Integer maxRecords) {
        try {
            Integer recordLimit = (maxRecords != null && maxRecords > 0) ? maxRecords : 12;
            
            // Check CRUD/FLS permissions before querying
            validateProductAccessPermissions();
            
            return [
                SELECT Id, Name, Description__c, Price__c, Image_URL__c
                FROM E_Cart_Product__c
                WITH USER_MODE
                ORDER BY Name ASC
                LIMIT :recordLimit
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Validates that the current user has read access to E_Cart_Product__c and its fields
     * @throws AuraHandledException if the user lacks necessary permissions
     */
    private static void validateProductAccessPermissions() {
        if (!Schema.sObjectType.E_Cart_Product__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access product data');
        }
        
        if (!Schema.sObjectType.E_Cart_Product__c.fields.Name.isAccessible() ||
            !Schema.sObjectType.E_Cart_Product__c.fields.Description__c.isAccessible() ||
            !Schema.sObjectType.E_Cart_Product__c.fields.Price__c.isAccessible() ||
            !Schema.sObjectType.E_Cart_Product__c.fields.Image_URL__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access product fields');
        }
    }
}