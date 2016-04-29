public with sharing class OpportunityViewOverride {
	
	private Opportunity opp;
	public String oppType{get; set;}
	public String oppId{get; set;}
	
	public list<NPR_Product__c> nrpBundles{get; set;}
	// Holds dynamically seleted OLI for MSA
	public OpportunityLineItem selectedOli{get; set;}
	// Holds dynamically seleted NPR Product for MSA
	public NPR_Product__c selectedNPRProd{get; set;}
	public set<String> stationNames{get; set;}
	
	public list<NPR_Product__c> nprProducts{get; set;}
	public list<list<OpportunityLineItem>> oliListList{get; set;}
	// Boolean that will show detial section if true
	public Boolean showDetails{get; set;}
	public Boolean showRefreshPopUp{get; set;}
	public Boolean showRenewPopUp{get; set;}
	
	public String bundleName {get; set;}
	
	 public OpportunityViewOverride(ApexPages.StandardController stdController) {
        
        stationNames = new set<String>{};
        
        this.opp = (Opportunity)stdController.getRecord();
        
        Opportunity o = [select Id, Type from Opportunity where Id=:opp.Id];
        
        oppType = o.Type;
        oppId = o.Id;
        
        stationNames = includedStationsQuery();
        getBundleNameOnPageLoad();
        // If type is MSA+
        system.debug('opp.type======>>>>> '+opp.type);
    	if(opp.type=='MSA')
    	{
    		oliListList = getOliLists();
    		nrpBundles = queryNPRBundle();
    		system.debug('nrpBundles==in view==>>> '+nrpBundles.size() + '=====>>>> '+nrpBundles);
    		system.debug('oliListList==in view==>>> '+oliListList.size() + '=====>>>>>>' +oliListList);
    	}
    	if(opp.type=='PPF')
    	{
    		nprProducts = nprProductListQueryPPF();
    	}
    }
    
    /*Added by Suhas*/
    public void getBundleNameOnPageLoad() {
        List<NPR_Product__c> nprProdList = new List<NPR_Product__c>();

        nprProdList = [select Id, Product__r.Name from NPR_Product__c 
                        where Opportunity_Name__c=:opp.Id and MSA_Bundle__c=true and Include_In_PPF_MSA__c = true];

        if(nprProdList != null && nprProdList.size() > 0) {
            system.debug('nprProdList[0].Product__r.Name=====>>> '+nprProdList[0].Product__r.Name);
            bundleName = nprProdList[0].Product__r.Name;
        }
        system.debug('bundleName in view==>>> '+bundleName);
    }
    /*Ends here Suhas*/
    
    public PageReference edit()
	{	
  		PageReference oppPage = new PageReference('/apex/OpporunityEditOverride?id='+opp.Id);
  		return oppPage;
	}
	
	public list<NPR_Product__c> queryNPRBundle()
    {   
    	system.debug('opp.Id====>>>> '+opp.Id);
    	return [select Id, Name, Include_In_PPF_MSA__c, Base_Fee_Annualized__c, Air_Onboard_Date__c, License_Fee_Annualized__c, MSA_Cap__c,
    		Last_FY_MSA_Anchor_List_Price__c, Last_FY_MSA_Price_Override__c, Final_Last_FY_MSA_Anchor_Price__c, Subtotal_Fee__c, Air_Onboard_Status__c,
    		Override_Discount__c, Drop_Date__c, Override_Discount_Comments__c, Drop_Reason__c, Override_Fee__c, Bill_Start_Date__c, Override_Fee_Comments__c,
    		Bill_End_Date__c, Product__r.Name, Final_Fee__c, LastModifiedBy.Name, LastModifiedDate, Other_Discount_Type__c, Final_Air_Date__c
    		from NPR_Product__c where Opportunity_Name__c=:opp.Id and MSA_Bundle__c=true];	
    }
    
	public set<String> includedStationsQuery()
    {
    	set<String> stationNameList = new set<String>{};
    	for(OpportunityLineItem oli : [select Id, Station_Name__c, Station__r.Name, Station__r.Type2__c from OpportunityLineItem where OpportunityId=:opp.Id])
    	{
    		if(!stationNameList.contains(oli.Station__r.Name+ ' ('+convertOliType(oli.Station__r.Type2__c)+')'))
    		{
    			stationNameList.add(oli.Station__r.Name + ' ('+convertOliType(oli.Station__r.Type2__c)+')');
    		}
    	}
    	return stationNameList;
    }
    
    public String convertOliType(String strType)
    {
    	if(strType!=null)
    	{
    		String returnString = '';
    		returnString = strType.replaceAll(';', ', ');
    		return returnString;
    
    	}
    	return strType;
    }
    
    public list<NPR_Product__c> nprProductListQueryPPF()
    {
    	return [select Id, Name, Product__r.Name, NPR_Product_Link__c
    		from NPR_Product__c where Opportunity_Name__c=:opp.Id order by Product__r.PPF_Type__c, Product__r.Name];	
    }
    
    public list<OpportunityLineItem> OLIListQueryMSA()
    {
    	return [select Id, Name, Station__r.Name, NPR_Product__c, NPR_Product__r.Product__r.Name, Opportunity_Product_Link__c
    	           ,NPR_Product__r.Product__r.Bundle__c
    		from OpportunityLineItem where OpportunityId=:opp.Id and Product2.MSA_Bundle__c=false order by NPR_Product__r.Product__r.Name,  Opportunity_Product_Link__c];	
    }
    
    public OpportunityLineItem OLIQueryMSA(String id)
    {
    	return [select Id, Name, Interested_In_Product__c, Recurrence_Price__c, Recurrence_Type__c, Annualized_Price__c, Set_up_Fee__c,
    		Subtotal_Fee__c, Override_Fee__c, Override_Fee_Comments__c, Final_Price__c, Bill_Start_Date__c, Bill_End_Date__c, Email_List_Size__c,
    		Adopt_Status__c, Adopt_Date__c, Air_Onboard_Date__c, Air_Onboard_Status__c, Drop_Date__c, Drop_Reason__c, 
    		Product2.MSA_Incremental_Type__c, Station__r.Name, NPR_Product__r.Product__r.Name, Opportunity_Product_Link__c,
    		LastModifiedBy.Name, LastModifiedDate
    		from OpportunityLineItem where Id=:id];	
    }
    
    public NPR_Product__c nprProductQueryPPF(String id)
    {
    	return [select Id, Name, Include_in_PPF_MSA__c, List_Fee__c, Discount_Type__c, Discount_Percent__c, Subtotal_Fee__c, Override_Discount__c, 
    		Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Air_Onboard_Date__c, Air_Onboard_Status__c, 
    		Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c, ATC_Uncapped_Price__c,
    		ATC_Last_FY_Price__c, Cap_Percent__c, ATC_Capped_Final_Fee__c, Last_FY_Fee_Override__c, Accelerated_Cap__c, 
    		Accelerated_Cap_Comments__c, Final_Fee__c, Product__r.PPF_Type__c, Product__r.Name, List_Fee_Annualized__c, List_Fee_Prorated__c,
    		Product_Name__c, NPR_Product_Link__c, LastModifiedBy.Name, LastModifiedDate, Other_Discount_Type__c, Final_Air_Date__c,
    		/* Added by Suhas 
                            According to Opportunity New, Repositioned and Relabeled Fields Detailed Design doc*/
    		Year_over_Year_Change__c,
    		Delta_Uncapped_and_Final_Price__c,
    		Prior_Year_Price__c,
    		Prior_Year_Discount__c,
    		Prior_Year_Discount_Type__c  
    		/*Added Code ends here*/
    		from NPR_Product__c where Id=:id];	
    }
    
    public list<list<OpportunityLineItem>> getOliLists()
    {
    	list<list<OpportunityLineItem>> oliLists = new list<list<OpportunityLineItem>>{};
    	list<OpportunityLineItem> oliList = new list<OpportunityLineItem>{};
    	
    	Boolean firstTime = true;
    	String lastNPRProdId = '';
    	for(OpportunityLineItem oli : OLIListQueryMSA())
    	{
    		if(firstTime)
    		{
    			firstTime = false;
    			lastNPRProdId = oli.NPR_Product__c;
    		}
    		if(oli.NPR_Product__c!=lastNPRProdId)
    		{
    			oliLists.add(oliList);
    			oliList = new list<OpportunityLineItem>{};
    		}
    		oliList.add(oli);
    		lastNPRProdId = oli.NPR_Product__c;
    	}
    	oliLists.add(oliList);
    	
    	
    	return oliLists;
    }
    
    public Map<String, OpportunityLineItem> oliMap = new Map<String, OpportunityLineItem>{};
    public void viewDetailsMSA()
    {
    	// Get passed in param
    	String oliId = ApexPages.currentPage().getParameters().get('oliId'); 
    	
    	// check if current oli is in map
    	if(oliMap.get(oliId)!=null)
    	{
    		// if found set selectedOli
    		selectedOli = oliMap.get(oliId);
    	}
    	else
    	{
    		// else if not found query for OLI
    		selectedOli = OLIQueryMSA(oliId);
    		// add to map
    		oliMap.put(selectedOli.Id, selectedOli);
    	}
    	showDetails=true;
    }
    
    public Map<String, NPR_Product__c> nprProdMap = new Map<String, NPR_Product__c>{};
    public void viewDetailsPPF()
    {
    	// Get passed in param
    	String nprProdId = ApexPages.currentPage().getParameters().get('nprProdId'); 
    	
    	// check if current NPR Prod is in map
    	if(nprProdMap.get(nprProdId)!=null)
    	{
    		// if found set selectedNPRProd
    		selectedNPRProd = nprProdMap.get(nprProdId);
    	}
    	else
    	{
    		// else if not found query for NPR Prod
    		selectedNPRProd = nprProductQueryPPF(nprProdId);
    		// add to map
    		nprProdMap.put(selectedNPRProd.Id, selectedNPRProd);
    	}
    	showDetails=true;
    }
    
    public void closeDetails()
    {
    	showDetails=false;
    }
    
    public void refresh()
    {
    	String keepOverrides = ApexPages.currentPage().getParameters().get('keepOverrides'); 
    	system.debug('\n\n\n keepOverrides = '+keepOverrides+'\n\n\n');
    	showRefreshPopUp = false;
    	
    	// Lock record
    	opp.Record_Locked__c = true;
    	update opp;
    	// Call async refresh method
    	refreshAsync(opp.Id, keepOverrides);
    }
    
    public static Opportunity queryAllOppFields(String oppId)
    {
    	// LastViewedDate, LastReferencedDate, 
    	return [select Type, Total_TSR_MSA__c, Total_Override__c, Total_Override_Comments__c, 
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
			Account.Membership_Pricing_Status__c
			from Opportunity where Id=:oppId];
    }
    
    @future 
    public static void refreshAsync(String oppId, String keepOverrides)
    {
		Opportunity o = queryAllOppFields(oppId);
    	
    	RefreshOpportunityClass roc = new RefreshOpportunityClass();
    	
    	
    	// Call refresh method
    	if(keepOverrides=='true')
    	{
    		system.debug('\n\n refreshOpportunityKeepOverrides \n\n');
    		roc.refreshOpportunityKeepOverrides(o);
    	}
    	else
    	{
    		system.debug('\n\n refreshOpportunityNoOverrides \n\n');
    		roc.refreshOpportunityNoOverrides(o);
    	}
    	
    	// Unlock record
		o.Record_Locked__c = false;
    	update o;
    }
    
    public pageReference renew()
    {	
    	// Stop record from being renewed more than once
    	//opp.Record_has_been_renewed__c = true
    	//update opp;
    	closeRenewPopupPanel();
    	// Call async renew method
    	renewAsync(opp.Id);
    	
    	PageReference accPage = new PageReference('/'+opp.AccountId);
  		accPage.setRedirect(true);
  		return accPage;
    }
    
    @future 
    public static void renewAsync(String oppId)
    {	
    	system.debug('\n\n 2 \n\n');
    	Opportunity o = queryAllOppFields(oppId);
    	// Call renew method
    	RenewOpportunityClass roc = new RenewOpportunityClass();
    	Opportunity newOpp = roc.generateRenewal(o);
    }
    
    public pageReference closeRefreshPopupPanel()
    {
    	showRefreshPopUp = false;
    	return null;
    }
    
    public pageReference refreshClick()
    {
    	showRefreshPopUp = true;
    	return null;
    }
    
    public pageReference closeRenewPopupPanel()
    {
    	showRenewPopUp = false;
    	return null;
    }
    
    public pageReference renewClick()
    {
    	showRenewPopUp = true;
    	return null;
    }
	
}