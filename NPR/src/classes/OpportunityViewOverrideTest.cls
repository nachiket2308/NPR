@isTest
private class OpportunityViewOverrideTest {

    /*static testMethod void testPPFType() {
    	Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=100, NPR_Station_Status__c='Member');
		insert a;
        Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=system.today().addMonths(1)); 
		insert o;
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod', Opportunity_Name__c=o.Id);
		insert npr;
		
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpportunityViewOverride controller = new OpportunityViewOverride(std);
        
        controller.edit();
        
        System.currentPagereference().getParameters().put('nprProdId', npr.Id);
        controller.viewDetailsPPF();
        controller.closeDetails();
        System.currentPagereference().getParameters().put('nprProdId', npr.Id);
        controller.viewDetailsPPF();
    }
    
     static testMethod void testMSAType() {
    	Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=100, NPR_Station_Status__c='Member');
		insert a;
		Account a2 = new Account(Name='Test Account2', type2__c='Station', LMA__c=false, TSR__c=100, NPR_Station_Status__c='Member');
		insert a2;
        Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='MSA', End_Date__c=system.today().addMonths(1)); 
		insert o;
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod', Opportunity_Name__c=o.Id);
		insert npr;
		
		Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Bundle__c=false);
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=o.Id, Station__c=a.Id, Quantity=1, NPR_Product__c=npr.Id, TotalPrice=100,
			PriceBookEntryId=pbe.Id);
		insert oli;
		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=o.Id, Station__c=a2.Id, Quantity=1, NPR_Product__c=npr.Id, TotalPrice=50,
			PriceBookEntryId=pbe.Id);
		insert oli2;
		
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpportunityViewOverride controller = new OpportunityViewOverride(std);
        
        System.currentPagereference().getParameters().put('oliId', oli.Id);
        controller.viewDetailsMSA();
        controller.closeDetails();
        System.currentPagereference().getParameters().put('oliId', oli.Id);
        controller.viewDetailsMSA();
        
        Test.startTest();        
        	System.currentPagereference().getParameters().put('keepOverrides', 'true');
        	controller.refresh();
        	
        	System.currentPagereference().getParameters().put('keepOverrides', 'false');
        	controller.refresh();
        	
        	controller.renew();
        Test.stopTest();
    }*/
   
