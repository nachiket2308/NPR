/*
*    Description : Apex controller class for 'NewFyPricingDetail' page which is used to create/edit
*                  FY Pricing Detail Record 
*
*    Version            Date                Author                Description
*    
*    1.0                04/29/2014          Siddharth Birari      Initial Draft
	 1.1                06/05/2014          Gaurav                Added Try catch block to handle error message
*/

public class NewFyPricingDetailController {
    
    private static String STRMODENEW = 'New';
    private static String STRMODEEDIT = 'Edit';
    private static String STRPRICINGDETAILTABURL = '/a0Z/o';
    
    public News_Mag_Level__c objMENewsMagLevel;
    public News_Mag_Level__c objATCNewsMagLevel;
    private static final string STR_ME_PRGRAM = 'Morning Edition';
    private static final string STR_ATC_PRGRAM = 'All Things Considered';
 
    private String strMode;
    private Pricing_Tier__c objPricingTier;
    private Discounts__c objDiscount;
    
    public FY_Pricing_Detail__c objFyPricingDetail {get; set;}    
    
    //Constructor
    public NewFyPricingDetailController(ApexPages.Standardcontroller objStandardController){
    
    	objPricingTier = new Pricing_Tier__c();
    	objDiscount = new Discounts__c();
        if(string.isBlank(objStandardController.getId())){
            
            objFyPricingDetail = new FY_Pricing_Detail__c();
            strMode = STRMODENEW;
        }
        else{
          
            objFyPricingDetail = (FY_Pricing_Detail__c)objStandardController.getRecord();            
            this.getFyPricingDetailRecord(objFyPricingDetail.Id);                      
            strMode = STRMODEEDIT;          
        }   
             
    }
    
    //Method retrives the details of FY Pricing Detail record under context
    public void getFyPricingDetailRecord(String pId){               
        
        List<FY_Pricing_Detail__c> fyPricingDetailList = [Select Id,
                                                                 Station__r.TSR__c,
                                                                 Station__r.Minority_Status__c,
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
                                                          where Id =: pId];
                                                          // LastViewedDate, LastReferencedDate, 
        
        if(!fyPricingDetailList.isEmpty()){
            this.objFyPricingDetail = fyPricingDetailList[0];
        }
    }
    
    //Method to Create/Update FY Pricing Detail Record
    public Pagereference savePricingDetail(){
        
        //getFyPricingDetailRecord(objFyPricingDetail.Id);   
        
        Account objAccount;
        if(objFyPricingDetail.Fiscal_Year__c != null)
		getCustomSettingValues();
		
		if(objFyPricingDetail.Station__c != null)
		   objAccount = [Select TSR__c, Minority_Status__c from Account where Id =: objFyPricingDetail.Station__c];
			
		if(objAccount != null && objAccount.TSR__c != null ){
					
		    objFyPricingDetail.TSR__c  = objAccount.TSR__c;
		    
			getTsrLevelValue(Integer.valueOf(objAccount.TSR__c));
			getDiscountsPercentValue(objFyPricingDetail.Fiscal_Year__c, objAccount.Minority_Status__c);
			
		    objFyPricingDetail.TSR_Level__c = objPricingTier != null && objPricingTier.Tier__c != null ? 
											    objPricingTier.Tier__c : 0;
			objFyPricingDetail.Discount_Percentage__c = objDiscount != null && objDiscount.Discount_Percent__c != null ?
												objDiscount.Discount_Percent__c : 0;	
			
			
			/*if(objFyPricingDetail.Id != null)
				getCappedPrice(objFyPricingDetail);	
			*/
		}										
        Pagereference pRef;
        try{
        	Database.Upsertresult oUpsertResult = Database.upsert(objFyPricingDetail);
            if(oUpsertResult.isSuccess()){
                pRef = Page.FyPricingDetailView;
                pRef.getParameters().put('Id', objFyPricingDetail.Id);
            }
        }
        catch(DmlException ex){
            return null;      
        }
        return pRef;
    }
    
