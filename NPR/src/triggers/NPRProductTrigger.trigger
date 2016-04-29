/** 
* A trigger to update "NPR_Product__c" and Populate field of OpportunityLineItem related to update NPR Product 
*
*    Initial Draft          Author              Date
*    version 1.0            Gaurav              6/5/2014
*
**/

trigger NPRProductTrigger on NPR_Product__c (after update, after insert) {
	
	list<Trigger_Settings__c> tsList = [select Id, Name, Disable_Triggers__c from Trigger_Settings__c];
	if(tsList.size()==0 || tsList[0].Disable_Triggers__c==false)
	{
		if(trigger.isAfter && trigger.isUpdate ){
			
		    NPRProductTriggerHandler objHandler = new NPRProductTriggerHandler();
		    if(Utility.isRecuriveUpdate != true)
		    objHandler.onAfterUpdatePopulateOpportunityProductFields(trigger.New, trigger.oldMap);
		}
		else if(trigger.isAfter && trigger.isInsert)
		{
			 NPRProductTriggerHandler objHandler = new NPRProductTriggerHandler();
			 objHandler.onAfterInsertCalcNPRProd(trigger.New);
		}
	}	
	
}