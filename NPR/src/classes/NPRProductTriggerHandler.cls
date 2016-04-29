/** 
*  A handler class for the NPRProductTrigger which controls the functionality of the Opportunity Prouduct
* 
*
*   Initial Draft         Author 			Date
*   Version 1.0			  Gaurav	        6/5/2014
**/

public with sharing class NPRProductTriggerHandler {
	
    public void onAfterUpdatePopulateOpportunityProductFields(List<NPR_Product__c> pLstNPRProduct,
                                                    Map<Id,NPR_Product__c> pOldMapIdToNPRProduct){
		
		//Populate OpportunityProduct Field On After Update of NPRProduct Record
		PopulateOpportunityProductFields objPopulateOpportunityProductField = new PopulateOpportunityProductFields();
		objPopulateOpportunityProductField.populateOpportunityProductFieldInfo(pLstNPRProduct, pOldMapIdToNPRProduct);
		
		set<String> oppIds = new set<String>{};
		Profile currentProfile = [select Name from Profile where id = :userinfo.getProfileId()];
												
		for(NPR_Product__c npr : pLstNPRProduct)
		{
			// if ISCHANGED(Include_In_PPF_MSA__c) and User.Profile = “Integration User”
			if(npr.Include_In_PPF_MSA__c != pOldMapIdToNPRProduct.get(npr.Id).Include_In_PPF_MSA__c &&
			   currentProfile.Name=='Integration User' && npr.Opportunity_Name__c!=null)
			{
				oppIds.add(npr.Opportunity_Name__c);
			}
		}
		NPRProductTriggerCalcOpp nprtco = new NPRProductTriggerCalcOpp();
		nprtco.calcOpp(oppIds);
		
		system.debug('\n\n pLstNPRProduct:'+pLstNPRProduct+'\n\n');
	}	
	
	public void onAfterInsertCalcNPRProd(List<NPR_Product__c> pLstNPRProduct)
	{
		list<String> lstNprProdIds = new list<String>{};
		for(NPR_Product__c npr : pLstNPRProduct)
		{
			lstNprProdIds.add(npr.Id);
		}
		
		list<NPR_Product__c> lstNprProds = [select Id, License_Fee_Factor__c, Product__r.Family, Product__r.PPF_Type__c, Accelerated_Cap__c, 
			Last_FY_Fee_Override__c, ATC_Capped_Final_Fee__c, ATC_Last_FY_Price__c, List_Price_PPF_Annualized__c, List_Fee_Non_News_Annualized__c, 
			Product__r.MSA_Bundle__c, Base_Fee_Annualized__c, Opportunity_Name__r.Total_TSR_MSA__c, MSA_Cap__c, Last_FY_MSA_Price_Override__c, 
			Final_Last_FY_MSA_Anchor_Price__c, List_Fee_Annualized__c, Previous_FY_Fee_Threshold_Min__c, Previous_FY_Fee_Threshold_Max__c, 
			Annual_FY_Increase__c, Discount_From_Anchor__c, Subtotal_Fee__c, List_Fee_Prorated__c, Discount_Percent__c, Override_Discount__c, 
			Final_Fee__c, Bill_Start_Date__c, Bill_End_Date__c, Opportunity_Name__r.Last_FY_MSA_Anchor_List_Price__c, Include_In_PPF_MSA__c from NPR_Product__c where Id IN :lstNprProdIds];
		
		list<NPR_Product__c> lstNPRProdToUpdate = new list<NPR_Product__c>{};
		PricingUtility pu = new PricingUtility();
		for(NPR_Product__c npr : lstNprProds)
		{
			lstNPRProdToUpdate.add(pu.calcNPRProd(npr));
		}
		
		update lstNPRProdToUpdate;
	}
}