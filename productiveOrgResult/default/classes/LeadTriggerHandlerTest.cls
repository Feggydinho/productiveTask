@isTest
private class LeadTriggerHandlerTest {
    @testSetup
    static void setup() {
        List<Lead> leads = new List<Lead>{
            new Lead(LastName='Test Lead', FirstName='abc', Company='TestCo', Phone='1234567890', Email='test@example.com', Bot_Script__c='ej100')
        };
        insert leads;
    }

    @isTest
    static void testSuccessfulCallout() {
        Test.setMock(HttpCalloutMock.class, new LeadHttpCalloutMock(200, '{"success":true}'));

        Test.startTest();
        List<Lead> leads = [SELECT Id, Bot_Script__c FROM Lead];
        leads[0].Bot_Script__c = 'ej90';
        update leads;
        Test.stopTest();

        leads = [SELECT Id, IsCalloutSuccessful__c FROM Lead];
        System.assertEquals('Yes', leads[0].IsCalloutSuccessful__c, 'The callout should be successful.');
    }

    @isTest
    static void testFailedCallout() {
        Test.setMock(HttpCalloutMock.class, new LeadHttpCalloutMock(400, '{"error":"Bad Request"}'));

        Test.startTest();
        List<Lead> leads = [SELECT Id, FirstName, LastName, Phone, Email, IsCalloutSuccessful__c FROM Lead];
        leads[0].Bot_Script__c = 'ej90';
        update leads;
        System.enqueueJob(new LeadCalloutQueueable(leads));
        Test.stopTest();

        leads = [SELECT Id, IsCalloutSuccessful__c FROM Lead];
        System.assertEquals('No', leads[0].IsCalloutSuccessful__c, 'The callout should fail.');
    }
}