trigger SEN_WorkOrder_Trigger on Work_Order__c (before insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        
        SEN_WorkOrderHandler.verifySiteCompliance(Trigger.new);
    }
}