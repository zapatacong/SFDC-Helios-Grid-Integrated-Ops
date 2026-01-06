@isTest
private class VOLT_InverterIntegration_Test {

    @testSetup
    static void setup() {
        // Create a Site with 'Valid' status to satisfy the Sentinel Trigger
        Account site = new Account(Name = 'Test Site', Site_Permit_Status__c = 'Valid');
        insert site;

        // Create an Asset with a Serial Number to be updated
        Asset inv = new Asset(
            Name = 'Inverter 1',
            Serial_Number__c = 'SN-TEST-123', // External ID
            AccountId = site.Id,
            Efficiency_Rating__c = 100
        );
        insert inv;
    }

    @isTest
    static void testUpdateEfficiencySuccess() {
        // 1. Prepare the JSON payload like a real solar panel would
        String jsonBody = '{"serialNumber": "SN-TEST-123", "reading": 75.5}';

        // 2. Mock the RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/inverters/efficiency/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        // 3. Execute the code
        Test.startTest();
        String result = VOLT_InverterIntegration.updateEfficiency();
        Test.stopTest();

        // 4. Verify the results
        System.assert(result.contains('Success'), 'The API should return a success message');
        
        Asset updatedInv = [SELECT Efficiency_Rating__c FROM Asset WHERE Serial_Number__c = 'SN-TEST-123'];
        System.assertEquals(75.5, updatedInv.Efficiency_Rating__c, 'The efficiency should have been updated to 75.5');
    }

    @isTest
    static void testUpdateEfficiencyFailure() {
        // Test with a Serial Number that DOES NOT exist
        String jsonBody = '{"serialNumber": "WRONG-SN", "reading": 50.0}';

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        Test.startTest();
        String result = VOLT_InverterIntegration.updateEfficiency();
        Test.stopTest();

        // Verify the failure message
        System.assert(result.contains('Error'), 'The API should return an error message for unknown serial numbers');
    }
}