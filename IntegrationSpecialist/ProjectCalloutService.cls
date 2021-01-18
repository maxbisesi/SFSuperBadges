public class ProjectCalloutService {
    @InvocableMethod(label='Post Opportunity To PMS')
	public static void postOpportunityToPMS(List<Id> ids){
		QueueablePMSCall job = new QueueablePMSCall(ids);
        Id jobid = System.enqueueJob(job);
    }
    
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
        
        private List<Id> oppIds;
        public QueueablePMSCall(List<Id> ids) {
            this.oppIds = ids;
        }
        
        public void execute(QueueableContext context) {
            Opportunity postOpp = [Select Name, Account.Name, CloseDate, Amount, StageName From Opportunity Where Id IN :this.oppIds];
        	ServiceTokens__c serv = ServiceTokens__c.getValues('ProjectServiceToken');
            
            HttpRequest req = new HttpRequest();
        	req.setEndpoint('callout:ProjectService');
        	req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('token',serv.Token__c);
            
            String body = '{"opportunityId": '+postOpp.Id+',"opportunityName": '+postOpp.Name+',"accountName": '+postOpp.Account.Name+',"closeDate": '+postOpp.CloseDate+',"amount": '+postOpp.Amount+'}';
            req.setBody(body);
            
        	Http http = new Http();
        	HttpResponse resp;
        	resp = http.send(req);
            System.debug('ProjectCalloutService, Response body:' + resp.getBody());
            
            if(resp.getStatusCode() == 201) {
                postOpp.StageName = 'Submitted Project';
            } else {
                postOpp.StageName = 'Resubmit Project';
            }
            
            update postOpp;
        }
    }
}