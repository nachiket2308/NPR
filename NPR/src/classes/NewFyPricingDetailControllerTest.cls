/*
*    Description : Apex TestClass for NewFyPricingDetailController
*
*    Version            Date                Author                Description
*    
*    1.0                05/02/2014          Siddharth Birari      Initial Draft
*/

@isTest
public class NewFyPricingDetailControllerTest {

    //Test method considers the creation of New FY Pricing Detail reccord
    public static testmethod void newPricingDetailRecordWithStationTest(){
    
    
    	//Create Custom Setting Record
        List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
       
        News_Mag_Settings__c setting = new News_Mag_Settings__c();
        setting.Name= 'Test ME 2015';
		setting.Fiscal_Year__c = 2015;
		/*setting.Cap_Factor__c = 6;*/
		setting.Floor_Cap_Factor__c = 4;   /*Change made by Suhas*/
		setting.Ceiling_Cap_Factor__c = 6; /*Change made by Suhas*/
		setting.LH_Rate__c = 6;
		setting.PPM_Rate__c = 6;
		setting.Program__c = 'Morning Edition';
		lstCustomSetting.add(setting);
		
		News_Mag_Settings__c settingATC = new News_Mag_Settings__c();
        settingATC.Name= 'Test ATC 2015';
		settingATC.Fiscal_Year__c = 2015;
		/*settingATC.Cap_Factor__c = 6;*/
		settingATC.Floor_Cap_Factor__c = 4;   /*Change made by Suhas*/
        settingATC.Ceiling_Cap_Factor__c = 6; /*Change made by Suhas*/
		settingATC.LH_Rate__c = 6;
		settingATC.PPM_Rate__c = 6;
		settingATC.Program__c = 'All Things Considered';
		lstCustomSetting.add(settingATC);
		insert lstCustomSetting;
    	
    	
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
        
        
        Account objTestAccount = new Account();
        objTestAccount.Name = 'TestStation';
        objTestAccount.TSR__c = 10;
        insert objTestAccount;
        
        FY_Pricing_Detail__c objTestFyPricingDetail = new FY_Pricing_Detail__c();
        Apexpages.Standardcontroller testStdCtrl = new Apexpages.Standardcontroller(objTestFyPricingDetail);
        
        NewFyPricingDetailController objCtrl = new NewFyPricingDetailController(testStdCtrl);
        
        
        objCtrl.objFyPricingDetail.Station__c = objTestAccount.Id;
        objCtrl.objFyPricingDetail.Fiscal_Year__c  = '2015';
        Test.startTest();
            
            Pagereference testPageRef = objCtrl.savePricingDetail();                                              
            
            Pagereference expectedPageRef = Page.FyPricingDetailView;
            expectedPageRef.getParameters().put('Id', objCtrl.objFyPricingDetail.Id);
            
            System.assertEquals(testPageRef.getUrl(), expectedPageRef.getUrl());
        Test.stopTest();
    }      
    
    //Test method considers editing the FY Pricing Detail reccord
    public static testMethod void editPricingDetailRecordTest(){

			//Create Custom Setting Record
        List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
       
        News_Mag_Settings__c setting = new News_Mag_Settings__c();
        setting.Name= 'Test ME 2015';
		setting.Fiscal_Year__c = 2015;
		/*setting.Cap_Factor__c = 6;*/
		setting.Floor_Cap_Factor__c = 4;   /*Change made by Suhas*/
        setting.Ceiling_Cap_Factor__c = 6; /*Change made by Suhas*/
		setting.LH_Rate__c = 6;
		setting.PPM_Rate__c = 6;
		setting.Program__c = 'Morning Edition';
		lstCustomSetting.add(setting);
		
		News_Mag_Settings__c settingATC = new News_Mag_Settings__c();
        settingATC.Name= 'Test ATC 2015';
		settingATC.Fiscal_Year__c = 2015;
		/*settingATC.Cap_Factor__c = 6;*/
		settingATC.Floor_Cap_Factor__c = 4;   /*Change made by Suhas*/
        settingATC.Ceiling_Cap_Factor__c = 6; /*Change made by Suhas*/
		settingATC.LH_Rate__c = 6;
		settingATC.PPM_Rate__c = 6;
		settingATC.Program__c = 'All Things Considered';
		lstCustomSetting.add(settingATC);
		insert lstCustomSetting;
    	
    	
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
        
        Account objTestAccount = new Account();
        objTestAccount.Name = 'TestStation';
        objTestAccount.TSR__c = 10;
        objTestAccount.Minority_Status__c = 'Rural Station';
        insert objTestAccount;
        
        FY_Pricing_Detail__c objTestFyPricingDetail = new FY_Pricing_Detail__c();
        objTestFyPricingDetail.Station__c = objTestAccount.Id;
        objTestFyPricingDetail.Fiscal_Year__c = '2015';
        objTestFyPricingDetail.ATC_Last_FY_Price__c = 100;        /*Change made by Suhas*/
        objTestFyPricingDetail.ATC_Ceiling_Cap_Factor__c = 10.0;  /*Change made by Suhas*/
        objTestFyPricingDetail.ATC_Floor_Cap_Factor__c = 4.0;     /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Ceiling_Cap_Factor__c = 10.0;   /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Floor_Cap_Factor__c = 4.0;      /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Last_FY_Price__c = 200;         /*Change made by Suhas*/
        objTestFyPricingDetail.ATC_Capped_Price__c  = 1;          /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Capped_Price__c = 1;            /*Change made by Suhas*/
        insert objTestFyPricingDetail;
                       
        Apexpages.Standardcontroller testStdCtrl = new Apexpages.Standardcontroller(objTestFyPricingDetail);
        
        NewFyPricingDetailController objCtrl = new NewFyPricingDetailController(testStdCtrl);                              
        objCtrl.callDefaultValue();
        Test.startTest();
            
            Pagereference testPageRef = objCtrl.savePricingDetail();                                              
            
            Pagereference expectedPageRef = Page.FyPricingDetailView;
            expectedPageRef.getParameters().put('Id', objCtrl.objFyPricingDetail.Id);
            
            System.assertEquals(testPageRef.getUrl(), expectedPageRef.getUrl());
        Test.stopTest();
    }
    
