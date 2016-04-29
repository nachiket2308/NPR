public class OpportunityDelete {

	public static void onOppDel(Opportunity[] oppTriggerList)
	{
		System.debug('\n\n\nin onOppDel\n\n\n');
		
		// Create set of opportuinty IDs
		set<Id> oppIdSet = new set<Id>{};
		for(Opportunity opp : oppTriggerList)
		{
			oppIdSet.add(opp.Id);
		}
		
		//delete Opportunity Products related to deleted Opportunities
		list<OpportunityLineItem> oppProdList = [select Id, OpportunityId from OpportunityLineItem where OpportunityId IN :oppIdSet];
		
    	if (oppProdList.size()>0) 
     	{ 
     		try {delete oppProdList;} 
     		catch (DmlException x)
     		{ 
     			System.debug('\n\n\nDML Exception is: ' + x.getMessage() + '\n\n\n'); 
     		}
     	}  
     	
		
		//delete NPR Products related to deleted Opportunities
		list<NPR_Product__c> nprList = [select Id, Name, Opportunity_Name__c from NPR_Product__c where Opportunity_Name__c IN :oppIdSet];
		
		
		// delete npr products
     	if (nprList.size()>0) 
     	{ 
     		try {delete nprList;} 
     		catch (DmlException x)
     		{ 
     			System.debug('\n\n\nDML Exception is: ' + x.getMessage() + '\n\n\n'); 
     		}
     	}     	

	}
}