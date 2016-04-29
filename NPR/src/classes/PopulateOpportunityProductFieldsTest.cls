/**
 * This class contains unit tests for validating the behavior of Opportunity Product Trigger
 * 
 */
@isTest
private class PopulateOpportunityProductFieldsTest {

    static testMethod void populateOpportunityProductFieldsUnitTest() {
       
        //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
      
        insert objAccount;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true];
        Id standardPbId = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',
        								  Description='Test Pricebook Entry 1', 
        								  isActive=true);
		insert pbk1;
		
		Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product';
        objProduct.Family = 'PPF';
        objProduct.MSA_Bundle__c = true;
        objProduct.isActive=true;
        insert objProduct;
        
        Product2 objProduct2 = new Product2();
        objProduct2.Name = 'Test Product 2';
        objProduct2.Family = 'PPF';
        objProduct2.MSA_Bundle__c = true;
        objProduct2.isActive=true;
        insert objProduct2;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPbId, 
        												  Product2Id = objProduct.Id,
        												  UnitPrice = 10000, 
        												  IsActive = true, 
        												  UseStandardPrice = false);
        insert standardPrice;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=objProduct.id,
                                                  Pricebook2ID=pbk1.id,
                                                  UnitPrice=50,isActive=true);
        insert pbe1;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.StageName = 'On Hold';
        objOpportunity.CloseDate = date.today();
        objOpportunity.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity.AccountId = objAccount.Id;
        insert objOpportunity;
        
        List<NPR_Product__c> lstNextYearNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
        insert lstNextYearNPR[0];
        
        List<NPR_Product__c> lstNPR= getNPRProductlist(1, objOpportunity.Id, objProduct2.id);
        lstNPR[0].Next_FY_NPR_Product__c = lstNextYearNPR[0].Id;
        insert lstNPR[0];
        
        OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
        objOpportunityLineItem.NPR_Product__c = lstNPR[0].Id;
        objOpportunityLineItem.Quantity = 100;
        objOpportunityLineItem.UnitPrice = 10;
        objOpportunityLineItem.OpportunityId = objOpportunity.Id;
        objOpportunityLineItem.PricebookEntryId = pbe1.Id;
        objOpportunityLineItem.Station__c = objAccount.Id;
        
        insert objOpportunityLineItem;
        
        lstNPR[0].Adopt_Date__c = Date.today();
        update lstNPR[0];
        
    }
    
    //Get NPR Product List
    static List<NPR_Product__c> getNPRProductlist(Integer pNPRProductCount ,Id opportunityId ,Id productId){
        List<NPR_Product__c> lstNPRProduct = new List<NPR_Product__c>();	
        for(Integer intNPRProductCount = 1; intNPRProductCount <= pNPRProductCount;  intNPRProductCount++){
        	
        	NPR_Product__c objNPRProduct = new NPR_Product__c();
        	objNPRProduct.Name= 'Test NPR'+intNPRProductCount;
        	objNPRProduct.Opportunity_Name__c = opportunityId;
        	objNPRProduct.Product__c = productId;
        	objNPRProduct.Adopt_Status__c = 'Complete';
        	objNPRProduct.Fiscal_Year__c = 2014;
        	lstNPRProduct.add(objNPRProduct);
        }
        if(!lstNPRProduct.isEmpty())
    	    return lstNPRProduct;
    	 
    	return null;    
    }
    
}