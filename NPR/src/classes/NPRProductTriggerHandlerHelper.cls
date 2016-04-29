/** 
*  A helper class for the NPRProductTrigger which controls the functionality of the NPRProduct 
   and Populate data related to opportunity product and NPR Product
* 
*   Initial Draft         Author 			Date
*   Version 1.0			  Gaurav	        6/5/2014
**/

public with sharing class NPRProductTriggerHandlerHelper {
	
	/** 
	* A method that returns the  list<OpportunityLineItem> to the handler methods only 
	* when the size of the list is greater than zero.
	**/
	public List<OpportunityLineItem> getLstOpportunityLineItem(Map<Id, NPR_Product__c> mapIdToNPRProduct){
		List<OpportunityLineItem> lstOpportunityLineItem = [Select  Id,
																    SPP__c, 
																	OpportunityId, 
																	NPR_Product__c,
																	Fiscal_Year__c, 
																	Drop_Reason__c, 
																	Drop_Date__c, 
																	Bill_Start_Date__c, 
																	Bill_End_Date__c, 
																	Air_Onboard_Status__c, 
																	Air_Onboard_Date__c, 
																	Adopt_Status__c,
																	Adopt_Date__c 
															From OpportunityLineItem 
															Where NPR_Product__r.Id 
															IN: mapIdToNPRProduct.keySet()];
		if(!lstOpportunityLineItem.isEmpty())													
		    return lstOpportunityLineItem;	
		    
		return null;    												
	}
	
	/** 
	* A method that returns the  list<NPR_Product__c> to the handler methods only 
	* when the size of the list is greater than zero.
	**/
	public List<NPR_Product__c> getNPRProductlist(Set<Id> setNPRProductId){
	    List<NPR_Product__c> lstNPRProduct = [Select Id,
												     Name, 
													 Uncapped_Fee__c, 
													 Subtotal_Fee__c, 
													 Product__c, 
													 Fiscal_Year__c,
													 Product__r.Family,
													 Product__r.MSA_Bundle__c,
													 Previous_FY_NPR_Product__c, 
													 OwnerId, Override_Fee__c, 
													 Override_Fee_Comments__c, 
													 Override_Discount__c, 
													 Override_Discount_Comments__c, 
													 Opportunity_Type__c, 
													 Opportunity_Name__c, 
													 Opportunity_Account_ID__c, 
													 Next_FY_NPR_Product__c, 
													 ME_Uncapped_Price__c, 
													 ME_Last_FY_Price__c, 
													 ME_Capped_Price__c,
													 ME_Cap_Factor__c, 
													 List_Fee__c, 
													 List_Fee_Annualized__c, 
													 Last_FY_Fee__c, 
													 Last_FY_Fee_Override__c, 
													 Include_In_PPF_MSA__c, 
													 Final_Fee__c, 
													 Drop_Reason__c,
													 Drop_Date__c, 
													 Discount_Type__c, 
													 Discount_Percent__c,  
													 Capped_Final_Fee__c, 
													 Cap_Percent__c, 
													 Bill_Start_Date__c, 
													 Bill_End_Date__c, 
													 Air_Onboard_Status__c, 
													 Air_Onboard_Date__c, 
													 Adopt_Status__c,
													 Adopt_Date__c, 
													 Accelerated_Cap__c, 
													 ATC_Uncapped_Price__c, 
													 ATC_Last_FY_Price__c,
													 ATC_Capped_Price__c, ATC_Cap_Factor__c 
												From NPR_Product__c 
												Where Id IN: setNPRProductId];
		if(!lstNPRProduct.isEmpty())													
		    return lstNPRProduct;	
		    
		return null;    												
	}
}