/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class VOLT_Efficiency_Test {

    @testSetup
    static void setupData() {
        //Create a Site (Account)
        Account site = new Account(
            Name = 'Test Solar Farm',
            Site_Permit_Status__c = 'Valid'
            );
        insert site;

        //Create one "Healthy" Inverter (95%) and one "Failing" Inverter (70%)
        List<Asset> assets = new List<Asset>();
        assets.add(new Asset(
            Name = 'Healthy Inverter',
            AccountId = site.Id,
            Efficiency_Rating__c = 95
        ));
        assets.add(new Asset(
            Name = 'Failing Inverter',
            AccountId = site.Id,
            Efficiency_Rating__c = 70
        ));
        insert assets;
    }

    @isTest
    static void testBatchExecution() {
        // Run the batch job
        Test.startTest();
        VOLT_EfficiencyBatch batch = new VOLT_EfficiencyBatch();
        Database.executeBatch(batch);
        Test.stopTest(); // This forces the batch to run and finish

        // Verify: Only 1 Work Order should have been created (for the failing inverter)
        List<Work_Order__c> results = [SELECT Id, Subject__c FROM Work_Order__c];
        System.assertEquals(1, results.size(), 'Only one Work Order should be created for failing assets.');
        System.assert(results[0].Subject__c.contains('Failing Inverter'), 'The Work Order should be linked to the correct Asset.');
    }

    @isTest
    static void testScheduler() {
        // Verify the scheduler can be called
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        String jobId = System.schedule('Test Volt-Track Schedule', cronExp, new VOLT_EfficiencyScheduler());
        Test.stopTest();

        // Check if the job is scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression);
    }

}