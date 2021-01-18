@isTest
global class ProjectCalloutServiceMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        //Test the Request..
        System.assertEquals('POST',req.getMethod());
        ServiceTokens__c serv = ServiceTokens__c.getValues('ProjectServiceToken');
        System.assertEquals(req.getHeader('token'), serv.Token__c);
        System.debug('Callout mock: Token is good');
        
        //Create and send fake response..
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(201);
        resp.setBody('It worked.');
        System.debug('Callout mock: Sending response...');
        return resp;
    }
}