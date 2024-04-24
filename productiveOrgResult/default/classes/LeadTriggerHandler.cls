public class LeadTriggerHandler {
    public static void handleLeadUpdate(Map<Id, Lead> oldMap, List<Lead> newLeads) {
        List<Lead> leadsToSend = new List<Lead>();
        for (Lead newLead : newLeads) {
            Lead oldLead = oldMap.get(newLead.Id);
            if (newLead.Bot_Script__c == 'ej90' && oldLead.Bot_Script__c != 'ej90') {
                leadsToSend.add(newLead);
            }
        }
        if (!leadsToSend.isEmpty()) {
            System.enqueueJob(new LeadCalloutQueueable(leadsToSend));
        }
    }
}