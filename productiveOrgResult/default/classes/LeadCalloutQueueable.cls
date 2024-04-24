public class LeadCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private List<Lead> leadsToSend;
    private List<Id> leadIds;
    
    public LeadCalloutQueueable(List<Lead> leadsToSend) {
        this.leadsToSend = leadsToSend;
        this.leadIds = new List<Id>();
        for (Lead lead : leadsToSend) {
            this.leadIds.add(lead.Id);
        }
    }
    
    public void execute(QueueableContext context) {
        List<Lead> modifiableLeads = [SELECT Id, FirstName, LastName, Phone, Email, IsCalloutSuccessful__c FROM Lead WHERE Id IN :leadIds];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        String endpointUrl = Integration_Setting__mdt.getInstance('Test').Endpoint_URL__c;
        
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(preparePayload(leadsToSend)));
        
        try {
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Success and responseBody is :' + response.getBody());
            } else {
                System.debug('Error from external service: ' + response.getBody());
            }
            updateLeadCalloutStatus(modifiableLeads, response.getStatusCode());
        } catch (Exception e) {
            System.debug('Exception occurred in LeadCalloutQueueable: ' + e.getMessage());
            updateLeadCalloutStatus(modifiableLeads, 0); 
        }
        
    }
    
    private List<Map<String, String>> preparePayload(List<Lead> leads) {
        List<Map<String, String>> payload = new List<Map<String, String>>();
        for (Lead lead : leads) {
            payload.add(new Map<String, String>{
                'firstName' => lead.FirstName,
                    'lastName' => lead.LastName,
                    'phone' => lead.Phone,
                    'email' => lead.Email
                    });
        }
        return payload;
    }
    
    private void updateLeadCalloutStatus(List<Lead> leads, Integer statusCode) {
        for (Lead lead : leads) {
            lead.IsCalloutSuccessful__c = (statusCode == 200) ? 'Yes' : 'No';
        }
        update leads;
    }
}