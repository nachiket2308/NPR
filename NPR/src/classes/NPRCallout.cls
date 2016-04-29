/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Suhas Patil
    Created Date: June 17, 2015
    Description: This class make a call out to the NPRCallout_RestCallOut which makes callout.
-----------------------------------------------------------------------*/
public with sharing class NPRCallout {
    public NPRCallout() {}

    public void triggerCall(Map<Id, Opportunity> oldOpportunityMap, Map<Id, Opportunity> newOpportunityMap) {
        system.debug('oldOpportunityMap===>>> '+oldOpportunityMap);
        system.debug('newOpportunityMap===>>> '+newOpportunityMap);
        String commaSeperatedOpportunityId = '';

        for(Id opportunityId : newOpportunityMap.keySet()) {
            if(oldOpportunityMap.containsKey(opportunityId)) {
                if(newOpportunityMap.get(opportunityId).IsWon__c == true 
                    && oldOpportunityMap.get(opportunityId).IsWon__c != newOpportunityMap.get(opportunityId).IsWon__c) {
                    system.debug('This is the Id '+opportunityId+ ' and this is the value of the IsWon__c'+newOpportunityMap.get(opportunityId).IsWon__c);
                    commaSeperatedOpportunityId += opportunityId + ',';
                }
            }
        }
        commaSeperatedOpportunityId = commaSeperatedOpportunityId.removeEnd(',');
        system.debug('commaSeperatedOpportunityId====>>> '+commaSeperatedOpportunityId);
        callOut(commaSeperatedOpportunityId);
    }

    @future(callout=true) 
    public static void callOut(String opportnityId) {
        system.debug('This is the opportunityId ====>>>> '+opportnityId);
        if(!String.isBlank(opportnityId)) {
            NPRCallout_RestCallOut.HTTP_Post(opportnityId);
        }
    }
}