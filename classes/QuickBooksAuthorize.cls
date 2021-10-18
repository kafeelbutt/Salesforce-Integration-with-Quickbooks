public with sharing class QuickBooksAuthorize {
    private static Quick_Books_Settings__c custom_settings = Quick_Books_Settings__c.getInstance();
    private static String clientID = custom_settings.Client_ID__c;
    private static String clientSecret = custom_settings.Client_Secret__c;
    private static String oAuthEndPoint = custom_settings.oAuth_Endpoint__c;
    private static String scope = custom_settings.Scope__c;
    private static String authorizationEndPoint = custom_settings.Authorization_Endpoint__c;
    private static String redirectURI = custom_settings.Redirect_URI__c;

    public static Pagereference authorizationQuickBooks(){
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        //String finalEndPoint = authorizationEndPoint + '?client_id' + clientID + '&scope=' + scope + '&redirect_uri=' + EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm()+'apex/QuickBooksAuthorizePg', 'UTF-8') + '&response_type=code&state=' + timestamp;
        String finalEndPoint = authorizationEndPoint+'?client_id='+clientID+'&response_type=code&scope='+
            scope+'&state='+timestamp+'&redirect_uri='+redirectURI;
        
        HttpRequest request = new HttpRequest();
        HttpResponse res;
        request.setEndpoint(finalEndPoint);
        request.setMethod('POST');
        request.setHeader('Content-Length', '146');
        Pagereference redirect = new Pagereference(finalEndPoint);
        return redirect;
    }
    public static void getAccessToken(){
        if( !ApexPages.currentPage().getParameters().containskey('code') )
        return;

        String encodedString = EncodingUtil.base64Encode(Blob.valueOf(clientID+':'+clientSecret));
        //String redirectUrl = EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickBooksAuthorizePg', 'UTF-8');
        String oAuthCode = ApexPages.currentPage().getParameters().get('code');
        String companyId = ApexPages.currentPage().getParameters().get('realmId');
        String stateID = ApexPages.currentPage().getParameters().get('state');

        String requestBody = 'grant_type=authorization_code&code='+oAuthCode+'&redirect_uri='+redirectURI;
        String errorMessage;

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setMethod('POST');
        request.setEndpoint(oAuthEndPoint);
        request.setHeader('Authorization', 'Basic '+encodedString);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);
        try {
            response = http.send(request);
            if(response.getStatusCode()==200){
                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                List<Quickbooks_Info__c> listOfQuickBooks= new List<Quickbooks_Info__c>();
                listOfQuickBooks = [Select Id, Name from Quickbooks_Info__c where Name = 'QuickBooks Setting Info'];
                Quickbooks_Info__c quickbooksSettingInfo = new Quickbooks_Info__c();

                String Name = 'QuickBooks Setting Info';
                String accessToken = (String) responseMap.get('access_token');
                String refreshToken = (String)responseMap.get('refresh_token');
                Decimal expiresIn = (Decimal)responseMap.get('expires_in');
                Decimal expiresInRefToken = (Decimal)responseMap.get('x_refresh_token_expires_in');

                quickbooksSettingInfo.Name = Name;
                quickbooksSettingInfo.Access_Token__c = accessToken;
                quickbooksSettingInfo.Refresh_Token__c = refreshToken;
                quickbooksSettingInfo.Exoire_in_Seconds__c = expiresIn;
                quickbooksSettingInfo.Refresh_Token_Expires_in_Seconds__c = expiresInRefToken;

                if(listOfQuickBooks!=null || listOfQuickBooks.size() > 0 ){
                    quickbooksSettingInfo.Id = listOfQuickBooks[0].Id;
                    upsert quickbooksSettingInfo;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully Authenticated with Quickbooks System!!!'));
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unexpected Error while communicating with Quickbooks API'+
                    'Status '+response.getStatus()+' and Status Code '+response.getStatuscode()));
                }
            }
        } catch(Exception e) {
            System.debug('Exception Executed '+e.getStackTraceString());
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup ->'
                +' Remote Site Setting and add '+' '+ oAuthEndPoint +' Endpoint';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
            else
            {
                errorMessage = 'Unexpected Error while communicating with Quickbooks API. ' +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }

    }
    @Future(callout=true)
    public static void refreshAccessToken(){
        String encodedString = EncodingUtil.base64Encode(Blob.valueOf(clientID + ':' +clientSecret));
        Quickbooks_Info__c QBInfo = new Quickbooks_Info__c();
        QBInfo = [Select Id, Name, Refresh_Token__c from Quickbooks_Info__c where Name='QuickBooks Setting Info'];
        String requestBody = 'grant_type=refresh_token&refresh_token=';
        if(QBInfo !=null && QBInfo.Refresh_Token__c!=null){
            requestBody+= QBInfo.Refresh_Token__c;

        }
        else{
            System.debug('Refresh Token is NULL');
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Refresh Token is NULL'));
        }
        String errorMessage='';

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setMethod('POST');
        request.setEndpoint(oAuthEndPoint);
        request.setHeader('Authorization' , 'Basic '+encodedString);
        request.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
        request.setBody(requestBody);
        
        try {
            response = http.send(request);
            if(response.getStatusCode()==200){
                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                List<Quickbooks_Info__c> listOfQuickBooks= new List<Quickbooks_Info__c>();
                listOfQuickBooks = [Select Id, Name from Quickbooks_Info__c where Name = 'QuickBooks Setting Info'];
                Quickbooks_Info__c quickbooksSettingInfo = new Quickbooks_Info__c();

                String Name = 'QuickBooks Setting Info';
                String accessToken = (String) responseMap.get('access_token');
                String refreshToken = (String)responseMap.get('refresh_token');
                Decimal expiresIn = (Decimal)responseMap.get('expires_in');
                Decimal expiresInRefToken = (Decimal)responseMap.get('x_refresh_token_expires_in');

                quickbooksSettingInfo.Name = Name;
                quickbooksSettingInfo.Access_Token__c = accessToken;
                quickbooksSettingInfo.Refresh_Token__c = refreshToken;
                quickbooksSettingInfo.Exoire_in_Seconds__c = expiresIn;
                quickbooksSettingInfo.Refresh_Token_Expires_in_Seconds__c = expiresInRefToken;

                if(listOfQuickBooks!=null || listOfQuickBooks.size() > 0 ){
                    quickbooksSettingInfo.Id = listOfQuickBooks[0].Id;
                    upsert quickbooksSettingInfo;
                    System.debug('Successfully Refresh Token');
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully Refresh Token'));
                }
                else
                {
                    System.debug('Unexpected Error while refreshing the token'+'Status '+response.getStatus()+' and Status Code '+response.getStatuscode());
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unexpected Error while refreshing the token'+'Status '+response.getStatus()+' and Status Code '+response.getStatuscode()));
                }
            }
            
        } catch (Exception e) {
            System.debug('Exception Executed '+e.getStackTraceString());
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup ->'
                +' Remote Site Setting and add '+' '+ oAuthEndPoint +' Endpoint';
                System.debug(errorMessage);
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
            else
            {
                errorMessage = 'Unexpected Error while communicating with Quickbooks API. ' +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(errorMessage);
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }
    }
}