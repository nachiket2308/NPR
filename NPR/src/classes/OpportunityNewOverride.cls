public class OpportunityNewOverride {

	private final Opportunity opp;
	
	public OpportunityNewOverride(ApexPages.StandardController stdController) { 
        this.opp = (Opportunity)stdController.getRecord();
     	
        String accountId = ApexPages.currentPage().getParameters().get('accid');
        if(accountId!='' && accountId!=null)
        {
        	opp.AccountId = accountId;
        }
    }
    
    public PageReference Next()
	{	
		try 
		{
			opp.Name = Opportunity.AccountId + '-' +Opportunity.Type + '-' +Opportunity.CloseDate;
			opp.StageName = opp.Status2__c;
  			insert opp;
  			
  			// redirect to next step of wizard
  			PageReference oppPage = new PageReference('/apex/OpporunityEditOverride?id='+opp.Id);
  			return oppPage;
		}
		catch (DmlException x)
		{
  			System.debug(x.getMessage());
		}
		return null;
	}
	
	public PageReference cancel()
	{
		String accountId = ApexPages.currentPage().getParameters().get('accid');
		
		PageReference oppPage = new PageReference('/'+accountId);
  		return oppPage;
	}
			

}