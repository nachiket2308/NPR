@isTest 
private class NPRCalloutTest {

    //Creates the Account instance for creating records.
    private static Account createAccount(String accountName) {

        Account objAccount = new Account();
        objAccount.Name = accountName;
        return objAccount;
    }

    //Creates the Opportunity instance for creating records.
    private static Opportunity createOpportunity(Id accountId, String opportunityName, String stageName,
                                                    Integer probablity, Date closeDate, String oppType) {

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = accountId;
        objOpportunity.Name = opportunityName;
        objOpportunity.StageName = stageName;
        objOpportunity.Probability = probablity;
        objOpportunity.CloseDate = closeDate;
        objOpportunity.Type = oppType; 
        return objOpportunity;
    }

    static testMethod void calloutTest() {

        Account objAccount = createAccount('TestAccount_1');
        insert objAccount;

        Opportunity objOpportunity = createOpportunity(objAccount.Id, 'TestOpportunity', 'Prospecting',
                                                        5, Date.today(), 'MSA');
        insert objOpportunity;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(objOpportunity.Id));
        objOpportunity.IsWon__c = true;
        update objOpportunity;
        Test.stopTest();
    }

    static testMethod void calloutTestBulk() {

        List<Opportunity> opportunityInsertList = new List<Opportunity>();
        List<Opportunity> opportunityUpdateList = new List<Opportunity>();
        String opportunityId = '';

        Account objAccount = createAccount('TestAccount_1');
        insert objAccount;

        for(Integer counter =0; counter <= 199; counter++) {
            Opportunity objOpportunity = createOpportunity(objAccount.Id, 'TestOpportunity'+counter, 'Prospecting',
                                                        5, Date.today(), 'MSA');
            opportunityInsertList.add(objOpportunity);
        }

        insert opportunityInsertList;
        List<Id> opportunityIdList = new List<Id>(); 
        for(Opportunity opp : opportunityInsertList) {
            opportunityId +=  opp.Id + ',';
            opp.isWon__c = true;
            opportunityUpdateList.add(opp);
        }
        opportunityId = opportunityId.removeEnd(',');

        system.debug('opportunityId===>>> '+opportunityId);
        system.debug('opportunityUpdateList===>>> '+opportunityUpdateList);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(opportunityId));
        if(opportunityUpdateList != null && opportunityUpdateList.size() > 0) {
            update opportunityUpdateList;
        }
        Test.stopTest();
    }
}