    //Method to test the click of Cancel in 'New' mode
    public static testMethod void newPricingDetailCancelTest(){
    	
        
        FY_Pricing_Detail__c objTestFyPricingDetail = new FY_Pricing_Detail__c();
        Apexpages.Standardcontroller testStdCtrl = new Apexpages.Standardcontroller(objTestFyPricingDetail);
        
        NewFyPricingDetailController objCtrl = new NewFyPricingDetailController(testStdCtrl);                              
        
        Test.startTest();
            
            Pagereference testPageRef = objCtrl.cancel();                                           
            
            Pagereference expectedPageRef = Page.FyPricingDetailView;
            expectedPageRef.getParameters().put('Id', objCtrl.objFyPricingDetail.Id);
            
            System.assertEquals(testPageRef.getUrl(), '/a0Z/o');
        Test.stopTest();
    }
    
    //Method to test the click of Cancel in 'Edit' mode
    public static testMethod void editPricingDetailCancelTest(){
        
        //Create Custom Setting Record
        List<News_Mag_Settings__c> lstCustomSetting = new List<News_Mag_Settings__c>();
        List<News_Mag_Level__c> lstNewsMagLevel  = new List<News_Mag_Level__c>();
       
        News_Mag_Settings__c setting = new News_Mag_Settings__c();
        setting.Name= 'Test ME 2015';
		setting.Fiscal_Year__c = 2015;
		/*setting.Cap_Factor__c = 6;*/
		setting.Floor_Cap_Factor__c = 4;   /*Change made by Suhas*/
        setting.Ceiling_Cap_Factor__c = 6; /*Change made by Suhas*/
		setting.LH_Rate__c = 6;
		setting.PPM_Rate__c = 6;
		setting.Program__c = 'Morning Edition';
		lstCustomSetting.add(setting);
		
		News_Mag_Settings__c settingATC = new News_Mag_Settings__c();
        settingATC.Name= 'Test ATC 2015';
		settingATC.Fiscal_Year__c = 2015;
		/*settingATC.Cap_Factor__c = 6;*/
		settingATC.Floor_Cap_Factor__c = 4;   /*Change made by Suhas*/
        settingATC.Ceiling_Cap_Factor__c = 6; /*Change made by Suhas*/
		settingATC.LH_Rate__c = 6;
		settingATC.PPM_Rate__c = 6;
		settingATC.Program__c = 'All Things Considered';
		lstCustomSetting.add(settingATC);
		insert lstCustomSetting;
        
        
        Account objTestAccount = new Account();
        objTestAccount.Name = 'TestStation';
        objTestAccount.TSR__c = 10;
        insert objTestAccount;
        
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
        
        FY_Pricing_Detail__c objTestFyPricingDetail = new FY_Pricing_Detail__c();
        objTestFyPricingDetail.Station__c = objTestAccount.Id;
        objTestFyPricingDetail.Fiscal_Year__c = '2015';
        objTestFyPricingDetail.ATC_Last_FY_Price__c = 100;        /*Change made by Suhas*/
        objTestFyPricingDetail.ATC_Ceiling_Cap_Factor__c = 10.0;  /*Change made by Suhas*/
        objTestFyPricingDetail.ATC_Floor_Cap_Factor__c = 4.0;     /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Ceiling_Cap_Factor__c = 10.0;   /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Floor_Cap_Factor__c = 4.0;      /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Last_FY_Price__c = 200;         /*Change made by Suhas*/
        objTestFyPricingDetail.ATC_Capped_Price__c  = 1;          /*Change made by Suhas*/
        objTestFyPricingDetail.ME_Capped_Price__c = 1;            /*Change made by Suhas*/
        insert objTestFyPricingDetail;
                       
        Apexpages.Standardcontroller testStdCtrl = new Apexpages.Standardcontroller(objTestFyPricingDetail);
        
        NewFyPricingDetailController objCtrl = new NewFyPricingDetailController(testStdCtrl);                              
        
        Test.startTest();
            
            Pagereference testPageRef = objCtrl.cancel();                                              
            
            Pagereference expectedPageRef = Page.FyPricingDetailView;
            expectedPageRef.getParameters().put('Id', objCtrl.objFyPricingDetail.Id);
            
            System.assertEquals(testPageRef.getUrl(), expectedPageRef.getUrl());
        Test.stopTest();
    }
}