/** 
*	A trigger which on Update of SPP rec updates  and the next year Opportunity product if exist 
*	
**/
public with sharing class OpportunityProductTriggerHandler {
	
	 PopulateSPPFields objPopulateSPPField = new PopulateSPPFields();
     public void onAfterInsertUpdatePopulateSPPFields(List<OpportunityLineItem> pLstOpportunityLineItem,
                                          Map<Id,OpportunityLineItem> pOldMapIdToOpportunityLineItem, 
                                              								     String strTrigger){
                   
		//Populate OpportunityProduct Field On After Update of OpportunityLineItem Record
		objPopulateSPPField.populateSPPFieldInfo(pLstOpportunityLineItem, pOldMapIdToOpportunityLineItem, 
																							 strTrigger);
		
	}	
	
	public void onAfterInsertCalcOLI(List<OpportunityLineItem> pLstOpportunityLineItem)
	{
		list<String> lstOliIds = new list<String>{};
		for(OpportunityLineItem oli : pLstOpportunityLineItem)
		{
			lstOliIds.add(oli.Id);
		}
		
		list<OpportunityLineItem> lstOLIs = [select Id, Set_up_fee__c, Annualized_Price__c, Bill_Start_Date__c, Bill_End_Date__c, Override_Fee__c,
			Final_Price__c, Subtotal_Fee__c from OpportunityLineItem where Id IN :lstOliIds];
		
		list<OpportunityLineItem> lstOLIsToUpdate = new list<OpportunityLineItem>{};
		PricingUtility pu = new PricingUtility();
		for(OpportunityLineItem oli : lstOLIs)
		{
			lstOLIsToUpdate.add(pu.calcOLI(oli));
		}
		
		update lstOLIsToUpdate;
	}
    	
}