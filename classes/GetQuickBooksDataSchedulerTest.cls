@isTest
public with sharing class GetQuickBooksDataSchedulerTest {
    @TestSetup
    static void makeData(){
        Quickbooks_Info__c quickbooks = new Quickbooks_Info__c(Name='QuickBooks Setting Info');
        quickbooks.Access_Token__c = 'ssdnjsknb';
        insert quickbooks;
        Quick_Books_Settings__c quickbooksSettings = new Quick_Books_Settings__c();
        quickbooksSettings.BaseURL__c='https://sandbox-quickbooks.api.intuit.com';
        quickbooksSettings.RealmId__c='4620816365179971660';
        insert quickbooksSettings;
    }
    @isTest static void testScheduler(){
        String cronExp = '0 0 * * * ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockGetQuickBooksData());
        String jobId = System.schedule('QuickBooksSchedulerTest', cronExp, new GetQuickBooksDataScheduler());
        Test.stopTest();
    }

}