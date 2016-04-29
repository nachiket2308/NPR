@isTest
public class OpporunityEditOverrideTest {
	static testMethod void testPPFType()
	{
		Account a2 = new Account(Name='Test Account2', type2__c='Parent', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
		insert a2; 
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5,  Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member', ParentId=a2.Id);
		insert a;
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod', List_Fee_Annualized__c=10, Bill_Start_Date__c=system.today(), 
			Bill_End_Date__c=system.today().addYears(1));
		insert npr;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=system.today().addMonths(1), Total_TSR_MSA__c=10, Admin_Fee_Override__c=10, Admin_Fee_Override_Comments__c='Test'); 
		insert o;
		//Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Id pbId = Test.getStandardPricebookId();
		system.debug('\n\n pbId = '+pbId+'\n\n');
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today());
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=o.Id, Station__c=a.Id, Quantity=1, NPR_Product__c=npr.Id, TotalPrice=100,
			PriceBookEntryId=pbe.Id, Annualized_Price__c=100, Bill_Start_Date__c=system.today(), Bill_End_Date__c=system.today().addYears(1));
		insert oli;
		
		
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpporunityEditOverride controller = new OpporunityEditOverride(std);
        
        System.currentPagereference().getParameters().put('nprProdId', npr.Id);
        controller.viewDetailsPPF();
        
        controller.selectedNPRProd.Include_In_PPF_MSA__c=true;
        System.currentPagereference().getParameters().put('fieldName', 'Include_In_PPF_MSA__c');
		controller.NPRProdFieldChanged();
		
		controller.selectedNPRProd.Include_In_PPF_MSA__c=false;
        System.currentPagereference().getParameters().put('fieldName', 'Include_In_PPF_MSA__c');
		controller.NPRProdFieldChanged();
		
		controller.selectedNPRProd.Override_Discount__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Discount__c');
		controller.NPRProdFieldChanged();
		
		controller.selectedNPRProd.Override_Fee__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Fee__c');
		controller.NPRProdFieldChanged();
		
		controller.selectedNPRProd.Air_Onboard_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Air_Onboard_Date__c');
		controller.NPRProdFieldChanged();
		
		controller.selectedNPRProd.Drop_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Drop_Date__c');
		controller.NPRProdFieldChanged();
		
		controller.selectedNPRProd.Bill_Start_Date__c=system.today();
        System.currentPagereference().getParameters().put('fieldName', 'Bill_Start_Date__c');
		controller.NPRProdFieldChanged();
        
        controller.closeDetails();
        System.currentPagereference().getParameters().put('nprProdId', npr.Id);
        controller.viewDetailsPPF();
         
        controller.opp.CloseDate = system.today()+1;
        controller.saveWrapper();
        controller.save();
        
        System.currentPagereference().getParameters().put('fieldName', 'Discount__c');
        controller.oppFieldChanged();
	}
	
	static testMethod void testMSAType()
	{
		
		Account a2 = new Account(Name='Test Account2', type2__c='Parent', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member');
		insert a2;
		Account a = new Account(Name='Test Account', type2__c='Station', LMA__c=false, TSR__c=10, NPR_Station_Status__c='Member', 
			TSR_in_Hierarchy__c=5, Email_List_Size__c=1, Minority_Status__c='Test', Membership_Status_for_MSA__c='Member', ParentId=a2.Id,
			MSA_Opt_Out__c=false);
		insert a;
		Id pbId = Test.getStandardPricebookId();
		Product2 p = new Product2(Name='Prod Test', Family='MSA', Active_Start_Date__c=system.today());
		insert p;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=p.Id, UnitPrice=1, isActive=true);
 		insert pbe;
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=a.Id, Type='MSA', End_Date__c=system.today().addMonths(1), Total_TSR_MSA__c=10, Admin_Fee_Override__c=10, Admin_Fee_Override_Comments__c='Test');
		insert o;
		NPR_Product__c npr = new NPR_Product__c(name='Test NPR Prod', List_Fee_Annualized__c=10, Bill_Start_Date__c=system.today(), 
			Bill_End_Date__c=system.today().addYears(1));
		insert npr;
		OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=o.Id, Station__c=a.Id, Quantity=1, NPR_Product__c=npr.Id, TotalPrice=100,
			PriceBookEntryId=pbe.Id, Annualized_Price__c=100, Bill_Start_Date__c=system.today(), Bill_End_Date__c=system.today().addYears(1));
		insert oli;
		
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpporunityEditOverride controller = new OpporunityEditOverride(std);
	
		System.currentPagereference().getParameters().put('oliId', oli.Id);
        controller.viewDetailsMSA();
        
        controller.selectedOli.Air_Onboard_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Air_Onboard_Date__c');
		controller.OLIFieldChanged();
		
		controller.selectedOli.Override_Fee__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Fee__c');
		controller.OLIFieldChanged();
        
        controller.selectedOli.Drop_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Drop_Date__c');
		controller.OLIFieldChanged();
        
        controller.closeDetails();
        
        //SP Comment out nrpBundle does not exist, please update
        
        controller.nrpBundles.add(npr);
        controller.nrpBundlesOld.add(npr);
        controller.nprBundleMap.put(npr.Id, npr);
        controller.nprBundleOldMap.put(npr.Id, npr);
       
        controller.nrpBundles[0].Include_In_PPF_MSA__c=true;
        System.currentPagereference().getParameters().put('fieldName', 'Include_In_PPF_MSA__c');
		System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Include_In_PPF_MSA__c=false;
        System.currentPagereference().getParameters().put('fieldName', 'Include_In_PPF_MSA__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Override_Discount__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Discount__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Override_Fee__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Fee__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Air_Onboard_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Air_Onboard_Date__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Drop_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Drop_Date__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Bill_Start_Date__c=system.today();
        System.currentPagereference().getParameters().put('fieldName', 'Bill_Start_Date__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
        
        controller.opp.CloseDate = system.today()+1;
        controller.saveWrapper();
		controller.save();
	}
	
	/*static testMethod void testMSAType()
	{
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
		
		
		//Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Id pbId = Test.getStandardPricebookId();
		Product2 p = new Product2(Name='Prod Test', Family='PPF', Active_Start_Date__c=system.today(), MSA_Incremental_Type__c='Email', 
			Product_Version__c='Core');
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
		
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=Date.newInstance(2015, 6, 1), StageName='Prospecting',
			AccountId=a.Id, Type='PPF', End_Date__c=Date.newInstance(2015, 12, 31), Admin_Fee_Override__c=10); 
		insert o;
		Opportunity o2 = [select Id, Name, CloseDate, StageName, AccountId, Type, End_Date__c, Total_Override__c, Fiscal_Year__c, 
			Sub_Total_Price__c, Account.Minority_Status__c, TSR_In_Hierarchy_PPF__c, Account.Membership_Pricing_Status__c, Admin_Fee_Override__c 
			from Opportunity where Id=:o.Id];
			
		list<NPR_Product__c> npr3List = [select Id,  Opportunity_Name__c, List_Fee__c, List_Fee_Annualized__c, Final_Fee__c 
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
		
		list<NPR_Product__c> npr4MSA = [select Id, Opportunity_Name__c, List_Fee__c, List_Fee_Annualized__c from NPR_Product__c where Opportunity_Name__c=:o4.Id];
		system.assert(npr4MSA.size()>0);
		for(NPR_Product__c npr4 : npr4MSA)
		{
			system.assert(npr4.Opportunity_Name__c!=null);
			system.assertEquals(o4.Id, npr4.Opportunity_Name__c);
			system.debug('+++++\n\n'+npr4.List_Fee_Annualized__c+'\n\n+++++');
		}
		
		list<OpportunityLineItem> oliList = [select Id, Name, Station__r.Name, NPR_Product__c, NPR_Product__r.Product__r.Name, OpportunityId
    		from OpportunityLineItem where OpportunityId=:o4.Id];
    	system.assert(oliList.size()>0);
    	for(OpportunityLineItem oli : oliList)
    	{
    		system.assert(oli.OpportunityId!=null);
    		system.assertEquals(o4.Id, oli.OpportunityId);
    	}
		
		PageReference pageRef = Page.OpporunityEditOverride;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController std=new ApexPages.StandardController(o);
        OpporunityEditOverride controller = new OpporunityEditOverride(std);
	
		System.currentPagereference().getParameters().put('oliId', oliList[0].Id);
        controller.viewDetailsMSA();
        
        controller.selectedOli.Air_Onboard_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Air_Onboard_Date__c');
		controller.OLIFieldChanged();
		
		controller.selectedOli.Override_Fee__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Fee__c');
		controller.OLIFieldChanged();
        
        controller.selectedOli.Drop_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Drop_Date__c');
		controller.OLIFieldChanged();
        
        controller.closeDetails();
        
        //SP Comment out nrpBundle does not exist, please update
        
       // controller.nrpBundles.add(npr);
       // controller.nrpBundleOld.add(npr);
       
        controller.nrpBundles[0].Include_In_PPF_MSA__c=true;
        System.currentPagereference().getParameters().put('fieldName', 'Include_In_PPF_MSA__c');
		System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Include_In_PPF_MSA__c=false;
        System.currentPagereference().getParameters().put('fieldName', 'Include_In_PPF_MSA__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Override_Discount__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Discount__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Override_Fee__c=10;
        System.currentPagereference().getParameters().put('fieldName', 'Override_Fee__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Air_Onboard_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Air_Onboard_Date__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Drop_Date__c=system.today()-1;
        System.currentPagereference().getParameters().put('fieldName', 'Drop_Date__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
		controller.nrpBundles[0].Bill_Start_Date__c=system.today();
        System.currentPagereference().getParameters().put('fieldName', 'Bill_Start_Date__c');
        System.currentPagereference().getParameters().put('fieldId', controller.nrpBundles[0].Id);
		controller.nrpBundleFieldChanged();
		
        
        controller.opp.CloseDate = system.today()+1;
        controller.saveWrapper();
		controller.save();
	}*/
}