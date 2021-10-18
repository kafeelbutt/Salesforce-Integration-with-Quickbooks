@isTest
public with sharing class SchedulerForRefreshTokenQuickBooksTest {
    @TestSetup
    static void makeData(){
        Quickbooks_Info__c quickbooks = new Quickbooks_Info__c(Name='QuickBooks Setting Info');
        quickbooks.Refresh_Token__c = 'ssdnjsknb';
        insert quickbooks;
        Quick_Books_Settings__c quickbooksSettings = new Quick_Books_Settings__c();
        quickbooksSettings.Client_ID__c='xxx';
        quickbooksSettings.Client_Secret__c='xss';
        quickbooksSettings.oAuth_Endpoint__c='https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
        quickbooksSettings.Scope__c='com.intuit.quickbooks.accounting';
        quickbooksSettings.Authorization_Endpoint__c='https://appcenter.intuit.com/connect/oauth2';
        quickbooksSettings.Redirect_URI__c='https://ocloudsolutions25-dev-ed--c.visualforce.com/apex/QuickBooksAuthorizePg';
        insert quickbooksSettings;
    }
    @isTest static void testScheduler(){
        String cronExp = '0 0 * * * ?';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockQuickBooksAuthorize());
        String jobId = System.schedule('QuickBooksSchedulerTest', cronExp, new SchedulerForRefreshTokenQuickBooks());
        Test.stopTest();
    }
}
