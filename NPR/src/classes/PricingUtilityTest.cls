@isTest
public class PricingUtilityTest {
	
	/*static testMethod void testInitOLIs()
	{
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			Email_List_Size__c=1);
		insert a;
		
		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa;
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa2;
		
		News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='Morning Edition', Name='Test ME 2015');
		insert nms;
		News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='All Things Considered', Name='Test ATC 2015');
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
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', Product_Version__c='1');
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
 		
 		Product2 p2 = new Product2(Name='Prod Test2', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Streaming', Product_Version__c='1');
		insert p2;
		PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p2.Id, UnitPrice=1, isActive=true);
 		insert pbe2;
		
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=system.today().addMonths(1)); 
		
		insert o;
		NPR_Product__c npr2 = [select Id,  Opportunity_Name__c from NPR_Product__c where Opportunity_Name__c=:o.Id];
		system.assertEquals(o.Id, npr2.Opportunity_Name__c);
		
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod', Opportunity_Name__c=o.Id);
		insert npr;
		
		list<OpportunityLineItem> oliList = new list<OpportunityLineItem>{};
		
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=o.Id, Station__c=a.Id, Quantity=1, NPR_Product__c=npr.Id, TotalPrice=100,
			PriceBookEntryId=pbe.Id);
		insert oli;
		OpportunityLineItem oliQ = [select Id, Product2Id, OpportunityId, Station__c, Quantity, NPR_Product__c, TotalPrice, PriceBookEntryId,
			Product2.MSA_Incremental_Type__c, Station__r.Email_List_Size__c, Station__r.Membership_Pricing_Status__c, Product2.Product_Version__c
			from OpportunityLineItem where Id=:oli.Id];
		oliList.add(oliQ);
		
		OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=o.Id, Station__c=a.Id, Quantity=1, NPR_Product__c=npr.Id, TotalPrice=100,
			PriceBookEntryId=pbe2.Id);
		insert oli2;
		OpportunityLineItem oli2Q = [select Id, Product2Id, OpportunityId, Station__c, Quantity, NPR_Product__c, TotalPrice, PriceBookEntryId, 
			Product2.MSA_Incremental_Type__c, Station__r.Email_List_Size__c, Station__r.Membership_Pricing_Status__c, Product2.Product_Version__c
			from OpportunityLineItem where Id=:oli2.Id];
		oliList.add(oli2Q);
		
		PricingUtility pu = new PricingUtility();
		list<OpportunityLineItem> returnOLIList = pu.initOLIs(o, oliList, npr);
	}
	
	static testMethod void testCalcOLI()
	{
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			Email_List_Size__c=1);
		insert a;
		
		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa;
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa2;
		
		News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='Morning Edition', Name='Test ME 2015');
		insert nms;
		News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='All Things Considered', Name='Test ATC 2015');
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
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', Product_Version__c='1');
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
 		
 		Product2 p2 = new Product2(Name='Prod Test2', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Streaming', Product_Version__c='1');
		insert p2;
		PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p2.Id, UnitPrice=1, isActive=true);
 		insert pbe2;
		
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod');
		insert npr;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=system.today().addMonths(1)); 
		insert o;
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=o.Id, Station__c=a.Id, Quantity=1, NPR_Product__c=npr.Id, TotalPrice=100,
			PriceBookEntryId=pbe.Id);
		insert oli;

		
		PricingUtility pu = new PricingUtility();
		OpportunityLineItem returnOLI = pu.calcOLI(oli);
	}*/
	
	static testMethod void testInitNPRProds()
	{	
		Test.startTest();
		Account a2 = new Account(Name='Test Account2', type2__c='Parent', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
		insert a2; 
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member', ParentId=a2.Id);
		insert a;
		
		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa;
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa2;
		
		//News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
		//	Program__c='Morning Edition', Name='Test ME 2016');
		//insert nms;
		
		News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Floor_Cap_Factor__c = 4, Ceiling_Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='Morning Edition', Name='Test ME 2016');
		insert nms;
		
		 		
		//News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
		//	Program__c='All Things Considered', Name='Test ATC 2016');
		//insert nms2;
		News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Floor_Cap_Factor__c = 4, Ceiling_Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
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
	                                      //ATC_Cap_Factor__c = 1,
	                                      ATC_Ceiling_Cap_Factor__c = 10.0, /*Change made by Suhas*/
	                                      ATC_Floor_Cap_Factor__c = 4.0,   /*Change made by Suhas*/
	                                      //ME_Cap_Factor__c = 2,
	                                      ME_Ceiling_Cap_Factor__c = 10.0, /*Change made by Suhas*/
	                                      ME_Floor_Cap_Factor__c = 4.0,  /*Change made by Suhas*/
	                                      ME_Last_FY_Price__c = 200);
		insert fyd;
		
		
		//Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Id pbId = Test.getStandardPricebookId();
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', Product_Version__c='Core');
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
 		