    //Method Cancel's the creating FY Pricing Detail Record (New Mode) and redirects the end user to 
    //FY Pricing Detail Tab OR
    //Method do not allows the end user to update the record (Edit Mode) and redirects the end user to 
    //existing FY Pricing Detail 'View' page
    public Pagereference cancel(){
    
        Pagereference pRef;         
        //Redirect the end user to FY Pricing Detail Tab
        if(strMode.equalsIgnoreCase(STRMODENEW)){
        
            pRef = new Pagereference(STRPRICINGDETAILTABURL);            
        }
        //Redirect the end user to FY Pricing Detail View Page
        if(strMode.equalsIgnoreCase(STRMODEEDIT)){
        
            pRef = Page.FyPricingDetailView;
            pRef.getParameters().put('Id', objFyPricingDetail.Id);
        }
        return pRef;
    }
    
    public News_Mag_Level__c getNewsMagLevel(String strProgram){
    	
    	List<News_Mag_Level__c> lstNewsMagLevel;
    	if(objFyPricingDetail.Station__r.TSR__c  != null && strProgram != null 
    	    && strProgram != '' && objFyPricingDetail.Fiscal_Year__c != null){
    		
	        lstNewsMagLevel  = [Select Rate__c 
							    From  News_Mag_Level__c 
							    Where (Fiscal_Year__c =: Decimal.valueOf(objFyPricingDetail.Fiscal_Year__c)
							    AND   Program__c =: strProgram
							    AND   Upper_Limit__c >=: objFyPricingDetail.Station__r.TSR__c 
							    AND   Lower_Limit__c <=: objFyPricingDetail.Station__r.TSR__c) 
							    order by LastModifiedDate Desc 
							    limit 1 ];
    	 }     
         if(!lstNewsMagLevel.isEmpty()){									 
        	  return lstNewsMagLevel[0];
         }	  
	     return null;
    }
    
    //Get values from custom setting
    public void getCustomSettingValues()
    {
    	Set<Integer> setFiscalYear = new Set<Integer>();
    	Map<String,News_Mag_Settings__c> mapNameToNewMagSettings;
    	
    	if(objFyPricingDetail.Fiscal_Year__c != null)
    		mapNameToNewMagSettings = News_Mag_Settings__c.getAll();
    			
		if(!mapNameToNewMagSettings.isEmpty() ){
			
			for(News_Mag_Settings__c objNewsMagSetting : mapNameToNewMagSettings.values()){
				
				setFiscalYear.add(Integer.valueOf(objNewsMagSetting.Fiscal_Year__c));
				//Compare All Time Edition value with Custom Setting fiscal Year
				if(objNewsMagSetting.Program__c.equalsIgnoreCase(STR_ATC_PRGRAM)
					&& objNewsMagSetting.Fiscal_Year__c == Integer.valueOf(objFyPricingDetail.Fiscal_Year__c)){
					
					objFyPricingDetail.ATC_PPM_Rate__c = objNewsMagSetting.PPM_Rate__c;
					objFyPricingDetail.ATC_LH_Rate__c = objNewsMagSetting.LH_Rate__c;	
					//objFyPricingDetail.ATC_Cap_Factor__c = objNewsMagSetting.Cap_Factor__c;
					objFyPricingDetail.ATC_Ceiling_Cap_Factor__c = objNewsMagSetting.Ceiling_Cap_Factor__c;    /*Change made by Suhas*/
					objFyPricingDetail.ATC_Floor_Cap_Factor__c = objNewsMagSetting.Floor_Cap_Factor__c;        /*Change made by Suhas*/
					
					if(objFyPricingDetail.Station__r.TSR__c != null && 
    	   				objFyPricingDetail.Fiscal_Year__c != null){
						objATCNewsMagLevel = getNewsMagLevel(STR_ATC_PRGRAM);
    	   			}
    	   			
					if(objATCNewsMagLevel!= null){
						objFyPricingDetail.ATC_Base_Price__c = objATCNewsMagLevel.Rate__c;
					}
				}
				
				//Compare Morning Edition value with Custom Setting fiscal Year
				if(objNewsMagSetting.Program__c.equalsIgnoreCase(STR_ME_PRGRAM)
					&& objNewsMagSetting.Fiscal_Year__c == Integer.valueOf(objFyPricingDetail.Fiscal_Year__c)){
			
					
					objFyPricingDetail.ME_PPM_Rate__c = objNewsMagSetting.PPM_Rate__c;
					objFyPricingDetail.ME_LH_Rate__c = objNewsMagSetting.LH_Rate__c;	
					//objFyPricingDetail.ME_Cap_Factor__c = objNewsMagSetting.Cap_Factor__c;
					objFyPricingDetail.ME_Ceiling_Cap_Factor__c = objNewsMagSetting.Ceiling_Cap_Factor__c;
					objFyPricingDetail.ME_Floor_Cap_Factor__c = objNewsMagSetting.Floor_Cap_Factor__c;
					
					if(objFyPricingDetail.Station__r.TSR__c != null 
    	   				 && objFyPricingDetail.Fiscal_Year__c != null){
						objMENewsMagLevel = getNewsMagLevel(STR_ME_PRGRAM);
    	   			}
					if(objMENewsMagLevel!= null){
						objFyPricingDetail.ME_Base_Price__c = objMENewsMagLevel.Rate__c;
					}
					
				}
				
			}
			 
		}
		else{
				callDefaultValue();
		}
		
		if(!setFiscalYear.contains(Integer.valueOf(objFyPricingDetail.Fiscal_Year__c))){
				callDefaultValue();
		}
    	
    }

