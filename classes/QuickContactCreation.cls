public with sharing class QuickContactCreation {
    @AuraEnabled
    public static String createContactwithAccountDetails(String accountId){
        Account actObj = [select id,name,phone from Account where id =:accountId];
        Contact contactObj = new Contact();
        contactObj.LastName = actObj.Name;
        contactObj.AccountId = actObj.Id;
        contactObj.Phone= actObj.Phone;
        insert contactObj;
        return contactObj.Id;
    }
    @AuraEnabled
    public static String createContact(Contact contObj){
        insert contObj;
        return contObj.Id;
    }
}
