/** 
*  A helper class for the OpportunityProductTrigger which controls the functionality of the OpportunityProduct
   and Populate data related to opportunity product and Station_Products_Programs__c
* 
*   Initial Draft         Author 			Date
*   Version 1.0			  Gaurav	        6/5/2014
**/


public with sharing class OpportunityProductTriggerHandlerHelper {

	/** 
	* A method that returns the  list<OpportunityLineItem> to the handler methods only 
	* when the size of the list is greater than zero.
	**/
	public List<OpportunityLineItem> getLstOpportunityLineItem(Set<ID> setOpportunityLineItemId){
	
		List<OpportunityLineItem> lstOpportunityLineItem = [Select  UnitPrice, 
																	TotalPrice, 
																	Tier_List_Fee__c, 
																	Subtotal_Fee__c, 
																	Streaming_Fee__c, 
																	Streaming_Bandwidth__c, 
																	Station__c, SortOrder, 
																	Set_up_fee__c, 
																	ServiceDate, 
																	SPP__c, 
																	Quantity, 
																	PricebookEntryId, 
																	PricebookEntry.Product2Id,
																	Override_Fee__c, 
																	Override_Fee_Comments__c, 
																	Opportunity_Completed_Date__c, 
																	OpportunityId, 
																	Opportunity.StageName,
																	Opportunity.IsWon,
																	Opportunity.Type,
																	NPR_Product__c, 
																	ListPrice,
																	Id, 
																	Fiscal_Year__c, 
																	Email_List_Size__c, 
																	Drop_Reason__c, 
																	Drop_Date__c, 
																	Description, 
																	Bill_Start_Date__c, 
																	Bill_End_Date__c, 
																	Air_Onboard_Status__c, 
																	Air_Onboard_Date__c, 
																	Adopt_Status__c, 
																	Adopt_Date__c 
															From OpportunityLineItem
															Where Id IN: setOpportunityLineItemId
															];
		if(!lstOpportunityLineItem.isEmpty())													
		    return lstOpportunityLineItem;	
		    
		return null;    												
	}
	
	/** 
	* A method that returns the  list<Station_Products_Programs__c> to the handler methods only 
	* when the size of the list is greater than zero.
	**/
	public List<Station_Products_Programs__c> getSPPlist(Set<Id> setSPPId){
	    List<Station_Products_Programs__c> lstSPP = [Select Id,
	    													URL_3__c, 
															URL_2__c, 
															URL_1__c, 
															Summarized_Product_Type__c, 
															Status_Indicator__c, 
															Station__c, 
															Start_Date__c, 
															Product_Program_Name__c, 
															Primary_Station_POC__c, 
															PPF__c, 
															//OwnerId,
															Name, 
															MSA__c, 
															Last_Drop__c, 
															First_Air_Onboard__c,
															End_Date__c, 
															Dropped__c, 
															Drop_Reason__c, 
															Discounts__c, 
															Deployment_Status__c, 
															Contract_Type__c, 
															Bill_Start_Date__c, 
															Bill_End_Date__c, 
															Air_Onboard_Status__c, 
															Adopt_Status__c, 
															Adopt_Date__c, 
															Additional_Station_Contacts__c, 
															Active_Air_Onboard_History__c 
													 From Station_Products_Programs__c 
													 Where Id IN: setSPPId];
		if(!lstSPP.isEmpty())													
		    return lstSPP;	
		    
		return null;    												
	}

}//End OpportunityProductTriggerHandlerHelper