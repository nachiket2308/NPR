public class OpportunityViewCheck {

	private final Opportunity opp;
	public String oppType{get; set;}
	public String oppId{get; set;}
	
	public OpportunityViewCheck(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        
        Opportunity o = [select Id, Type from Opportunity where Id=:opp.Id];
        
        oppType = o.Type;
        oppId = o.Id;
    }

}