	//Get the Tsr Level value from Pricing_Tier__c object
	public void getTsrLevelValue(Integer pIntTsrValue){
		
		if(pIntTsrValue != null){
		    List<Pricing_Tier__c> lstPricingTier = [ Select Tier__c ,
		    												TSR_High__c ,
		    												TSR_Low__c,
		    												Type__c
													 From Pricing_Tier__c 
													 Where TSR_High__c >=: pIntTsrValue
													 AND TSR_Low__c <=: pIntTsrValue
													 AND Type__c = 'PPF'
													 Order by 
													 LastModifiedDate Desc 
													 Limit 1
												   ];
												   
			 if(lstPricingTier !=null && !lstPricingTier.isEmpty()){
			 	
	            this.objPricingTier = lstPricingTier[0];
	        }										 
		}					  
	}
	
	//Get the Discounts Percent value from Discounts__c object
	public void getDiscountsPercentValue(String pStrFiscalYear, String pStrDiscountType){
		
		if(pStrFiscalYear != null && pStrDiscountType != null && pStrDiscountType != ''){
		
		    List<Discounts__c> lstDiscount = [ SELECT Discount_Percent__c
											   FROM Discounts__c
											   WHERE Fiscal_Year__c =: pStrFiscalYear 
											   AND Discount_Type__c =: pStrDiscountType 
											   AND News_Non_News__c = 'News'
											 ];
												   
			 if(lstDiscount !=null && !lstDiscount.isEmpty()){
	            this.objDiscount = lstDiscount[0];
	        }	
		}									 
									  
	}
	
	//Ser Defalue value for ATC and ME when condition not matched
    public void callDefaultValue(){
    	
        objFyPricingDetail.ATC_PPM_Rate__c = 0;
		objFyPricingDetail.ATC_LH_Rate__c = 0;	
		//objFyPricingDetail.ATC_Cap_Factor__c = 0;
		objFyPricingDetail.ATC_Ceiling_Cap_Factor__c = 0; /*Changes made by Suhas*/
		objFyPricingDetail.ATC_Floor_Cap_Factor__c = 0;   /*Changes made by Suhas*/
		objFyPricingDetail.ATC_Base_Price__c = 0;
		objFyPricingDetail.ME_PPM_Rate__c = 0;
		objFyPricingDetail.ME_LH_Rate__c = 0;	
		//objFyPricingDetail.ME_Cap_Factor__c = 0;
		objFyPricingDetail.ME_Ceiling_Cap_Factor__c = 0; /*Changes made by Suhas*/
		objFyPricingDetail.ME_Floor_Cap_Factor__c = 0;   /*Changes made by Suhas*/
		objFyPricingDetail.ME_Base_Price__c= 0;
		
    }
    
