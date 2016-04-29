@isTest
public class OpportunityNewOverrideTest {
	
	static testMethod void testExt()
	{
		Account a = new Account(Name='Test Account');
		insert a;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(),
			AccountId=a.Id, End_Date__c=system.today().addMonths(1), Status2__c='Prospecting');
		
			
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		System.currentPagereference().getParameters().put('accid', a.Id);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpportunityNewOverride controller = new OpportunityNewOverride(std);
        controller.next();
        controller.cancel();
	}
	
	static testMethod void testFail()
	{
		Account a = new Account(Name='Test Account');
		insert a;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(),
			AccountId=a.Id, End_Date__c=system.today().addMonths(1));
		
			
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpportunityNewOverride controller = new OpportunityNewOverride(std);
        controller.next();
		controller.cancel();
	}

}