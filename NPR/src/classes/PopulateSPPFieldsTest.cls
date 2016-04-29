/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest 
private class PopulateSPPFieldsTest {

    static testMethod void PopulateSPPFieldsTest() {
        Test.startTest();
        // TO DO: implement unit test
         //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
      
        insert objAccount;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true];
        Id PbId = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
		insert pbk1;
		
		Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product';
        objProduct.Family = 'PPF';
        objProduct.MSA_Bundle__c = false;
        objProduct.isActive=true;
        objProduct.Contract_Type__c = 'PPF (recurring)';
        insert objProduct;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = PbId, Product2Id = objProduct.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=objProduct.id,Pricebook2ID=pbk1.id,UnitPrice=50,isActive=true);
        insert pbe1;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.StageName = 'Wins';
        objOpportunity.CloseDate = date.today();
        objOpportunity.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity.AccountId = objAccount.Id;
        insert objOpportunity;
        
        Test.stopTest();
        
        Opportunity objOpportunity1 = new Opportunity();
        objOpportunity1.Name = 'Test Opp';
        objOpportunity1.StageName = 'Wins';
        objOpportunity1.CloseDate = date.today().addYears(1);
        objOpportunity1.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity1.AccountId = objAccount.Id;
        insert objOpportunity1;
        
        List<NPR_Product__c> lstNextYearNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
        insert lstNextYearNPR[0];
        
        List<NPR_Product__c> lstNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
        lstNPR[0].Next_FY_NPR_Product__c = lstNextYearNPR[0].Id;
        insert lstNPR[0];
        
        Station_Products_Programs__c objSPP = new Station_Products_Programs__c();
        objSPP.Station__c = objAccount.Id;
        objSPP.Product_Program_Name__c = objProduct.Id;
        objSPP.Name= 'Test SPP'; 
        objSPP.Start_Date__c = date.today();
        insert objSPP;
        
        List<OpportunityLineItem> lstOpportunityLineItem = new  List<OpportunityLineItem>();
        
        OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
        objOpportunityLineItem.NPR_Product__c = lstNPR[0].Id;
        objOpportunityLineItem.Quantity = 100;
        objOpportunityLineItem.SPP__c = objSPP.Id; 
        objOpportunityLineItem.UnitPrice = 10;
        objOpportunityLineItem.Adopt_Date__c = Date.today();
        objOpportunityLineItem.OpportunityId = objOpportunity.Id;
        objOpportunityLineItem.PricebookEntryId = pbe1.Id;
        objOpportunityLineItem.Station__c = objAccount.Id;
        objOpportunityLineItem.Air_Onboard_Status__c = 'Complete';
        lstOpportunityLineItem.add(objOpportunityLineItem);
        
        OpportunityLineItem objOpportunityLineItem1 = new OpportunityLineItem();
        objOpportunityLineItem1.NPR_Product__c = lstNPR[0].Id;
        objOpportunityLineItem1.Quantity = 100;
        objOpportunityLineItem1.SPP__c = objSPP.Id; 
        objOpportunityLineItem1.UnitPrice = 10;
        objOpportunityLineItem1.Adopt_Date__c = Date.today();
        objOpportunityLineItem1.OpportunityId = objOpportunity1.Id;
        objOpportunityLineItem1.PricebookEntryId = pbe1.Id;
        objOpportunityLineItem1.Station__c = objAccount.Id;
        
        lstOpportunityLineItem.add(objOpportunityLineItem1);
        insert lstOpportunityLineItem;
        
        objOpportunityLineItem.Bill_Start_Date__c = Date.today();
        objOpportunityLineItem.Air_Onboard_Date__c = Date.today();
        objOpportunityLineItem.Adopt_Date__c = Date.today()+2;
        objOpportunityLineItem.Adopt_Status__c = 'Test';
        update objOpportunityLineItem;
        
        objOpportunityLineItem.Air_Onboard_Status__c = 'Dropped';
        objOpportunityLineItem.Bill_End_Date__c = Date.today();
        objOpportunityLineItem.Drop_Date__c = Date.today();
        objOpportunityLineItem.Drop_Reason__c = 'test';
        update objOpportunityLineItem;
        
        system.assertEquals(objOpportunityLineItem1.Drop_Date__c, null);
        
    }
    
    static testMethod void PopulateSPPFieldsForDroppdConditionTest() {
       
        Test.startTest();
        //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
      
        insert objAccount;
        
        //get standard pricebook
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true];
        Id PbId = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
		insert pbk1;
		
		Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product';
        objProduct.Family = 'PPF';
        objProduct.MSA_Bundle__c = false;
        objProduct.isActive=true;
        objProduct.Contract_Type__c = 'PPF (recurring)';
        insert objProduct;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = PbId, Product2Id = objProduct.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=objProduct.id,Pricebook2ID=pbk1.id,UnitPrice=50,isActive=true);
        insert pbe1;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.StageName = 'Wins';
        objOpportunity.CloseDate = date.today();
        objOpportunity.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Type = 'MSA';
        insert objOpportunity;
        
        Test.stopTest();
        
        Opportunity objOpportunity1 = new Opportunity();
        objOpportunity1.Name = 'Test Opp';
        objOpportunity1.StageName = 'Wins';
        objOpportunity1.CloseDate = date.today().addYears(1);
        objOpportunity1.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity1.AccountId = objAccount.Id;
        insert objOpportunity1;
        
        List<NPR_Product__c> lstNextYearNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
        insert lstNextYearNPR[0];
        
        List<NPR_Product__c> lstNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
        lstNPR[0].Next_FY_NPR_Product__c = lstNextYearNPR[0].Id;
        insert lstNPR[0];
        
        Station_Products_Programs__c objSPP = new Station_Products_Programs__c();
        objSPP.Station__c = objAccount.Id;
        objSPP.Product_Program_Name__c = objProduct.Id;
        objSPP.Name= 'Test SPP'; 
        objSPP.Start_Date__c = date.today();
        insert objSPP;
        
        List<OpportunityLineItem> lstOpportunityLineItem = new  List<OpportunityLineItem>();
        
        OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
        objOpportunityLineItem.NPR_Product__c = lstNPR[0].Id;
        objOpportunityLineItem.Quantity = 100;
        objOpportunityLineItem.SPP__c = objSPP.Id; 
        objOpportunityLineItem.UnitPrice = 10;
        objOpportunityLineItem.Adopt_Date__c = Date.today();
        objOpportunityLineItem.OpportunityId = objOpportunity.Id;
        objOpportunityLineItem.PricebookEntryId = pbe1.Id;
        objOpportunityLineItem.Station__c = objAccount.Id;
        objOpportunityLineItem.Air_Onboard_Status__c = 'Complete';
        objOpportunityLineItem.Adopt_Status__c = 'Test Status';
        objOpportunityLineItem.Drop_Date__c = Date.today();
        objOpportunityLineItem.Drop_Reason__c  ='Test';
        lstOpportunityLineItem.add(objOpportunityLineItem);
        
        OpportunityLineItem objOpportunityLineItem1 = new OpportunityLineItem();
        objOpportunityLineItem1.NPR_Product__c = lstNPR[0].Id;
        objOpportunityLineItem1.Quantity = 100;
        objOpportunityLineItem1.SPP__c = objSPP.Id; 
        objOpportunityLineItem1.UnitPrice = 10;
        objOpportunityLineItem1.Adopt_Date__c = Date.today();
        objOpportunityLineItem1.OpportunityId = objOpportunity1.Id;
        objOpportunityLineItem1.PricebookEntryId = pbe1.Id;
        objOpportunityLineItem1.Station__c = objAccount.Id;
        
        lstOpportunityLineItem.add(objOpportunityLineItem1);
        insert lstOpportunityLineItem;
       
        objOpportunityLineItem.Air_Onboard_Status__c = 'Dropped';
        objOpportunityLineItem.Bill_End_Date__c = Date.today();
        objOpportunityLineItem.Drop_Date__c = Date.today();
        objOpportunityLineItem.Drop_Reason__c  ='Test';
        update objOpportunityLineItem;
        
        system.assertEquals(objOpportunityLineItem1.Drop_Date__c, null);
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
        	lstNPRProduct.add(objNPRProduct);
        }
        if(!lstNPRProduct.isEmpty())
    	    return lstNPRProduct;
    	 
    	return null;    
    }
}