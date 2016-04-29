/*
 * This class contains unit tests for validating the behavior of ValidationUtiliyClass
 * 
 */
@isTest(seeAllData = true)
private class ValidationUtilityTest {

static testmethod void validateNprProductUnitTest(){
    	
    	Test.startTest();
    	ValidationUtility objValidateField = new ValidationUtility();
    	
        //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
      
        insert objAccount;
        
        //get standard pricebook
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true];
        
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
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPb.Id, 
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
        objOpportunity.End_Date__c = date.today();
        objOpportunity.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Discount__c = 1;
        objOpportunity.Discount_Comments__c = 'test';
        objOpportunity.Admin_Fee_Override__c = 1.0;
        objOpportunity.Admin_Fee_Override_Comments__c = 'test';
        objOpportunity.Total_Override__c = 1.0;
        objOpportunity.Total_Override_Comments__c = 'test';
        insert objOpportunity;
        
        List<NPR_Product__c> lstNextYearNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
        insert lstNextYearNPR[0];
        
        NPR_Product__c objnpr = lstNextYearNPR[0];
        
        /* Validation for object NPR_Product__c and Override_Discount_Comments__c Field */
        objnpr.Override_Discount__c = 1.0;
        objnpr.Override_Discount_Comments__c = null;
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
         /* Validation for object NPR_Product__c and Override_Fee_Comments__c Field */
        objnpr.Override_Discount__c = null;
        objnpr.Override_Fee__c = 1.0;
        objnpr.Override_Fee_Comments__c = null;
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
         /* Validation for object NPR_Product__c and Adopt_Date__c Field */
         
        Date billstartdate = date.newinstance(2014,6,6);
        Date billEnddate = date.newinstance(2014,6,7);
        
        objnpr.Override_Fee__c  = null;
        objnpr.Bill_Start_Date__c = billstartdate;
        objnpr.Bill_End_Date__c = billEnddate; 
        objnpr.Adopt_Date__c = billstartdate; 
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        objOpportunity.CloseDate = date.today();
        objOpportunity.End_Date__c = date.today().addDays(1);
        update objOpportunity;
        
        objnpr = [Select Opportunity_Name__r.CloseDate, Opportunity_Name__r.End_Date__c From NPR_Product__c Where Opportunity_Name__c = :objOpportunity.Id and 
        	Id = :objnpr.Id limit 1];
        	
       	//objNPRProduct.Air_Onboard_Date__c < objNPRProduct.Opportunity_Name__r.CloseDate 
       	objnpr.Adopt_Date__c = null;
        objnpr.Air_Onboard_Date__c = billstartdate.addDays(-1);
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        // objNPRProduct.Air_Onboard_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c
        objnpr.Air_Onboard_Date__c = date.today().addDays(2);
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Air_Onboard_Date__c > objNPRProduct.Drop_Date__c 
        objnpr.Air_Onboard_Date__c = Date.today().addDays(8);
        objnpr.Bill_Start_Date__c = billstartdate;
        objnpr.Bill_End_Date__c = billEnddate; 
        objnpr.Drop_Date__c = billEnddate;
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Drop_Reason__c == null && objNPRProduct.Drop_Date__c != NULL 
        objnpr.Air_Onboard_Date__c = null;
        objnpr.Bill_Start_Date__c = null;
        objnpr.Bill_End_Date__c = null; 
        objnpr.Adopt_Date__c = null;
        objnpr.Drop_Date__c = Date.today();
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Drop_Date__c <= objNPRProduct.Opportunity_Name__r.CloseDate
        objnpr.Drop_Date__c = Date.today().addMonths(-1);
        objnpr.Drop_Reason__c = 'Test';
        objValidateField.validateNPRProductField(objnpr,objnpr);
    
        //objNPRProduct.Drop_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c 
        objnpr.Drop_Date__c = Date.today().addMonths(1);
        objnpr.Drop_Reason__c = 'Test';
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Bill_Start_Date__c < objNPRProduct.Opportunity_Name__r.CloseDate - 90
        objnpr.Drop_Date__c = null;
        objnpr.Drop_Reason__c = null;
        objnpr.Bill_Start_Date__c = Date.today().addMonths(-3);
        objnpr.Bill_End_Date__c = Date.today();
        objnpr.Air_Onboard_Date__c = Date.today();
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Bill_Start_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c + 90  
        objnpr.Bill_Start_Date__c = Date.today().addMonths(4);
        objValidateField.validateNPRProductField(objnpr,objnpr);
         
