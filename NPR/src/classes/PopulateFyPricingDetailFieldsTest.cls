/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest
private class PopulateFyPricingDetailFieldsTest {

    static testMethod void PopulateFyPricingDetailFieldsUnitTest() {
       
        Test.startTest();
       //Create Custom Setting Record
        List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
        List<FY_Pricing_Detail__c> lstFyPricingDetail  = new List<FY_Pricing_Detail__c>();
       
        //Insert Custom setting Record
        News_Mag_Settings__c setting = getFyPricingDetailRecord('Morning Edition');
        setting.Name= 'Test ME 2015';
        lstCustomSetting.add(setting);
        
        News_Mag_Settings__c settingATC = getFyPricingDetailRecord('All Things Considered');
        settingATC.Name= 'Test ATC 2015';
        settingATC.Program__c = 'All Things Considered';
        lstCustomSetting.add(settingATC);
        
        insert lstCustomSetting;

        //Create Account Data
        Account objAccount = getAccountRecord();
        insert objAccount;
        
        News_Mag_Level__c objNewMagLevel = getNewMagLevelRecord('Morning Edition');
        objNewMagLevel.Name = 'Test ME 2015';
        
        News_Mag_Level__c objATCNewMagLevel = getNewMagLevelRecord('All Things Considered');
        objATCNewMagLevel.Name = 'Test ATC 2015';
        
        lstNewsMagLevel.add(objNewMagLevel);
        lstNewsMagLevel.add(objATCNewMagLevel);
        
        insert lstNewsMagLevel;
        
        Discounts__c objDiscount = new Discounts__c();
        objDiscount.Discount_Percent__c = 0;
        objDiscount.Fiscal_Year__c= '2015';
        objDiscount.News_Non_News__c= 'News';
        objDiscount.Discount_Type__c = 'Rural Station';
          
        insert objDiscount;
        
        //Insert  Pricing_Tier__c Record
        Pricing_Tier__c  objPricingTier = new Pricing_Tier__c();
        objPricingTier.Type__c= 'PPF';
        objPricingTier.Tier__c = 2;
        objPricingTier.TSR_Low__c = 1; 
        objPricingTier.TSR_High__c = 2;
        
        insert objPricingTier;
        
        List<FY_Pricing_Detail__c> lstFyPricingDetailRecord = getFyPricingDetailRecord(1,objAccount.Id);
        insert lstFyPricingDetailRecord;
        Test.stopTest();
        
        system.assertEquals(lstFyPricingDetailRecord[0].Fiscal_Year__c, '2015');
       
    }
    
    //Bulk Test Data for Fypricing Record
     static testMethod void PopulateBulkFyPricingDetailFieldsUnitTest() {
        
        Test.startTest();
        //Create Custom Setting Record
        List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
        List<FY_Pricing_Detail__c> lstFyPricingDetail  = new List<FY_Pricing_Detail__c>();
       
        //Insert Custom setting Record
        News_Mag_Settings__c setting = getFyPricingDetailRecord('Morning Edition');
        setting.Name= 'Test ME 2015';
        lstCustomSetting.add(setting);
        
        News_Mag_Settings__c settingATC = getFyPricingDetailRecord('All Things Considered');
        settingATC.Name= 'Test ATC 2015';
        settingATC.Program__c = 'All Things Considered';
        lstCustomSetting.add(settingATC);
        
        insert lstCustomSetting;
        
        Discounts__c objDiscount = new Discounts__c();
        objDiscount.Discount_Percent__c = 10;
        objDiscount.Fiscal_Year__c= '2015';
        objDiscount.News_Non_News__c= 'News';
        objDiscount.Discount_Type__c = 'Rural Station';  
        insert objDiscount;

        //Create Account Data
        Account objAccount = getAccountRecord();
        insert objAccount;
        
        News_Mag_Level__c objNewMagLevel = getNewMagLevelRecord('Morning Edition');
        objNewMagLevel.Name = 'Test ME 2015';
        
        News_Mag_Level__c objATCNewMagLevel = getNewMagLevelRecord('All Things Considered');
        objATCNewMagLevel.Name = 'Test ATC 2015';
        
        lstNewsMagLevel.add(objNewMagLevel);
        lstNewsMagLevel.add(objATCNewMagLevel);
        
        insert lstNewsMagLevel;
        
        //Insert  Pricing_Tier__c Record
        Pricing_Tier__c  objPricingTier = new Pricing_Tier__c();
        objPricingTier.Type__c= 'PPF';
        objPricingTier.Tier__c = 2;
        objPricingTier.TSR_Low__c = 1; 
        objPricingTier.TSR_High__c = 2;
        
        insert objPricingTier;
        
        List<FY_Pricing_Detail__c> lstFyPricingDetailRecord = getFyPricingDetailRecord(100,objAccount.Id);
        insert lstFyPricingDetailRecord;
        
        lstFyPricingDetailRecord[0].ME_Last_FY_Price__c = 10000;
        lstFyPricingDetailRecord[0].ATC_Last_FY_Price__c = 10000;
        
        Update lstFyPricingDetailRecord[0];
        
        Test.stopTest();
        
        system.assertEquals(lstFyPricingDetailRecord[0].Fiscal_Year__c, '2015');
     }
        
