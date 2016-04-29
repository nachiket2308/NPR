/** 
* A trigger to update "OpportunityLineItem" and Populate field of SPP record related to updated OpportunityLineItem 
*
*    Initial Draft          Author              Date
*    version 1.0            Gaurav              6/5/2014
*
**/

trigger OpportunityProductTrigger on OpportunityLineItem (after insert, after update) {
	
	list<Trigger_Settings__c> tsList = [select Id, Name, Disable_Triggers__c from Trigger_Settings__c];
	if(tsList.size()==0 || tsList[0].Disable_Triggers__c==false)
	{
		OpportunityProductTriggerHandler objHandler = new OpportunityProductTriggerHandler();
		if(trigger.isAfter && trigger.isUpdate ){
			if(Utility.isFutureUpdate != true)
		    objHandler.onAfterInsertUpdatePopulateSPPFields(trigger.New, trigger.oldMap, 'Update');
		}	
		if(trigger.isAfter && trigger.isInsert)
		{
			objHandler.onAfterInsertCalcOLI(trigger.New);
		}
	}
}