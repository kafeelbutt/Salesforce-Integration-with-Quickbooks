global with sharing class SchedulerForRefreshTokenQuickBooks implements Schedulable{
    global void execute(SchedulableContext SC){
        QuickBooksAuthorize.refreshAccessToken();
    }

}
