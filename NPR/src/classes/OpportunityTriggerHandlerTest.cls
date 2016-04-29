/**
 * This class contains unit tests for validating the behavior of Apex handler classes that are 
 * related to the OpportunityTrigger . i.e associating the spp records with same station and 
 * the product_programs to the related opportunity product that has the same station and
 * Product_program  with the Updated opportunity whose isWon status is true.
 * 
 * Initail Drafts            Author                 Date
 * Version 1.0				Dhirendra Verma			5/12/2014
 */
 
@isTest
private class OpportunityTriggerHandlerTest {

	
	/**
	* A method to create the test opportunity and its related LineOpportunityItem with the satation_c
	* product data that is related to the Line OpportunityItem
	**/
	static Id prepareTestData(){
			Account objAccount = new Account();
			objAccount.Name = 'first Account';
			insert objAccount;
			
			Opportunity objOpportunity = new Opportunity();
			objOpportunity.AccountId = objAccount.Id;
			objOpportunity.Name='first Opportunity';
			objOpportunity.StageName = 'Prospecting';
			objOpportunity.Probability = 5;
			objOpportunity.CloseDate = system.today();
			objOpportunity.type = 'PPF';
			insert objOpportunity;
			
			Product2 objProduct  = new Product2();
			objProduct.Name = 'first Product';
			objProduct.Contract_Type__c = 'MSA (recurring)';
			objProduct.Program_Product_Type__c = 'DS services';
			objProduct.ProductCode = '1234';
			insert objProduct;
			
			NPR_Product__c objNprProduct = new NPR_Product__c();
			objNprProduct.Name = 'First ObjNprProduct';
			objNprProduct.Product__c = objProduct.Id;
			Insert objNprProduct;
			
			//Pricebook2 Pbe =  [select id from Pricebook2 where isStandard = true  limit 1];
			Id PbeId = Test.getStandardPricebookId();
			
			PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = PbeId,
			Product2Id = objProduct.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        	insert standardPrice;
			
		    Account objstationAccount = new Account();
			objstationAccount.Name = 'Station first Account';
			insert objstationAccount;
			
			OpportunityLineItem objLineItem = new OpportunityLineItem();
			objLineItem.Station__c = objstationAccount.Id;
			objLineItem.NPR_Product__c = objNprProduct.Id;
			objLineItem.PricebookEntryId = standardPrice.Id;
			objLineItem.OpportunityId = objOpportunity.Id;
			objLineItem.Quantity = 2.00;
			objLineItem.UnitPrice = 124;
			insert objLineItem;
			return objOpportunity.Id;
	}
	
	
    /**
	 *	A test method to test when there is already existing spp records present that has the same 
	 *   Station and same productProgram as that of the realated opportunityProduct a
	 *   than when the opportunity is upadated as its fields isWon is true in such a case
	 *   a spp records associated to such a spp record is created.
	 */
    static testMethod void UpdateOpportunityiLineItemwithSpp(){
    	Id objOpportunityId = prepareTestData();
        Test.startTest();
        Account objAccount = new Account();
        List<Account> lstAccount = [Select Id from Account where Name = 'Station first Account'];
        if(lstAccount != null){
        	objAccount = lstAccount[0];
        }
        
        Product2 objProduct = new Product2();
        List<Product2> listProduct = [Select Id from Product2 where Name = 'first Product'];
        if(listProduct != null){
        	objProduct = listProduct[0];
        }
        
        Station_Products_Programs__c objSpp = new Station_Products_Programs__c();
        objSpp.End_Date__c = system.today().addDays(4);
        objSpp.Start_Date__c = system.today();
        objSpp.Station__c = objAccount.Id;
        objSpp.Product_Program_Name__c = objProduct.id;
        objSpp.Drop_Reason__c = 'First data';
        insert objSpp;
        
        Opportunity objOpportunity = [Select Id, StageName from Opportunity where Id =: objOpportunityId];
        objOpportunity.StageName = 'Wins';
        update ObjOpportunity;
        List<OpportunityLineItem> lstrelatedOpplineItem = [Select id, SPP__c from OpportunityLineItem
        												   where OpportunityId =: objOpportunityId	];
        system.assertEquals(lstrelatedOpplineItem[0].SPP__c, objSpp.Id);												   
		Test.stopTest();
    }
    
    /**
	 *	A test method to test when there is no spp records present that has the same 
	 *   Station and same productProgram as that of the realated opportunityProduct a
	 *   than when the opportunity is upadated as its fields isWon is true in such a case
	 *   a new spp records associated to such a spp record is created.
	 */
    static testMethod void UpdateOpportunityLineItemWithNOSpp() {
        // TO DO: implement unit test
        Id objOpportunityId = prepareTestData();
        Test.startTest();
        Opportunity objOpportunity = [Select Id ,StageName, Name
        							  from Opportunity
        							  where Id =: objOpportunityId];
        objOpportunity.StageName = 'Wins';
        update ObjOpportunity;
        
        List<OpportunityLineItem> lstrelatedOpplineItem = [Select id, SPP__c from OpportunityLineItem
        												   where OpportunityId =: ObjOpportunity.Id	];
        
        system.assertNotEquals(lstrelatedOpplineItem,null);												   
        system.assertNotEquals(lstrelatedOpplineItem[0].SPP__c,null);
		Test.stopTest();
    }
    
}