 		Product2 p2 = new Product2(Name='Prod Test2', Family='PPF', Active_Start_Date__c=Date.newInstance(2014, 6, 1), Active_End_Date__c=Date.newInstance(2015, 12, 31), MSA_Incremental_Type__c='Streaming', Product_Version__c='Core');
		insert p2;
		PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p2.Id, UnitPrice=1, isActive=true);
 		insert pbe2;
 		
 		Product2 p3 = new Product2(Name='Prod Test3', Family='MSA', Active_Start_Date__c=Date.newInstance(2014, 6, 1), Active_End_Date__c=Date.newInstance(2015, 12, 31), MSA_Incremental_Type__c='Streaming', Product_Version__c='Core');
		insert p3;
		PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p3.Id, UnitPrice=1, isActive=true);
 		insert pbe3;
 		
 		Product2 p4 = new Product2(Name='Prod Test4', Family='MSA', Active_Start_Date__c=Date.newInstance(2014, 6, 1), Active_End_Date__c=Date.newInstance(2015, 12, 31), MSA_Incremental_Type__c='Email', Product_Version__c='Core');
		insert p4;
		PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p4.Id, UnitPrice=1, isActive=true);
 		insert pbe4;
 		
 		Discounts__c d = new Discounts__c(Discount_Percent__c=10, News_Non_News__c='News', Effective_Date__c=Date.newInstance(2014, 6, 1),
		Expiration_Date__c=Date.newInstance(2014, 6, 1), Discount_Type__c='Test');
		insert d;
 		
 		Pricing_Table__c pt = new Pricing_Table__c(List_Fee__c=100, Effective_Date__c=Date.newInstance(2014, 6, 1), 
 			Expiration_Date__c=Date.newInstance(2015, 12, 31), TSR_High__c=10000000, TSR_Low__c=1, Membership_Pricing_Status__c='Member', 
 			Product__c=p.Id);
 		insert pt;
		
		/*list<NPR_Product__c> nprProdList = new list<NPR_Product__c>{};
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod');
		insert npr;
		nprProdList.add(npr);
		NPR_Product__c npr2 = new NPR_Product__c(name='Test NPR Prod');
		insert npr2;
		nprProdList.add(npr2);
		*/

		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=Date.newInstance(2015, 6, 1), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=Date.newInstance(2015, 12, 31), Admin_Fee_Override__c=10); 
		insert o;
		Opportunity o2 = [select Id, Name, CloseDate, StageName, AccountId, Type, End_Date__c, Total_Override__c, Fiscal_Year__c, 
			Sub_Total_Price__c, Account.Minority_Status__c, TSR_In_Hierarchy_PPF__c, Account.Membership_Pricing_Status__c, Admin_Fee_Override__c,
			Discount__c, Sub_Total_Price_2__c, Total_Contract_Price__c, Admin_Fee__c
			from Opportunity where Id=:o.Id];
		
		Test.stopTest();
		
		list<NPR_Product__c> npr3List = [select Id, Name, Include_in_PPF_MSA__c, List_Fee__c, Discount_Type__c, Discount_Percent__c, Subtotal_Fee__c, Override_Discount__c, 
    		Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Air_Onboard_Date__c, Air_Onboard_Status__c, 
    		Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c, ATC_Uncapped_Price__c,
    		ATC_Last_FY_Price__c, Cap_Percent__c, ATC_Capped_Final_Fee__c, Last_FY_Fee_Override__c, Accelerated_Cap__c, 
    		Accelerated_Cap_Comments__c, Final_Fee__c, Product__r.PPF_Type__c, Product__r.Name, List_Fee_Annualized__c, List_Fee_Prorated__c,
    		Product_Name__c, NPR_Product_Link__c, LastModifiedBy.Name, LastModifiedDate, Other_Discount_Type__c, Opportunity_Name__c
			from NPR_Product__c where Opportunity_Name__c=:o.Id];
		for(NPR_Product__c npr3 : npr3List)
		{
			system.assertEquals(o.Id, npr3.Opportunity_Name__c);
			system.debug('+++++\n\n'+npr3.List_Fee_Annualized__c+'\n\n+++++');
		}
		
		
		Opportunity o3 = new Opportunity(Name='Test Opportunity 2', CloseDate=Date.newInstance(2014, 6, 1), StageName='Prospecting',
			AccountId=a.Id, Type='MSA', End_Date__c=Date.newInstance(2015, 12, 31), Admin_Fee_Override__c=10); 
		insert o3;
		Opportunity o4 = [select Id, Name, CloseDate, StageName, AccountId, Type, End_Date__c, Total_Override__c, Fiscal_Year__c, 
			Sub_Total_Price__c, Account.Minority_Status__c, TSR_In_Hierarchy_PPF__c, Account.Membership_Pricing_Status__c,
			Total_TSR_MSA__c, Admin_Fee_Override__c
			from Opportunity where Id=:o3.Id];
		
		
		list<NPR_Product__c> npr4List = [select Id, Opportunity_Name__c, List_Fee__c, List_Fee_Annualized__c from NPR_Product__c where Opportunity_Name__c=:o4.Id];
		//system.assert(npr4List.size()>0);
		for(NPR_Product__c npr4 : npr4List)
		{
			system.assert(npr4.Opportunity_Name__c!=null);
			system.assertEquals(o4.Id, npr4.Opportunity_Name__c);
			system.debug('+++++\n\n'+npr4.List_Fee_Annualized__c+'\n\n+++++');
		}
		
		list<OpportunityLineItem> oliList = [select Id, Name, Station__r.Name, NPR_Product__c, NPR_Product__r.Product__r.Name, OpportunityId, 
			PricebookEntryId
    		from OpportunityLineItem where OpportunityId=:o4.Id];
    	//system.assert(oliList.size()>0);
    	for(OpportunityLineItem oli : oliList)
    	{
    		system.assert(oli.OpportunityId!=null);
    		system.assertEquals(o4.Id, oli.OpportunityId);
    	}
		
		NPR_Product__c npr1 = npr3List[0].clone();
		npr1.Discount_Percent__c = 10;
		
		PricingUtility pu = new PricingUtility();
		Opportunity returnO = pu.calcOpportunity(o2, npr3List[0], npr1);
		//NPR_Product__c returnNPR = pu.calcNPRProd(npr3List[0]);
		//OpportunityLineItem returnOLI = pu.calcOLI(oliList[0]);
		
		//list<NPR_Product__c> returnNPRList = pu.initNPRProds(o2, nprProdList);
		//list<NPR_Product__c> returnNPRList2 = pu.initNPRProds(o4, nprProdList);
	}
	
	/*static testMethod void testCalcNPRProd()
	{
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			Email_List_Size__c=1);
		insert a;
		
		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa;
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa2;
		
		News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='Morning Edition', Name='Test ME 2015');
		insert nms;
		News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='All Things Considered', Name='Test ATC 2015');
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
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', Product_Version__c='1');
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
 		
 		Product2 p2 = new Product2(Name='Prod Test2', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Streaming', Product_Version__c='1');
		insert p2;
		PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p2.Id, UnitPrice=1, isActive=true);
 		insert pbe2;
		
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod', Accelerated_Cap__c=10, Last_FY_Fee_Override__c=10,
			ATC_Capped_Final_Fee__c=1, ATC_Last_FY_Price__c=10, Product__c=p.Id);
		insert npr;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=system.today().addMonths(1)); 
		insert o;

		
		PricingUtility pu = new PricingUtility();
		NPR_Product__c returnNPR = pu.calcNPRProd(npr);
	}*/
	
	static testMethod void testCalcOpportunity()
	{
		Test.startTest();
		Account a2 = new Account(Name='Test Account2', type2__c='Parent', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
		insert a2;
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member', ParentId=a2.Id);
		insert a;
		
		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa;
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Member',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='1', Email_List_Size_Low__c=1, Email_List_Size_High__c=1);
		insert msa2;
		
		//News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
		//	Program__c='Morning Edition', Name='Test ME 2015');
		//insert nms;
		News_Mag_Settings__c nms = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Floor_Cap_Factor__c = 4, Ceiling_Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='Morning Edition', Name='Test ME 2015');
		insert nms;
		
		
		//News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
		//	Program__c='All Things Considered', Name='Test ATC 2015');
		//insert nms2;
		News_Mag_Settings__c nms2 = new News_Mag_Settings__c (Fiscal_Year__c = 2015, Floor_Cap_Factor__c = 4, Ceiling_Cap_Factor__c = 6, LH_Rate__c = 6, PPM_Rate__c = 6, 
			Program__c='All Things Considered', Name='Test ATC 2015');
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
	                                      //ATC_Cap_Factor__c = 1,
	                                      ATC_Ceiling_Cap_Factor__c = 10.0, /*Change made by Suhas*/
                                          ATC_Floor_Cap_Factor__c = 4.0,/*Change made by Suhas*/
	                                      //ME_Cap_Factor__c = 2,
	                                      ME_Ceiling_Cap_Factor__c = 10.0, /*Change made by Suhas*/
                                          ME_Floor_Cap_Factor__c = 4.0,  /*Change made by Suhas*/
	                                      ME_Last_FY_Price__c = 200);
		insert fyd;
		
		
		//Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Id pbId = Test.getStandardPricebookId();
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', Product_Version__c='1');
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
 		
 		Product2 p2 = new Product2(Name='Prod Test2', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Streaming', Product_Version__c='1');
		insert p2;
		PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p2.Id, UnitPrice=1, isActive=true);
 		insert pbe2;
		
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod');
		insert npr;
		NPR_Product__c npr2 = new NPR_Product__c(name='Test NPR Prod');
		insert npr2;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=system.today().addMonths(1), Total_Override__c=100, Admin_Fee_Override__c=10); 
		insert o;
		Test.stopTest();
		
		PricingUtility pu = new PricingUtility();
		Opportunity returnO = pu.calcOpportunity(o, npr, npr2);
	}
}