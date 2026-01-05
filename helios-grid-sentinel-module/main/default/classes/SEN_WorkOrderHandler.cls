public with sharing class SEN_WorkOrderHandler {
    
    /* @description: Validates associated Site(Account) before Work Order is created */
    public static void verifySiteCompliance(List<Work_Order__c> newWorkOrders) {

        Set<Id> siteIds = new Set<Id>();

        for(Work_Order__c wo: newWorkOrders){
            /* Collect Site Ids(Accounts) from Work Orders */
            if(wo.Site__c != null){
                siteIds.add(wo.Site__c);
            }

            if (siteIds.isEmpty()){
                return;
            }
        }

        Map<Id, Account> siteMap = new Map<Id, Account>([
            SELECT Id, Site_Permit_Status__c
            FROM Account 
            WHERE Id IN :siteIds
        ]);

        for(Work_Order__c wo: newWorkOrders){

            Account parentSite = siteMap.get(wo.Site__c);

            
            if(parentSite != null && parentSite.Site_Permit_Status__c != 'Valid'){

                /* This will check first if parentSite is not null to avoid null pointer exception */
                String currentStatus = parentSite.Site_Permit_Status__c != null ? parentSite.Site_Permit_Status__c : 'Missing';
                wo.addError('Cannot create Work Order. The associated Site does not have a Valid Permit Status. The current Site Permit Status is: ' + currentStatus + '.');
            }

        }

    }
}