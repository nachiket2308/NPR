/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Suhas Patil
    Created Date: June 17, 2015
    Description: This class make a call out to the NPR station API.
-----------------------------------------------------------------------*/
public with sharing class NPRCallout_RestCallOut {
    public static final String NPR_URL = 'https://www.nprstations.org/salesforce/pdfgen.cfc?method=opp';

    //Post callout method.
    public static void HTTP_Post(String commaSeperatedOpportunityId) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NPR_URL);
        req.setMethod('POST');
        req.setBody('&key=V@9wxB7oDX&id='+commaSeperatedOpportunityId);

        system.debug('req====>>' +req);
        system.debug('req.getBody()====>>' +req.getBody());

        HttpResponse res = http.send(req);
        system.debug('res.getBody()===>>'+res.getBody()) ;
    }
}