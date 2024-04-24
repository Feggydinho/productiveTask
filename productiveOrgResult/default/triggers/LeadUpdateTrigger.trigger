trigger LeadUpdateTrigger on Lead (after update) {
    LeadTriggerHandler.handleLeadUpdate(Trigger.oldMap, Trigger.new);
}