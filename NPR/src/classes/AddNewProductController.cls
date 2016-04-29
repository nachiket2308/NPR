/**
** Description : A class to controls the functionality of the vfpage " AddNewProduct  " 
**
**  Inital Draft          Author               Date
**  version 1.0         Dhirendra           6/6/2014
**/
public with sharing class AddNewProductController {
    public String strOppId;
    public List<Product2> lstProduct;
    public String SelectedProductId{get;set;}
    public List<String> SelectedList{get;set;}
    public Map<Id, Boolean> mapStationIdToLMABoolean = new Map<Id, Boolean>();
    public Map<String, OpportunityLineItem> mapStringToOpportunityLineItem = new Map<String, OpportunityLineItem>();
    public Map<Id, Account> oppAccountMap {set; get;}
    public Map<String, list<FY_Pricing_Detail__c>> oppFYMap {set; get;}
    public Map<String, list<Discounts__c>> oppDiscountMap {set; get;}
	public List <Pricing_Table__c> pricingTables {set; get;}
	public List<Pricing_MSA_License_Fee__c> pricingMsaLicenseFees {set; get;}
	public  Map<String, List<NPR_Product__c>> oppNprProdMap {set; get;}
	public  Map<String, List<Product2>> oppProductsMap {set; get;}
	public List<Product2> productListMSA {set; get;}
	public List<MSA_Incremental__c> MSAIncStreamingList {set; get;}
	public List<MSA_Incremental__c> MSAIncEmailList {set; get;}
	public PricingUtility pu {set; get;}
    
    //Declaration
    Map<Id,OpportunityLineItem> mapIdToAccountId = new  Map<Id,OpportunityLineItem>();
    Set<String> SetOpportunityLineItemStation = new Set<String>();
    List<OpportunityLineItem> lstInsertOppLineItem = new List<OpportunityLineItem>();
    List<OpportunityLineItem> lstUpdateOpportunityLineItem = new List<OpportunityLineItem>();
    List<OpportunityLineItem> lstOppLineItemDuplicate = new List<OpportunityLineItem>();
    NPR_Product__c objNPR;
    Set<OpportunityLineItem> setOpportunityLineItem = new Set<OpportunityLineItem>();
    
    //Constructor
    public AddNewProductController(){
        strOppId = apexPages.currentPage().getHeaders().get('Id');
        SelectedList = new list<String>();
        lstProduct = new List<Product2>();
        SelectedProductId = '';
        objNPR = new NPR_Product__c(); 
        
        oppAccountMap = new Map<Id, Account>();
        oppFYMap = new Map<String, list<FY_Pricing_Detail__c>>(); 
        oppDiscountMap = new Map<String, list<Discounts__c>>(); 
		pricingTables = new List <Pricing_Table__c>();
		pricingMsaLicenseFees = new List<Pricing_MSA_License_Fee__c>();
		oppNprProdMap = new Map<String, List<NPR_Product__c>>();
		oppProductsMap = new Map<String, List<Product2>>();
		productListMSA = new List<Product2>();
		MSAIncStreamingList = new List<MSA_Incremental__c>(); 
		MSAIncEmailList = new List<MSA_Incremental__c>();
		pu = new PricingUtility();
    }
    
    //Get Product record for given Oppportunity
    public List<SelectOption> getProductforOpportunity(){
        
        strOppId = apexPages.currentPage().getParameters().get('Id');
        lstProduct = new List<Product2>();
        Opportunity objOpp = [Select Opportunity.Type,opportunity.CloseDate from Opportunity where Id =: strOppId];
        List<Product2> lstAllProduct = new List<Product2>();
        Map<Id,Product2> mapAllProduct = new Map<Id,Product2>();
        for(Product2 objProduct:[Select Id, 
                                        Name,
                                        Family,
                                        Active_End_Date__c,
                                        Active_Start_Date__c, 
                                        MSA_Type__c, 
                                        ATC__c, 
                                        ME__c, 
                                        PPF_Type__c, 
                                        MSA_Incremental_Type__c, 
                                        Product_Version__c
                                 FROM Product2
                                 where Product_Version__c =:'Trial' OR
                                       Product_Version__c =:'Version 2+' OR
                                       Product_Version__c =:'Free']){
                                        
            if((objOpp.Type=='MSA' &&  objProduct.Family == 'MSA' && 
                (objProduct.Active_Start_Date__c <= objOpp.CloseDate 
                    && objProduct.Active_End_Date__c >= objOpp.CloseDate )) ||
                (objOpp.Type=='PPF' &&  objProduct.Family == 'PPF' && 
                (objProduct.Active_Start_Date__c <= objOpp.CloseDate 
                    && objProduct.Active_End_Date__c >= objOpp.CloseDate ))){
                        mapAllProduct.put(objProduct.Id,objProduct);
                        lstAllProduct.add(objProduct);
                    }                               
        }
        //Get All Npr Product Record related to that Opportunity 
        Set<String>setNPrProductId = new set<String>();
        for(NPR_Product__c objNpr: [Select Id,
                                           Product__c,
                                           Opportunity_Name__c  
                                    from NPR_Product__c 
                                    where Opportunity_Name__c  =: strOppId]){
            setNPrProductId.add(objNpr.Product__c);
            
        }
        //Remove the common product from Product Record which map to NPR Product
        for(Product2 objProduct : [Select id,
                                          Name,
                                          Family,
                                          Active_End_Date__c,
                                          Active_Start_Date__c, 
                                          MSA_Type__c, 
                                          ATC__c, 
                                          ME__c, 
                                          PPF_Type__c, 
                                          MSA_Incremental_Type__c, 
                                          Product_Version__c
                                   from Product2 where Id IN: setNPrProductId]){
                                    
                                                
            if(mapAllProduct.containsKey(objProduct.Id)){
                mapAllProduct.remove(objProduct.Id);
            }
        }
        
        //Picklist value of Product that display on AddNewProduct Page
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','None'));
        for(Product2 objProduct: mapAllProduct.values()){
            options.add(new SelectOption(String.valueOf(objProduct.Id),objProduct.Name));
        }
        
        return options;
    }
    
    //On Click of Next Button
    public PageReference clickNext(){
    
        Product2 objProduct =new Product2();
        //mapStationIdToLMABoolean = new Map<Id, Boolean>(); 
        //mapStringToOpportunityLineItem = new Map<String, OpportunityLineItem>();
        if( SelectedList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select at least one product'));
            return null;
        }else if(SelectedList.size() > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select only one product'));
            return null;
        }
        
        if(SelectedList.size() > 0 )
            SelectedProductId = SelectedList[0];
            
        if(SelectedProductId == 'None'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select at least one product'));
            return null;
        }
    
        SelectedProductId = SelectedProductId.remove('[').remove(']');
        
        //Get Product record from Selected Product Record
        for(Product2 objSelectedProduct: [Select Product_Version__c, 
                                                 PPF_Type__c, 
                                                 MSA_Type__c, 
                                                 MSA_Incremental_Type__c, 
                                                 ME__c, Id, 
                                                 ATC__c, MSA_Bundle__c, Family
                                           From Product2  
                                           where Id =:SelectedProductId]){
                                      
            objProduct =  objSelectedProduct;
        }
        
        // LastViewedDate, LastReferencedDate, 
        //Get Opportunity record from where Opportunity 
        Opportunity objOpportunity = new Opportunity();
        for(Opportunity objOpp: [Select  Type, Total_TSR_MSA__c, Total_Override__c, Total_Override_Comments__c, 
			Total_Contract_Price__c, TotalOpportunityQuantity, TSR_In_Hierarchy_PPF__c, SystemModstamp, Sub_Total_Price__c, 
			Sub_Total_Price_2__c, Status2__c, Station_Product_Program_POC__c, StageName, Renewal_Batch__c, Record_has_been_renewed__c, 
			Record_Locked__c, RecordTypeId, Processor__c, Probability, Pricing_Tier__c, Pricebook2Id, Previous_FY_Opportunity__c, 
			OwnerId, Original_Contract_Price__c, Opportunity_Type__c, NextStep, Name, NPRStations_Validated__c, Legacy_ID__c, 
			LeadSource, Last_FY_MSA_Anchor_List_Price__c, LastModifiedDate, LastModifiedById, 
			LastActivityDate, IsWon__c, IsWon, IsPrivate, IsDeleted, IsClosed, Include_In_Next_FY_Renewal__c, Id, 
			HasOpportunityLineItem, ForecastCategoryName, ForecastCategory, Fiscal_Year__c, FiscalYear, FiscalQuarter, Fiscal, 
			FY_Fee_Percentage__c, FY_End_Date__c, ExpectedRevenue, End_of_FY__c, End_Date__c, Display_Refresh__c, Discount__c, 
			Discount_Type__c, Discount_Comments__c, Description, Days_in_Opportunity__c, CreatedDate, CreatedById, 
			Contract_Executed_Date__c, Completion_Status__c, CloseDate, CampaignId, Amount, Allow_Refresh__c, Admin_Fee__c, 
			Admin_Fee_Override__c, Admin_Fee_Override_Comments__c, Account_Owner__c, AccountId, Account.Membership_Status_for_MSA__c,
            Account.Membership_Pricing_Status__c, Account.Minority_Status1__c, Account.Id, Account.Email_List_Size__c
			From Opportunity o where Id =:strOppId]){
                objOpportunity = objOpp;                                
            }
        for(OpportunityLineItem objOppLineItem: [Select Id,
                                                        Station__r.Email_List_Size__c,
                                                        Station__r.Membership_Pricing_Status__c,
                                                        Station__r.Name,
                                                        Station__r.Id,
                                                        Station__r.LMA__c,
                                                        Station__c,
                                                        Opportunity.Id From OpportunityLineItem
                                                        where Opportunity.Id =: strOppId]){
                mapIdToAccountId.put(objOppLineItem.Opportunity.Id, objOppLineItem);                                            
                SetOpportunityLineItemStation.add(objOppLineItem.Station__r.Id);    
                mapStationIdToLMABoolean.put(objOppLineItem.Station__r.Id, objOppLineItem.Station__r.LMA__c);   
        }
        
        //Call to createNPRandOpportunityProductRecord fucntion for Inserting NPR and Opportunity Product Record
        createNPRandOpportunityProductRecord(objProduct,objOpportunity);
        //return null;
        
        String strRedirectURL = '/apex/OpportunityViewOverride?id='+strOppId;
        PageReference objPageRefer = new PageReference(strRedirectURL);
        objPageRefer.setRedirect(true);
        return objPageRefer;
        
    }
    
    //Cancel Button click - Redirect to Opportunity View Override page
    public PageReference clickCancel(){
        String strRedirectURL = '/apex/OpportunityViewOverride?id='+strOppId;
        PageReference objPageRefer = new PageReference(strRedirectURL);
        objPageRefer.setRedirect(true);
        return objPageRefer;
    }
    
    //
    public void createNPRandOpportunityProductRecord(Product2 objProduct ,Opportunity objOpportunity){
        
        List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>(); 
        
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();  
        objNPR = new NPR_Product__c(); 
        objNPR.Opportunity_Name__c = objOpportunity.Id;
        objNPR.Product__c = objProduct.Id;
        objNPR.Bill_Start_Date__c = objOpportunity.CloseDate;
        objNPR.Bill_End_Date__c = objOpportunity.End_Date__c;
        
          //initialize NPR Products for objOpportunity
		populateMapsForNprProdInitQuery(objOpportunity, objNPR, objProduct);
		
		List<NPR_Product__c> listToInsert = new List<NPR_Product__c>(); 		
		if (objOpportunity.Id!=null && oppAccountMap!=null && oppAccountMap.get(objOpportunity.Id)!=null && oppNprProdMap!=null && oppNprProdMap.get(objOpportunity.Id)!=null && oppProductsMap != null && oppProductsMap.get(objOpportunity.Id)!=null)
		{
			listToInsert.addAll(pu.initNPRProds(objOpportunity, oppAccountMap.get(objOpportunity.Id), oppNprProdMap.get(objOpportunity.Id), oppFYMap.get(objOpportunity.Id), oppDiscountMap.get(objOpportunity.Id), oppProductsMap.get(objOpportunity.Id), pricingTables, pricingMsaLicenseFees));
		}
			
		if (listToInsert.size()>0) insert listToInsert;		
        else insert objNPR;
        
        List<PricebookEntry> lstPricebookEntry = [Select UnitPrice, ProductCode, 
                                                         Product2Id, Pricebook2Id, 
                                                         Name, Id 
                                                  From PricebookEntry 
                                                  Where Product2Id = : objProduct.Id
                                                  and Pricebook2Id = : objOpportunity.Pricebook2Id ]; 
            
            if(Test.isRunningTest()){
                lstOppLineItem = null;
            }       
            else{                       
                if(lstPricebookEntry.size() > 0 ) {
                    lstOppLineItem =  getOpportunityLineItem(SetOpportunityLineItemStation, 
                                                                 objOpportunity.Fiscal_Year__c , 
                                                                 lstPricebookEntry[0].Product2Id);
                }           
            }
                    
            if(lstOppLineItem == null || lstOppLineItem.isEmpty() && lstOppLineItem.size() == 0)
            {
            	Map<Id,Id> pbeToProd = new Map<Id,Id>();
            	    
            	system.debug('\n\n mapStationIdToLMABoolean.keySet() = ' + mapStationIdToLMABoolean.keySet() + '\n\n');
                //Create new Opportunity Product
                for(Id accountId : mapStationIdToLMABoolean.keySet())
                {
                	//if(objProduct.MSA_Type__c == 'Member' && mapStationIdToLMABoolean.get(accountId) == true){
                	system.debug('\n\n objProduct.MSA_Type__c = ' + objProduct.MSA_Type__c + '\n\n');
                	system.debug('\n\n mapStationIdToLMABoolean.get(accountId) = ' + mapStationIdToLMABoolean.get(accountId) + '\n\n');
                	// Dont want to create if member && lma=true
                	// want to create if != member && lma=true
                	//                if != member && lma=false
                	//                if == member && lma=false
                    if(objProduct.MSA_Type__c != 'Member' || mapStationIdToLMABoolean.get(accountId) == false){  
                        OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
                        objOpportunityLineItem.OpportunityId = objOpportunity.Id;
                        objOpportunityLineItem.PricebookEntryId = lstPricebookEntry[0].Id;
                        objOpportunityLineItem.Bill_Start_Date__c = objOpportunity.CloseDate;
                        objOpportunityLineItem.Bill_End_Date__c = objOpportunity.End_Date__c;
                        objOpportunityLineItem.Station__c = accountId;
                        objOpportunityLineItem.Quantity = 1;
                        objOpportunityLineItem.NPR_Product__c = objNPR.Id;
                        objOpportunityLineItem.UnitPrice = 0; 
                        
                        lstInsertOppLineItem.add(objOpportunityLineItem);
                        pbeToProd.put(lstPricebookEntry[0].Id, lstPricebookEntry[0].Product2Id);
                    }
                }
                       
                //initialize Opportunity products for MSA Opportunities before inserting
                if (objOpportunity.Type=='MSA')
                {
                	List<Opportunity> msaOpps = new List<Opportunity>();
                	msaOpps.add(objOpportunity);
                	
                	List<NPR_Product__c> nprProds = new List<NPR_Product__c>();
					nprProds.add(objNPR);
                	
                	if (objProduct.Family=='MSA') productListMSA.add(objProduct);  					
  					                    	                	
					populateMapsForOppProdInitQuery(lstInsertOppLineItem, msaOpps, nprProds, productListMSA, pbeToProd);
					
					Map<String, List<Account>> oppStationsMap = new Map<String, List<Account>>();
					oppStationsMap.put(objOpportunity.Id, new List<Account> { objOpportunity.Account });
												
					for (Opportunity opp: msaOpps)
					{
						if (opp.Id!=null && lstInsertOppLineItem!=null && oppNprProdMap!=null && oppProductsMap != null && oppStationsMap!=null)
						{
							//initialize Opp Products for each opportunity and add them to the list for mass insert
							oliListToInsert.addAll(pu.initOLIs(opp, lstInsertOppLineItem, oppNprProdMap.get(opp.Id), oppProductsMap.get(opp.Id), oppStationsMap.get(opp.Id), MSAIncStreamingList, MSAIncEmailList, lstPricebookEntry));
						}
					}               
                }
                
                system.debug('\n\n lstInsertOppLineItem = ' + lstInsertOppLineItem + '\n\n');
                system.debug('\n\n oliListToInserts = ' + oliListToInsert + '\n\n');
                if (oliListToInsert.size()>0) insert oliListToInsert;
                else 
                {              
                	//Insert New Opportunity Product
                	if(lstInsertOppLineItem != null && !lstInsertOppLineItem.isEmpty() && lstInsertOppLineItem.size() > 0)
                	insert lstInsertOppLineItem;
                }
            }
            
                
        if(lstInsertOppLineItem != null && !lstInsertOppLineItem.isEmpty()){
            
            for(OpportunityLineItem objOpportunityLineItem :lstInsertOppLineItem){
                
                String strKey = objOpportunityLineItem.PricebookEntryId;
                mapStringToOpportunityLineItem.put(strKey,objOpportunityLineItem);
            }
        }
        
        if(SetOpportunityLineItemStation != null && objOpportunity.Fiscal_Year__c != null && lstPricebookEntry[0].Product2Id != null){  
            updateOpportunityLineitem(SetOpportunityLineItemStation,Double.valueOf(objOpportunity.Fiscal_Year__c),lstPricebookEntry[0].Product2Id);
        }
        
        //CALC OPPORTUNITY - Run pricing calculation on Opportunity	
        List<Opportunity> opps = new List<Opportunity>();
		opps.add(objOpportunity);
		
		calcOpp(opps);	           
    }
    
    //Update New and Old Opportunity Product as per Condition
    public void updateOpportunityLineitem(Set<String> SetOpportunityLineItemStation, Double fiscalYear , Id productId ){
        
        
         if(SetOpportunityLineItemStation != null && fiscalYear != null && productId != null){  
                        
            List<OpportunityLineItem> lstPreviousOppLineItem = getOpportunityLineItem(SetOpportunityLineItemStation, 
                                                                                          Decimal.valueOf(fiscalYear - 1), 
                                                                                          productId);
          
            if(lstPreviousOppLineItem != null && !lstPreviousOppLineItem.isEmpty()){                                                
                for(OpportunityLineItem objOpportunityLineItem : lstPreviousOppLineItem){
                    
                    String strKey = objOpportunityLineItem.PricebookEntryId;
                    
                    if(mapStringToOpportunityLineItem.containsKey(strKey)){
                        
                        OpportunityLineItem newOpportunityLineItem = mapStringToOpportunityLineItem.get(strKey);
                
                        newOpportunityLineItem.Last_FY_Opp_Product_ID__c = objOpportunityLineItem.Id;
                        objOpportunityLineItem.Next_FY_Opp_Product_ID__c = newOpportunityLineItem.Id;
                        
                        if(objOpportunityLineItem.Air_Onboard_Status__c == 'Complete'){
                            
                            newOpportunityLineItem.Adopt_Status__c  = objOpportunityLineItem.Adopt_Status__c;
                            newOpportunityLineItem.Adopt_Date__c = objOpportunityLineItem.Adopt_Date__c; 
                            newOpportunityLineItem.Air_Onboard_Date__c = objOpportunityLineItem.Air_Onboard_Date__c;
                            newOpportunityLineItem.Air_Onboard_Status__c =  objOpportunityLineItem.Air_Onboard_Status__c; 
                                
                            newOpportunityLineItem.Drop_Date__c = null;
                            newOpportunityLineItem.Drop_Reason__c = null; 
                        }
                        if(objOpportunityLineItem.Air_Onboard_Status__c == 'Dropped'){
                            
                            newOpportunityLineItem.Adopt_Status__c  = null;
                            newOpportunityLineItem.Adopt_Date__c =null; 
                            newOpportunityLineItem.Air_Onboard_Date__c = null;
                            newOpportunityLineItem.Air_Onboard_Status__c =  null; 
                                
                            newOpportunityLineItem.Drop_Date__c = null;
                            newOpportunityLineItem.Drop_Reason__c = null; 
                        }
                        
                        lstUpdateOpportunityLineItem.add(objOpportunityLineItem);
                        lstUpdateOpportunityLineItem.add(newOpportunityLineItem);
                        setOpportunityLineItem.add(newOpportunityLineItem);
                        setOpportunityLineItem.add(objOpportunityLineItem);
                        
                    }
                }               
            }   
        }
        
        //Udpate the Old and New Opportunity Product            
        if(setOpportunityLineItem != null && !setOpportunityLineItem.isEmpty())
        {
            List<OpportunityLineItem> lstOppLineItemUpdate = new List<OpportunityLineItem>();
            lstOppLineItemUpdate.addAll(setOpportunityLineItem);
            
            update lstOppLineItemUpdate;
        }
    }
    
    //Get All Opportunity Product with Matching Fiscal year and Product
    private List<OpportunityLineItem> getOpportunityLineItem(Set<String> SetOpportunityLineItemStation, 
                                                                  Decimal fiscalYear, Id productId ){ 
                                                                    
         return  [Select Id,
                        Station__r.Email_List_Size__c,
                        Station__r.Membership_Pricing_Status__c,
                        Station__r.Name,
                        Station__r.Id,
                        Station__c,
                        Quantity,
                        Opportunity.Id,
                        Fiscal_Year__c,
                        Adopt_Date__c, 
                        Adopt_Status__c, Air_Onboard_Date__c, 
                        PricebookEntry.Product2Id,
                        OpportunityId,
                        PricebookEntryId,
                        Air_Onboard_Status__c, 
                        Drop_Date__c,
                        Drop_Reason__c
                   From OpportunityLineItem
                   Where PricebookEntry.Product2Id =: productId and
                   Station__c IN :SetOpportunityLineItemStation and
                   Fiscal_Year__c =: fiscalYear];
    }
    
    public void populateMapsForNprProdInitQuery(Opportunity newOpp, NPR_Product__c nprProd, Product2 pr)
	{
		List<Opportunity> opps = new List<Opportunity>();
		opps.add(newOpp);
		
		List<NPR_Product__c> nprProds = new List<NPR_Product__c>();
		nprProds.add(nprProd);
	
		populateOppAccountMap(newOpp);
		oppFYMap = pu.FYPricingDetailQuery(opps);
		oppDiscountMap = pu.NPRDiscountQuery(opps, oppAccountMap.values());
		
		oppNprProdMap.put(newOpp.Id, new List<NPR_Product__c> { nprProd });
		oppProductsMap.put(newOpp.Id, new List<Product2> { pr });
		
		pricingTables = pu.pricingTable(opps, nprProds, oppAccountMap.values());
		pricingMsaLicenseFees = pu.MSALicenseFee(opps, nprProds, oppAccountMap.values());		
	}
	
	public void populateOppAccountMap(Opportunity opp)
	{
		Account oppAccount = [SELECT Id, Minority_Status__c, Membership_Pricing_Status__c, Membership_Status_for_MSA__c FROM Account where Id =: opp.AccountId];
		
		if (oppAccount!=null) oppAccountMap.put(opp.Id, oppAccount);
	}
	
	public void populateMapsForOppProdInitQuery(List<OpportunityLineItem> oppProductList, Opportunity[] msaOpps, List<NPR_Product__c> nprProducts, List<Product2> productListMSA, Map<Id,Id> pbeToProd)
	{
		List<Account> stations = new List<Account>();
		stations.add(msaOpps[0].Account);
		
		if (oppProductList!=null && nprProducts!=null && msaOpps!=null && productListMSA!=null)
		{
			MSAIncStreamingList = pu.MSAIncrementalStreaming(oppProductList, nprProducts, msaOpps, productListMSA, pbeToProd, oppAccountMap);
		}
		if (oppProductList!=null && nprProducts!=null && stations!=null)
		{
			MSAIncEmailList = pu.MSAIncrementalEmail(oppProductList, nprProducts, stations);
		}			
	}
	
	public void calcOpp(List<Opportunity> newOpps)
	{
		// LastViewedDate, LastReferencedDate, 
		List<Opportunity> oppsToUpdate = [select Type, Total_TSR_MSA__c, Total_Override__c, Total_Override_Comments__c, 
			Total_Contract_Price__c, TotalOpportunityQuantity, TSR_In_Hierarchy_PPF__c, SystemModstamp, Sub_Total_Price__c, 
			Sub_Total_Price_2__c, Status2__c, Station_Product_Program_POC__c, StageName, Renewal_Batch__c, Record_has_been_renewed__c, 
			Record_Locked__c, RecordTypeId, Processor__c, Probability, Pricing_Tier__c, Pricebook2Id, Previous_FY_Opportunity__c, 
			OwnerId, Original_Contract_Price__c, Opportunity_Type__c, NextStep, Name, NPRStations_Validated__c, Legacy_ID__c, 
			LeadSource, Last_FY_MSA_Anchor_List_Price__c, LastModifiedDate, LastModifiedById, 
			LastActivityDate, IsWon__c, IsWon, IsPrivate, IsDeleted, IsClosed, Include_In_Next_FY_Renewal__c, Id, 
			HasOpportunityLineItem, ForecastCategoryName, ForecastCategory, Fiscal_Year__c, FiscalYear, FiscalQuarter, Fiscal, 
			FY_Fee_Percentage__c, FY_End_Date__c, ExpectedRevenue, End_of_FY__c, End_Date__c, Display_Refresh__c, Discount__c, 
			Discount_Type__c, Discount_Comments__c, Description, Days_in_Opportunity__c, CreatedDate, CreatedById, 
			Contract_Executed_Date__c, Completion_Status__c, CloseDate, CampaignId, Amount, Allow_Refresh__c, Admin_Fee__c, 
			Admin_Fee_Override__c, Admin_Fee_Override_Comments__c, Account_Owner__c, AccountId, Account.Membership_Status_for_MSA__c
			from Opportunity where Id in: newOpps];
		List<Opportunity> newSet = new List<Opportunity>();
		
		System.debug('\n\n\noppNprProdMap is: ' + oppNprProdMap + '\n\n\n');
		
		for (Opportunity opp : oppsToUpdate) 
		{
			System.debug('\n\n\nopp is: ' + opp + '\n\n\n');
			System.debug('\n\n\noppNprProdMap.get(opp) is: ' + oppNprProdMap.get(opp.Id) + '\n\n\n');
			
			for(NPR_Product__c npr : oppNprProdMap.get(opp.Id))
			{
				newSet.add(pu.calcOpportunity(opp, npr, new NPR_Product__c())); 
			}
		}
	
		if (newSet.size()>0) update newSet;
	}
  
}