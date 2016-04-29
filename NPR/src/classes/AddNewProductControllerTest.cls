/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class AddNewProductControllerTest {

    static testMethod void AddNewProductControllerUnitTest() {
    	
    	Set<String> SetOpportunityLineItemStation = new Set<String>();	
        //Create Custom Setting Record
        List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
       
        News_Mag_Settings__c setting = new News_Mag_Settings__c();
        setting.Name= 'Test ME 2015';
		setting.Fiscal_Year__c = 2014;
		//setting.Cap_Factor__c = 6;
		setting.Floor_Cap_Factor__c = 4;
		setting.Ceiling_Cap_Factor__c = 6;
		setting.LH_Rate__c = 6;
		setting.PPM_Rate__c = 6;
		setting.Program__c = 'Morning Edition';
		lstCustomSetting.add(setting);
		
		News_Mag_Settings__c settingATC = new News_Mag_Settings__c();
        settingATC.Name= 'Test ATC 2015';
		settingATC.Fiscal_Year__c = 2014;
		//settingATC.Cap_Factor__c = 6;
		setting.Floor_Cap_Factor__c = 4;
		setting.Ceiling_Cap_Factor__c = 6;
		settingATC.LH_Rate__c = 6;
		settingATC.PPM_Rate__c = 6;
		settingATC.Program__c = 'All Things Considered';
		lstCustomSetting.add(settingATC);
		//insert lstCustomSetting;
		
		 News_Mag_Settings__c setting1 = new News_Mag_Settings__c();
        setting1.Name= 'Test ME 2013';
		setting1.Fiscal_Year__c = 2013;
		//setting1.Cap_Factor__c = 6;
		setting.Floor_Cap_Factor__c = 4;
		setting.Ceiling_Cap_Factor__c = 6;
		setting1.LH_Rate__c = 6;
		setting1.PPM_Rate__c = 6;
		setting1.Program__c = 'Morning Edition';
		lstCustomSetting.add(setting1);
		
		News_Mag_Settings__c settingATC1 = new News_Mag_Settings__c();
        settingATC1.Name= 'Test ATC 2013';
		settingATC1.Fiscal_Year__c = 2013;
		//settingATC1.Cap_Factor__c = 6;
		setting.Floor_Cap_Factor__c = 4;
		setting.Ceiling_Cap_Factor__c = 6;
		settingATC1.LH_Rate__c = 6;
		settingATC1.PPM_Rate__c = 6;
		settingATC1.Program__c = 'All Things Considered';
		lstCustomSetting.add(settingATC1);
		insert lstCustomSetting;

        //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
        objAccount.LMA__c = true;
      
        insert objAccount;
        
         Account objAccount1 = new Account();
        objAccount1.Name = 'Test Account1';
        objAccount1.TSR__c = 10;
        objAccount1.LMA__c = true;
        insert objAccount1;
        SetOpportunityLineItemStation.add(objAccount.Id);
        SetOpportunityLineItemStation.add(objAccount1.Id);
        
        //Create News Mag Level Test Record
        News_Mag_Level__c objNewsMagLevel = new News_Mag_Level__c();
        objNewsMagLevel.Fiscal_Year__c = 2014;
        objNewsMagLevel.Upper_Limit__c = 100;
        objNewsMagLevel.Lower_Limit__c = 1;
        objNewsMagLevel.Rate__c = 10;
        objNewsMagLevel.Program__c = 'Morning Edition';
        objNewsMagLevel.Name = 'Test Level';
        
        lstNewsMagLevel.add(objNewsMagLevel);
        
        News_Mag_Level__c objNewsMagLevel1 = new News_Mag_Level__c();
        objNewsMagLevel1.Fiscal_Year__c = 2014;
        objNewsMagLevel1.Upper_Limit__c = 100;
        objNewsMagLevel1.Lower_Limit__c = 1;
        objNewsMagLevel1.Rate__c = 10;
        objNewsMagLevel1.Program__c = 'All Things Considered';
        objNewsMagLevel1.Name = 'Test Level';
        
        lstNewsMagLevel.add(objNewsMagLevel1);
        
        //Create News Mag Level Test Record
        News_Mag_Level__c objNewsMagLevel3 = new News_Mag_Level__c();
        objNewsMagLevel3.Fiscal_Year__c = 2013;
        objNewsMagLevel3.Upper_Limit__c = 100;
        objNewsMagLevel3.Lower_Limit__c = 1;
        objNewsMagLevel3.Rate__c = 10;
        objNewsMagLevel3.Program__c = 'Morning Edition';
        objNewsMagLevel3.Name = 'Test Level1';
        
        lstNewsMagLevel.add(objNewsMagLevel3);
        
        News_Mag_Level__c objNewsMagLevel2 = new News_Mag_Level__c();
        objNewsMagLevel2.Fiscal_Year__c = 2013;
        objNewsMagLevel2.Upper_Limit__c = 100;
        objNewsMagLevel2.Lower_Limit__c = 1;
        objNewsMagLevel2.Rate__c = 10;
        objNewsMagLevel2.Program__c = 'All Things Considered';
        objNewsMagLevel2.Name = 'Test Level2';
        
        lstNewsMagLevel.add(objNewsMagLevel2);
        
        insert lstNewsMagLevel;
         
        //Insert  Pricing_Tier__c Record
        Pricing_Tier__c  objPricingTier = new Pricing_Tier__c();
        objPricingTier.Type__c= 'PPF';
        objPricingTier.Tier__c = 2;
        objPricingTier.TSR_Low__c = 1; 
        objPricingTier.TSR_High__c = 2;
        
        insert objPricingTier;
        
        //Insert  Pricing_Tier__c Record
        Pricing_Tier__c  objPricingTier1 = new Pricing_Tier__c();
        objPricingTier1.Type__c= 'PPF';
        objPricingTier1.Tier__c = 2;
        objPricingTier1.TSR_Low__c = 1; 
        objPricingTier1.TSR_High__c = 2;
        
        insert objPricingTier1;
        
        //Create FyPricing Test Record
        FY_Pricing_Detail__c objFyPricing = new FY_Pricing_Detail__c();
        objFyPricing.Station__c = objAccount.Id;
        objFyPricing.Fiscal_Year__c = '2014';
      
        insert objFyPricing;
    
        //Create FyPricing Test Record
        FY_Pricing_Detail__c objFyPricing1 = new FY_Pricing_Detail__c();
        objFyPricing1.Station__c = objAccount1.Id;
        objFyPricing1.Fiscal_Year__c = '2013';
      
        insert objFyPricing1;
	        
		//pricebook2 Pbe =  [select id from Pricebook2 where isStandard = true  limit 1];
        Id PbeId = Test.getStandardPricebookId();
        
        Test.startTest();
        
		Opportunity objOpportunity = new Opportunity();
		objOpportunity.AccountId = objAccount.Id;
		objOpportunity.Name='first Opportunity';
		objOpportunity.StageName = 'Prospecting';
		objOpportunity.Probability = 5;
		objOpportunity.CloseDate = Date.today();
		objOpportunity.Pricebook2Id =PbeId; 
		objOpportunity.Type ='MSA';
		
		insert objOpportunity;
		
		//objOpportunity = [select id ,Fiscal_Year__c from Opportunity where id =: objOpportunity.id];
		
		Opportunity objOpportunity1 = new Opportunity();
		objOpportunity1.AccountId = objAccount1.Id;
		objOpportunity1.Name='first Opportunity2';
		objOpportunity1.StageName = 'Prospecting';
		objOpportunity1.Probability = 3;
		objOpportunity1.CloseDate = system.today().addYears(-1);
		objOpportunity1.Pricebook2Id =PbeId; 
		objOpportunity1.Type ='MSA';
		
		insert objOpportunity1;
		
		//objOpportunity1 = [select id ,Fiscal_Year__c from Opportunity where id =: objOpportunity1.id];
		
		Test.stopTest();
		
		Product2 objProduct  = new Product2();
		objProduct.Name = 'first Product';
		objProduct.Contract_Type__c = 'MSA(recurring)';
		objProduct.Program_Product_Type__c = 'DS services';
		objProduct.ProductCode = '1234';
		objProduct.Product_Version__c = 'Trial';
		objProduct.Family = 'MSA';
		objProduct.MSA_Type__c = 'Member';
		objProduct.Active_Start_Date__c = system.today();
		objProduct.Active_End_Date__c = system.today();
		insert objProduct;
		
		NPR_Product__c objNprProduct = new NPR_Product__c();
		objNprProduct.Name = 'First ObjNprProduct';
		objNprProduct.Product__c = objProduct.Id;
		objNprProduct.Opportunity_Name__c = objOpportunity.Id;
		insert objNprProduct;
		
    	PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = PbeId,
		Product2Id = objProduct.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
    	insert standardPrice;
    	
		OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
        objOpportunityLineItem.NPR_Product__c = objNprProduct.Id;
        objOpportunityLineItem.Quantity = 100;
        objOpportunityLineItem.UnitPrice = 10;
        objOpportunityLineItem.OpportunityId = objOpportunity1.Id;
        objOpportunityLineItem.PricebookEntryId = standardPrice.Id;
        objOpportunityLineItem.Air_Onboard_Status__c = 'Complete';
        objOpportunityLineItem.Station__c = objAccount.Id;
    
    	insert objOpportunityLineItem;
    	
    	OpportunityLineItem objOpportunityLineItem1 = new OpportunityLineItem();
        objOpportunityLineItem1.NPR_Product__c = objNprProduct.Id;
        objOpportunityLineItem1.Quantity = 100;
        objOpportunityLineItem1.UnitPrice = 10;
        objOpportunityLineItem1.OpportunityId = objOpportunity.Id;
        objOpportunityLineItem1.PricebookEntryId = standardPrice.Id;
        objOpportunityLineItem1.Station__c = objAccount1.Id;
    
    	//insert objOpportunityLineItem1;
    	
		OpportunityLineItem objOppLineItem =  [Select Id,
													Station__r.Email_List_Size__c,
													Station__r.Membership_Pricing_Status__c,
													Station__r.Name,
													Station__r.Id,
													Station__r.LMA__c,
													PricebookEntryId,
													Station__c,
													Opportunity.Id From OpportunityLineItem
													where Opportunity.Id =: objOpportunity1.id limit 1];
											
    	 //Test.startTest();
    	
    	 //Set Current page to View mode FiscalYearPricing page
        PageReference pageRef = Page.AddnewProduct;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', objOpportunity.Id);
    
    	AddNewProductController objAddNewProductController = new AddNewProductController();
    	
    	objAddNewProductController.mapStationIdToLMABoolean.put(objOppLineItem.Station__r.Id, objOppLineItem.Station__r.LMA__c);
    	objAddNewProductController.mapStringToOpportunityLineItem.put(objOppLineItem.PricebookEntryId,objOppLineItem);

    	objAddNewProductController.getProductforOpportunity();
    	objAddNewProductController.SelectedList.add(objProduct.Id); 
    	objAddNewProductController.clickNext();
    	
    	objAddNewProductController = new AddNewProductController();
    	objAddNewProductController.updateOpportunityLineitem(SetOpportunityLineItemStation,Double.valueOf(objOpportunity.Fiscal_Year__c),objProduct.id);
    	objAddNewProductController.clickCancel();
    	
    	objAddNewProductController = new AddNewProductController();
    	objOpportunityLineItem.Air_Onboard_Status__c = 'Dropped';
    	objAddNewProductController.updateOpportunityLineitem(SetOpportunityLineItemStation,Double.valueOf(objOpportunity.Fiscal_Year__c),objProduct.id);
    
    	//Test.stopTest();
    }
}//End AddNewProductControllerTest