        //objNPRProduct.Bill_Start_Date__c ==null  
        objnpr.Drop_Date__c = null;
        objnpr.Drop_Reason__c = null;
        objnpr.Bill_Start_Date__c = null;
        objnpr.Bill_End_Date__c = null;
        objnpr.Air_Onboard_Date__c = null;
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Bill_End_Date__c ==null  
        objnpr.Bill_Start_Date__c = Date.today();
        objnpr.Bill_End_Date__c = null;
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Bill_End_Date__c < objNPRProduct.Opportunity_Name__r.CloseDate - 90 
        objnpr.Bill_Start_Date__c = Date.today();
        objnpr.Bill_End_Date__c = Date.today().addMonths(-5);
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Bill_End_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c + 90 
        objnpr.Bill_Start_Date__c = Date.today();
        objnpr.Bill_End_Date__c = Date.today().addMonths(5);
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Accelerated_Cap__c != null && objNPRProduct.Accelerated_Cap__c <= 0 
        objnpr.Bill_Start_Date__c = Date.today();
        objnpr.Bill_End_Date__c = Date.today().addDays(1);
        objnpr.Accelerated_Cap__c = -1.0;
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Accelerated_Cap__c != null && objNPRProduct.Accelerated_Cap__c <= 0 
        objnpr.Bill_Start_Date__c = Date.today();
        objnpr.Bill_End_Date__c = Date.today().addDays(1);
        objnpr.Accelerated_Cap__c = 2.0;
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        //objNPRProduct.Adopt_Date__c    <> null && objNPRProduct.Adopt_Status__c    == null
        objnpr.Bill_Start_Date__c = Date.today();
        objnpr.Bill_End_Date__c = Date.today().addDays(1);
        objnpr.Accelerated_Cap__c  = null;
        objnpr.Adopt_Date__c = Date.today();
        objValidateField.validateNPRProductField(objnpr,objnpr);
        
