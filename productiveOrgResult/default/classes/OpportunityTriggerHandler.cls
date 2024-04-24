public class OpportunityTriggerHandler {
    public static void handleOpportunity(List<Opportunity> newList, List<Opportunity> oldList, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        Set<Id> accountIds = new Set<Id>();
        
        if (isDelete) {
            for (Opportunity opp : oldList) {
                accountIds.add(opp.AccountId);
            }
        } else {
            for (Opportunity opp : newList) {
                accountIds.add(opp.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            updateAccountTotals(accountIds);
        }
    }

    private static void updateAccountTotals(Set<Id> accountIds) {
        Map<Id, Decimal> accountTotals = new Map<Id, Decimal>();
        for (Opportunity opp : [SELECT Amount, AccountId FROM Opportunity WHERE AccountId IN :accountIds]) {
            accountTotals.put(opp.AccountId, (accountTotals.get(opp.AccountId) ?? 0) + opp.Amount);
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            accountsToUpdate.add(new Account(Id = accId, Total_Amount__c = accountTotals.get(accId)));
        }

        update accountsToUpdate;
    }
}