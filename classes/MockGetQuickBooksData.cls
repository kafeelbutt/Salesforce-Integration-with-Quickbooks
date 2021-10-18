@isTest
public with sharing class MockGetQuickBooksData implements HttpCalloutMock {
    public static HTTPResponse respond(HTTPRequest request) {
        Quick_Books_Settings__c custom_settings = Quick_Books_Settings__c.getInstance();
        String baseURL = custom_settings.BaseURL__c;
        String realmId = custom_settings.RealmId__c; 
        HttpResponse response = new HttpResponse();
        if(request.getEndpoint().endsWith('true&minorversion=62'))
        {
            String timeScheduler='2021-10-18T04:00:00-07:00';
            String queryParameter = EncodingUtil.urlEncode('select * from Customer Where Metadata.LastUpdatedTime > \'' +timeScheduler+'\' and Active = true','UTF-8');
            String requestEndPoint = baseURL+ '/v3/company/'+realmId+'/query?query='+queryParameter+'&minorversion=62';
            System.assertEquals('GET', request.getMethod());
            // Create a fake response
            response.setHeader('Content-Type' , 'application/json');
            response.setBody('{"QueryResponse": {"Customer":[{"GivenName":"ss","MiddleName":"ss","FamilyName":"sss","PrimaryEmailAddr":{"Address":"kafee@gmail.com"},"PrimaryPhone":{"FreeFormNumber":"00"},"BillAddr":{"Id":"96","Line1":"DHA Phase 03","City":"Lahore","CountrySubDivisionCode":"Lahore","PostalCode":"54600"},"ShipAddr":{"Id":"96","Line1":"DHA Phase 03","City":"Lahore","CountrySubDivisionCode":"Lahore","PostalCode":"54600"},"Id":"96"}]}}');
            response.setStatusCode(200);
            return response;
        }
        else if(request.getEndpoint().endsWith('&minorversion=62'))
        {
            String timeScheduler='2021-10-18T04:00:00-07:00';
            String queryParameter = EncodingUtil.urlEncode('select * from CompanyInfo Where Metadata.LastUpdatedTime > \'' +timeScheduler+'\'','UTF-8');
            String requestEndPoint = baseURL+ '/v3/company/'+realmId+'/query?query='+queryParameter+'&minorversion=62';
            System.assertEquals('GET', request.getMethod());
            // Create a fake response
            response.setHeader('Content-Type' , 'application/json');
            response.setBody('{"QueryResponse": {"CompanyInfo":[{"CompanyName":"ss","PrimaryPhone":{"FreeFormNumber":"00"},"CompanyAddr":{"Id":"96","Line1":"DHA Phase 03","City":"Lahore","CountrySubDivisionCode":"Lahore","PostalCode":"54600"},"Id":"96"}]}}');
            response.setStatusCode(200);  
            return response;
        }
        else{
            System.assert(false, 'unexpected endpoint ' + request.getEndpoint());
            return null;
        }
    }
}