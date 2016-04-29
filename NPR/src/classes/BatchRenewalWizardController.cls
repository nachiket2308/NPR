public class BatchRenewalWizardController 
{
	private final Batch_Renewal__c br;
	public Integer currentFiscalYear = System.today().year();
	public List<Opportunity> newOpps = new List<Opportunity>();
	public Boolean recordHasBeenRenewed {get; set;}
	
	public BatchRenewalWizardController(ApexPages.StandardController stdController) 
	{ 
        this.br = (Batch_Renewal__c)stdController.getRecord();
        this.br.Fiscal_Year__c = String.valueOf(currentFiscalYear);
        recordHasBeenRenewed = false;
    }
    
    public PageReference ProcessRenewals()
	{	
		System.debug('\n\n\nIn ProcessRenewals\n\n\n');
		
		System.debug('\n\n\nrecordHasBeenRenewed is: ' + recordHasBeenRenewed + '\n\n\n');
		
		// Stop record from being renewed more than once
    	recordHasBeenRenewed = true;
    	
    	System.debug('\n\n\nrecordHasBeenRenewed is: ' + recordHasBeenRenewed + '\n\n\n');
    	
		//create new 
		insert br;
		
		System.debug('\n\n\nbr record insertedn\n\n');
		
		Id batchInstanceId = Database.executeBatch(new RenewalBatchable(String.valueOf(this.br.Id), this.br.Fiscal_Year__c, this.br.Renewal_Type__c), 1);
		
		/*
		createBatchRenewalOpportunities(previousFYOppsQuery());
		
		try 
		{
			if (newOpps.size()>0) insert newOpps;
			
  			//PageReference nextPage = new PageReference('/apex/BatchRenewalViewOverride?id='+br.Id);
  			//return nextPage;
		}
		catch (DmlException x)
		{
  			System.debug(x.getMessage());
		}
		*/
		return null;
	}
	
	public List<Opportunity> previousFYOppsQuery()
	{
		//Determine the list of accounts that should have renewal opportunities
		//generated based on current fiscal year opportunities
		
		System.debug('\n\n\nIn previousFYOppsQuery\n\n\n');
		
		return [SELECT Id, Account.Id, Fiscal_Year__c, Type, StageName, Include_in_Next_FY_Renewal__c FROM Opportunity 
			WHERE Fiscal_Year__c =: System.today().year() AND 
			      (StageName = 'Approved' OR Include_in_Next_FY_Renewal__c = TRUE)];

	}	
	
	public void createBatchRenewalOpportunities(List<Opportunity> previousFYOpps)
	{		
		System.debug('\n\n\nIn createBatchRenewalOpportunities\n\n\n');
		System.debug('\n\n\nbr is: ' + br + '\n\n\n');
		System.debug('\n\n\npreviousFYOpps are: ' + previousFYOpps + '\n\n\n');
		
		//create new opportunities by using the following values:
		
		for (Opportunity opp : previousFYOpps)
		{
			system.debug('\n\n'+opp.Type+'\n\n');
			system.debug('\n\n'+br.Renewal_Type__c+'\n\n');
			if(opp.Type==br.Renewal_Type__c)
			{
				Opportunity newOpp = new Opportunity();
		
				newOpp.AccountId = opp.AccountId; 			
				newOpp.CloseDate = Date.newInstance(currentFiscalYear, 10, 1); 
				newOpp.End_Date__c = Date.newInstance(currentFiscalYear+1, 9, 30);
				newOpp.Type = br.Renewal_Type__c;
				
				//Note that configured workflow rule should override this name
				newOpp.Name = 'Account - ' + newOpp.Type + ' - ' + newOpp.CloseDate;
				
				newOpp.StageName = 'Proposal';
				newOpp.Renewal_Batch__c = br.Id;
				newOpp.Previous_FY_Opportunity__c = opp.Id;
							
				newOpps.add(newOpp);
			}
		}		
	}
	
}