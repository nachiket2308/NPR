/** 
*  A handler class for the FyPricingDetailTrigger which controls the functionality of the
* FieldPricing   DetailTrigger 
*
*
*   Initial Draft         Author            Date
*   Version 1.0           Gaurav            5/2/2014
**/
public with sharing class FyPricingDetailTriggerHandlerHelper {
    // final variables
    private static final String MORNING_EDITION = 'Morning Edition';
    private static final String ALL_THINGS_CONSIDERED = 'All Things Considered';
    
     //Get record from Custom Setting 
     Map<String,News_Mag_Settings__c> mapNameToNewMagSettings = News_Mag_Settings__c.getAll();
        
    /** 
    * A method that returns the  list<News_Mag_Level__c> to the handler methods only 
    * when the size of the list is greater than zero.
    **/
    public List<News_Mag_Level__c> getAssociatedNewsMagLevelforMorningEdition(Set<Integer> pSetCurrentFiscalYear, Decimal tsrLow, Decimal tsrHigh){
        List<News_Mag_Level__c> listNewsMagLevel = [Select Id,
                                                           Upper_Limit__c ,
                                                           Lower_Limit__c, 
                                                           Fiscal_Year__c,
                                                           Program__c,Rate__c 
                                                    From News_Mag_Level__c
                                                    Where Program__c =: MORNING_EDITION AND
                                                    Fiscal_Year__c IN: pSetCurrentFiscalYear AND
                                                    Upper_Limit__c >=: tsrHigh AND
                                                    Lower_Limit__c <=: tsrLow 
                                                    Order by LastModifiedDate Desc];
        if(!listNewsMagLevel.isEmpty()){
            return listNewsMagLevel;
        }
        
        return null;
    }
    /** 
    * A method that returns the  list<News_Mag_Settings__c> to the handler methods only 
    * when the size of the list is greater than zero.
    **/
    public List<News_Mag_Settings__c> getNewMagSettingsRecforMorningEdition(Set<Integer> pSetCurrentFiscalYear){
        
        List<News_Mag_Settings__c> lstNewsMapSettings = new List<News_Mag_Settings__c>();
        if(!mapNameToNewMagSettings.isEmpty()){
                
            for(News_Mag_Settings__c objNewsMagSetting : mapNameToNewMagSettings.values()){ 
                
                //Compare Morning Edition value with Custom Setting fiscal Year
                if(objNewsMagSetting.Program__c.equalsIgnoreCase(MORNING_EDITION)
                    && pSetCurrentFiscalYear.contains(Integer.valueOf(objNewsMagSetting.Fiscal_Year__c)))
               	{
                    lstNewsMapSettings.add(objNewsMagSetting);
                } 
            }
        }
        
        if(!lstNewsMapSettings.isEmpty()){
            return lstNewsMapSettings;
        }
        return null;
    }
    
    /** 
    * A method that returns the  list<News_Mag_Level__c> with the records having the program__c field as
    * "All things considered" to the handler methods only when the size of the list is greater than zero.
    **/
    public List<News_Mag_Level__c> getAssociatedNewsMagLevelAllThingsConsidered(Set<Integer> pSetCurrentFiscalYear, Decimal tsrLow, Decimal tsrHigh){
        List<News_Mag_Level__c> listNewsMagLevelThingsConsidered = [Select Id,
                                                                           Upper_Limit__c,
                                                                           Lower_Limit__c, 
                                                                           Fiscal_Year__c,
                                                                           Program__c,Rate__c 
                                                                    From News_Mag_Level__c
                                                                    Where Program__c =:ALL_THINGS_CONSIDERED
                                                                    AND Fiscal_Year__c IN: pSetCurrentFiscalYear
                                                                    AND Upper_Limit__c >=: tsrHigh 
                                                                    AND Lower_Limit__c <=: tsrLow
                                                                    Order by LastModifiedDate Desc];
        if(!listNewsMagLevelThingsConsidered.isEmpty()){
            return listNewsMagLevelThingsConsidered;
        }
        
        return null;
    } 

    /** 
    * A method that returns the  list<News_Mag_Settings__c> with the records having the program__c field as
    * "All things considered" to the handler methods only when the size of the list is greater than zero.
    **/
    public List<News_Mag_Settings__c> getNewMagSettingsThingsConsidered(Set<Integer> pSetCurrentFiscalYear){
        
        List<News_Mag_Settings__c> lstNewsMapSettingAllThingsConsidered = new List<News_Mag_Settings__c>();
        if(!mapNameToNewMagSettings.isEmpty()){
                
            for(News_Mag_Settings__c objNewsMagSetting : mapNameToNewMagSettings.values()){
                
                //Compare All Time Edition value with Custom Setting fiscal Year
                if(objNewsMagSetting.Program__c.equalsIgnoreCase(ALL_THINGS_CONSIDERED)
                    && pSetCurrentFiscalYear.contains(Integer.valueOf(objNewsMagSetting.Fiscal_Year__c))){
                
                    lstNewsMapSettingAllThingsConsidered.add(objNewsMagSetting);
                }
            }
        }   
        if(!lstNewsMapSettingAllThingsConsidered.isEmpty()){
            return lstNewsMapSettingAllThingsConsidered;
        }
        
        return null;
    }
    
    /** 
    * A method that returns the  list<FY_Pricing_Detail__c>   to the handler methods only 
    * when the size of the list is greater than zero.
    **/
    
    public List<FY_Pricing_Detail__c> getFYPricingDetials(Set<String> pSetFiscalYear, Set<Id> pSetStations){
        
        List<FY_Pricing_Detail__c> listFyPricingDetails = [Select ME_Capped_Price__c,
                                                                  ATC_Capped_Price__c,
                                                                  Station__c,
                                                                  Station__r.Minority_Status__c,
                                                                  Discount_Percentage__c,
                                                                  Station__r.TSR__c,
                                                                  ATC_Last_FY_Price__c,
                                                                  ME_Last_FY_Price__c,
                                                                  ATC_Cap_Factor_Used__c,
                                                                  ME_Cap_Factor_Used__c          
                                                           From FY_Pricing_Detail__c 
                                                           Where Fiscal_Year__c IN: pSetFiscalYear
                                                           AND Station__c IN: pSetStations
                                                           order by LastModifiedDate 
                                                           Desc limit 1];
                                                           
        if(!listFyPricingDetails.isEmpty()){
            return listFyPricingDetails;
        }
        return null;
    }
    
    //Method retrives the details of FY Pricing Detail record under context
    public list<FY_Pricing_Detail__c> getFyPricingDetailRecord(Set<Id> setFyPricingDetailId){               
        
        List<FY_Pricing_Detail__c> fyPricingDetailList = [Select Id,
                                                                 Station__r.TSR__c,
                                                                 Station__r.Minority_Status__c,
                                                                 TSR__c, 
                                                                 TSR_Level__c, 
                                                                 SystemModstamp, 
                                                                 Station__c, 
                                                                 Name, 
                                                                 Discount_Percentage__c ,
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
                                                                 /*ME_Cap_Factor__c, */
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
                                                                 /*ATC_Cap_Factor__c, */
                                                                 ATC_Ceiling_Cap_Factor__c, ATC_Floor_Cap_Factor__c, /*Change made by Suhas*/
                                                                 ATC_Base_Price__c, 
                                                                 ATC_Average_of_Fiscal_Periods__c,
                                                                 Total_Uncapped_Price__c,
                                                                 Last_FY_Total_Fees__c,
                                                                 ATC_Ratio__c,
                                                                 ME_Ratio__c,
                                                                 ATC_Cap_Factor_Used__c,
                                                                 ME_Cap_Factor_Used__c      
                                                          from FY_Pricing_Detail__c 
                                                          where Id IN: setFyPricingDetailId];
                                                          // LastViewedDate, LastReferencedDate, 
        
        if(!fyPricingDetailList.isEmpty()){
           return fyPricingDetailList;
        }
        return null;
    }

    //Get the Tsr Level value from Pricing_Tier__c object
    public List<Pricing_Tier__c> getTsrLevelValue(Set<Integer> setTsrValue){
        
        List<Pricing_Tier__c> lstPricingTierNew = new List<Pricing_Tier__c>();
        if(setTsrValue != null && !setTsrValue.isEmpty()){
            List<Pricing_Tier__c> lstPricingTier = [ Select Tier__c ,
                                                            TSR_High__c ,
                                                            TSR_Low__c,
                                                            Type__c
                                                     From Pricing_Tier__c 
                                                     Where Type__c = 'PPF'
                                                     order by LastModifiedDate 
                                                     Desc
                                                   ];
             if(lstPricingTier !=null && !lstPricingTier.isEmpty()){
                
                for(Pricing_Tier__c objPricingTier : lstPricingTier){
                    for(Integer intTsrValue : setTsrValue){
                        if(intTsrValue <= objPricingTier.TSR_High__c 
                            && intTsrValue >= objPricingTier.TSR_Low__c){ 
                                
                          lstPricingTierNew.add(objPricingTier);    
                          break;
                        } 
                         
                    }
                }
                return lstPricingTierNew;
             }      
        }
        return null;                          
    }
    
    //Get the Tsr Value from Account
    public List<Account> getAccountTSRValue(Set<Id> setStationId){
        
        List<Account> lstAccount = [ Select Id,
                                            TSR__c,
                                            Minority_Status__c
                                     From Account 
                                     Where Id IN: setStationId
                                    ];
        if(!lstAccount.isEmpty()){
            return lstAccount;
        }
        return null;
                              
    }
    
    //Get the Tsr Value from specific Account
    public double getAccountTSRValue(String stationId)
    {
        List<Account> lstAccount = [ Select Id,
                                            TSR__c
                                     From Account 
                                     Where Id =: stationId
                                    ];
        if(!lstAccount.isEmpty() && lstAccount[0].TSR__c!=null)
        {
            return lstAccount[0].TSR__c;
        }
        return null;
                              
    }
    
    //Get the Discounts Percent value from Discounts__c object
    public List<Discounts__c> getDiscountsPercentValue(Set<String> setFiscalYear, Set<String> setDiscountType){
        
        if(setFiscalYear != null && setDiscountType != null
            && !setDiscountType.isEmpty() && !setFiscalYear.isEmpty()){
        
            List<Discounts__c> lstDiscount = [ SELECT Discount_Percent__c
                                               FROM Discounts__c
                                               WHERE Fiscal_Year__c IN: setFiscalYear 
                                               AND Discount_Type__c IN: setDiscountType 
                                               AND News_Non_News__c = 'News'
                                             ];
                                                   
             if(lstDiscount !=null && !lstDiscount.isEmpty()){
               return lstDiscount;
            }   
        }   
        return null;                                 
    }
    
}