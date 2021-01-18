public class BillingCalloutService {

    public static void callBillingService(Map<Id,Project__c> oldMap, List<Project__c> newList) {
         for(Project__c p : newList) {
            Project__c oldProject = oldMap.get(p.Id);
            if(p.Status__c == 'Billable' && oldProject.Status__c != 'Billable') {
                updateSquarePegBilling(p.Id, p.ProjectRef__c, (Double)p.Billable_Amount__c);
            }
        } 	
    }
    
    @future(callout=true)
    static void updateSquarePegBilling(Id projectID, String projectRef, Double amount) {
        BillingServiceProxy.InvoicesPortSoap11 squarepeg = new BillingServiceProxy.InvoicesPortSoap11();
        BillingServiceProxy.project spr = new BillingServiceProxy.project();
        ServiceCredentials__c creds = ServiceCredentials__c.getValues('BillingServiceCredential');
        spr.username = creds.Username__c;
        spr.password = creds.Password__c;
        spr.projectid = projectRef;
        spr.billAmount = amount;
        String response = squarepeg.billProject(spr); 
        if(response == 'OK') {
            Project__c prj = [Select Status__c From Project__c Where Id = :projectID];
            prj.Status__c = 'Billed';
            update prj;
        }
        
    }
}