    /* static testMethod void testPPFType() {
     	Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			Email_List_Size__c=1, TSR_in_Hierarchy__c=5, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
		insert a;
		
		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa;
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa2;
		
		News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='Morning Edition', Name='Test ME 2016');
		insert nms;
		News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='All Things Considered', Name='Test ATC 2016');
		insert nms2;	
		
		News_Mag_Level__c nml1 =  new News_Mag_Level__c(Fiscal_Year__c=2015, Lower_Limit__c=1, Upper_Limit__c=100, Rate__c=10, Program__c='Morning Edition');
		insert nml1;
		News_Mag_Level__c nml2 =  new News_Mag_Level__c(Fiscal_Year__c=2015, Lower_Limit__c=1, Upper_Limit__c=100, Rate__c=10, Program__c='All Things Considered');
		insert nml2;
		
		Pricing_Tier__c  objPricingTier = new Pricing_Tier__c();
        objPricingTier.Type__c= 'PPF';
        objPricingTier.Tier__c = 2;
        objPricingTier.TSR_Low__c = 1; 
        objPricingTier.TSR_High__c = 2;
        insert objPricingTier;
		
		FY_Pricing_Detail__c fyd = new FY_Pricing_Detail__c(Station__c = a.Id,
	                                      Fiscal_Year__c = '2015',
	                                      ATC_Last_FY_Price__c = 100,
	                                      ATC_Cap_Factor__c = 1,
	                                      ME_Cap_Factor__c = 2,
	                                      ME_Last_FY_Price__c = 200);
		insert fyd;
		
		
		Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', Product_Version__c='Core');
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
 		
 		Product2 p2 = new Product2(Name='Prod Test2', Family='PPF', Active_Start_Date__c=Date.newInstance(2014, 6, 1), Active_End_Date__c=Date.newInstance(2015, 12, 31), MSA_Incremental_Type__c='Streaming', Product_Version__c='Core');
		insert p2;
		PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p2.Id, UnitPrice=1, isActive=true);
 		insert pbe2;
 		
 		Product2 p3 = new Product2(Name='Prod Test3', Family='MSA', Active_Start_Date__c=Date.newInstance(2014, 6, 1), Active_End_Date__c=Date.newInstance(2015, 12, 31), MSA_Incremental_Type__c='Streaming', Product_Version__c='Core');
		insert p3;
		PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p3.Id, UnitPrice=1, isActive=true);
 		insert pbe3;
 		
 		Product2 p4 = new Product2(Name='Prod Test4', Family='MSA', Active_Start_Date__c=Date.newInstance(2014, 6, 1), Active_End_Date__c=Date.newInstance(2015, 12, 31), MSA_Incremental_Type__c='Email', Product_Version__c='Core');
		insert p4;
		PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p4.Id, UnitPrice=1, isActive=true);
 		insert pbe4;
 		
 		Discounts__c d = new Discounts__c(Discount_Percent__c=10, News_Non_News__c='News', Effective_Date__c=Date.newInstance(2014, 6, 1),
		Expiration_Date__c=Date.newInstance(2014, 6, 1), Discount_Type__c='Test');
		insert d;
 		
 		Pricing_Table__c pt = new Pricing_Table__c(List_Fee__c=100, Effective_Date__c=Date.newInstance(2014, 6, 1), 
 			Expiration_Date__c=Date.newInstance(2015, 12, 31), TSR_High__c=10000000, TSR_Low__c=1, Membership_Pricing_Status__c='Member', 
 			Product__c=p.Id);
 		insert pt;
		
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=Date.newInstance(2015, 6, 1), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=Date.newInstance(2015, 12, 31)); 
		insert o;
		Opportunity o2 = [select Id, Name, CloseDate, StageName, AccountId, Type, End_Date__c, Total_Override__c, Fiscal_Year__c, 
			Sub_Total_Price__c, Account.Minority_Status__c, TSR_In_Hierarchy_PPF__c, Account.Membership_Pricing_Status__c from 
			Opportunity where Id=:o.Id];
		
		list<NPR_Product__c> nprList = [select Id, Opportunity_Name__c, List_Fee__c, List_Fee_Annualized__c from NPR_Product__c where Opportunity_Name__c=:o.Id];
		list<OpportunityLineItem> oliList = [select Id, Name, OpportunityId from OpportunityLineItem where OpportunityId=:o.Id];
		
		
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpportunityViewOverride controller = new OpportunityViewOverride(std);
        
        System.currentPagereference().getParameters().put('nprProdId', nprList[0].Id);
        controller.viewDetailsPPF();
        controller.closeDetails();
        System.currentPagereference().getParameters().put('nprProdId', nprList[0].Id);
        controller.viewDetailsPPF();
        
        Test.startTest();        
        	System.currentPagereference().getParameters().put('keepOverrides', 'true');
        	controller.refresh();
        	
        	System.currentPagereference().getParameters().put('keepOverrides', 'false');
        	controller.refresh();
        	
        	controller.renew();
        Test.stopTest();
       
        Date d1 = date.newinstance(System.today().year(), 10, 1);
        Date d2 = date.newinstance(System.today().year()+1, 9, 30);
        
        Opportunity o3 = [select Id from Opportunity 
        	where AccountId=:a.Id and CloseDate=:d1 and End_Date__c=:d2];
        system.assert(o3.Id!=null);
        
    	list<NPR_Product__c> nprList2 = [select Id,  Opportunity_Name__c, List_Fee__c, List_Fee_Annualized__c, Final_Fee__c 
			from NPR_Product__c where Opportunity_Name__c=:o3.Id];
		for(NPR_Product__c npr : nprList2)
		{
			system.assertEquals(o3.Id, npr.Opportunity_Name__c);
			system.debug('+++++\n\n'+npr.List_Fee_Annualized__c+'\n\n+++++');
		}
        
        controller.edit();
     }*/
     
