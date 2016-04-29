global class MockHttpResponseGenerator implements HttpCalloutMock {
    public String opportunityId;
    global MockHttpResponseGenerator(String opportunityId) {
        system.debug('opportunityId in the mock class==>> '+opportunityId);
        this.opportunityId = opportunityId;
    }

    global HTTPResponse respond(HTTPRequest req) {

        system.debug('req in mock callout class ====>>>>' +req);
        HttpResponse response = new HttpResponse();
        String strResponse = '';
        if( req.getMethod() == 'POST') {
             //res.setHeader('Content-Type', 'application/vnd.cpc.shipment-v4+xml; charset=UTF-8');
            strResponse = '"'+'{'+'oppid:'+'\''+opportunityId+'\''
                            +','+'date:'+'\''+Date.today()+'\''+'}'+'"';
            system.debug('This is the response mock====>>> '+strResponse);//"{'oppid':'006M000000CayTSIAZ','date':'2015-06-22 04:53:18'}"
            response.setBody(strResponse);
            response.setStatus('OK');
            response.setStatusCode(200);
        }
        return response;
    }
}