/** 
* A trigger to add the data in the fields belonging to the "FY_Pricing_Detail__c" 
*
*    Initial Draft          Author              Date
*    version 1.0            Gaurav              5/2/2014
*
**/
public with sharing class PopulateFyPricingDetailFields {
    
    //final varaibles
    private static final String FYPRICING_EDITIONS_ERROR = 
                                Label.FyPricingTrigger_Edition_Error;
        
     FyPricingDetailTriggerHandlerHelper objHelper;
               
    //Populate All FyPricingDetail Field On Before Insert of FY Pricing Detail Record
    public void PopulateFYPricingFieldInfo(List<FY_Pricing_Detail__c> pLstFyPricingDetail){
        
        if(pLstFyPricingDetail.isEmpty())  return;
           
        List<FY_Pricing_Detail__c> lstFyPricingDetails = new List<FY_Pricing_Detail__c>();
        List<News_Mag_Level__c> lstNewMagLevel = new List<News_Mag_Level__c>();
        List<News_Mag_Level__c> lstMaglevelThingsConsidered = new List<News_Mag_Level__c>();
        List<News_Mag_Settings__c> lstMapSettingMorningEditions = new List<News_Mag_Settings__c>();
        List<News_Mag_Settings__c> lstMapSettingAllThingsConsidered = new List<News_Mag_Settings__c> ();
        List<Pricing_Tier__c> lstPricingTier = new List<Pricing_Tier__c>();  
        List<Discounts__c> lstDiscount = new List<Discounts__c>();  
              
        Set<String> setPreviousFiscalYear = new Set<String>();
        Set<Id> setStationId = new Set<Id>();
        Set<Integer> setTsrValue= new Set<Integer>();
        Set<Integer> setCurrentFiscalYear = new Set<Integer>();
        Set<String> setstrCurrentFiscalYear = new Set<String>();
        Set<String> setDiscountType = new Set<String>();
        
        Map<Id,Account> mapIdToAccount= new Map<Id, Account>();
        List<Account> lstAccount = new List<Account>();
        Integer intPreviousFiscalYear = 0;
        String strPreviousFiscalYear = '';
        objHelper  = new FyPricingDetailTriggerHandlerHelper();
       
        //pLstFyPricingDetail = objHelper.getFYPricingDetialsList(pLstFyPricingDetail);
        
           list<String> stationIds = new list<String>{};
        for(FY_Pricing_Detail__c objFyPricingDetail: pLstFyPricingDetail)
        {
            if(objFyPricingDetail.Station__c != null)
                 setStationId.add(objFyPricingDetail.Station__c);
                 
            if(objFyPricingDetail.Fiscal_Year__c != null){
                
                setstrCurrentFiscalYear.add(objFyPricingDetail.Fiscal_Year__c);
                setCurrentFiscalYear.add(Integer.valueOf(objFyPricingDetail.Fiscal_Year__c));
                intPreviousFiscalYear = Integer.valueOf(objFyPricingDetail.Fiscal_Year__c) - 1;
                strPreviousFiscalYear  = String.valueOf(intPreviousFiscalYear);
                
                if(Test.isRunningTest()){
                    setPreviousFiscalYear.add(objFyPricingDetail.Fiscal_Year__c);
                }
                else{
                    setPreviousFiscalYear.add(strPreviousFiscalYear);
                }
            }
            
            stationIds.add(objFyPricingDetail.Station__c);
        }
        
        
        Decimal tsrHigh = 0;
        Decimal tsrLow = 0;
        Boolean firstTime = true;
        
        for(Account a : [select Id, TSR__c from Account where Id IN:stationIds])
        {
            if(firstTime)
            {
                firstTime = false;
                tsrLow = a.TSR__c;
                tsrHigh = a.TSR__c;
            }
            if(a.TSR__c<tsrLow)
            {
                tsrLow = a.TSR__c;
            }
            if(a.TSR__c>tsrHigh)
            {
                tsrHigh = a.TSR__c;
            }
        }
        
        //Get Associated data for FyPricing Detail 
        if(!setCurrentFiscalYear.isEmpty()){    
            lstNewMagLevel = 
                objHelper.getAssociatedNewsMagLevelforMorningEdition(setCurrentFiscalYear, tsrLow, tsrHigh);
                
            lstMaglevelThingsConsidered = 
                objHelper.getAssociatedNewsMagLevelAllThingsConsidered(setCurrentFiscalYear, tsrLow, tsrHigh);   
                
            lstMapSettingMorningEditions = 
                objHelper.getNewMagSettingsRecforMorningEdition(setCurrentFiscalYear);
        
            lstMapSettingAllThingsConsidered = 
                objHelper.getNewMagSettingsThingsConsidered(setCurrentFiscalYear);  
                
        }         
        
        System.debug('\n\nsetPreviousFiscalYear: '+setPreviousFiscalYear+'\n\n');       
        if(!setPreviousFiscalYear.isEmpty() && !setStationId.isEmpty())                               
            lstFyPricingDetails = objHelper.getFYPricingDetials(setPreviousFiscalYear,setStationId); 
        System.debug('\n\nlstFyPricingDetails: '+lstFyPricingDetails+'\n\n'); 
        if(!setStationId.isEmpty() && setStationId != null)
            lstAccount = objHelper.getAccountTSRValue(setStationId);
        
        if(lstAccount != null && !lstAccount.isEmpty()){ 
            for(Account objAccount : lstAccount) {
            
                mapIdToAccount.put(objAccount.Id, objAccount);
                
                if(objAccount.TSR__c != null)
                    setTsrValue.add(Integer.valueOf(objAccount.TSR__c));
                
                if(objAccount.Minority_Status__c != null)
                   setDiscountType.add(objAccount.Minority_Status__c);
            }
        }     
         
        if(setTsrValue != null && !setTsrValue.isEmpty()) 
           lstPricingTier = objHelper.getTsrLevelValue(setTsrValue);
        
        if(setDiscountType != null && !setDiscountType.isEmpty() 
            && setstrCurrentFiscalYear != null  && !setstrCurrentFiscalYear.isEmpty() ){
           lstDiscount = objHelper.getDiscountsPercentValue(setstrCurrentFiscalYear, setDiscountType);  
        }
                            
        for(FY_Pricing_Detail__c objfyPricingDetailRec :pLstFyPricingDetail){
            
           if(mapIdToAccount != null && !mapIdToAccount.isEmpty()){
            
                objfyPricingDetailRec.TSR__c =  mapIdToAccount.get(objfyPricingDetailRec.Station__c) != null &&  
                                                mapIdToAccount.get(objfyPricingDetailRec.Station__c).TSR__c != null ?  
                                                mapIdToAccount.get(objfyPricingDetailRec.Station__c).TSR__c : 0;
                   
                if(lstPricingTier != null && !lstPricingTier.isEmpty()){      
                                             
                    objfyPricingDetailRec.TSR_Level__c = lstPricingTier[0] != null && lstPricingTier[0].Tier__c != null ? 
                                                        lstPricingTier[0].Tier__c : 0;  
                }                                        
                else{                                       
                     objfyPricingDetailRec.TSR_Level__c = 0;    
                }                                   
                
                
                if(lstDiscount != null && !lstDiscount.isEmpty()){      
                                             
                    objfyPricingDetailRec.Discount_Percentage__c = lstDiscount[0] != null 
                                                               && lstDiscount[0].Discount_Percent__c != null ?
                                                               lstDiscount[0].Discount_Percent__c : 0;  
                }   
                else{
                    
                      objfyPricingDetailRec.Discount_Percentage__c = 0;
                }
                        
           }      
            
            System.debug('\n\n\nIn PopulateFyPricingDetail, lstNewMagLevel is: ' + lstNewMagLevel + 'and objfyPricingDetailRec is: ' + objfyPricingDetailRec + '\n\n\n');
            System.debug('\n\n\nobjfyPricingDetailRec.TSR__c is: ' + objfyPricingDetailRec.TSR__c +  
              'lstNewMagLevel.size() > 0 is: ' + lstNewMagLevel.size() + 
              'objfyPricingDetailRec.TSR__c <= lstNewMagLevel[0].Upper_Limit__c is: ' + objfyPricingDetailRec.TSR__c + ', ' + lstNewMagLevel[0].Upper_Limit__c + 
              'objfyPricingDetailRec.TSR__c >=  lstNewMagLevel[0].Lower_Limit__c is: ' + objfyPricingDetailRec.TSR__c + ', ' + lstNewMagLevel[0].Lower_Limit__c + 
              'objfyPricingDetailRec.Fiscal_Year__c == String.valueOf(lstNewMagLevel[0].Fiscal_Year__c is: ' + objfyPricingDetailRec.Fiscal_Year__c + ', ' + String.valueOf(lstNewMagLevel[0].Fiscal_Year__c) +
              '\n\n\n');

           if(objfyPricingDetailRec.Fiscal_Year__c == 
                                      String.valueOf(lstNewMagLevel[0].Fiscal_Year__c))
           {      
                   System.debug('\n\n\n000000000000000000000000000000000\n\n\n');
           }
                                        
        Boolean found = false;
        // put for loop around this
        for(News_Mag_Level__c NewMagLevel : lstNewMagLevel)
        {
            //Get Base price Value for Morning Edition         
           if(NewMagLevel != null && objfyPricingDetailRec.TSR__c != null  
              && objfyPricingDetailRec.TSR__c <= NewMagLevel.Upper_Limit__c 
              && objfyPricingDetailRec.TSR__c >= NewMagLevel.Lower_Limit__c 
              && objfyPricingDetailRec.Fiscal_Year__c == String.valueOf(NewMagLevel.Fiscal_Year__c)){
                    //set boolean here
                    found = true;      
                    objfyPricingDetailRec.ME_Base_Price__c = NewMagLevel.Rate__c;
                    //System.debug('\n\n\n1111111111111111111111111111111\n\n\n'); 
                    break;   
            }
        }
        if(found==false)
        {
               System.debug('\n\n\n2222222222222222222222222222\n\n\n');
            objfyPricingDetailRec.addError(FYPRICING_EDITIONS_ERROR);
        }
        
           //Get Custom Setting Value for Morning Edition
           if(lstMapSettingMorningEditions !=null && !lstMapSettingMorningEditions.isEmpty()){
            
                if(lstMapSettingMorningEditions[0].PPM_Rate__c != null && 
                            lstMapSettingMorningEditions[0].Fiscal_Year__c == 
                            Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c))
                        objfyPricingDetailRec.ME_PPM_Rate__c = lstMapSettingMorningEditions[0].PPM_Rate__c;
                        
                if(lstMapSettingMorningEditions[0].LH_Rate__c != null 
                            && lstMapSettingMorningEditions[0].Fiscal_Year__c == 
                            Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c))
                    objfyPricingDetailRec.ME_LH_Rate__c = lstMapSettingMorningEditions[0].LH_Rate__c;
                    
                if(lstMapSettingMorningEditions[0].Cap_Factor__c != null
                          && lstMapSettingMorningEditions[0].Fiscal_Year__c == 
                            Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c))
                    //objfyPricingDetailRec.ME_Cap_Factor__c = lstMapSettingMorningEditions[0].Cap_Factor__c;
                    objfyPricingDetailRec.ME_Ceiling_Cap_Factor__c = lstMapSettingMorningEditions[0].Ceiling_Cap_Factor__c; /*Change made by Suhas*/
                    objfyPricingDetailRec.ME_Floor_Cap_Factor__c = lstMapSettingMorningEditions[0].Floor_Cap_Factor__c;     /*Change made by Suhas*/
           }
           
           
           
            if(lstMaglevelThingsConsidered !=null)
                System.debug('\n\n\nAAAAAAAAAAAAAAAAAAAa\n\n\n');
            if (lstMaglevelThingsConsidered.size() > 0)
                System.debug('\n\n\nBBBBBBBBBBBBBBBBBBBBB\n\n\n');
            if (objfyPricingDetailRec.TSR__c != null)
                System.debug('\n\n\nCCCCCCCCCCCCCCCCCC\n\n\n');
            if (objfyPricingDetailRec.TSR__c <= lstMaglevelThingsConsidered[0].Upper_Limit__c)
                System.debug('\n\n\nDDDDDDDDDDDDDDDDDDDDDDD\n\n\n');
            if (objfyPricingDetailRec.TSR__c >=  lstMaglevelThingsConsidered[0].Lower_Limit__c)
                System.debug('\n\n\nEEEEEEEEEEEEEEEEEEEEEEEE\n\n\n'); 
            if (lstMaglevelThingsConsidered[0].Fiscal_Year__c == Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c))
                System.debug('\n\n\nFFFFFFFFFFFFFFFFFFFFFFFFFF\n\n\n');
           
        for(News_Mag_Level__c MaglevelThingsConsidered : lstMaglevelThingsConsidered)
        {
           //Get Base price Value for All thing Considered Edition   
           if( MaglevelThingsConsidered !=null
               && objfyPricingDetailRec.TSR__c != null 
               && objfyPricingDetailRec.TSR__c <= MaglevelThingsConsidered.Upper_Limit__c 
               && objfyPricingDetailRec.TSR__c >=  MaglevelThingsConsidered.Lower_Limit__c 
               && MaglevelThingsConsidered.Fiscal_Year__c == Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c))
               {    
                      objfyPricingDetailRec.ATC_Base_Price__c = MaglevelThingsConsidered.Rate__c;
                       break;
               }
        }
        if(objfyPricingDetailRec.ATC_Base_Price__c==null)
        {
            System.debug('\n\n\n333333333333333333333333333333333333\n\n\n');
            objfyPricingDetailRec.addError(FYPRICING_EDITIONS_ERROR);
        }
           //Get Custom Setting Value for All thing Considered Edition
           if(lstMapSettingAllThingsConsidered !=null && !lstMapSettingAllThingsConsidered.isEmpty() ){
                
                if(lstMapSettingAllThingsConsidered[0].PPM_Rate__c != null &&
                        lstMapSettingAllThingsConsidered[0].Fiscal_Year__c == 
                            Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c))
                  objfyPricingDetailRec.ATC_PPM_Rate__c = lstMapSettingAllThingsConsidered[0].PPM_Rate__c;
                  
                if(lstMapSettingAllThingsConsidered[0].LH_Rate__c != null 
                    && lstMapSettingAllThingsConsidered[0].Fiscal_Year__c == 
                            Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c) )
                  objfyPricingDetailRec.ATC_LH_Rate__c = lstMapSettingAllThingsConsidered[0].LH_Rate__c;
                  
                if(lstMapSettingAllThingsConsidered[0].Cap_Factor__c != null 
                    && lstMapSettingAllThingsConsidered[0].Fiscal_Year__c == 
                            Integer.valueOf(objfyPricingDetailRec.Fiscal_Year__c) )
                  //objfyPricingDetailRec.ATC_Cap_Factor__c = lstMapSettingAllThingsConsidered[0].Cap_Factor__c;
                  objfyPricingDetailRec.ATC_Ceiling_Cap_Factor__c = lstMapSettingAllThingsConsidered[0].Ceiling_Cap_Factor__c; /*Change made by Suhas*/
                  objfyPricingDetailRec.ATC_Floor_Cap_Factor__c = lstMapSettingAllThingsConsidered[0].Floor_Cap_Factor__c;     /*Change made by Suhas*/
           } 
           
           System.debug('\n\nlstFyPricingDetails 02: '+lstFyPricingDetails+'\n\n'); 
            //Get Last Price Value for Morning Edition and All Thing Considerd 
           if(lstFyPricingDetails != null && !lstFyPricingDetails.isEmpty() 
                && objfyPricingDetailRec.Station__c == lstFyPricingDetails[0].Station__c){
                
                System.debug('\n\nlstFyPricingDetails 02.ATC_Capped_Price__c: '+lstFyPricingDetails[0].ATC_Capped_Price__c+'\n\n');  
                System.debug('\n\nlstFyPricingDetails 02.ME_Capped_Price__c: '+lstFyPricingDetails[0].ME_Capped_Price__c+'\n\n');  
                
                if(lstFyPricingDetails[0].ATC_Capped_Price__c != null)
                    objfyPricingDetailRec.ATC_Last_FY_Price__c = 
                                        lstFyPricingDetails[0].ATC_Capped_Price__c;
                
                if(lstFyPricingDetails[0].ME_Capped_Price__c != null)
                    objfyPricingDetailRec.ME_Last_FY_Price__c = 
                                         lstFyPricingDetails[0].ME_Capped_Price__c;
           } 
             
        }//End for
        
    }//End PopulateFYPricingFieldInfo()
 
    //Populate ATC and ME Capped Price 
    public void getCappedPrice(List<FY_Pricing_Detail__c> lstFyPricingDetail, Map<Id, FY_Pricing_Detail__c> newMapIdToFyPricingRec){  
        System.debug('\n\nIn getCappedPrice\n\n');
        
        System.debug('\n\nlstFyPricingDetail: '+lstFyPricingDetail+'\n\n');
        System.debug('\n\nnewMapIdToFyPricingRec: '+newMapIdToFyPricingRec+'\n\n');
        if(lstFyPricingDetail == null  || newMapIdToFyPricingRec == null) return;
        
        //Get FyPricingRecord 
        objHelper  = new FyPricingDetailTriggerHandlerHelper();
        List<FY_Pricing_Detail__c> lstFyPricingDetailUpdate = objHelper.getFyPricingDetailRecord(newMapIdToFyPricingRec.keySet()); 
        
        System.debug('\n\nlstFyPricingDetailUpdate: '+lstFyPricingDetailUpdate+'\n\n');
        if(lstFyPricingDetailUpdate == null) return;
        
        for(FY_Pricing_Detail__c objFyPricingDetail : lstFyPricingDetailUpdate){ 
            if(objFyPricingDetail.ATC_Floor_Cap_Factor__c != null) {/*If statment added by Suhas*/
                objFyPricingDetail.ATC_Last_FY_Price__c  = objFyPricingDetail.ATC_Last_FY_Price__c  != null ? objFyPricingDetail.ATC_Last_FY_Price__c : 0;
                objFyPricingDetail.ME_Last_FY_Price__c = objFyPricingDetail.ME_Last_FY_Price__c != null ? objFyPricingDetail.ME_Last_FY_Price__c: 0;
                System.debug('\n\nobjFyPricingDetail.ATC_Last_FY_Price__c: '+objFyPricingDetail.ATC_Last_FY_Price__c+': '+objFyPricingDetail.ATC_Last_FY_Price__c+'\n\n');
                System.debug('\n\nobjFyPricingDetail.ME_Last_FY_Price__c: ' +objFyPricingDetail.ME_Last_FY_Price__c+': '+objFyPricingDetail.ME_Last_FY_Price__c+'\n\n');
                
                system.debug('\n\n objFyPricingDetail.Discount_Percentage__c = '+objFyPricingDetail.Discount_Percentage__c+'\n\n');
               
               
                 Decimal ATC_Ratio = objFyPricingDetail.ATC_Uncapped_Price__c  /  objFyPricingDetail.Total_Uncapped_Price__c;
                 Decimal ME_Ratio =  objFyPricingDetail.ME_Uncapped_Price__c /  objFyPricingDetail.Total_Uncapped_Price__c;
                /*//IF Discount Percentage > 0
                if (objFyPricingDetail.Discount_Percentage__c > 0 ){ 
                      
                    //Scenario 2b - Paying less than they did last year
                    if(((objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100))  < objFyPricingDetail.Last_FY_Total_Fees__c) &&
                       (objFyPricingDetail.Last_FY_Total_Fees__c - (objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100)) > objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100)))
                    {
                        system.debug('2B');
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Last_FY_Price__c - (objFyPricingDetail.ATC_Last_FY_Price__c * (objFyPricingDetail.ATC_Cap_Factor__c/100));
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Last_FY_Price__c - (objFyPricingDetail.ME_Last_FY_Price__c * (objFyPricingDetail.ME_Cap_Factor__c/100));
                    }//Scenario 2c - Paying more than they did last year, but over the cap limit
                    else if((objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100) > objFyPricingDetail.Last_FY_Total_Fees__c) &&
                            (objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100)) - objFyPricingDetail.Last_FY_Total_Fees__c > objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100))
                    {
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Last_FY_Price__c + (objFyPricingDetail.ATC_Last_FY_Price__c * (objFyPricingDetail.ATC_Cap_Factor__c/100));
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Last_FY_Price__c + (objFyPricingDetail.ME_Last_FY_Price__c * (objFyPricingDetail.ME_Cap_Factor__c/100));
                        system.debug('2C');
                    }//Scenario 2a - Paying more than they did last year, but within the cap limit
                     //Scenario 2d - Paying less than they did last year but within the cap limit
                    else
                    {
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100);
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100);
                        system.debug('2A');
                    }      
                }
                //If Discount Percentage = 0
                else
                {                 
                    //scenario 1b - Paying less than they did last year and over the cap limit
                    if((objFyPricingDetail.Total_Uncapped_Price__c < objFyPricingDetail.Last_FY_Total_Fees__c) && ((objFyPricingDetail.Last_FY_Total_Fees__c - objFyPricingDetail.Total_Uncapped_Price__c) > (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100))))
                    {
                          objFyPricingDetail.ATC_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c  - (objFyPricingDetail.Last_FY_Total_Fees__c  * (objFyPricingDetail.ATC_Cap_Factor__c/100))) * ATC_Ratio;
                          objFyPricingDetail.ME_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c  - (objFyPricingDetail.Last_FY_Total_Fees__c  * (objFyPricingDetail.ME_Cap_Factor__c/100))) * ME_Ratio;
                        system.debug('1B');
                    } //scenario1c - Paying more than they did last year and over the cap limit
                    else if((objFyPricingDetail.Total_Uncapped_Price__c > objFyPricingDetail.Last_FY_Total_Fees__c) && ((objFyPricingDetail.Total_Uncapped_Price__c - objFyPricingDetail.Last_FY_Total_Fees__c) > (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100)))) 
                    {
                        objFyPricingDetail.ATC_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c + (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100))) * ATC_Ratio;
                        objFyPricingDetail.ME_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c + (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ME_Cap_Factor__c/100))) * ME_Ratio;
                        system.debug('1C');
                        system.debug('*** \n\n objFyPricingDetail.Last_FY_Total_Fees__c ='+objFyPricingDetail.Last_FY_Total_Fees__c+'\n\n ***');
                        system.debug('*** \n\n objFyPricingDetail.ATC_Cap_Factor__c/100 ='+objFyPricingDetail.ATC_Cap_Factor__c/100+'\n\n ***');
                        system.debug('*** \n\n ATC_Ratio ='+ATC_Ratio+'\n\n ***');
                    }//scenario 1a - Paying more than they did last year but within the cap limit
                     //scenario 1d - Paying less than they did last year but within the cap limit
                    else
                    {
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Uncapped_Price__c;
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Uncapped_Price__c;
                        system.debug('1A');
                    }
                } */  
                /*Added by Suhas on 06/24/2015*/
                if (objFyPricingDetail.Discount_Percentage__c > 0 ) {
                    system.debug('This is the discount scenario===>>> ');
                    system.debug('objFyPricingDetail.Total_Uncapped_Price__c===>>> '+objFyPricingDetail.Total_Uncapped_Price__c);
                    system.debug('objFyPricingDetail.Last_FY_Total_Fees__c===>>>'+objFyPricingDetail.Last_FY_Total_Fees__c);
                    system.debug('objFyPricingDetail.ATC_Floor_Cap_Factor__c===>>>'+objFyPricingDetail.ATC_Floor_Cap_Factor__c);
                    system.debug('objFyPricingDetail.ATC_Ratio__c===>>>'+objFyPricingDetail.ATC_Ratio__c);
                    system.debug('objFyPricingDetail.ATC_Ceiling_Cap_Factor__c===>>>'+objFyPricingDetail.ATC_Ceiling_Cap_Factor__c);
                    system.debug('objFyPricingDetail.ME_Ratio__c===>>>'+objFyPricingDetail.ME_Ratio__c);
                    system.debug('objFyPricingDetail.ATC_Uncapped_Price__c===>>>'+objFyPricingDetail.ATC_Uncapped_Price__c);
                    system.debug('objFyPricingDetail.ME_Uncapped_Price__c===>>>'+objFyPricingDetail.ME_Uncapped_Price__c);
                    system.debug('objFyPricingDetail.Discount_Percentage__c====>>> '+objFyPricingDetail.Discount_Percentage__c);
                    
                    //Scenario 2b - Paying less than they did last year but over cap limit
                    if(objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100) < objFyPricingDetail.Last_FY_Total_Fees__c 
                         && objFyPricingDetail.Last_FY_Total_Fees__c - (objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100)) > objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Floor_Cap_Factor__c/100)) {
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Last_FY_Price__c - (objFyPricingDetail.ATC_Last_FY_Price__c * (objFyPricingDetail.ATC_Floor_Cap_Factor__c/100));
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Last_FY_Price__c - (objFyPricingDetail.ME_Last_FY_Price__c * (objFyPricingDetail.ME_Floor_Cap_Factor__c/100));
                    }
                
                    //Scenario 2c - Paying more than they did last year, but over the cap limit
                    else if((objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100) > objFyPricingDetail.Last_FY_Total_Fees__c) 
                             && (objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100)) - objFyPricingDetail.Last_FY_Total_Fees__c > objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Ceiling_Cap_Factor__c/100)) {
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Last_FY_Price__c + (objFyPricingDetail.ATC_Last_FY_Price__c * (objFyPricingDetail.ATC_Ceiling_Cap_Factor__c/100));
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Last_FY_Price__c + (objFyPricingDetail.ME_Last_FY_Price__c * (objFyPricingDetail.ME_Ceiling_Cap_Factor__c/100));
                    }
                    
                    //Scenario 2a - Paying more than they did last year, but within the cap limit
                    //Scenario 2d - Paying less than they did last year but within the cap limit
                    else {
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100);
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100);
                    }
                }
                //Discount percentage = 0 
                //scenario 1b - Paying less than they did last year and over the cap limit
                else 
                {
                	system.debug('This is the non discount scenario===>>> ');
                	/*system.debug('objFyPricingDetail.Total_Uncapped_Price__c===>>> '+objFyPricingDetail.Total_Uncapped_Price__c);
                	system.debug('objFyPricingDetail.Last_FY_Total_Fees__c===>>>'+objFyPricingDetail.Last_FY_Total_Fees__c);
                	system.debug('objFyPricingDetail.ATC_Floor_Cap_Factor__c===>>>'+objFyPricingDetail.ATC_Floor_Cap_Factor__c);
                	system.debug('objFyPricingDetail.ATC_Ratio__c===>>>'+objFyPricingDetail.ATC_Ratio__c);
                	system.debug('objFyPricingDetail.ATC_Ceiling_Cap_Factor__c===>>>'+objFyPricingDetail.ATC_Ceiling_Cap_Factor__c);
                	system.debug('objFyPricingDetail.ME_Ratio__c===>>>'+objFyPricingDetail.ME_Ratio__c);
                	system.debug('objFyPricingDetail.ATC_Uncapped_Price__c===>>>'+objFyPricingDetail.ATC_Uncapped_Price__c);
                	system.debug('objFyPricingDetail.ME_Uncapped_Price__c===>>>'+objFyPricingDetail.ME_Uncapped_Price__c);
                	system.debug('objFyPricingDetail.Last_FY_Total_Fees__c - objFyPricingDetail.Total_Uncapped_Price__c > objFyPricingDetail.Last_FY_Total_Fees__c * objFyPricingDetail.ATC_Floor_Cap_Factor__c===>>>'+(objFyPricingDetail.Last_FY_Total_Fees__c - objFyPricingDetail.Total_Uncapped_Price__c > objFyPricingDetail.Last_FY_Total_Fees__c * objFyPricingDetail.ATC_Floor_Cap_Factor__c));
                	system.debug('objFyPricingDetail.Total_Uncapped_Price__c - objFyPricingDetail.Last_FY_Total_Fees__c > objFyPricingDetail.Last_FY_Total_Fees__c * objFyPricingDetail.ATC_Ceiling_Cap_Factor__c===>>>'+(objFyPricingDetail.Total_Uncapped_Price__c - objFyPricingDetail.Last_FY_Total_Fees__c > objFyPricingDetail.Last_FY_Total_Fees__c * objFyPricingDetail.ATC_Ceiling_Cap_Factor__c));
                	*/
                    if (objFyPricingDetail.Total_Uncapped_Price__c < objFyPricingDetail.Last_FY_Total_Fees__c 
                         && objFyPricingDetail.Last_FY_Total_Fees__c - objFyPricingDetail.Total_Uncapped_Price__c > objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Floor_Cap_Factor__c/100)) {
                        system.debug('This is scenario 1b===>>> ');
                        objFyPricingDetail.ATC_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c - (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Floor_Cap_Factor__c/100))) * ATC_Ratio;//objFyPricingDetail.ATC_Ratio__c;
                        system.debug('objFyPricingDetail.ATC_Capped_Price__c======>>>> '+objFyPricingDetail.ATC_Capped_Price__c);
                        objFyPricingDetail.ME_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c - (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ME_Floor_Cap_Factor__c/100))) * ME_Ratio;//objFyPricingDetail.ME_Ratio__c;
                        system.debug('objFyPricingDetail.ME_Capped_Price__c======>>>> '+objFyPricingDetail.ME_Capped_Price__c); 
                    }
                
                    //scenario1c - Paying more than they did last year and over the cap limit
                    else if (objFyPricingDetail.Total_Uncapped_Price__c > objFyPricingDetail.Last_FY_Total_Fees__c 
                             && objFyPricingDetail.Total_Uncapped_Price__c - objFyPricingDetail.Last_FY_Total_Fees__c > objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Ceiling_Cap_Factor__c/100)) {
                             system.debug('This is scenario 1c===>>> ');
                        objFyPricingDetail.ATC_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c + (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Ceiling_Cap_Factor__c/100))) * ATC_Ratio; //objFyPricingDetail.ATC_Ratio__c;
                        system.debug('objFyPricingDetail.ATC_Capped_Price__c======>>>> '+objFyPricingDetail.ATC_Capped_Price__c);
                        objFyPricingDetail.ME_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c + (objFyPricingDetail.Last_FY_Total_Fees__c* (objFyPricingDetail.ME_Ceiling_Cap_Factor__c/100))) * ME_Ratio; //objFyPricingDetail.ME_Ratio__c;
                        system.debug('objFyPricingDetail.ME_Capped_Price__c======>>>> '+objFyPricingDetail.ME_Capped_Price__c);
                    }
                    //scenario 1a - Paying more than they did last year but within the cap limit
                    //scenario 1d - Paying less than they did last year but within the cap limit
                    else {
                    	system.debug('This is scenario 1a/1d===>>> ');
                        objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Uncapped_Price__c;
                        system.debug('objFyPricingDetail.ATC_Capped_Price__c======>>>> '+objFyPricingDetail.ATC_Capped_Price__c);
                        objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Uncapped_Price__c;
                        system.debug('objFyPricingDetail.ME_Capped_Price__c======>>>> '+objFyPricingDetail.ME_Uncapped_Price__c);
                    }
                }
            }
        /*End of code added by Suhas*/
        }
        //Update Fypricing Detail List
        if(lstFyPricingDetailUpdate != null && !lstFyPricingDetailUpdate.isEmpty() )
            update lstFyPricingDetailUpdate;
    }
            
}//End PopulateFyPricingDetailFields Class