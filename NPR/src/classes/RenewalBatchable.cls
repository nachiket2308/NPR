global class RenewalBatchable implements Database.Batchable<sObject>
{
	global String Query = '';
 	global String batchRenewalId;
	global String fiscalYear;
	global String batchRenewalType;  
	global Integer currentFiscalYear;
	global String strFY;

	global RenewalBatchable(String brId, String fy, String renewalType)
	{
		batchRenewalId = brId;
		fiscalYear = fy;
		batchRenewalType = renewalType;   
		
		currentFiscalYear = System.today().year();
		strFY = String.valueOf(currentFiscalYear);
		
		Query = 'SELECT Id, Account.Id, Fiscal_Year__c, Type, StageName, Include_in_Next_FY_Renewal__c FROM Opportunity ' + 
				'WHERE Fiscal_Year__c =: currentFiscalYear AND (StageName = \'Approved\' OR Include_in_Next_FY_Renewal__c = TRUE)';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		System.debug('\n\n\nQuery is: ' + Query + '\n\n\n');
		
	    return Database.getQueryLocator(Query);
	}

   	global void execute(Database.BatchableContext BC, List<Opportunity> previousFYOpps)
   	{
   		for (Opportunity opp : previousFYOpps)
		{
			if(opp.Type==batchRenewalType)
			{
				Opportunity newOpp = new Opportunity();
		
				newOpp.AccountId = opp.AccountId; 			
				newOpp.CloseDate = Date.newInstance(currentFiscalYear, 10, 1); 
				newOpp.End_Date__c = Date.newInstance(currentFiscalYear+1, 9, 30);
				newOpp.Type = batchRenewalType;
				
				//Note that configured workflow rule should override this name
				newOpp.Name = 'Account - ' + newOpp.Type + ' - ' + newOpp.CloseDate;
				
				newOpp.StageName = 'Proposal';
				newOpp.Renewal_Batch__c = batchRenewalId;
				newOpp.Previous_FY_Opportunity__c = opp.Id;
							
				insert newOpp;
			}
		}
    }

   global void finish(Database.BatchableContext BC)
   {
   }
}