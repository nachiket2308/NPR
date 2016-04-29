/** 
*  A handler class for the FyPricingDetailTrigger which controls the functionality of the FieldPricing 
* DetailTrigger
*
*   Initial Draft         Author 			Date
*   Version 1.0			  Gaurav	        5/2/2014
**/
public with sharing class FyPricingDetailTriggerHandler {
	
	PopulateFyPricingDetailFields objPopulateFyPricingDetailFields = new PopulateFyPricingDetailFields();
	
	public void onBeforeInsertPopulateFyPricingDetailFields(List<FY_Pricing_Detail__c> lstFyPricingRec){
		
		//Populate All FyPricingDetail Field On Before Insert of FY Pricing Detail Record
		objPopulateFyPricingDetailFields.PopulateFYPricingFieldInfo(lstFyPricingRec);
	}
	
	public void onAfterInsertPopulateFyPricingDetailFields(List<FY_Pricing_Detail__c> lstFyPricingRec, Map<Id, FY_Pricing_Detail__c> newMapIdToFyPricingRec){
		
		//Populate Capped Price value  On After Insert of FY Pricing Detail Record
		objPopulateFyPricingDetailFields.getCappedPrice(lstFyPricingRec, newMapIdToFyPricingRec);
	}
	
	
}