@isTest
private class SEN_WorkOrder_Test {

    @isTest
    static void testBlockdWorkOrder() {

        // Create a Site(Account) with invalid permit status
        Account expiredSite = new Account(
            Name = 'Expired Solar Farm',
            Site_Permit_Status__c = 'Expired'
        );
        insert expiredSite;
        
        // Attempt to create a Work Order associated with the invalid Site
        Work_Order__c wo = new Work_Order__c(
            Site__c = expiredSite.Id
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(wo, false);
        Test.stopTest();

        //verify that the Work Order insertion failed
        System.assertEquals(false, result.isSuccess(), 'Work Order insertion should fail due to invalid Site permit status.');
        System.assert(result.getErrors()[0].getMessage().contains('Cannot create Work Order.'), 'Error message should indicate invalid Site permit status.');

    }

    @isTest
    static void testAllowedWorkOrder(){
        // Create a Site(Account) with valid permit status
        Account validSite = new Account(
            Name = 'Valid Solar Farm',
            Site_Permit_Status__c = 'Valid'
        );
        insert validSite;
        
        // Attempt to create a Work Order associated with the valid Site
        Work_Order__c wo = new Work_Order__c(
            Site__c = validSite.Id
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(wo, true);
        Test.stopTest();

        // Verify that the Work Order insertion succeeded
        System.assertEquals(true, result.isSuccess(), 'Work Order insertion should succeed for Site with valid permit status.');
    }




}