     /*static testMethod void testMSAType() {
     	Account a2 = new Account(Name='Test Account2', type2__c='Parent', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			Email_List_Size__c=1, TSR_in_Hierarchy__c=5, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
		insert a2;
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			Email_List_Size__c=1, TSR_in_Hierarchy__c=5, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member', ParentId=a2.Id);
		insert a;
		
		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa;
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa2;
		
		News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='Morning Edition', Name='Test ME 2016');
		insert nms;
		News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='All Things Considered', Name='Test ATC 2016');
		insert nms2;	
		
		News_Mag_Level__c nml1 =  new News_Mag_Level__c(Fiscal_Year__c=2015, Lower_Limit__c=1, Upper_Limit__c=100, Rate__c=10, Program__c='Morning Edition');
		insert nml1;
		News_Mag_Level__c nml2 =  new News_Mag_Level__c(Fiscal_Year__c=2015, Lower_Limit__c=1, Upper_Limit__c=100, Rate__c=10, Program__c='All Things Considered');
		insert nml2;
		
		Pricing_Tier__c  objPricingTier = new Pricing_Tier__c();
        objPricingTier.Type__c= 'MSA';
        objPricingTier.Tier__c = 2;
        objPricingTier.TSR_Low__c = 1; 
        objPricingTier.TSR_High__c = 2;
        insert objPricingTier;
		
		FY_Pricing_Detail__c fyd = new FY_Pricing_Detail__c(Station__c = a.Id,
	                                      Fiscal_Year__c = '2015',
	                                      ATC_Last_FY_Price__c = 100,
	                                      ATC_Cap_Factor__c = 1,
	                                      ME_Cap_Factor__c = 2,
	                                      ME_Last_FY_Price__c = 200);
		insert fyd;
		
		
		//Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
 		Id pbId = Test.getStandardPricebookId();
 		
 		Product2 p = new Product2(Name='Prod Test', Family='MSA', Active_Start_Date__c=Date.newInstance(2014, 6, 1), Active_End_Date__c=Date.newInstance(2015, 12, 31), MSA_Incremental_Type__c='Email', Product_Version__c='Core');
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
 		
 		Discounts__c d = new Discounts__c(Discount_Percent__c=10, News_Non_News__c='News', Effective_Date__c=Date.newInstance(2014, 6, 1),
		Expiration_Date__c=Date.newInstance(2014, 6, 1), Discount_Type__c='Test');
		insert d;
 		
 		Pricing_Table__c pt = new Pricing_Table__c(List_Fee__c=100, Effective_Date__c=Date.newInstance(2014, 6, 1), 
 			Expiration_Date__c=Date.newInstance(2015, 12, 31), TSR_High__c=10000000, TSR_Low__c=1, Membership_Pricing_Status__c='Member', 
 			Product__c=p.Id);
 		insert pt;
		
		Opportunity o = new Opportunity(Name='Test Opportunity 2', CloseDate=Date.newInstance(2014, 6, 1), StageName='Prospecting',
			AccountId=a.Id, Type='MSA', End_Date__c=Date.newInstance(2015, 12, 31)); 
		insert o;
		Opportunity o2 = [select Id, Name, CloseDate, StageName, AccountId, Type, End_Date__c, Total_Override__c, Fiscal_Year__c, 
			Sub_Total_Price__c, Account.Minority_Status__c, TSR_In_Hierarchy_PPF__c, Account.Membership_Pricing_Status__c,
			Total_TSR_MSA__c
			from Opportunity where Id=:o.Id];
		
		list<NPR_Product__c> nprList = [select Id, Opportunity_Name__c, List_Fee__c, List_Fee_Annualized__c from NPR_Product__c where Opportunity_Name__c=:o.Id];
		list<OpportunityLineItem> oliList = [select Id, Name, OpportunityId from OpportunityLineItem where OpportunityId=:o.Id];
		
		system.assert(oliList.size()>0);
		
		
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpportunityViewOverride controller = new OpportunityViewOverride(std);
        
        System.currentPagereference().getParameters().put('oliId', oliList[0].Id);
        controller.viewDetailsMSA();
        controller.closeDetails();
        System.currentPagereference().getParameters().put('oliId', oliList[0].Id);
        controller.viewDetailsMSA();
        
        Test.startTest();        
        	System.currentPagereference().getParameters().put('keepOverrides', 'true');
        	controller.refresh();
        	
        	System.currentPagereference().getParameters().put('keepOverrides', 'false');
        	controller.refresh();
        	
        	controller.renew();
        Test.stopTest();
        
        Date d1 = date.newinstance(System.today().year(), 10, 1);
        Date d2 = date.newinstance(System.today().year()+1, 9, 30);
        
        Opportunity o3 = [select Id from Opportunity 
        	where AccountId=:a.Id and CloseDate=:d1 and End_Date__c=:d2];
        system.assert(o3.Id!=null);
        
    	list<NPR_Product__c> nprList2 = [select Id,  Opportunity_Name__c, List_Fee__c, List_Fee_Annualized__c, Final_Fee__c 
			from NPR_Product__c where Opportunity_Name__c=:o3.Id];
		for(NPR_Product__c npr : nprList2)
		{
			system.assertEquals(o3.Id, npr.Opportunity_Name__c);
			system.debug('+++++\n\n'+npr.List_Fee_Annualized__c+'\n\n+++++');
		}
		
		list<OpportunityLineItem> oliList2 = [select Id, Name, Station__r.Name, NPR_Product__c, NPR_Product__r.Product__r.Name, OpportunityId
			from OpportunityLineItem where OpportunityId=:o3.Id];
    	system.assert(oliList2.size()>0);
    	for(OpportunityLineItem oli : oliList2)
    	{
    		system.assert(oli.OpportunityId!=null);
    		system.assertEquals(o3.Id, oli.OpportunityId);
    	}
    	
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
		
		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = PbId,
		Product2Id = objProduct.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
    	insert standardPrice;
		
													
    	 //Set Current page to View mode FiscalYearPricing page
        PageReference pageRef2 = Page.AddnewProduct;
        Test.setCurrentPage(pageRef2);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', o.Id);
    
    	//AddNewProductController objAddNewProductController = new AddNewProductController();
    	//objAddNewProductController.SelectedList.add(objProduct.Id); 
    	//objAddNewProductController.clickNext();
     }*/
     
