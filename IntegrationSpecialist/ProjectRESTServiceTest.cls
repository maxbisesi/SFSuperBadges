@isTest
private class ProjectRESTServiceTest {
  	//Implement Apex REST service tests here
    
    @testSetup static void setupTest() {
        Account ac = new Account(Name='TEST ACCOUNT');
        insert ac;
        
        Opportunity op1 = new Opportunity();
        op1.Name = 'Existing Opp proj';
        op1.StageName = 'Prospecting';
        op1.Amount = 22;
        op1.AccountId = ac.Id;
        op1.CloseDate = Date.today();
        insert op1;
        
        Project__c proj = new Project__c();
        proj.ProjectRef__c = '1253456';
        proj.Name = 'Existing Project';
        proj.Opportunity__c = op1.Id;
        proj.Start_Date__c = Date.today();
        proj.End_Date__c = Date.today();
        proj.Billable_Amount__c = 100;
        proj.Status__c = 'Running';
        insert proj;
        
        Opportunity op2 = new Opportunity();
        op2.Name = 'New Project';
        op2.StageName = 'Prospecting';
        op2.Amount = 23;
        op2.CloseDate = Date.today();
        op2.AccountId = ac.Id;
        insert op2; 
    }
  		
  	@isTest
    static void testOppPostNewProj() { 
		Opportunity op1 = [SELECT Name, DeliveryInstallationStatus__c FROM Opportunity WHERE Name = 'New Project'];
        
       	Date todayfive = Date.today();
        Date todaythree = Date.today();
        
        todayfive.addDays(5);
        todaythree.addDays(3);
        
        ProjectRESTService.postProjectData('778899','Big New Project',op1.Id,todaythree, todayfive, 201, 'Running');
        
        Opportunity opAfter = [SELECT Name, DeliveryInstallationStatus__c FROM Opportunity WHERE Name = 'New Project'];
        System.assertEquals('In Progress',opAfter.DeliveryInstallationStatus__c);
        
        Project__c proj = [Select Name, Status__c, Billable_Amount__c From Project__c Where Opportunity__c = :op1.Id];
        System.assertEquals('Big New Project',proj.Name);
    }
    
    @isTest
    static void testOppPostExistingProj() { 
		Opportunity op = [SELECT Name, DeliveryInstallationStatus__c FROM Opportunity WHERE Name = 'Existing Opp proj'];
        
       	Date todayfive = Date.today();
        Date todaythree = Date.today();
        
        todayfive.addDays(5);
        todaythree.addDays(3);
        
        ProjectRESTService.postProjectData('223344','UPDATED EXISTING PROJ',op.Id,todaythree, todayfive, 101, 'Billed');
        
        Opportunity opAfter = [SELECT Name, DeliveryInstallationStatus__c FROM Opportunity WHERE Name = 'Existing Opp proj'];
        System.assertEquals('In Progress',opAfter.DeliveryInstallationStatus__c);
        
        Project__c proj = [Select Name, Status__c, Billable_Amount__c From Project__c Where Opportunity__c = :op.Id];
        System.assertEquals('UPDATED EXISTING PROJ',proj.Name);
    }
}