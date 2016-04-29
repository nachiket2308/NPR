@isTest
private class NPRProductTriggerCalcOppTest {

    static testMethod void myUnitTest() 
    {
	    // Setup test data
	    // This code runs as the system user
	    /*Profile p = [SELECT Id FROM Profile WHERE Name='Integration User']; 
	    User u = new User(Alias = 'TestIU', Email='standarduser@testorg.com', 
	    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	    LocaleSidKey='en_US', ProfileId = p.Id, 
	    TimeZoneSidKey='America/Los_Angeles', UserName='TestIU@acfSolutoins.com');
	
	    System.runAs(u) 
	    {*/
	    	// The following code runs as user 'u' 
	        System.debug('Current User: ' + UserInfo.getUserName());
	        System.debug('Current Profile: ' + UserInfo.getProfileId()); 
	   		
	   		
	   	//Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Id pbId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', Product_Version__c='Core');
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=prod.Id, UnitPrice=1, isActive=true);
	 	insert pbe;
	 	Account a2 = new Account(Name='Test Account2', type2__c='Parent', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1,  Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
		insert a2;
	 	Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member', ParentId=a2.Id);
		insert a;
	 	Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=Date.newInstance(2015, 6, 1), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=Date.newInstance(2015, 12, 31), Admin_Fee_Override__c=10); 
		insert o;
	    NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod 123', Accelerated_Cap__c=10, Last_FY_Fee_Override__c=10,
		ATC_Capped_Final_Fee__c=1, ATC_Last_FY_Price__c=10, Product__c=prod.Id, Include_In_PPF_MSA__c=false, Opportunity_Name__c=o.Id);
		insert npr; 	
		
			npr.Include_In_PPF_MSA__c = true;
			update npr;
		//}
    }
}