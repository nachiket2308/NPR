/*
    Revision History:
    
    Version     Version Author     Date           Comments
    1.0         Gaurav  Kakariya   29/04/2014     To Show FY Pricing Detail Record on FyPricingDetailView Page
    
*/

public with sharing class FyPricingDetailViewController {
    
    //Private
    private Integer intFiscalYear;
    private static final string STR_ME_PRGRAM = 'Morning Edition';
    private static final string STR_ATC_PRGRAM = 'All Things Considered';
    
    //public
    public Integer strPreviousFiscalYear {get; set;}
    public Integer strNextPreviousFiscalYear {get; set;}
    public FY_Pricing_Detail__c objFyPricingDetail {get; set;}
    public News_Mag_Level__c objMENewsMagLevel {get; set;}
    public News_Mag_Level__c objATCNewsMagLevel {get; set;}
    public News_Mag_Settings__c objMENewsMagSetting {get; set;}
    public News_Mag_Settings__c objATCNewsMagSetting {get; set;}
    public Boolean isMEError {get; set;}
    public Boolean isATCError {get; set;}
    
    //Constructor
    public FyPricingDetailViewController(ApexPages.StandardController objStdController){
        
        //Get Fiscal Year Pricing Record
        objFyPricingDetail = new FY_Pricing_Detail__c();
        objFyPricingDetail.Id = objStdController.getId();
        system.debug('*********111objFyPricingDetail'+objFyPricingDetail.Id);
        objFyPricingDetail = getFyPricingDetailRecord(objFyPricingDetail.Id);
        system.debug('*********objFyPricingDetail'+objFyPricingDetail.ME_Last_FY_Price__c);
        objMENewsMagSetting =  new News_Mag_Settings__c();
        objATCNewsMagSetting =  new News_Mag_Settings__c();
        objATCNewsMagLevel = new News_Mag_Level__c();
        objMENewsMagLevel = new News_Mag_Level__c();
        isMEError = false;
        isATCError = false;

        //Calculate Previous Fiscal Year
        if(objFyPricingDetail != null && objFyPricingDetail.Fiscal_Year__c != null 
            && objFyPricingDetail.Fiscal_Year__c != '' )
        {
            intFiscalYear = Integer.valueOf(objFyPricingDetail.Fiscal_Year__c);
            strPreviousFiscalYear = Integer.valueOf(objFyPricingDetail.Fiscal_Year__c);
            strPreviousFiscalYear  = strPreviousFiscalYear -2;
            
            strNextPreviousFiscalYear = Integer.valueOf(objFyPricingDetail.Fiscal_Year__c);
            strNextPreviousFiscalYear  = strNextPreviousFiscalYear -3;
        }
        getCustomSettingRecords(); /*Change made by Suhas*/
    }
    
    //Get all the FY Pricind Detail Record
    public Static FY_Pricing_Detail__c getFyPricingDetailRecord(Id FyPricingDetailId){
        
    List<FY_Pricing_Detail__c> lstFyPricingDetail = [Select Id, 
                                                            TSR__c, 
                                                            TSR_Level__c, 
                                                            SystemModstamp, 
                                                            Station__c, 
                                                            Name, 
                                                            ME_Will_Not_Purchase_News_Mag__c, 
                                                            ME_Uncapped_Price__c, 
                                                            ME_Total_of_Fiscal_Periods__c, 
                                                            ME_Rate_Sum_Last_Period__c, 
                                                            ME_Rate_Sum_4th_Recent__c, 
                                                            ME_Rate_Sum_3rd_Recent__c, 
                                                            ME_Rate_Sum_2nd_Recent__c, ME_PPM_Rate__c, 
                                                            ME_PPM_Rate_Calc_Last__c, ME_PPM_Rate_Calc_4th_Recent__c, 
                                                            ME_PPM_Rate_Calc_3rd_Recent__c, 
                                                            ME_PPM_Rate_Calc_2nd_Recent__c, ME_PPM_Last_Period__c, 
                                                            ME_PPM_4th_Recent__c, ME_PPM_3rd_Recent__c, 
                                                            ME_PPM_2nd_Recent__c, ME_No_Listener_Hour_Data__c, 
                                                            ME_News_Mag_Pricing_Status__c, 
                                                            ME_Last_FY_Price__c, ME_LH_Rate__c, 
                                                            ME_LH_Rate_Calc_Last__c, ME_LH_Rate_Calc_4th_Recent__c, 
                                                            ME_LH_Rate_Calc_3rd_Recent__c, 
                                                            ME_LH_Rate_Calc_2nd_Recent__c, 
                                                            ME_LH_Last_Period__c, ME_LH_4th_Recent__c, 
                                                            ME_LH_3rd_Recent__c, 
                                                            ME_LH_2nd_Recent__c, 
                                                            ME_Capped_Price__c, 
                                                            /*ME_Cap_Factor__c,*/
                                                            ME_Ceiling_Cap_Factor__c, ME_Floor_Cap_Factor__c, /*Change made by Suhas*/ 
                                                            ME_Base_Price__c, ME_Average_of_Fiscal_Periods__c, 
                                                            LastModifiedDate, 
                                                            LastModifiedById, 
                                                            LastActivityDate, IsDeleted, 
                                                            Fiscal_Year__c, 
                                                            CreatedDate, 
                                                            CreatedById, 
                                                            ATC_Will_Not_Purchase_News_Mag__c, 
                                                            ATC_Uncapped_Price__c, ATC_Total_of_Fiscal_Periods__c, 
                                                            ATC_Rate_Sum_Last_Period__c, 
                                                            ATC_Rate_Sum_4th_Recent__c, ATC_Rate_Sum_3rd_Recent__c, 
                                                            ATC_Rate_Sum_2nd_Recent__c, ATC_PPM_Rate__c, 
                                                            ATC_PPM_Rate_Calc_Last__c, 
                                                            ATC_PPM_Rate_Calc_4th_Recent__c, 
                                                            ATC_PPM_Rate_Calc_3rd_Recent__c, 
                                                            ATC_PPM_Rate_Calc_2nd_Recent__c, ATC_PPM_Last_Period__c, 
                                                            ATC_PPM_4th_Recent__c, 
                                                            ATC_PPM_3rd_Recent__c, ATC_PPM_2nd_Recent__c, 
                                                            ATC_No_Listener_Hour_Data__c, ATC_News_Mag_Pricing_Status__c, 
                                                            ATC_Last_FY_Price__c, 
                                                            ATC_LH_Rate__c, ATC_LH_Rate_Calc_Last__c, 
                                                            ATC_LH_Rate_Calc_4th_Recent__c, ATC_LH_Rate_Calc_3rd_Recent__c, 
                                                            ATC_LH_Rate_Calc_2nd_Recent__c, 
                                                            ATC_LH_Last_Period__c, ATC_LH_4th_Recent__c, 
                                                            ATC_LH_3rd_Recent__c, ATC_LH_2nd_Recent__c, 
                                                            ATC_Capped_Price__c, 
                                                            /*ATC_Cap_Factor__c,*/
                                                            ATC_Ceiling_Cap_Factor__c, ATC_Floor_Cap_Factor__c,/*Change made by Suhas*/ 
                                                            ATC_Base_Price__c, 
                                                            ATC_Average_of_Fiscal_Periods__c,
                                                            Discount_Type__c,
                                                            ATC_Cap_Factor_Used__c,
                                                            ME_Cap_Factor_Used__c
                                                    From FY_Pricing_Detail__c 
                                                    Where Id =: FyPricingDetailId]; 
                                                    // LastViewedDate, LastReferencedDate, 
                                                    
        if(!lstFyPricingDetail.isEmpty())
            return lstFyPricingDetail[0];
        else
            return null;    
    }

    
    //OnClick of Edit button -Redirect to Edit page FyPricing Detail Record 
    public pageReference callEditFyPricingDetail(){

        Pagereference objPageReference = Page.NewFyPricingDetail;
        String idFromURL = ApexPages.currentPage().getParameters().get('id');
        if(idFromURL == null || idFromURL == '')
        {
            return objPageReference;
        }
        if(objFyPricingDetail.Id != null )
            objPageReference.getParameters().put('id', objFyPricingDetail.Id);
        return objPageReference;
        
    }

    /*Added by Suhas on 06/25/2015 */
    //Get the records from the custom setting and populate the objATCNewsMagSetting and objMENewsMagSetting object
    //for displaying the Ceiling cap factor and floor cap factor on page.
    public Map<String,News_Mag_Settings__c> getCustomSettingRecords() {
        Map<String,News_Mag_Settings__c> mapNameToNewMagSettings = News_Mag_Settings__c.getAll();
        system.debug('mapNameToNewMagSettings in get records===>>> '+mapNameToNewMagSettings);
        if(!mapNameToNewMagSettings.isEmpty()) {
            for(News_Mag_Settings__c objNewsMagSetting : mapNameToNewMagSettings.values()){
                if(objNewsMagSetting.Program__c.equalsIgnoreCase(STR_ATC_PRGRAM)
                    && objNewsMagSetting.Fiscal_Year__c == intFiscalYear) {
                        objATCNewsMagSetting = objNewsMagSetting; 
                        system.debug('objATCNewsMagSetting===>> '+objATCNewsMagSetting);
                }
                if(objNewsMagSetting.Program__c.equalsIgnoreCase(STR_ME_PRGRAM)
                    && objNewsMagSetting.Fiscal_Year__c == intFiscalYear) {
                    objMENewsMagSetting = objNewsMagSetting; 
                    system.debug('objMENewsMagSetting====>>> '+objMENewsMagSetting);
                }
            }
        }
        return mapNameToNewMagSettings;
    }
    /*Code ends here*/

    //Get Custom setting values for ME and All Thing Considered Edition
    public PageReference getFyPricingRateValuesFromCustomSetting(){
        
        isATCError = false;
        isMEError = false;
        
        //Get record from Custom Setting 
        //Map<String,News_Mag_Settings__c> mapNameToNewMagSettings = News_Mag_Settings__c.getAll();   
        Map<String,News_Mag_Settings__c> mapNameToNewMagSettings = getCustomSettingRecords();   /*Change made by Suhas*/
        system.debug('mapNameToNewMagSettings===>>> '+mapNameToNewMagSettings);

        if(!mapNameToNewMagSettings.isEmpty()){
            for(News_Mag_Settings__c objNewsMagSetting : mapNameToNewMagSettings.values()){
                
                //Compare All Time Edition value with Custom Setting fiscal Year
                if(objNewsMagSetting.Program__c.equalsIgnoreCase(STR_ATC_PRGRAM)
                    && objNewsMagSetting.Fiscal_Year__c == intFiscalYear){
                
                    objFyPricingDetail.ATC_PPM_Rate__c = objNewsMagSetting.PPM_Rate__c;
                    objFyPricingDetail.ATC_LH_Rate__c = objNewsMagSetting.LH_Rate__c;   
                    //objFyPricingDetail.ATC_Cap_Factor__c = objNewsMagSetting.Cap_Factor__c;
                    objFyPricingDetail.ATC_Ceiling_Cap_Factor__c = objNewsMagSetting.Ceiling_Cap_Factor__c; /*Changes made by Suhas*/
                    objFyPricingDetail.ATC_Floor_Cap_Factor__c = objNewsMagSetting.Floor_Cap_Factor__c;     /*Changes made by Suhas*/
                    
                    objATCNewsMagLevel = getNewsMagLevel(STR_ATC_PRGRAM);
                    if(objATCNewsMagLevel!= null){
                        if(objATCNewsMagLevel.Rate__c == null){
                            isATCError = true;
                        }   
                        objFyPricingDetail.ATC_Base_Price__c = objATCNewsMagLevel.Rate__c;
                    }
                    
                }
                //Compare Morning Edition value with Custom Setting fiscal Year
                if(objNewsMagSetting.Program__c.equalsIgnoreCase(STR_ME_PRGRAM)
                    && objNewsMagSetting.Fiscal_Year__c == intFiscalYear){
            
                    objFyPricingDetail.ME_PPM_Rate__c = objNewsMagSetting.PPM_Rate__c;
                    objFyPricingDetail.ME_LH_Rate__c = objNewsMagSetting.LH_Rate__c;    
                    //objFyPricingDetail.ME_Cap_Factor__c = objNewsMagSetting.Cap_Factor__c;
                    objFyPricingDetail.ME_Ceiling_Cap_Factor__c = objNewsMagSetting.Ceiling_Cap_Factor__c; /*Changes made by Suhas*/
                    objFyPricingDetail.ME_Floor_Cap_Factor__c = objNewsMagSetting.Floor_Cap_Factor__c; /*Changes made by Suhas*/
                    objMENewsMagLevel = getNewsMagLevel(STR_ME_PRGRAM);
                    if(objMENewsMagLevel!= null){
                        if(objMENewsMagLevel.Rate__c == null){
                            isMEError = true;
                        }
                        
                        objFyPricingDetail.ME_Base_Price__c = objMENewsMagLevel.Rate__c;
                    }
                }
            }   
            if(isMEError == true || isATCError == true){
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                    Label.npr_BasePriceError));
                return null;
            }   
        }   
        else{
                    objFyPricingDetail.ATC_PPM_Rate__c = 0;
                    objFyPricingDetail.ATC_LH_Rate__c = 0;  
                    //objFyPricingDetail.ATC_Cap_Factor__c = 0;
                    objFyPricingDetail.ATC_Ceiling_Cap_Factor__c = 0;   /*Changes made by Suhas*/
                    objFyPricingDetail.ATC_Floor_Cap_Factor__c = 0;     /*Changes made by Suhas*/
                    objFyPricingDetail.ATC_Base_Price__c = 0;
                    objFyPricingDetail.ME_PPM_Rate__c = 0;
                    objFyPricingDetail.ME_LH_Rate__c = 0;   
                    //objFyPricingDetail.ME_Cap_Factor__c = 0;
                    objFyPricingDetail.ME_Ceiling_Cap_Factor__c =0;     /*Changes made by Suhas*/
                    objFyPricingDetail.ME_Floor_Cap_Factor__c = 0;      /*Changes made by Suhas*/
                    objFyPricingDetail.ME_Base_Price__c= 0;
                    
        }
        update objFyPricingDetail;
        objFyPricingDetail= getFyPricingDetailRecord(objFyPricingDetail.Id);
        return null;
    }
    
    //OnClick of Refresh button - Update the value of FyPricing Detail Record as per Fiscal Year
    public PageReference refreshFyPricingDetailValues(){
        
        //Calculate Previous Fiscal Year
        if(objFyPricingDetail != null && objFyPricingDetail.Fiscal_Year__c != null 
            && objFyPricingDetail.Fiscal_Year__c != '' ){
            getFyPricingRateValuesFromCustomSetting();
        }
        
       return null;                                   
    }
    
    //Get News Mag Level Record from Fiscal Year and Program condition
    public News_Mag_Level__c getNewsMagLevel(String strProgram){
       
        List<News_Mag_Level__c> lstNewsMagLevel;
        if(objFyPricingDetail.TSR__c != null && strProgram != null 
            && strProgram != '' && intFiscalYear != null){
            
            lstNewsMagLevel  = [Select Rate__c 
                                From  News_Mag_Level__c 
                                Where (Fiscal_Year__c =: intFiscalYear
                                AND   Program__c =: strProgram
                                AND   Upper_Limit__c >=: objFyPricingDetail.TSR__c 
                                AND   Lower_Limit__c <=: objFyPricingDetail.TSR__c) 
                                order by LastModifiedDate Desc 
                                limit 1 ];
         }     
         if(!lstNewsMagLevel.isEmpty()){                                     
              return lstNewsMagLevel[0];
         }  
        
           
         return null;
    }
    
}//End FyPricingDetailViewController