    //Populate ATC and ME Capped Price 
	/*public void getCappedPrice(FY_Pricing_Detail__c objFyPricingDetail){  
		
		system.debug('******objFyPricingDetail'+objFyPricingDetail);
		
		objFyPricingDetail.ATC_Last_FY_Price__c  = objFyPricingDetail.ATC_Last_FY_Price__c  != null ? objFyPricingDetail.ATC_Last_FY_Price__c : 0;
		objFyPricingDetail.ME_Last_FY_Price__c = objFyPricingDetail.ME_Last_FY_Price__c != null ? objFyPricingDetail.ME_Last_FY_Price__c: 0;

		 	Decimal ATC_Ratio = objFyPricingDetail.ATC_Uncapped_Price__c  /  objFyPricingDetail.Total_Uncapped_Price__c;
			Decimal ME_Ratio =  objFyPricingDetail.ME_Uncapped_Price__c /  objFyPricingDetail.Total_Uncapped_Price__c;
            //IF Discount Percentage > 0
            if (objFyPricingDetail.Discount_Percentage__c > 0 ){ 
                  
                //Scenario 2b - Paying less than they did last year
				if(((objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100))  < objFyPricingDetail.Last_FY_Total_Fees__c) &&
				   (objFyPricingDetail.Last_FY_Total_Fees__c - (objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100)) > objFyPricingDetail.Last_FY_Total_Fees__c * objFyPricingDetail.ATC_Cap_Factor__c))
				{
                    system.debug('2B');
					objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Last_FY_Price__c - (objFyPricingDetail.ATC_Last_FY_Price__c * (objFyPricingDetail.ATC_Cap_Factor__c/100));
					objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Last_FY_Price__c - (objFyPricingDetail.ME_Last_FY_Price__c * (objFyPricingDetail.ME_Cap_Factor__c/100));
				}//Scenario 2c - Paying more than they did last year, but over the cap limit
				else if((objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100) > objFyPricingDetail.Last_FY_Total_Fees__c) &&
						(objFyPricingDetail.Total_Uncapped_Price__c * (objFyPricingDetail.Discount_Percentage__c/100)) - objFyPricingDetail.Last_FY_Total_Fees__c > objFyPricingDetail.Last_FY_Total_Fees__c * objFyPricingDetail.ATC_Cap_Factor__c)
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
            	system.debug('***'+objFyPricingDetail.Total_Uncapped_Price__c+'***');
            	system.debug('***'+objFyPricingDetail.Last_FY_Total_Fees__c+'***');
            	system.debug('***'+objFyPricingDetail.Total_Uncapped_Price__c+'***');
            	system.debug('***'+objFyPricingDetail.Last_FY_Total_Fees__c+'***');
            	system.debug('***'+objFyPricingDetail.Last_FY_Total_Fees__c+'***');
            	system.debug('***'+objFyPricingDetail.ATC_Cap_Factor__c/100+'***');      	
            	//scenario 1b - Paying less than they did last year and over the cap limit
				if((objFyPricingDetail.Total_Uncapped_Price__c < objFyPricingDetail.Last_FY_Total_Fees__c) && ((objFyPricingDetail.Last_FY_Total_Fees__c - objFyPricingDetail.Total_Uncapped_Price__c) > (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100))))
				{
					  objFyPricingDetail.ATC_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c  - (objFyPricingDetail.Last_FY_Total_Fees__c  * (objFyPricingDetail.ATC_Cap_Factor__c/100))) * ATC_Ratio;
                      objFyPricingDetail.ME_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c  - (objFyPricingDetail.Last_FY_Total_Fees__c  * (objFyPricingDetail.ME_Cap_Factor__c/100))) * ME_Ratio;
					system.debug('** 1B **');
                } //scenario1c - Paying more than they did last year and over the cap limit
				else if((objFyPricingDetail.Total_Uncapped_Price__c > objFyPricingDetail.Last_FY_Total_Fees__c) && ((objFyPricingDetail.Total_Uncapped_Price__c - objFyPricingDetail.Last_FY_Total_Fees__c) > (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100)))) 
				{
					objFyPricingDetail.ATC_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c + (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ATC_Cap_Factor__c/100))) * ATC_Ratio;
					objFyPricingDetail.ME_Capped_Price__c = (objFyPricingDetail.Last_FY_Total_Fees__c + (objFyPricingDetail.Last_FY_Total_Fees__c * (objFyPricingDetail.ME_Cap_Factor__c/100))) * ME_Ratio;
					system.debug('** 1C **');
				}//scenario 1a - Paying more than they did last year but within the cap limit
				 //scenario 1d - Paying less than they did last year but within the cap limit
				else
				{
					objFyPricingDetail.ATC_Capped_Price__c = objFyPricingDetail.ATC_Uncapped_Price__c;
					objFyPricingDetail.ME_Capped_Price__c = objFyPricingDetail.ME_Uncapped_Price__c;
					system.debug('** 1A **');
                }
            }   
	}*/
	
}