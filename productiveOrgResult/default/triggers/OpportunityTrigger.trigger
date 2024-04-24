trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) {
    OpportunityTriggerHandler.handleOpportunity(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
}