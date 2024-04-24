@isTest
private class SubscriberControllerTest {
    
    @testSetup
    static void setup() {
        // Create test data for Subscribers
        List<Subscriber__c> subscribers = new List<Subscriber__c>();
        subscribers.add(new Subscriber__c(Name='Active Subscriber', Phone__c='1234567890', Email__c='active@example.com', Data_Used__c='10GB', Country__c='USA', Date_Joined__c=Date.today(), Status__c='ACTIVE'));
        subscribers.add(new Subscriber__c(Name='Suspended Subscriber', Phone__c='0987654321', Email__c='suspended@example.com', Data_Used__c='15GB', Country__c='Canada', Date_Joined__c=Date.today(), Status__c='SUSPENDED'));
        subscribers.add(new Subscriber__c(Name='Disconnected Subscriber', Phone__c='1122334455', Email__c='disconnected@example.com', Data_Used__c='5GB', Country__c='UK', Date_Joined__c=Date.today(), Status__c='DISCONNECTED'));
        insert subscribers;
    }
    
    @isTest
    static void testGetSubscribersActiveOnly() {
        Test.startTest();
        List<Subscriber__c> results = SubscriberController.getSubscribers('', 10, 1, false);
        Test.stopTest();
        
        // Verify that only active and suspended subscribers are returned
        System.assertEquals(2, results.size(), 'Should return two subscribers.');
        for (Subscriber__c sub : results) {
            System.assertNotEquals('DISCONNECTED', sub.Status__c, 'Disconnected subscribers should not be included.');
        }
    }
    
    @isTest
    static void testGetSubscribersIncludeDisconnected() {
        Test.startTest();
        List<Subscriber__c> results = SubscriberController.getSubscribers('', 10, 1, true);
        Test.stopTest();
        
        // Verify that disconnected subscribers are included
        System.assertEquals(3, results.size(), 'Should return three subscribers.');
    }
    
    @isTest
    static void testSearchSubscribers() {
        Test.startTest();
        List<Subscriber__c> results = SubscriberController.getSubscribers('Active', 10, 1, false);
        Test.stopTest();
        
        // Verify search functionality
        System.assertEquals(1, results.size(), 'Should return one subscriber matching \'Active\'.');
        System.assertEquals('Active Subscriber', results[0].Name, 'Subscriber name should match the search string.');
    }
    
    @isTest
    static void testGetAllSubscribers() {
        Test.startTest();
        List<Subscriber__c> results = SubscriberController.getAllSubscribers();
        Test.stopTest();
        
        // Verify that all subscribers are returned
        System.assertEquals(3, results.size(), 'Should return all subscribers.');
    }
    
}