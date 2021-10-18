public with sharing class GetQuickBooksData {
    private static Quick_Books_Settings__c custom_settings = Quick_Books_Settings__c.getInstance();
    private static String baseURL = custom_settings.BaseURL__c;
    private static String realmId = custom_settings.RealmId__c;
    
    private static String getAccessToken(){
        Quickbooks_Info__c quickBooksObject = [SELECT Access_Token__c FROM Quickbooks_Info__c where Name = 'QuickBooks Setting Info'];
        String accessToken = 'Bearer '+quickBooksObject.Access_Token__c;
        return accessToken;

    }
    
    private static String getSchedulerTime(){
        CronTrigger previousTime = [SELECT PreviousFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'QuickBooks Data Scheduler'];
        Datetime previousFireTime = previousTime.PreviousFireTime.addHours(-7);
        String previousdateTime = String.valueOf(previousFireTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss-07:00'));
        return previousdateTime;

    }
    public static CustomerDataClass customersData {
        get;
        set;
    }
    public static CompanyDataClass companiesData {
        get;
        set;
    }
    
    @Future(callout=true)
    public static void getCustomerData(){
        String timeScheduler = getSchedulerTime();
        System.debug(timeScheduler);
        String queryParameter = EncodingUtil.urlEncode('select * from Customer Where Metadata.LastUpdatedTime > \'' +timeScheduler+'\' and Active = true','UTF-8');
        String requestEndPoint = baseURL+ '/v3/company/'+realmId+'/query?query='+queryParameter+'&minorversion=62';
        String accessToken = getAccessToken();
        String errorMessage = '';
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestEndPoint);
        request.setMethod('GET');
        request.setHeader('Authorization', accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        try {
            response = http.send(request);
            if(response.getStatusCode()==200){
                System.debug(response.getBody());
                customersData = (CustomerDataClass) JSON.deserialize(response.getBody(), CustomerDataClass.class);
                if(customersData.QueryResponse.Customer==null){
                    System.debug('No record is found (Response is Null)');
                    return;
                }
                List<Contact> contactList = new List<Contact>();
                Contact contactObj = new Contact();
                for(CustomerDataClass.Customer customer: customersData.QueryResponse.Customer){
                    contactObj.Customer_Id__c = Integer.valueOf(customer.Id);
                    contactObj.FirstName = customer.GivenName + ' ' +customer.MiddleName;
                    contactObj.LastName = customer.FamilyName;
                    contactObj.Phone = customer.PrimaryPhone.FreeFormNumber;
                    contactObj.Email = customer.PrimaryEmailAddr.Address;
                    contactObj.MailingStreet = customer.BillAddr.Line1;
                    contactObj.MailingCity = customer.BillAddr.City;
                    contactObj.MailingState = customer.BillAddr.CountrySubDivisionCode;
                    contactObj.MailingPostalCode = customer.BillAddr.PostalCode;
                    contactObj.OtherStreet = customer.ShipAddr.Line1;
                    contactObj.OtherCity = customer.ShipAddr.City;
                    contactObj.OtherPostalCode = customer.ShipAddr.PostalCode;
                    contactObj.OtherState = customer.ShipAddr.CountrySubDivisionCode;
                    contactList.add(contactObj);
                }
                Schema.SObjectField externalIdToken = Contact.Fields.Customer_Id__c;
                Database.UpsertResult[] upsertContactList = Database.upsert(contactList, externalIdToken, false);
                for(Database.UpsertResult result: upsertContactList){
                    if(result.isSuccess()){
                        System.debug('Operation is Successful');
                    }
                    else{
                        for(Database.Error error : result.getErrors()){
                            System.debug('error has occurred.' + error.getStatusCode() + ': ' + error.getMessage());
                            System.debug('fields that affected this error: ' + error.getFields());
                        }
                    }
                }
                System.debug(contactObj);
            }
        } catch(Exception e) {
            System.debug('Exception Executed: '+e.getStackTraceString());
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup ->'
                +' Remote Site Setting and add '+' '+ baseURL +' Endpoint';
                System.debug(errorMessage);
            }
            else
            {
                errorMessage = 'Unexpected Error while communicating with Quickbooks API. ' +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(errorMessage);
            }
        }
    }

    @Future(callout=true)
    public static void getCompanyData(){
        String timeScheduler = getSchedulerTime();
        String queryParameter = EncodingUtil.urlEncode('select * from CompanyInfo Where Metadata.LastUpdatedTime > \'' +timeScheduler+'\'','UTF-8');
        String requestEndPoint = baseURL+ '/v3/company/'+realmId+'/query?query='+queryParameter+'&minorversion=62';
        String accessToken = getAccessToken();
        String errorMessage = '';
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestEndPoint);
        request.setMethod('GET');
        request.setHeader('Authorization', accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        try {
            response = http.send(request);
            if(response.getStatusCode()==200){
                System.debug(response.getBody());
                companiesData = (CompanyDataClass) JSON.deserialize(response.getBody(), CompanyDataClass.class);
                if(companiesData.QueryResponse.CompanyInfo==null){
                    System.debug('No record is found (Response is Null)');
                    return;
                }
                List<Account> accountList = new List<Account>();
                Account accountObj = new Account();
                for(CompanyDataClass.Company company: companiesData.QueryResponse.CompanyInfo){
                    accountObj.Company_Id__c = Integer.valueOf(company.Id);
                    accountObj.Name = company.CompanyName;
                    accountObj.Phone = company.PrimaryPhone.FreeFormNumber;
                    accountObj.BillingStreet = company.CompanyAddr.Line1;
                    accountObj.BillingCity = company.CompanyAddr.City;
                    accountObj.BillingState = company.CompanyAddr.CountrySubDivisionCode;
                    accountObj.BillingCountry = company.CompanyAddr.Country;
                    accountObj.BillingPostalCode = company.CompanyAddr.PostalCode;
                    accountList.add(accountObj);
                }
                Schema.SObjectField externalIdToken = Account.Fields.Company_Id__c;
                Database.UpsertResult[] upsertAccountList = Database.upsert(accountList, externalIdToken, false);
                for(Database.UpsertResult result: upsertAccountList){
                    if(result.isSuccess()){
                        System.debug('Operation is Successful');
                    }
                    else{
                        for(Database.Error error : result.getErrors()){
                            System.debug('error has occurred.' + error.getStatusCode() + ': ' + error.getMessage());
                            System.debug('fields that affected this error: ' + error.getFields());
                        }
                    }
                }
                System.debug(accountObj);
            }
        } catch(Exception e) {
            System.debug('Exception Executed: '+e.getStackTraceString());
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup ->'
                +' Remote Site Setting and add '+' '+ baseURL +' Endpoint';
                System.debug(errorMessage);
            }
            else
            {
                errorMessage = 'Unexpected Error while communicating with Quickbooks API. ' +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(errorMessage);
            }
        }
    }
}