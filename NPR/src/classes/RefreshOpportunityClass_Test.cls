/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class RefreshOpportunityClass_Test 
{

    static testMethod void unitTest1() 
    {
        Test.startTest();
 
   	   	List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
        List<FY_Pricing_Detail__c> lstFyPricingDetail  = new List<FY_Pricing_Detail__c>();
       
        //Insert Custom setting Record
        News_Mag_Settings__c setting = new  News_Mag_Settings__c
                                         (
                                          Fiscal_Year__c = 2015,
                                          Cap_Factor__c = 6,
                                          LH_Rate__c = 6,
                                          PPM_Rate__c = 6,
                                          Program__c ='Morning Edition');
                                          
        setting.Name= 'Test ME 2019';
        lstCustomSetting.add(setting);
        
        News_Mag_Settings__c settingATC = new  News_Mag_Settings__c
                                         (
                                          Fiscal_Year__c = 2015,
                                          Cap_Factor__c = 6,
                                          LH_Rate__c = 6,
                                          PPM_Rate__c = 6,
                                          Program__c ='All Things Considered');
                                          
        settingATC.Name= 'Test ATC 2019';
        settingATC.Program__c = 'All Things Considered';
        lstCustomSetting.add(settingATC);
        
        insert lstCustomSetting;

        //Create Account Data
         Account parentAccount = new Account(TSR_in_Hierarchy__c=10, Name='AccountABC999', Type2__c='Licensee',  Licensee_Type__c='State', LMA__c = false, NPR_Station_Status__c='Non-Member', Membership_Status_for_MSA__c='Non-Member');
    	insert parentAccount;
    	
    	
        Account objAccount = new Account( Name = 'Test Account', ParentId=parentAccount.Id, 
                                            TSR_in_Hierarchy__c=20, TSR__c = 10, type2__c='Station', LMA__c=false,  
                                            Minority_Status__c = 'Rural Station', NPR_Station_Status__c='Non-Member', Email_List_Size__c=1
                                           );                                          
        insert objAccount;
            
        News_Mag_Level__c objNewMagLevel = new News_Mag_Level__c( Fiscal_Year__c  = 2015,
                                                                    Upper_Limit__c  =100,
                                                                    Lower_Limit__c = 1,
                                                                    Rate__c = 10,
                                                                    Program__c = 'Morning Edition');
        objNewMagLevel.Name = 'Test ME 2019';
        
        News_Mag_Level__c objATCNewMagLevel = new News_Mag_Level__c( Fiscal_Year__c  = 2015,
                                                                    Upper_Limit__c  =100,
                                                                    Lower_Limit__c = 1,
                                                                    Rate__c = 10,
                                                                    Program__c = 'All Things Considered');
        objATCNewMagLevel.Name = 'Test ATC 2019';
        
        lstNewsMagLevel.add(objNewMagLevel);
        lstNewsMagLevel.add(objATCNewMagLevel);
        
        insert lstNewsMagLevel;
        
        Pricing_Tier__c  objPricingTier = new Pricing_Tier__c();
        objPricingTier.Type__c= 'PPF';
        objPricingTier.Tier__c = 2;
        objPricingTier.TSR_Low__c = 1; 
        objPricingTier.TSR_High__c = 2;
        insert objPricingTier;
        
        Admin_Fee__c af = new Admin_Fee__c(); 
		af.Effective_Date__c = system.today() - 10; 
		af.Expiration_Date__c = system.today().addMonths(2); 
		af.TSR_Low__c = 5; 
		af.TSR_High__c = 12; 
		insert af;						
        
        FY_Pricing_Detail__c lstFyPricingDetailRecord = new FY_Pricing_Detail__c 
                                         (
                                          Station__c = objAccount.Id,
                                          Fiscal_Year__c = '2015',
                                          ATC_Last_FY_Price__c = 100,
                                          ATC_Cap_Factor__c = 1,
                                          //ME_Cap_Factor__c = 2,
                                          ME_Ceiling_Cap_Factor__c = 10.0,                    
                                          ME_Floor_Cap_Factor__c = 4.0, 
                                          ME_Last_FY_Price__c = 200,
                                          ATC_Capped_Price__c  = 1,
                                          ME_Capped_Price__c = 1);
        insert lstFyPricingDetailRecord;
		
		Product2 pr = new Product2(name='prABC1', Product_Version__c = 'Core', Family='PPF', Active_Start_Date__c=System.today()-5, Active_End_Date__c=System.today()-1, IsActive=true, MSA_Incremental_Type__c='Streaming');
    	insert pr;
    	
    	Product2 prPY = new Product2(name='prABC134', Product_Version__c = 'Core', Family='PPF', Active_Start_Date__c=Date.newInstance(2012, 6, 1), Active_End_Date__c=Date.newInstance(2012, 10, 1), IsActive=true, MSA_Incremental_Type__c='Streaming');
    	insert prPY;

		//Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		Id pbId = Test.getStandardPricebookId();
		
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pbId, Product2Id=pr.Id, UnitPrice=10, isActive=true, UseStandardPrice=false);
 		insert pbe;
 		
 		PricebookEntry pbePY = new PricebookEntry(Pricebook2Id=pbId, Product2Id=prPY.Id, UnitPrice=10, isActive=true, UseStandardPrice=false);
 		insert pbePY;
 		
 		Pricing_Table__c pt = new Pricing_Table__c(List_Fee__c=100, Effective_Date__c=Date.newInstance(2014, 6, 1), 
 			Expiration_Date__c=Date.newInstance(2015, 12, 31), TSR_High__c=10000000, TSR_Low__c=1, Membership_Pricing_Status__c='Member', 
 			Product__c=pr.Id);
 		insert pt;
 	 		
 		Discounts__c d = new Discounts__c(Discount_Percent__c=10, News_Non_News__c='News', Effective_Date__c=Date.newInstance(2014, 6, 1),
			Expiration_Date__c=Date.newInstance(2014, 7, 1), Discount_Type__c='Rural Station');
		insert d;
 		
 		MSA_Incremental__c msa = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Streaming', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1,
			Effective_Date__c=Date.newInstance(2014, 6, 1), Expiration_Date__c=Date.newInstance(2015, 9, 1));
		insert msa;
		
		MSA_Incremental__c msa2 = new MSA_Incremental__c(Setup_Fee__c=10, Annualized_Fee__c=10, Recurrence_Fee__c=10, Recurrence_Type__c='Monthly',
			Product_Type__c='Email', Membership_Type__c='Member', Product_Version__c='Core', Email_List_Size_Low__c=1, Email_List_Size_High__c=1,
			Effective_Date__c=Date.newInstance(2014, 6, 1), Expiration_Date__c=Date.newInstance(2015, 9, 1));
		insert msa2;
		
 		Pricing_MSA_License_Fee__c mSALicenseFee = new Pricing_MSA_License_Fee__c();
 		mSALicenseFee.Effective_Date__c=Date.newInstance(2014, 6, 1);
		mSALicenseFee.Expiration_Date__c=Date.newInstance(2015, 9, 1);  
		mSALicenseFee.TSR_Low__c=3;
		mSALicenseFee.TSR_High__c=3; 
		mSALicenseFee.Member_Pricing_Status__c='Rural Station';
		insert mSALicenseFee;
		
		Opportunity o = new Opportunity(Name='Test Opportunity', CloseDate=system.today(), StageName='Prospecting',
			AccountId=parentAccount.Id, Type='MSA', End_Date__c=system.today().addMonths(1), Total_TSR_MSA__c=3, Total_Override__c=10); 
		insert o; 
		
    	Test.stopTest();
    	
    	RefreshOpportunityClass roc = new RefreshOpportunityClass();
    	roc.refreshOpportunityKeepOverrides(o);
    	
    	roc = new RefreshOpportunityClass();
    	roc.refreshOpportunityNoOverrides(o);
    	
    	//After Opp calc is called check calculated fields on Opportunity
    	System.debug('\n\n\nOpportunity.Sub_Total_Price__c is: ' + o.Sub_Total_Price__c + '\n\n\n');
    }
}