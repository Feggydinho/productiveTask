public with sharing class SubscriberController {
    
    @AuraEnabled(cacheable=true)
    public static List<Subscriber__c> getAllSubscribers() {
        return [SELECT Name, Phone__c, Email__c, Data_Used__c, Country__c, Date_Joined__c, Status__c FROM Subscriber__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Subscriber__c> getSubscribers(String searchString, Integer pageSize, Integer pageNumber, Boolean includeDisconnected) {
        System.debug('searchString:'+searchString+'.pageSize:'+pageSize+'.pageNumber'+pageNumber+'.includeDisconnected:'+includeDisconnected);
        // Prepare variables for dynamic SOQL
        Integer offset = (pageNumber - 1) * pageSize; // Calculate offset outside SOQL

        // Build the WHERE clause
        List<String> filters = new List<String>();
        filters.add('Status__c = \'ACTIVE\'');
        filters.add('Status__c = \'SUSPENDED\'');
        if (includeDisconnected) {
            filters.add('Status__c = \'DISCONNECTED\'');
        }
        String whereClause = '(' + String.join(filters, ' OR ') + ')';

        if (!String.isBlank(searchString)) {
            searchString = '%' + searchString + '%';
            whereClause += ' AND (Name LIKE :searchString OR Phone__c LIKE :searchString)';
        }

        // Build the entire query
        String query = 'SELECT Name, Phone__c, Email__c, Data_Used__c, Country__c, Date_Joined__c, Status__c ' +
                       'FROM Subscriber__c ' +
                       'WHERE ' + whereClause +
                       ' ORDER BY Name ASC ' +
                       'LIMIT :pageSize OFFSET :offset'; // Use variables for LIMIT and OFFSET

        System.debug('query is:'+query);
        return Database.query(query);
    }
}