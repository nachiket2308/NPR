trigger StationProductsProgramsTrigger on Station_Products_Programs__c (after insert, after update) 
{
	list<Trigger_Settings__c> tsList = [select Id, Name, Disable_Triggers__c from Trigger_Settings__c];
	if(tsList.size()==0 || tsList[0].Disable_Triggers__c==false)
	{
		if (Trigger.isInsert) StationProductsPrograms.handleInsert(Trigger.New);
		
		if (Trigger.isUpdate) StationProductsPrograms.handleUpdate(Trigger.New, Trigger.Old);
	}
}