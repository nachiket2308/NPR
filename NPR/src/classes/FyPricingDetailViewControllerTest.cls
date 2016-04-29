/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.

 */
@isTest
private class FyPricingDetailViewControllerTest {

    static testMethod void fyPricingDetailViewTest() {
        
        //Create Custom Setting Record
        List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
       
        News_Mag_Settings__c setting = new News_Mag_Settings__c();
        setting.Name= 'Test ME 2015';
		setting.Fiscal_Year__c = 2015;
		//setting.Cap_Factor__c = 6;
		setting.Floor_Cap_Factor__c = 4;
		setting.Ceiling_Cap_Factor__c = 6;
		setting.LH_Rate__c = 6;
		setting.PPM_Rate__c = 6;
		setting.Program__c = 'Morning Edition';
		lstCustomSetting.add(setting);
		
		News_Mag_Settings__c settingATC = new News_Mag_Settings__c();
        settingATC.Name= 'Test ATC 2015';
		settingATC.Fiscal_Year__c = 2015;
		//settingATC.Cap_Factor__c = 6;
		setting.Floor_Cap_Factor__c = 4;
		setting.Ceiling_Cap_Factor__c = 6;
		settingATC.LH_Rate__c = 6;
		settingATC.PPM_Rate__c = 6;
		settingATC.Program__c = 'All Things Considered';
		lstCustomSetting.add(settingATC);
		insert lstCustomSetting;

        //Create Account Data
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.TSR__c = 10;
      
        insert objAccount;
        
        //Create News Mag Level Test Record
        News_Mag_Level__c objNewsMagLevel = new News_Mag_Level__c();
        objNewsMagLevel.Fiscal_Year__c = 2015;
        objNewsMagLevel.Upper_Limit__c = 100;
        objNewsMagLevel.Lower_Limit__c = 1;
        objNewsMagLevel.Rate__c = 10;
        objNewsMagLevel.Program__c = 'Morning Edition';
        objNewsMagLevel.Name = 'Test Level';
        
        lstNewsMagLevel.add(objNewsMagLevel);
        
        News_Mag_Level__c objNewsMagLevel1 = new News_Mag_Level__c();
        objNewsMagLevel1.Fiscal_Year__c = 2015;
        objNewsMagLevel1.Upper_Limit__c = 100;
        objNewsMagLevel1.Lower_Limit__c = 1;
        objNewsMagLevel1.Rate__c = 10;
        objNewsMagLevel1.Program__c = 'All Things Considered';
        objNewsMagLevel1.Name = 'Test Level';
        
        lstNewsMagLevel.add(objNewsMagLevel1);
        
        insert lstNewsMagLevel;
         
        //Insert  Pricing_Tier__c Record
        Pricing_Tier__c  objPricingTier = new Pricing_Tier__c();
        objPricingTier.Type__c= 'PPF';
        objPricingTier.Tier__c = 2;
        objPricingTier.TSR_Low__c = 1; 
        objPricingTier.TSR_High__c = 2;
        
        insert objPricingTier;
        
        //Create FyPricing Test Record
        FY_Pricing_Detail__c objFyPricing = new FY_Pricing_Detail__c();
        objFyPricing.Station__c = objAccount.Id;
        objFyPricing.Fiscal_Year__c = '2015';
      
        insert objFyPricing;
        
        //Set Current page to View mode FiscalYearPricing page
        PageReference pageRef = Page.FyPricingDetailView;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', objFyPricing.Id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(objFyPricing);
		FyPricingDetailViewController objFyPricingDetailViewController = new FyPricingDetailViewController(std);
        
        objFyPricingDetailViewController.refreshFyPricingDetailValues();
        objFyPricingDetailViewController.callEditFyPricingDetail();
        
        String nextPage = objFyPricingDetailViewController.callEditFyPricingDetail().getUrl();
        System.assertEquals('/apex/newfypricingdetail?id='+objFyPricing.Id, nextPage);
        
    }
}