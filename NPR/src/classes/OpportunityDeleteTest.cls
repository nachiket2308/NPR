@isTest
public class OpportunityDeleteTest {

	static testMethod void testOppDelete()
	{
		Account a = new Account(Name='Test Account');
		insert a;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			Account=a, AccountId=a.Id);
		insert o;
		NPR_Product__c npr = new NPR_Product__c(name='test npr', Opportunity_Name__c=o.Id);
		insert npr;
		NPR_Product__c npr2 = new NPR_Product__c(name='test npr2', Opportunity_Name__c=o.Id);
		insert npr2;
		
		delete o;
		list<NPR_Product__c> nprList = [select Id, Name from NPR_Product__c where Opportunity_Name__c=:o.Id];
		system.assertEquals(nprList.size(), 0);
		undelete o;
	}

}