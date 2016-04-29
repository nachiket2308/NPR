/*
*    Description : ApexClass which is invokded from OpportunityTriggerHandler on Opportunity trigger event AfterUpdate
*                  The functionality updates the related OpportunityProduct records and creates SP & P records subject to 
*                  meeting the given conditions
*
*    Version            Date                Author                Description
*    
*    1.0                05/06/2014          Siddharth Birari      Initial Draft
*/

public class CreateUpdateStationProductsProgram {
    
    private static final String STAGENAME_WON = 'Won';
    
    private static Boolean blnIsExecuted = false; 

    List<Opportunity> listNewOpportunity = new List<Opportunity>();
    List<OpportunityLineItem> listOpportunityLineItem = new List<OpportunityLineItem>();       
    
    Set<Id> setOppProductProduct2Id = new Set<Id>();
    Set<Id> setOppProductStationId = new Set<Id>();   
    
    Set<Id> setOpportunityId = new Set<Id>();
    
    //Method to perform operations to create/update SP & P records to link with OpportunityProduct records
    public void upsertStationProudctsProgram(Map<Id, Opportunity> pMapOldOpportunity, Map<Id, Opportunity> pMapNewOpportunity){
        
        if(!blnIsExecuted){
        
            listNewOpportunity = pMapNewOpportunity.values();
            setOpportunityId = pMapNewOpportunity.keySet();
            
            //If at least one Opportunity is being updated
            if(!listNewOpportunity.isEmpty()){
                
                //Retrive all the OpportunityLineItem where SPP__c is null and OpportunityStage = Won 
                listOpportunityLineItem = [select Id,
                                                  SPP__c,
                                                  Product2Id,
                                                  Station__c
                                           from OpportunityLineItem 
                                           where OpportunityId IN : setOpportunityId AND
                                           SPP__c = NULL AND
                                           Opportunity.StageName =: STAGENAME_WON];                                                          
            }
            
            System.debug('========= OpportunityProducts ' + listOpportunityLineItem);
            
            if(!listOpportunityLineItem.isEmpty()){
            
                for(OpportunityLineItem objLineItem : listOpportunityLineItem){
                    
                    setOppProductProduct2Id.add(objLineItem.Product2Id);
                    setOppProductStationId.add(objLineItem.Station__c);
                }
            }
            
            //Set blnIsExecuted = true to ensure that the trigger would execute only once
            blnIsExecuted = true;    
        }//If blnIsExecuted
    }//Method upsertStationProudctsProgram
    
    //Method returns the related SPP Records
    public void getSPPRecords(){
        
        
    }
}