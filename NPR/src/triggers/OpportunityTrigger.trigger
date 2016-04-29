//********************************************************************
// Author: ACF Solutions
//		   Sophak Phou
// Date: May 2014 
// Description: Apex Trigger for various events on Opportunity
//              

trigger OpportunityTrigger on Opportunity (before insert, after insert, after update, after undelete, before delete)
{
	system.debug('\n\nOld\n\n'+trigger.old+'\n\n');
	system.debug('\n\nNew\n\n'+trigger.new+'\n\n');
	
	list<Trigger_Settings__c> tsList = [select Id, Name, Disable_Triggers__c from Trigger_Settings__c];
	if(tsList.size()==0 || tsList[0].Disable_Triggers__c==false)
	{
	
		OpportunityTriggerHandler oOppTH = new OpportunityTriggerHandler(); 
		NPRCallout oNPRCallOut = new NPRCallout();
	
		if (Trigger.isDelete){
			//Delete related action plans
			oOppTH.ActionPlanDelete(Trigger.old);
			oOppTH.OppDelete(Trigger.old);
		}
		
		if (Trigger.isUnDelete ){
			//Undelete related action plans
			oOppTH.ActionPlanUndelete(Trigger.new);
		}
	
		if (Trigger.isBefore && Trigger.isInsert)
		{
			system.debug('Suhas Thisis before insert trigger fired===>>>>>>> ');
			oOppTH.OppCreateInitialize(Trigger.new);
		}
		
		if (Trigger.isAfter && Trigger.isInsert)
		{
			system.debug('Suhas Thisis after insert trigger fired===>>>>>>> ');
			oOppTH.OppObjectsCreate(Trigger.new);
		}
		
		if(Trigger.isAfter && Trigger.isUpdate){
	        oOppTH.OppProductUpdate(Trigger.oldMap, Trigger.newMap);
	        //oNPRCallOut.triggerCall(Trigger.oldMap, Trigger.newMap);
		}
	}
}