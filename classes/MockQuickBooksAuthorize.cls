@isTest
public with sharing class MockQuickBooksAuthorize implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {

        System.assertEquals('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer', request.getEndpoint());
        System.assertEquals('POST', request.getMethod());
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type' , 'application/json');
        response.setBody('{"token_type": "bearer","expires_in": 3600,"refresh_token":"Q311488394272qbajGfLBwGmVsbF6VoNpUKaIO5oL49aXLVJUB","x_refresh_token_expires_in":15551893,"access_token":"eJlbm"}');
        response.setStatusCode(200);
        return response;
    }
}
