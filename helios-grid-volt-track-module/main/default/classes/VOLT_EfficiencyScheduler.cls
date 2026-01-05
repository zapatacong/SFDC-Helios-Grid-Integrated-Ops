
/**
 * @description       : VOLT Efficiency Scheduler Class
 * Implements schedulable to allow Salesforce to run Batch job on a timer
 */
public with sharing class VOLT_EfficiencyScheduler implements Schedulable 
{
       public void execute(SchedulableContext sc) {
        // When the alarm goes off, start the Batch job with a chunk size of 200
        VOLT_EfficiencyBatch b = new VOLT_EfficiencyBatch();
        Database.executeBatch(b, 200);
    }
}