        Test.stopTest();
    }


    static testMethod void validationUtilityUnitTest() {
       
       	Test.startTest();
        ValidationUtility objValidateField = new ValidationUtility();
        
        //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
      
        insert objAccount;
        
        //get standard pricebook
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true];
        
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
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPb.Id, 
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
        objOpportunity.CloseDate = date.today().addDays(-1);
        objOpportunity.End_Date__c = date.today();
        objOpportunity.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Discount__c = 1;
        objOpportunity.Discount_Comments__c = 'test';
        objOpportunity.Admin_Fee_Override__c = 1.0;
        objOpportunity.Admin_Fee_Override_Comments__c = 'test';
        objOpportunity.Total_Override__c = 1.0;
        objOpportunity.Total_Override_Comments__c = 'test';
        insert objOpportunity;
        
        objValidateField.validateOpportunityField(objOpportunity);
        
        objOpportunity.CloseDate = date.today();
        objOpportunity.End_Date__c = date.today();
        objValidateField.validateOpportunityField(objOpportunity);
        
        /* Validation for object Opportunity and End_Date__c Field */
        objOpportunity.CloseDate = date.today().addDays(-1);
        objOpportunity.End_Date__c = date.today();
        
        objOpportunity.CloseDate = date.today().addDays(+1);
        objOpportunity.End_Date__c = date.today();
        objValidateField.validateOpportunityField(objOpportunity);
        
        /* Validation for object Opportunity and Discount_Type__c Field */
        objOpportunity.CloseDate = date.today().addDays(-1);
        objOpportunity.End_Date__c = date.today();
        objOpportunity.Discount_Type__c = null;
        objOpportunity.Discount__c = 1.0;
        objValidateField.validateOpportunityField(objOpportunity);
        
         /* Validation for object Opportunity and Discount_Comments__c Field */
        objOpportunity.CloseDate = date.today().addDays(-1);
        objOpportunity.End_Date__c = date.today();
        objOpportunity.Discount_Type__c = 'Test';
        objOpportunity.Discount_Comments__c = null;
        objOpportunity.Discount__c = 1.0;
        objValidateField.validateOpportunityField(objOpportunity);
        
        /* Validation for object Opportunity and Total_Override_Comments__c Field */
        objOpportunity.CloseDate = date.today().addDays(-1);
        objOpportunity.End_Date__c = date.today();
        objOpportunity.Discount_Type__c = 'Test';
        objOpportunity.Discount_Comments__c = 'Test';
        objOpportunity.Discount__c = 1.0;
        objOpportunity.Total_Override__c = 1.0;
        objOpportunity.Total_Override_Comments__c = null;
        objValidateField.validateOpportunityField(objOpportunity);
        
        /* Validation for object Opportunity and Admin_Fee_Override__c Field */
        objOpportunity.CloseDate = date.today().addDays(-1);
        objOpportunity.End_Date__c = date.today();
        objOpportunity.Discount_Type__c = 'Test';
        objOpportunity.Discount_Comments__c = 'Test';
        objOpportunity.Discount__c = 1.0;
        objOpportunity.Total_Override__c = 1.0;
        objOpportunity.Total_Override_Comments__c = 'Test';
        objOpportunity.Admin_Fee_Override__c = 1.0;
        objOpportunity.Admin_Fee_Override_Comments__c = null;
        objValidateField.validateOpportunityField(objOpportunity);
        
        Test.stopTest();
    }
    
    
    
    //Test Method for OpportunityLineItem
    static testMethod void validationOpportunityLineItemTest() {
       
       	Test.startTest();
        ValidationUtility objValidateField = new ValidationUtility();
        
        //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
      
        insert objAccount;
        
        //get standard pricebook
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true];
        
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
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPb.Id, 
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
        objOpportunity.End_Date__c = date.today();
        objOpportunity.Pricebook2Id = pbe1.Pricebook2Id;
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Discount__c = 1;
        objOpportunity.Discount_Comments__c = 'test';
        objOpportunity.Admin_Fee_Override__c = 1.0;
        objOpportunity.Admin_Fee_Override_Comments__c = 'test';
        objOpportunity.Total_Override__c = 1.0;
        objOpportunity.Total_Override_Comments__c = 'test';
        insert objOpportunity;
        
        
        List<NPR_Product__c> lstNextYearNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
        //insert lstNextYearNPR[0];
        
        List<NPR_Product__c> lstNPR= getNPRProductlist(1, objOpportunity.Id, objProduct.id);
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
        
        //objOpportunityLineItem.Override_Fee__c != null && objOpportunityLineItem.Override_Fee_Comments__c  == null 
        objOpportunityLineItem.Override_Fee__c = 1.0;
        objOpportunityLineItem.Override_Fee_Comments__c = null;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        //objOpportunityLineItem.Adopt_Date__c <> null && objOpportunityLineItem.Adopt_Status__c  == null
        objOpportunityLineItem.Override_Fee__c = 1.0;
        objOpportunityLineItem.Override_Fee_Comments__c = 'Test';
        objOpportunityLineItem.Adopt_Date__c = Date.today();
        objOpportunityLineItem.Adopt_Status__c = null;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        //objOpportunityLineItem.Opportunity.CloseDate  != null  && objOpportunityLineItem.Air_Onboard_Date__c < objOpportunityLineItem.Opportunity.CloseDate
        
        objOpportunityLineItem = [Select Opportunity.End_Date__c, 
			Opportunity.CloseDate,Override_Fee__c,Override_Fee_Comments__c, List_Fee__c,  Air_Onboard_Date__c, Air_Onboard_Status__c, 
    		Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c From OpportunityLineItem  Where  
			 Id = :objOpportunityLineItem.id];
			 
		objOpportunity.End_Date__c = objOpportunityLineItem.Opportunity.End_Date__c;
		objOpportunity.CloseDate = objOpportunityLineItem.Opportunity.CloseDate;	 
	 	update objOpportunity;
	 	
        objOpportunityLineItem.Override_Fee__c = 1.0;
        objOpportunityLineItem.Override_Fee_Comments__c = 'Test';
        objOpportunityLineItem.Adopt_Date__c = Date.today();
        objOpportunityLineItem.Adopt_Status__c = 'Test';
        
        objOpportunityLineItem.Air_Onboard_Date__c = Date.today().addDays(-1);
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        //objOpportunityLineItem.Opportunity.End_Date__c  != null && objOpportunityLineItem.Air_Onboard_Date__c 
        //> objOpportunityLineItem.Opportunity.End_Date__c  ){
        objOpportunityLineItem.Override_Fee__c = 1.0;
        objOpportunityLineItem.Override_Fee_Comments__c = 'Test';
        objOpportunityLineItem.Adopt_Date__c = Date.today();
        objOpportunityLineItem.Adopt_Status__c = 'Test';
        
        objOpportunityLineItem.Air_Onboard_Date__c = Date.today().addDays(2);
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        //objOpportunityLineItem.Air_Onboard_Date__c > objOpportunityLineItem.Drop_Date__c
        objOpportunityLineItem.Override_Fee__c = 1.0;
        objOpportunityLineItem.Override_Fee_Comments__c = 'Test';
        objOpportunityLineItem.Adopt_Date__c = Date.today();
        objOpportunityLineItem.Adopt_Status__c = 'Test';
        
        objOpportunityLineItem.Air_Onboard_Date__c = Date.today();
         objOpportunityLineItem.Drop_Date__c = Date.today().addDays(-1);
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        //objOpportunityLineItem.Drop_Reason__c == null && objOpportunityLineItem.Drop_Date__c <> NULL 
        objOpportunityLineItem.Override_Fee__c = 1.0;
        objOpportunityLineItem.Override_Fee_Comments__c = 'Test';
        objOpportunityLineItem.Adopt_Date__c = Date.today();
        objOpportunityLineItem.Adopt_Status__c = 'Test';
        
        objOpportunityLineItem.Air_Onboard_Date__c = Date.today();
        objOpportunityLineItem.Drop_Date__c = Date.today().addDays(-1);
        objOpportunityLineItem.Drop_Reason__c = NULL; 
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        Date dCloseDate = date.newinstance(2014,6, 6);
        Date billstartdate = date.newinstance(2013,5,13);
        objOpportunity.End_Date__c = objOpportunityLineItem.Opportunity.End_Date__c;
		objOpportunity.CloseDate = dCloseDate;	 
	 	update objOpportunity;
	 	
	 	objOpportunityLineItem = [Select Opportunity.End_Date__c, 
			Opportunity.CloseDate,Override_Fee__c,Override_Fee_Comments__c, List_Fee__c,  Air_Onboard_Date__c, Air_Onboard_Status__c, 
    		Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c From OpportunityLineItem  Where  
			 Id = :objOpportunityLineItem.id];
			 
        //objOpportunityLineItem.Opportunity.CloseDate  != null &&  
        	//objOpportunityLineItem.Bill_Start_Date__c < objOpportunityLineItem.Opportunity.CloseDate - 90
        objOpportunityLineItem.Bill_Start_Date__c = billstartdate;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);	
        
        Date dEndDate = date.newinstance(2014,6, 7);
        Date billstartdate1 = date.newinstance(2014,9,7);
        objOpportunity.End_Date__c = dEndDate;
		objOpportunity.CloseDate = dCloseDate;	 
	 	update objOpportunity;
	 	
	 	objOpportunityLineItem = [Select Opportunity.End_Date__c, 
			Opportunity.CloseDate,Override_Fee__c,Override_Fee_Comments__c, List_Fee__c,  Air_Onboard_Date__c, Air_Onboard_Status__c, 
    		Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c From OpportunityLineItem  Where  
			 Id = :objOpportunityLineItem.id];
			 
        //objOpportunityLineItem.Bill_Start_Date__c > objOpportunityLineItem.Opportunity.End_Date__c + 90
        objOpportunityLineItem.Bill_Start_Date__c = billstartdate1;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
			 
        //objOpportunityLineItem.Bill_Start_Date__c == null
        objOpportunityLineItem.Bill_Start_Date__c = null;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        	
        //objOpportunityLineItem.Bill_End_Date__c == null
        objOpportunityLineItem.Bill_Start_Date__c = Date.today();
        objOpportunityLineItem.Bill_End_Date__c = null;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
			 
        Date billstartdate2 = date.newinstance(2014,6,7);
        Date billEnddate2 = date.newinstance(2014,3,7);
        
        //objOpportunityLineItem.Bill_End_Date__c < objOpportunityLineItem.Opportunity.CloseDate - 90 
        objOpportunityLineItem.Bill_Start_Date__c = billstartdate2;
        objOpportunityLineItem.Bill_End_Date__c = billEnddate2;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
      	Date billEnddate3 = date.newinstance(2014,9,7);
        objOpportunityLineItem.Bill_End_Date__c = billEnddate3;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        Date Dropdate = date.newinstance(2014,6,7);
        objOpportunityLineItem.Drop_Date__c = Dropdate;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        dCloseDate = date.newinstance(2014,6, 6);
        dEndDate = date.newinstance(2014,6, 7);
       
        objOpportunity.End_Date__c = dEndDate;
		objOpportunity.CloseDate = dCloseDate;	 
		
	 	update objOpportunity;
	 	
	 	billstartdate2 = date.newinstance(2014,6,7);
        billEnddate2 = date.newinstance(2014,6,7);
	 	
	 	objOpportunityLineItem = [Select Opportunity.End_Date__c, 
			Opportunity.CloseDate,Override_Fee__c,Override_Fee_Comments__c, List_Fee__c,  Air_Onboard_Date__c, Air_Onboard_Status__c, 
    		Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c From OpportunityLineItem  Where  
			 Id = :objOpportunityLineItem.id];
			 
        Date Dropdate1 = date.newinstance(2014,5,7);
        objOpportunityLineItem.Drop_Date__c = Dropdate1;
        objOpportunityLineItem.Drop_Reason__c = 'Test';
        objOpportunityLineItem.Bill_Start_Date__c = billstartdate2;
        objOpportunityLineItem.Bill_End_Date__c = billEnddate2;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        Dropdate1 = date.newinstance(2014,7,7);
        objOpportunityLineItem.Drop_Date__c = Dropdate1;
        objValidateField.validateOpportunityProduct(objOpportunityLineItem,objOpportunityLineItem);
        
        Test.stopTest();
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