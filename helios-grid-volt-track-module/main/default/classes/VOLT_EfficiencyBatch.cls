public with sharing class VOLT_EfficiencyBatch implements Database.Batchable<SObject> {

    // start method: find all Inverters with efficiency below 80%
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, AccountId, Efficiency_Rating__c ' +
            'FROM Asset ' +
            'WHERE Efficiency_Rating__c < 80 AND Name LIKE \'%Inverter%\''
            );
    }

    // execute method: process each batch of assets
    public void execute(Database.BatchableContext bc, List<Asset> scope) {
        List<Work_Order__c> maintenanceOrders = new List<Work_Order__c>();

        for (Asset inv: scope){
            maintenanceOrders.add(new Work_Order__c(
                Site__c = inv.AccountId,
                Source_Asset__c = inv.Id,
                Type__c = 'Maintenance',
                Subject__c =  'Automated Efficiency Alert: ' + inv.Name,
                Description__c = 'Asset efficiency dropped to ' + inv.Efficiency_Rating__c + '%. Automated maintenance requested.'
            ));
        }

        if(!maintenanceOrders.isEmpty()){
            insert maintenanceOrders;
        }
    }

    //Finish method: log completion
    public void finish(Database.BatchableContext bc) {
        System.debug('Volt-Track: Efficiency scan complete.');
    }
}