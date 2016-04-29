public class RenewOpportunityClass 
{
	public Opportunity generateRenewal(Opportunity existingOpp)
	{
		System.debug('\n\n\nIn generateRenewal\n\n\n');
		
		//generate Opportunity for the next fiscal period 
		
		Opportunity newOpp = new Opportunity();
		newOpp.Name='a';
		newOpp.AccountId = existingOpp.AccountId;			
		newOpp.CloseDate = date.newinstance(System.today().year(), 10, 1); 
		newOpp.End_Date__c = date.newinstance(System.today().year()+1, 9, 30); 
		newOpp.Type = existingOpp.Type;		
		newOpp.StageName = 'Proposal';		
		newOpp.Previous_FY_Opportunity__c = existingOpp.Id;	
		
		System.debug('\n\n\nRenewal Opp is: ' + newOpp + '\n\n\n');
			
		insert newOpp;
			
		return newOpp;		
	}
	
	

}