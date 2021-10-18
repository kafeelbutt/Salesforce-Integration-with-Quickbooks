global with sharing class GetQuickBooksDataScheduler implements Schedulable {
    global void execute(SchedulableContext SC){
        GetQuickBooksData.getCustomerData();
        GetQuickBooksData.getCompanyData();
    }

}
