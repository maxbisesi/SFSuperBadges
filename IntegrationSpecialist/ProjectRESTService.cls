@RestResource(urlMapping='/project/*')
global class ProjectRESTService {
    
    //Implement service logic here
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate, Date EndDate, Double Amount, String Status) {
        // Get opporutnity
        Savepoint sp = Database.setSavepoint();
        try {
            List<Project__c> projlist = [Select Id From Project__c Where Opportunity__c = :OpportunityId];
            Project__c proj;
            if(projlist.size() == 0) {
                System.debug('Project record DNE...');
                proj = new Project__C();
                proj.ProjectRef__c = ProjectRef;
                proj.Name = ProjectName;
                proj.Start_Date__c = StartDate;
                proj.Opportunity__c = OpportunityId;
                proj.End_Date__c = EndDate;
                proj.Billable_Amount__c = Amount;
                proj.Status__c = Status;
                insert proj;
            } else {
                System.debug('Project record exists...');
                proj = projlist[0];
                proj.ProjectRef__c = ProjectRef;
                proj.Name = ProjectName;
                proj.Start_Date__c = StartDate;
                proj.End_Date__c = EndDate;
                proj.Billable_Amount__c = Amount;
                proj.Status__c = Status;
                update proj;
            }
    
           List<Opportunity> opp = [Select Id,DeliveryInstallationStatus__c From Opportunity Where Id = :OpportunityId];
           opp[0].DeliveryInstallationStatus__c = 'In Progress';
           update opp[0];
           System.debug('Upserted Project record name:'+proj.Name+' - Id '+proj.Opportunity__c+' - status '+proj.Status__c);
        } catch(Exception e) {
            System.debug(e);
            Database.rollback(sp);
            return e.getMessage();
        }
        
        System.debug('OKEY');
        return 'OK';
        
        
    }
}