     static testMethod void testMSAType() 
     {
     	Account objAccount = new Account();
			objAccount.Name = 'first Account';
			insert objAccount;
			
			Account a2 = new Account(Name='Test Account2', type2__c='Parent', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
			insert a2; 
			Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
				TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member', ParentId=a2.Id);
			insert a; 
			
			Opportunity objOpportunity = new Opportunity();
			objOpportunity.AccountId = a.Id;
			objOpportunity.Name='first Opportunity';
			objOpportunity.StageName = 'Prospecting';
			objOpportunity.Probability = 5;
			objOpportunity.CloseDate = system.today();
			objOpportunity.type = 'MSA';
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
			
			list<OpportunityLineItem> oliList = [select Id, Name, OpportunityId from OpportunityLineItem where OpportunityId=:objOpportunity.Id];
			system.assert(oliList.size()>0);
    	
    		PageReference pageRef = Page.OpporunityEditOverride;
			Test.setCurrentPage(pageRef);
			
			ApexPages.StandardController std=new ApexPages.StandardController(objOpportunity);
	        OpportunityViewOverride controller = new OpportunityViewOverride(std);
	        
	        System.currentPagereference().getParameters().put('oliId', oliList[0].Id);
	        controller.viewDetailsMSA();
	        controller.closeDetails();
	        System.currentPagereference().getParameters().put('oliId', oliList[0].Id);
	        controller.viewDetailsMSA();
	        
	        Test.startTest();        
	        	System.currentPagereference().getParameters().put('keepOverrides', 'true');
	        	controller.refresh();
	        	
	        	System.currentPagereference().getParameters().put('keepOverrides', 'false');
	        	controller.refresh();
	        	
	        	controller.renew();
	        Test.stopTest();
	        
	        controller.edit();
     }
     
     static testMethod void testPPFType() 
     {
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
			
			NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod', Opportunity_Name__c=objOpportunity.Id);
			insert npr;
    	
    		PageReference pageRef = Page.OpporunityEditOverride;
			Test.setCurrentPage(pageRef);
		
			ApexPages.StandardController std=new ApexPages.StandardController(objOpportunity);
        	OpportunityViewOverride controller = new OpportunityViewOverride(std);
        
        	System.currentPagereference().getParameters().put('nprProdId', npr.Id);
        	controller.viewDetailsPPF();
        	controller.closeDetails();
        	System.currentPagereference().getParameters().put('nprProdId', npr.Id);
        	controller.viewDetailsPPF();
     }
}