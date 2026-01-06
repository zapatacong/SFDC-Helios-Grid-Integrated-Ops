@RestResource(urlMapping='/inverters/efficiency/*')
global with sharing class VOLT_InverterIntegration {

    //This method handles the incoming "PATCH" request from inverter
    @HttpPatch
    global static String updateEfficiency() {
        RestRequest req = RestContext.request;
        
        // 1. Extract the JSON body from the request
        String jsonBody = req.requestBody.toString();
        
        // 2. Map the JSON to an Apex Object (we will build this helper next)
        InverterData data = (InverterData) JSON.deserialize(jsonBody, InverterData.class);
        
        try {
            // 3. Find the Asset using the Serial Number (The External ID)
            Asset inv = [SELECT Id, Efficiency_Rating__c FROM Asset WHERE Serial_Number__c = :data.serialNumber LIMIT 1];
            
            // 4. Update the record
            inv.Efficiency_Rating__c = data.reading;
            update inv;
            
            return 'Success: Inverter ' + data.serialNumber + ' updated to ' + data.reading + '%';
        } catch (Exception e) {
            return 'Error: Could not find or update inverter with Serial Number ' + data.serialNumber;
        }
    }

    // Helper class to structure the incoming data
    public class InverterData {
        public String serialNumber;
        public Decimal reading;
    }
}