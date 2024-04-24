@isTest
private class OpportunityTriggerHandlerTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(Name = 'Test Opp 1', StageName = 'Prospecting', CloseDate = System.today().addDays(30), Amount = 100, AccountId = acc.Id),
            new Opportunity(Name = 'Test Opp 2', StageName = 'Prospecting', CloseDate = System.today().addDays(30), Amount = 200, AccountId = acc.Id)
        };
        insert opportunities;
    }

    @isTest
    static void testUpdateAccountTotalOnOpportunityUpdate() {
        List<Opportunity> opportunities = [SELECT Id, Amount FROM Opportunity];
        Account acc = [SELECT Id, Total_Amount__c FROM Account LIMIT 1];

        Opportunity opp1 = opportunities[0];
        opp1.Amount = 150;
        update opp1;

        Account updatedAcc = [SELECT Total_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(350, updatedAcc.Total_Amount__c, 'The total amount should be correctly aggregated after update.');
    }

    @isTest
    static void testAccountTotalAfterOpportunityDeletion() {
        List<Opportunity> opportunities = [SELECT Id, Amount FROM Opportunity];
        Account acc = [SELECT Id, Total_Amount__c FROM Account LIMIT 1];

        delete opportunities[0];

        Account updatedAcc = [SELECT Total_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(200, updatedAcc.Total_Amount__c, 'The total amount should be adjusted correctly after the deletion of an opportunity.');
    }
}