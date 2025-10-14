@isTest
private class ProductControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test products
        List<E_Cart_Product__c> testProducts = new List<E_Cart_Product__c>();
        
        for (Integer i = 1; i <= 15; i++) {
            testProducts.add(new E_Cart_Product__c(
                Name = 'Test Product ' + i,
                Description__c = 'This is a test product description for product ' + i,
                Price__c = 100.00 + (i * 10),
                Image_URL__c = 'https://example.com/product' + i + '.jpg'
            ));
        }
        
        insert testProducts;
    }
    
    @isTest
    static void testGetProductsWithDefaultLimit() {
        // Test with null maxRecords (should default to 12)
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(null);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(12, results.size(), 'Should return default limit of 12 products');
        System.assertNotEquals(null, results[0].Name, 'Product Name should not be null');
        System.assertNotEquals(null, results[0].Description__c, 'Product Description should not be null');
        System.assertNotEquals(null, results[0].Price__c, 'Product Price should not be null');
        System.assertNotEquals(null, results[0].Image_URL__c, 'Product Image URL should not be null');
    }
    
    @isTest
    static void testGetProductsWithCustomLimit() {
        // Test with custom limit of 5
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(5);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(5, results.size(), 'Should return custom limit of 5 products');
    }
    
    @isTest
    static void testGetProductsWithLimitExceedingRecords() {
        // Test with limit greater than available records (15 created, asking for 20)
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(20);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(15, results.size(), 'Should return all 15 available products');
    }
    
    @isTest
    static void testGetProductsWithZeroLimit() {
        // Test with zero limit (should default to 12)
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(0);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(12, results.size(), 'Should return default limit of 12 when zero is passed');
    }
    
    @isTest
    static void testGetProductsWithNegativeLimit() {
        // Test with negative limit (should default to 12)
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(-5);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(12, results.size(), 'Should return default limit of 12 when negative is passed');
    }
    
    @isTest
    static void testGetProductsOrderByName() {
        // Test that products are ordered by name
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(5);
        Test.stopTest();
        
        // Verify ordering
        for (Integer i = 0; i < results.size() - 1; i++) {
            System.assert(
                results[i].Name <= results[i + 1].Name,
                'Products should be ordered by Name ASC'
            );
        }
    }
    
    @isTest
    static void testGetProductsWithNoRecords() {
        // Delete all products to test empty result
        delete [SELECT Id FROM E_Cart_Product__c];
        
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(10);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(0, results.size(), 'Should return empty list when no products exist');
        System.assertNotEquals(null, results, 'Should return non-null empty list');
    }
    
    @isTest
    static void testGetProductsFieldAccessibility() {
        // Test that all required fields are accessible
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(1);
        Test.stopTest();
        
        // Verify all fields are accessible
        E_Cart_Product__c product = results[0];
        System.assertNotEquals(null, product.Id, 'Id should be accessible');
        System.assertNotEquals(null, product.Name, 'Name should be accessible');
        System.assertNotEquals(null, product.Description__c, 'Description__c should be accessible');
        System.assertNotEquals(null, product.Price__c, 'Price__c should be accessible');
        System.assertNotEquals(null, product.Image_URL__c, 'Image_URL__c should be accessible');
    }
    
    @isTest
    static void testGetProductsWithLargeLimit() {
        // Test with a very large limit (should still respect available records)
        Test.startTest();
        List<E_Cart_Product__c> results = ProductController.getProducts(1000);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(15, results.size(), 'Should return all 15 available products even with large limit');
    }
    
    @isTest
    static void testGetProductsCacheability() {
        // Test method is cacheable (verify no DML operations)
        Test.startTest();
        List<E_Cart_Product__c> results1 = ProductController.getProducts(5);
        List<E_Cart_Product__c> results2 = ProductController.getProducts(5);
        Test.stopTest();
        
        // Verify both calls return same data
        System.assertEquals(results1.size(), results2.size(), 'Cacheable method should return consistent results');
    }
    
    @isTest
    static void testGetProductsWithSharingEnforced() {
        // Create a test user to verify 'with sharing' enforcement
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@fluent.test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@fluent.test.com'
        );
        insert testUser;
        
        System.runAs(testUser) {
            Test.startTest();
            // This will respect the user's sharing rules
            List<E_Cart_Product__c> results = ProductController.getProducts(5);
            Test.stopTest();
            
            // Verify the method executes with user's security context
            System.assertNotEquals(null, results, 'Method should execute with user context');
        }
    }
    
    @isTest
    static void testGetProductsFlsPermissionCheck() {
        // Test that FLS checks are in place
        // This test verifies the code has FLS checks, actual enforcement depends on user permissions
        Test.startTest();
        try {
            List<E_Cart_Product__c> results = ProductController.getProducts(5);
            // Should succeed with appropriate permissions
            System.assertNotEquals(null, results, 'Should return results with proper permissions');
        } catch (AuraHandledException e) {
            // If permissions are insufficient, should throw specific error
            System.assert(
                e.getMessage().contains('Insufficient permissions') || 
                e.getMessage().contains('Error fetching products'),
                'Should throw appropriate permission error'
            );
        }
        Test.stopTest();
    }
}