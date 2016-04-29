//********************************************************************
// Author: ACF Solutions
//		   Sophak Phou
// Date: May 2014 
// Description: Opportunity Trigger Handler Class
//

public class OpportunityTriggerHandler {
    
    public set<ID> cIds {set; get;}
	public List<String> apIds {set; get;}
	public List<ActionPlan__c> deletePermantently_apIds {set; get;}
    
    public OpportunityTriggerHandler(){
    	cIds = new set<ID>();
		apIds = new List<String>();
		deletePermantently_apIds = new List<ActionPlan__c>();	
    }
    
    public void ActionPlanDelete(List<Opportunity> triggerold){
    	for( Opportunity o : triggerold){
        	cIds.add( o.Id );
   		} 
   		
 		/* GET Action Plans to delete from recycle bin */
   		deletePermantently_apIds = [ select Id, Name , LastModifiedDate from ActionPlan__c where Opportunity__c in : cIds and isDeleted = true ALL ROWS ];
   		
   		if ( deletePermantently_apIds.size() >0 ){   		
			Database.emptyRecycleBin(deletePermantently_apIds);
   		}
   		  		
		List<ActionPlan__c> apList =  [ select Id from ActionPlan__c where Opportunity__c in : cIds ];
		for( ActionPlan__c ap : [ select Id from ActionPlan__c where Opportunity__c in : cIds ] ){
        	apIds.add( ap.Id );
   		}
   		if ( apIds.size() >0 ){  		
			ActionPlansBatchDelete aPBatch = new ActionPlansBatchDelete(apIds, Userinfo.getUserId());
			Database.ExecuteBatch( aPBatch );	
   		}	
    }
    
    public void ActionPlanUndelete(List<Opportunity> triggernew){
    	for( Opportunity o : triggernew){
        	cIds.add( o.Id );
   		}
   		list <ActionPlan__c> aPs = [ select Id from ActionPlan__c where Opportunity__c in : cIds ALL ROWS ];
   		
   		try{
   			if(ActionPlanObjectTriggerTest.isTest){
   				//throw dmlException
   				insert new Contact();	
   			}
   			//undelete aPs;
   			Database.undelete( aPs,false);
   		} catch ( Dmlexception e ){
   			for (Opportunity o: triggernew){
				o.addError('You can not undelete an action plan whose related object is deleted.');
			}
   		}
    }
    
    public void OppCreateInitialize(List<Opportunity> triggernew)
    {
    	if(oppContainsPPFOrMSA(triggernew))
    	{
    		system.debug('Suhas :: This is OppCreateInitialize====>>>>> ');
    		NewOpportunityClass noc = new NewOpportunityClass(); 
    		noc.opportunityCreationProcess(triggernew);
    
    	}
    }
    
    public void OppObjectsCreate(List<Opportunity> triggernew)
    {
    	if(oppContainsPPFOrMSA(triggernew))
    	{
    		NewOpportunityClass noc = new NewOpportunityClass(); 
    		noc.opportunityCreationProcessAfter(triggernew);
    	}
    }
    
    public void OppDelete(List<Opportunity> triggerold)
    {
    	if(oppContainsPPFOrMSA(triggerold))
    	{
    		OpportunityDelete.onOppDel(triggerold);
    	}
    }
    
    //Method would be invoked on AfterUpdate event of Opportunity
    public void OppProductUpdate(Map<Id, Opportunity> pMapOldOpportunity, Map<Id, Opportunity> pMapNewOpportunity){
        
        if(oppContainsPPFOrMSA(pMapNewOpportunity.values()))
    	{
	        //Invoking method to update the related OpportunityProduct records
	        UpdateOpportunityProduct oUpdateOpportunityProduct = new UpdateOpportunityProduct();
	        oUpdateOpportunityProduct.updateOpportunityProductRecords(pMapOldOpportunity, pMapNewOpportunity);
    	}
    }
    
    public boolean oppContainsPPFOrMSA(list<Opportunity> opps)
	{
		boolean contains = false;
		for(Opportunity o : opps)
		{
			if(o.Type=='PPF' || o.Type=='MSA')
			{
				contains = true;
			}
		}
		return contains;
	}
}