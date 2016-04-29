/** 
* A trigger to add the data in the fields belonging to the "FY_Pricing_Detail__c" 
*
*    Initial Draft          Author              Date
*    version 1.0            Gaurav              5/2/2014
*
**/


trigger FyPricingDetailTrigger on FY_Pricing_Detail__c (before insert, after insert, after update) {
        
	    FyPricingDetailTriggerHandler objHandler = new FyPricingDetailTriggerHandler(); 
	    if(trigger.isBefore && trigger.isInsert ){
	        
	        objHandler.onBeforeInsertPopulateFyPricingDetailFields(trigger.New);
	    }   
	
	    if(trigger.isAfter && trigger.isInsert){
	        
	        objHandler.onAfterInsertPopulateFyPricingDetailFields(trigger.New, trigger.newMap);
	    }
	    
	    if(trigger.isUpdate)
	    {	
		    if(checkRecursive.runOnce())
		    {
		        objHandler.onAfterInsertPopulateFyPricingDetailFields(trigger.New, trigger.newMap);
		    }	
    	}
}