    //Get List of FyPricing Detail  Record 
    static List<FY_Pricing_Detail__c> getFyPricingDetailRecord(Integer pIntFyPricingDetailRecordCount, Id pAccountId) {
        
         List<FY_Pricing_Detail__c> lstFyPricingDetail  = new List<FY_Pricing_Detail__c>();
         for(Integer FyPricingDetailRecordCount = 1; FyPricingDetailRecordCount <= pIntFyPricingDetailRecordCount; 
                 FyPricingDetailRecordCount++){
                    
            lstFyPricingDetail.add(new FY_Pricing_Detail__c
                                         (
                                          Station__c = pAccountId,
                                          Fiscal_Year__c = '2015',
                                          ATC_Last_FY_Price__c = 100,
                                          /*ATC_Cap_Factor__c = 1,*/
                                          ATC_Ceiling_Cap_Factor__c = 10.0, /*Change made by Suhas*/
                                          ATC_Floor_Cap_Factor__c = 4.0,   /*Change made by Suhas*/
                                          /*ME_Cap_Factor__c = 2,*/
                                          ME_Ceiling_Cap_Factor__c = 10.0, /*Change made by Suhas*/
                                          ME_Floor_Cap_Factor__c = 4.0,  /*Change made by Suhas*/
                                          ME_Last_FY_Price__c = 200,
                                          ATC_Capped_Price__c  = 1,
                                          ME_Capped_Price__c = 1
                                          ));
         }//for
         return lstFyPricingDetail;      
    }
    
     //Get News_Mag_Level__c Record 
    static News_Mag_Level__c getNewMagLevelRecord(String pStrProgram) {
         News_Mag_Level__c objNewMagLevel  = new News_Mag_Level__c( Fiscal_Year__c  = 2015,
                                                                    Upper_Limit__c  =100,
                                                                    Lower_Limit__c = 1,
                                                                    Rate__c = 10,
                                                                    Program__c = pStrProgram
                                                                    );
         return objNewMagLevel;      
    } 
    
    //Get Account Record 
    static Account getAccountRecord() {
         Account objAccount  = new Account( Name = 'Test Account',
                                            TSR__c = 10,
                                            Minority_Status__c = 'Rural Station'
                                           );
         return objAccount;      
    } 
    
    //Get Custom Setting Record for ME and All Thing Considerd
    static News_Mag_Settings__c getFyPricingDetailRecord(String pStrProgram) {
        
        News_Mag_Settings__c objCustomSetting = new News_Mag_Settings__c (  Fiscal_Year__c = 2015,
                                                                            /*Cap_Factor__c = 6,*/
                                                                            Floor_Cap_Factor__c = 4, Ceiling_Cap_Factor__c = 6, /*Change made by Suhas*/
                                                                            LH_Rate__c = 6,
                                                                            PPM_Rate__c = 6,
                                                                            Program__c = pStrProgram
                                                                          );                                                                 
        return objCustomSetting;      
    }
    
}