public class NewOpportunityClass 
{
    public Map<Id, Opportunity> accountOppMapPPF {set; get;}
    public Map<Id, Opportunity> accountOppMapMSA {set; get;}
    public Map<Id, Account> oppAccountMap {set; get;}
    public Map<Id, Account> oppAccountMapMSA {set; get;}
    public List<NPR_Product__c> allNprProducts {set; get;}
    public Map<Id, NPR_Product__c> oliNprProdMap {set; get;}
        
    public Map<String, list<FY_Pricing_Detail__c>> oppFYMap {set; get;}
    public Map<String, list<Discounts__c>> oppDiscountMap {set; get;}
    public List <Pricing_Table__c> pricingTables {set; get;}
    public List<Pricing_MSA_License_Fee__c> pricingMsaLicenseFees {set; get;}
    public List<MSA_Incremental__c> MSAIncStreamingList {set; get;}
    public List<MSA_Incremental__c> MSAIncEmailList {set; get;}
        
    public List<Opportunity> oppsToUpdatePPF {set; get;}
    public List<Opportunity> oppsToUpdateMSA {set; get;}
    public List<Product2> productListMSA {set; get;}
    public List<Product2> combinedProductList {set; get;}
    
    public  Map<Opportunity, List<Account>> oppStationsMapMSA {set; get;}
    public  Map<Opportunity, List<Account>> oppStationsMapBefore {set; get;}
    public  Map<String, List<Account>> oppStationsMap {set; get;}
    public  Map<Opportunity, List<Product2>> oppProductsMapPPF {set; get;}
    public  Map<Opportunity, List<Product2>> oppProductsMapMSA {set; get;}
    public  Map<String, List<NPR_Product__c>> oppNprProdMap {set; get;}
    
    public  Map<String, NPR_Product__c> productToNprProdMap {set; get;}
    public  Map<String, String> productToOppAccountMap {set; get;}
    public  Map<String, Decimal> productToFYMap {set; get;}
    public  Map<String, OpportunityLineItem> productToOppProdMap {set; get;}
    public  PricingUtility pu {set; get;}
                
    public  List<Account> stations1PPF {set; get;}
    public  List<Account> stations1MSA {set; get;}
    public  List<Account> stations1 {set; get;}
    public  List<Account> stations2 {set; get;}
    public  List<Account> stations3 {set; get;}
    public  List<Account> stationsFinal {set; get;}
                    
    ///<summary> WrapperClass for Account-Opportunity fields </summary>
    public class accountOppWrapper
    {
        public Account a {get;set;}
        public Opportunity o {get; set;}
    }               
                    
    public List<accountOppWrapper> accOppWrapperList {set; get;}
                            
    public NewOpportunityClass()
    {
        accountOppMapPPF = new Map<Id, Opportunity>();
        accountOppMapMSA = new Map<Id, Opportunity>();
        oppAccountMap = new Map<Id, Account>(); 
        
        oppFYMap = new Map<String, list<FY_Pricing_Detail__c>>(); 
        oppDiscountMap = new Map<String, list<Discounts__c>>(); 
        pricingTables = new List <Pricing_Table__c>();
        pricingMsaLicenseFees = new List<Pricing_MSA_License_Fee__c>();
        
        allNprProducts = new List<NPR_Product__c>(); 
        
        oppsToUpdatePPF = new List<Opportunity>();
        oppsToUpdateMSA = new List<Opportunity>();
        combinedProductList = new List<Product2>();
    
        oppStationsMapMSA = new Map<Opportunity, List<Account>>();
        oppStationsMapBefore = new Map<Opportunity, List<Account>>();
        oppStationsMap = new Map<String, List<Account>>();
        oppProductsMapPPF = new Map<Opportunity, List<Product2>>();
        oppProductsMapMSA = new Map<Opportunity, List<Product2>>();
        oppNprProdMap = new Map<String, List<NPR_Product__c>>();
        
        oliNprProdMap = new Map<Id, NPR_Product__c>(); 
    
        productToNprProdMap = new Map<String, NPR_Product__c>();
        productToOppProdMap = new Map<String, OpportunityLineItem>();
        pu = new PricingUtility();
                
        stations1PPF = new List<Account>();
        stations1MSA = new List<Account>();
        stations1 = new List<Account>();
        stations2 = new List<Account>();
        stations3 = new List<Account>();
        stationsFinal = new List<Account>();
        
        productToOppAccountMap = new Map<String, String>(); 
        productToFYMap = new Map<String, Decimal>();
        productListMSA = new List<Product2>();  
        
        MSAIncStreamingList = new List<MSA_Incremental__c>(); 
        MSAIncEmailList = new List<MSA_Incremental__c>();
        
        accOppWrapperList = new List<accountOppWrapper>(); 
    }   
                
    public  void opportunityCreationProcess(Opportunity[] newOpps)
    {
        populateAccountOppMapsBefore(newOpps);
        //populateStationsList();
        // Need this because the oppId is null because it is before insert      
        populateStationsListBefore();
                        
        oppInit();  
    }
    
    public  void opportunityCreationProcessAfter(Opportunity[] newOpps)
    {
        System.debug('\n\n\n opportunityCreationProcessAfter \n\n\n');
        for(Opportunity o : newOpps)
        {
            system.debug('***\n\n'+o.Account.Membership_Status_for_MSA__c+'\n\n***');
        }
        
        clearAll();
        populateAccountOppMaps(newOpps);        
        populateStationsList();
        
        createNprProducts(newOpps);         
        linkNprProducts(newOpps);
        
        requeryNPRProducts(newOpps);                    
                    
        //Create Opportunity Products--------------------------------
        createOpportunityProducts(oppProductsMapPPF);
        createOpportunityProducts(oppProductsMapMSA);   
        linkOppProducts(newOpps);
        
        //CALC OPPORTUNITY - Run pricing calculation on Opportunity 
        calcOpp(newOpps);           
        
        System.debug('\n\n\nOpportunity is: ' + newOpps[0] + '\n\n\n');
    }
    
    public  Account[] relatedStationsQuery1(Set<Id> accIds, String oppType)
    {
        //Capture a list of accounts that should be included in the opportunity
        //this list will be used to create Opportunity Product records
        
        //The query will identify child accounts related to the Opportunity.Account based on the 
        //standard Salesforce account hierarchy.  The results of this list will be used as the 
        //basis for 'Related Stations Query 2' below
        
        if (oppType == 'PPF')
        {
            system.debug('\n\n\n Related Stations Query for PPF \n\n\n');
            
            return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c, TSR__c, Email_List_Size__c, 
                Membership_Status_for_MSA__c, Licensee__c 
                from Account
                Where Parent.Id in: accIds AND 
                    Type2__c includes ('Associate')];
                    // Type2__c excludes ('LMA Station')
                    // Type2__c includes ('Station')
                    //LMA__c = false];
        }
        else if (oppType == 'MSA')
        {
            system.debug('accIds=======>>>>> '+accIds);
            return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c, TSR__c, Email_List_Size__c, 
                Membership_Status_for_MSA__c, Licensee__c 
                from Account
                Where Parent.Id in: accIds AND 
                    ((Type2__c includes ('Station') OR Type2__c includes ('Associate')) AND MSA_Opt_Out__c = false) AND 
                    (Type2__c excludes ('LMA Station') OR LMA__c=true)];
        }    
        else return null;
    }
    
    public  Account[] relatedStationsQuery2(Account[] q1Accounts)
    {
        //Capture a list of accounts that should be included in the opportunity
        //this list will be used to create Opportunity Product records.  
        
        //The query will identify child accounts related to the accounts identified in the 
        //'Related Stations Query 1’, based on the standard Salesforce account hierarchy.  
        //This will only be run for Type = MSA opportunities.
        return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, Parent.Parent.Id, LMA__c, TSR__c, Email_List_Size__c, 
                Membership_Status_for_MSA__c, Licensee__c
                FROM Account
                WHERE Parent.Id in: q1Accounts AND 
                (Type2__c includes ('Station') OR Type2__c includes ('Associate')) AND 
                MSA_Opt_Out__c = false];        
    }
    
    public  Account[] oppAccountStationQuery(Set<Id> accIds)
    {
        //Determine if the Opportunity.Account is a station account and if so, add to the 'Stations' list.
        return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, TSR__c, LMA__c, Email_List_Size__c, Membership_Status_for_MSA__c,
                Licensee__c 
                FROM Account
                Where Id in: accIds AND (Type2__c includes ('Station') OR Type2__c includes ('Associate'))];
    }

    public Product2[] productsQuery(String productFamily)
    {
        //Identify products that should be pulled into the opportunity.  
        //This list of products will be used to create NPR_Product__c records and, in combination with 
        //'Stations' list, will help create Opportunity Products.
        
        return [Select Id, Name, MSA_Type__c, Product_Version__c, Active_Start_Date__c, Active_End_Date__c, PPF_Type__c, MSA_Incremental_Type__c, MSA_Bundle__c,
                ME__c, ATC__c 
                FROM Product2 
                WHERE Product_Version__c = 'Core' AND Family=:productFamily];           
    }
    
    public void requeryNPRProducts(list<Opportunity> opps)
    {
        set<String> oppIds = new set<String>();
        for(Opportunity opp : opps)
        {
            oppIds.add(opp.Id);
        }
        
        map<String, list<NPR_Product__c>> oppIdToNPR = new map<String, list<NPR_Product__c>>();
        for(NPR_Product__c npr : [select Id, License_Fee_Factor__c, Product__r.Family, Product__r.PPF_Type__c, Accelerated_Cap__c, 
            Last_FY_Fee_Override__c, ATC_Capped_Final_Fee__c, ATC_Last_FY_Price__c, List_Price_PPF_Annualized__c, List_Fee_Non_News_Annualized__c, 
            Product__r.MSA_Bundle__c, Base_Fee_Annualized__c, Opportunity_Name__r.Total_TSR_MSA__c, MSA_Cap__c, Last_FY_MSA_Price_Override__c, 
            Final_Last_FY_MSA_Anchor_Price__c, List_Fee_Annualized__c, Previous_FY_Fee_Threshold_Min__c, Previous_FY_Fee_Threshold_Max__c, 
            Annual_FY_Increase__c, Discount_From_Anchor__c, Subtotal_Fee__c, List_Fee_Prorated__c, Discount_Percent__c, Override_Discount__c, 
            Final_Fee__c, Bill_Start_Date__c, Bill_End_Date__c, Opportunity_Name__r.Last_FY_MSA_Anchor_List_Price__c, Include_In_PPF_MSA__c,
            Product_PPF_Type__c, ATC_Uncapped_Price__c             
            from NPR_Product__c 
            where Opportunity_Name__c IN :oppIds])
        {
            //populate Opportunity - Npr Products Map
            if (oppIdToNPR.containsKey(npr.Opportunity_Name__c))
                oppIdToNPR.get(npr.Opportunity_Name__c).add(npr);
            else oppIdToNPR.put(npr.Opportunity_Name__c, new List<NPR_Product__c> { npr });
        }
        system.debug('\n\n oppIdToNPR = '+oppIdToNPR+'\n\n');
        oppNprProdMap = oppIdToNPR;
        system.debug('\n\n oppNprProdMap = '+oppNprProdMap+'\n\n');
    }
        
    public void createNprProducts(Opportunity[] newOpps)
    {       
        List<Product2> productListPPF = productsQuery('PPF');
        productListMSA = productsQuery('MSA');      
        combinedProductList.addAll(productListPPF);
        combinedProductList.addAll(productListMSA);
        
        System.debug('\n\n\nIn createNprProducts\n\n\n');
        System.debug('\n\n\noppNprProdMap is: ' + oppNprProdMap + '\n\n\n');
        
        for (Opportunity opp: accountOppMapPPF.values())
        {
            for (Product2 pr: productListPPF)
            {       
                if (pr.Active_Start_Date__c <= opp.CloseDate && pr.Active_End_Date__c >= opp.CloseDate)
                {
                    NPR_Product__c nprProd = new NPR_Product__c();
                    nprProd.Name = 'NPR Product for Opp ' + opp.Name;
                    nprProd.Opportunity_Name__c = opp.Id;
                    nprProd.Product__c = pr.Id;
                    nprProd.Bill_Start_Date__c = opp.CloseDate;
                    nprProd.Bill_End_Date__c = opp.End_Date__c;
                    nprProd.Fiscal_Year__c = opp.Fiscal_Year__c;
                    //nprProd.Include_In_PPF_MSA__c = true;
                    nprProd.ATC_Uncapped_Price__c = null;
                    
                    //populate Opportunity - Products Map
                    if (oppProductsMapPPF.containsKey(opp))
                        oppProductsMapPPF.get(opp).add(pr);
                    else oppProductsMapPPF.put(opp, new List<Product2> { pr });
                    
                    //populate Opportunity - Npr Products Map
                    if (oppNprProdMap.containsKey(opp.Id))
                        oppNprProdMap.get(opp.Id).add(nprProd);
                    else oppNprProdMap.put(opp.Id, new List<NPR_Product__c> { nprProd });
                    
                    System.debug('\n\n\noppNprProdMap is: ' + oppNprProdMap + '\n\n\n');
                                        
                    allNprProducts.add(nprProd);
                    productToOppAccountMap.put(pr.Id, opp.AccountId);
                }
            }
        }
    
        for (Opportunity opp: accountOppMapMSA.values())
        {
            for (Product2 pr: productListMSA)
            {   /*Added by Suhas MSA bundle Enhancement. If condition to check Account's MSA member status and Product's MSA type*/
                if(opp.Account.MSA_Member_Status__c == 'Member') {
                    if(pr.Active_Start_Date__c <= opp.CloseDate && pr.Active_End_Date__c >= opp.CloseDate 
                           && (pr.MSA_Type__c == 'Member' || pr.MSA_Type__c ==   'Member and Non-Member')) {
                        NPR_Product__c nprProd = new NPR_Product__c();
                        nprProd.Name = 'NPR Product for Opp ' + opp.Name;
                        nprProd.Opportunity_Name__c = opp.Id;
                        nprProd.Product__c = pr.Id;
                        nprProd.Bill_Start_Date__c = opp.CloseDate;
                        nprProd.Bill_End_Date__c = opp.End_Date__c;
                        nprProd.Fiscal_Year__c = opp.Fiscal_Year__c;

                        //populate Opportunity - Products Map
                        if (oppProductsMapMSA.containsKey(opp))
                            oppProductsMapMSA.get(opp).add(pr);
                        else oppProductsMapMSA.put(opp, new List<Product2> { pr });

                        //populate Opportunity - Npr Products Map
                        if (oppNprProdMap.containsKey(opp.Id))
                            oppNprProdMap.get(opp.Id).add(nprProd);
                        else oppNprProdMap.put(opp.Id, new List<NPR_Product__c> { nprProd });

                        allNprProducts.add(nprProd);
                        productToOppAccountMap.put(pr.Id, opp.AccountId);
                    }
                } else if(opp.Account.MSA_Member_Status__c == 'Non-Member') {
                    if(pr.Active_Start_Date__c <= opp.CloseDate && pr.Active_End_Date__c >= opp.CloseDate 
                           && (pr.MSA_Type__c == 'Member and Non-Member' || pr.MSA_Type__c == 'Non-Member')) {
                        NPR_Product__c nprProd = new NPR_Product__c();
                        nprProd.Name = 'NPR Product for Opp ' + opp.Name;
                        nprProd.Opportunity_Name__c = opp.Id;
                        nprProd.Product__c = pr.Id;
                        nprProd.Bill_Start_Date__c = opp.CloseDate;
                        nprProd.Bill_End_Date__c = opp.End_Date__c;
                        nprProd.Fiscal_Year__c = opp.Fiscal_Year__c;

                        //populate Opportunity - Products Map
                        if (oppProductsMapMSA.containsKey(opp))
                            oppProductsMapMSA.get(opp).add(pr);
                        else oppProductsMapMSA.put(opp, new List<Product2> { pr });

                        //populate Opportunity - Npr Products Map
                        if (oppNprProdMap.containsKey(opp.Id))
                            oppNprProdMap.get(opp.Id).add(nprProd);
                        else oppNprProdMap.put(opp.Id, new List<NPR_Product__c> { nprProd });

                        allNprProducts.add(nprProd);
                        productToOppAccountMap.put(pr.Id, opp.AccountId);
                    }
                }
                /*Code end here*/
                /*if (pr.Active_Start_Date__c <= opp.CloseDate && pr.Active_End_Date__c >= opp.CloseDate)
                {
                    NPR_Product__c nprProd = new NPR_Product__c();
                    nprProd.Name = 'NPR Product for Opp ' + opp.Name;
                    nprProd.Opportunity_Name__c = opp.Id;
                    nprProd.Product__c = pr.Id;
                    nprProd.Bill_Start_Date__c = opp.CloseDate;
                    nprProd.Bill_End_Date__c = opp.End_Date__c;
                    nprProd.Fiscal_Year__c = opp.Fiscal_Year__c;
                    
                    //populate Opportunity - Products Map
                    if (oppProductsMapMSA.containsKey(opp))
                        oppProductsMapMSA.get(opp).add(pr);
                    else oppProductsMapMSA.put(opp, new List<Product2> { pr });
                                        
                    //populate Opportunity - Npr Products Map
                    if (oppNprProdMap.containsKey(opp.Id))
                        oppNprProdMap.get(opp.Id).add(nprProd);
                    else oppNprProdMap.put(opp.Id, new List<NPR_Product__c> { nprProd });
                                        
                    allNprProducts.add(nprProd);
                    productToOppAccountMap.put(pr.Id, opp.AccountId);
                }*/
            }
        }
    
        //initialize NPR Products for each Opportunity
        populateMapsForNprProdInitQuery(newOpps);   

        List<NPR_Product__c> listToInsert = new List<NPR_Product__c>();         
        for (Opportunity opp: accountOppMapPPF.values())
        {
            system.debug('\n\n OppId = '+opp.Id+'\n\n');
            system.debug('\n\n oppAccountMap = '+oppAccountMap+'\n\n');
            system.debug('\n\n oppAccountMap.get(opp.Id) = '+oppAccountMap.get(opp.Id)+'\n\n');
            system.debug('\n\n oppNprProdMap = '+oppNprProdMap+'\n\n');
            system.debug('\n\n oppNprProdMap.get(opp.Id) = '+oppNprProdMap.get(opp.Id)+'\n\n');
            system.debug('\n\n oppProductsMapPPF = '+oppProductsMapPPF+'\n\n');
            system.debug('\n\n oppProductsMapPPF.get(opp) = '+oppProductsMapPPF.get(opp)+'\n\n');
            if (opp.Id!=null && oppAccountMap!=null && oppAccountMap.get(opp.Id)!=null && oppNprProdMap!=null && oppNprProdMap.get(opp.Id)!=null && oppProductsMapPPF != null && oppProductsMapPPF.get(opp)!=null)
            {
                //initialize NPR Products for each opportunity and add them to the list for mass insert
                listToInsert.addAll(pu.initNPRProds(opp, oppAccountMap.get(opp.Id), oppNprProdMap.get(opp.Id), oppFYMap.get(opp.Id), oppDiscountMap.get(opp.Id), oppProductsMapPPF.get(opp), pricingTables, pricingMsaLicenseFees));
            }
        }
        
        for (Opportunity opp: accountOppMapMSA.values())
        {
            if (opp.Id!=null && oppAccountMap!=null && oppAccountMap.get(opp.Id)!=null && oppNprProdMap!=null && oppNprProdMap.get(opp.Id)!=null && oppProductsMapMSA != null && oppProductsMapMSA.get(opp)!=null)
            {
                //initialize NPR Products for each opportunity and add them to the list for mass insert
                listToInsert.addAll(pu.initNPRProds(opp, oppAccountMap.get(opp.Id), oppNprProdMap.get(opp.Id), oppFYMap.get(opp.Id), oppDiscountMap.get(opp.Id), oppProductsMapMSA.get(opp), pricingTables, pricingMsaLicenseFees));
            }
        }
        /*
        system.debug('\n\n'+listToInsert[0]+'\n\n');
        list<NPR_Product__c> nprProdsCalced = new list<NPR_Product__c>();
        for(NPR_Product__c npr : listToInsert)
        {
            nprProdsCalced.add(pu.calcNPRProd(npr));
        }
        
        listToInsert = nprProdsCalced;
        system.debug('\n\n'+listToInsert[0]+'\n\n');
        */
        //Insert NPR Products, allow for partial insert (in case there are duplicates)
        if (listToInsert.size()>0)
        { 
            Database.insert(listToInsert, false);
            
            for (NPR_Product__c nprProd : listToInsert)
            {
                productToNprProdMap.put(nprProd.Product__c, nprProd);
            }
        }
        else if (allNprProducts.size()>0)
        {
            Database.insert(allNprProducts, false);
                            
            for (NPR_Product__c nprProd : allNprProducts)
            {
                system.debug('\n\nnpr Opp name = '+nprProd.Opportunity_Name__c+'\n\n');
                productToNprProdMap.put(nprProd.Product__c, nprProd);
            }
        }
        
        System.debug('\n\n\nallNprProducts are: ' + allNprProducts + '\n\n\n');
        System.debug('\n\n\nlistToInsert for NPR Products is: ' + listToInsert + '\n\n\n');
        for(NPR_Product__c npr : listToInsert)
        {
            system.debug('\n\n npr.Final_Fee__c = '+npr.Final_Fee__c+'\n\n');
        }
    }   
    
    /* New with wrapper class
    public  void createOpportunityProducts(Map<Opportunity, List<Product2>> oppProdMap)
    {
        //For each record in the nprProducts list and each account in the stations list, 
        //create an Opportunity Product record except where Product.MSA_Type__c = ‘Member’
        //AND Account.LMA__c = TRUE.
        
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppProductListMSAIncr = new List<OpportunityLineItem>();
        
        List<Opportunity> msaOpps = new List<Opportunity>();
        oppAccountMapMSA = new Map<Id, Account>();
    
        //create a Prodiuct2id to PriceBookEntry.Id Map
        List<PricebookEntry> pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :combinedProductList AND Pricebook2.isStandard=true]; 
        Map<Id,Id> prodToPbe = new Map<Id,Id>(); 
        Map<Id,Id> pbeToProd = new Map<Id,Id>();
        
        System.debug('\n\n\n In createOpportunityProducts \n\n\n');
        
        for (PricebookEntry pbEntry: pbeList) 
        { 
            prodToPbe.put(pbEntry.Product2Id, pbEntry.Id); 
            pbeToProd.put(pbEntry.Id, pbEntry.Product2Id);
        } 
        
        System.debug('\n\n\n oppProdMap is:' + oppProdMap + ' \n\n\n');
        System.debug('\n\n\n oppProdMap.keySet() is:' + oppProdMap.keySet() + ' \n\n\n');
    
        //use helper class for Account and three Opp fields, id, CloseDate and End_Date__c
        //iterate through the list of wrapper classes first and then through the list of products                       
        for (accountOppWrapper wr : accOppWrapperList)
        {
            if (wr.o != null && oppProdMap.containsKey(wr.o))
            {
                System.debug('\n\n\n oppProdMap.get(wr.o) is:' + oppProdMap.get(wr.o) + ' \n\n\n');
                
                for (Product2 pr : oppProdMap.get(wr.o))
                {       
                    if (pr.MSA_Type__c != 'Member' || wr.a.LMA__c == false)
                    {                       
                        OpportunityLineItem oppProduct = new OpportunityLineItem();
                        
                        oppProduct.OpportunityId = wr.o.Id;
                        oppProduct.PricebookEntryId = prodToPbe.get(pr.Id);                     
                        oppProduct.Station__c = wr.a.Id;
                        oppProduct.Bill_Start_Date__c = wr.o.CloseDate;
                        oppProduct.Bill_End_Date__c = wr.o.End_Date__c;
                        oppProduct.NPR_Product__c = productToNprProdMap.get(pr.Id).Id;
                    
                        oppProduct.UnitPrice = 0;
                        oppProduct.Quantity = 1;
                                        
                        System.debug('\n\n\n Opportunity Product to be Inserted is: ' + oppProduct);
                                
                        oppProductList.add(oppProduct);
                                
                        productToFYMap.put(pr.Id, wr.o.Fiscal_Year__c);
                                
                        if (pr.MSA_Incremental_Type__c=='Streaming' || pr.MSA_Incremental_Type__c=='Email') oppProductListMSAIncr.add(oppProduct);                              
                        
                        productToOppProdMap.put(pr.Id, oppProduct);
                    }
                }
            }
                    
            if (wr.o.Type == 'MSA')
            {
                msaOpps.add(wr.o);
                oppAccountMapMSA.put(wr.o.Id, wr.o.Account);
            }           
        }
                                        
        //initialize Opportunity products for MSA Opportunities before inserting
        populateMapsForOppProdInitQuery(oppProductListMSAIncr, msaOpps, allNprProducts, productListMSA, pbeToProd); 

        System.debug('\n\n\n*******************OLIs before init: ' + oppProductList + '*******************\n\n\n');
        System.debug('\n\n\nmsaOpps are: ' + msaOpps + '\noppProductListMSAIncr=' + oppProductListMSAIncr + '\noppNprProdMap=' + oppNprProdMap + '\noppProductsMapMSA=' + oppProductsMapMSA + '\noppStationsMap='+oppStationsMap);
        
        List<OpportunityLineItem> listToInsert = new List<OpportunityLineItem>();       
        for (Opportunity opp: msaOpps)
        {
            if (opp.Id!=null && oppProductList!=null && oppNprProdMap!=null && oppProductsMapMSA != null && oppStationsMap!=null)
            {
                //initialize Opp Products for each opportunity and add them to the list for mass insert
                listToInsert.addAll(pu.initOLIs(opp, oppProductList, oppNprProdMap.get(opp.Id), oppProductsMapMSA.get(opp), oppStationsMap.get(opp.Id), MSAIncStreamingList, MSAIncEmailList, pbeList)); //, oppAccountMap));
            }
        }
            
        //Insert Opportunity Products, allow partial update, in case there are duplicates
        try 
        {
            if (listToInsert.size()>0) 
            {
                Database.insert(listToInsert, false);
                System.debug('\n\n\nAfter Insert, Opp Products are: ' + listToInsert + '\n\n\n');
            }
            else if (oppProductList.size()>0)
            {
                Database.insert(oppProductList, false);
                System.debug('\n\n\nAfter Insert, Opp Products are: ' + oppProductList + '\n\n\n');
            }   
                
        }
        catch(DMLException e)
        {
            system.debug('\n\nGOT AN INSERT ERROR: ' + e.getDMLMessage(0));
        }
                        
    } */
    
    
    
    public  void createOpportunityProducts(Map<Opportunity, List<Product2>> oppProdMap)
    {
        //For each record in the nprProducts list and each account in the stations list, 
        //create an Opportunity Product record except where Product.MSA_Type__c = ‘Member’
        //AND Account.LMA__c = TRUE.
        
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppProductListMSAIncr = new List<OpportunityLineItem>();
        
        List<Opportunity> msaOpps = new List<Opportunity>();
        oppAccountMapMSA = new Map<Id, Account>();
        
        //create a Prodiuct2id to PriceBookEntry.Id Map
        List<PricebookEntry> pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :combinedProductList AND Pricebook2.isStandard=true];
        system.debug('pbeList===>>> '+pbeList); 
        Map<Id,Id> prodToPbe = new Map<Id,Id>(); 
        Map<Id,Id> pbeToProd = new Map<Id,Id>();
        
        System.debug('\n\n\n In createOpportunityProducts \n\n\n');
        
        for (PricebookEntry pbEntry: pbeList) 
        { 
            prodToPbe.put(pbEntry.Product2Id, pbEntry.Id); 
            pbeToProd.put(pbEntry.Id, pbEntry.Product2Id);
        } 
        
        System.debug('\n\n\n oppProdMap is:' + oppProdMap + ' \n\n\n');
        System.debug('\n\n\n oppProdMap.keySet() is:' + oppProdMap.keySet() + ' \n\n\n');
        system.debug('oppProdMap= in newoppclass===>>> '+oppProdMap);
        for (Opportunity opp : oppProdMap.keySet())
        {
            System.debug('\n\n\n oppProdMap.containsKey(opp):' + oppProdMap.containsKey(opp) + ' \n\n\n');
            
            //create a helper class for Account and three Opp fields, id, CloseDate and End_Date__c
            //iterate through the list of wrapper classes first and then through the list of products                       
            
            if (opp != null && oppProdMap.containsKey(opp))
            {
                system.debug('This line is executed====>>>>> ');
                System.debug('\n\n\n oppProdMap.get(opp) is:' + oppProdMap.get(opp) + ' \n\n\n');
                for (Product2 pr : oppProdMap.get(opp))
                {
                    System.debug('\n\n\n oppStationsMap is: ' + oppStationsMap + '\n\n\n');
                    System.debug('\n\n\n opp.Id is: ' + opp.Id + '\n\n\n');
                    System.debug('\n\n\n oppStationsMap.containsKey(opp.Id) is: ' + oppStationsMap.containsKey(opp.Id) + '\n\n\n');
                    system.debug('oppStationsMap==in===>>> '+oppStationsMap);
                    if (oppStationsMap!=null && opp.Id != null && oppStationsMap.containsKey(opp.Id)) 
                    {
                        system.debug('This is the line for oppStationsMap!=null===>>>> ');
                        //System.debug('\n\n\n oppStationsMap is:' + oppStationsMap + ' \n\n\n');               
                        for (Account st : oppStationsMap.get(opp.Id))
                        {
                            if (pr.MSA_Type__c != 'Member' || st.LMA__c == false)
                            {  
                                system.debug('This is the line for pr.MSA_Type__c===>>>> ');                     
                                OpportunityLineItem oppProduct = new OpportunityLineItem();
                        
                                oppProduct.OpportunityId = opp.Id;
                                oppProduct.PricebookEntryId = prodToPbe.get(pr.Id);                     
                                oppProduct.Station__c = st.Id;
                                oppProduct.Bill_Start_Date__c = opp.CloseDate;
                                oppProduct.Bill_End_Date__c = opp.End_Date__c;
                                oppProduct.NPR_Product__c = productToNprProdMap.get(pr.Id).Id;
                    
                                oppProduct.UnitPrice = 0;
                                oppProduct.Quantity = 1;
                                        
                                System.debug('\n\n\n Opportunity Product to be Inserted is: ' + oppProduct);
                                
                                oppProductList.add(oppProduct);
                                
                                productToFYMap.put(pr.Id, opp.Fiscal_Year__c);
                                
                                system.debug('\n\n pr.MSA_Incremental_Type__c = '+pr.MSA_Incremental_Type__c+'\n\n');
                                if (pr.MSA_Incremental_Type__c=='Streaming' || pr.MSA_Incremental_Type__c=='Email') oppProductListMSAIncr.add(oppProduct);                              
                                system.debug('\n\n oppProductListMSAIncr = '+oppProductListMSAIncr+'\n\n');
                                
                                productToOppProdMap.put(pr.Id, oppProduct);
                            }
                        }
                    }
                }
            }
            system.debug('oppProductList==in==>>> '+oppProductList);
            if (opp.Type == 'MSA')
            {
                msaOpps.add(opp);
                oppAccountMapMSA.put(opp.Id, opp.Account);
            }  
            system.debug('oppAccountMapMSA===>>>'+oppAccountMapMSA);         
        }
        
        System.debug('\n\n\nmsaOpps are: ' + msaOpps + '\noppProductListMSAIncr=' + oppProductListMSAIncr + '\noppNprProdMap=' + oppNprProdMap + '\noppProductsMapMSA=' + oppProductsMapMSA + '\noppStationsMap='+oppStationsMap);
        //initialize Opportunity products for MSA Opportunities before inserting
        populateMapsForOppProdInitQuery(oppProductListMSAIncr, msaOpps, allNprProducts, productListMSA, pbeToProd); 

        System.debug('\n\n\n*******************OLIs before init: ' + oppProductList + '*******************\n\n\n');
        System.debug('\n\n\nmsaOpps are: ' + msaOpps + '\noppProductListMSAIncr=' + oppProductListMSAIncr + '\noppNprProdMap=' + oppNprProdMap + '\noppProductsMapMSA=' + oppProductsMapMSA + '\noppStationsMap='+oppStationsMap);
        system.debug('msaOpps====>>> '+msaOpps);
        List<OpportunityLineItem> listToInsert = new List<OpportunityLineItem>();       
        for (Opportunity opp: msaOpps)
        {
            if (opp.Id!=null && oppProductList!=null && oppNprProdMap!=null && oppProductsMapMSA != null && oppStationsMap!=null)
            {
                //initialize Opp Products for each opportunity and add them to the list for mass insert
                listToInsert.addAll(pu.initOLIs(opp, oppProductList, oppNprProdMap.get(opp.Id), oppProductsMapMSA.get(opp), oppStationsMap.get(opp.Id), MSAIncStreamingList, MSAIncEmailList, pbeList)); //, oppAccountMap));
            }
        }
        system.debug('listToInsert====>>> '+listToInsert);
        //Insert Opportunity Products, allow partial update, in case there are duplicates
        try 
        {
            if (listToInsert.size()>0) 
            {
                Set <OpportunityLineItem> setToInsert = new Set<OpportunityLineItem>();
                setToInsert.addAll(listToInsert);
                listToInsert.clear();
                listToInsert.addAll(setToInsert);
                                
                Database.insert(listToInsert, false);
                System.debug('\n\n\nAfter Insert, Opp Products are: ' + listToInsert + '\n\n\n');
            }
            else if (oppProductList.size()>0)
            {
                Database.insert(oppProductList, false);
                System.debug('\n\n\nAfter Insert, Opp Products are: ' + oppProductList + '\n\n\n');
            }   
                
        }
        catch(DMLException e)
        {
            system.debug('\n\nGOT AN INSERT ERROR: ' + e.getDMLMessage(0));
        }
                        
    }
    

    public  NPR_Product__c[] previousFYNPRProductQuery(List<Account> accounts, Set<String> prodIds, list<Opportunity> opps)
    {
        list<Decimal> years = new list<Decimal>();
        for(Opportunity o : opps)
        {
            years.add(o.Fiscal_Year__c-1);
        }
        
        //Query NPR_Product__c records to identify previous Fiscal Year's records 
        
        return [SELECT  Adopt_Date__c, Adopt_Status__c, Air_Onboard_Date__c, Air_Onboard_Status__c, Drop_Reason__c, Opportunity_Name__c, 
                    Opportunity_Name__r.AccountId, Product__c, Fiscal_Year__c, Opportunity_Account_ID__c, Next_FY_NPR_Product__c, ATC_Uncapped_Price__c  
                FROM NPR_Product__c 
                WHERE Opportunity_Name__r.AccountId IN: accounts AND Product__c IN: prodIds AND Fiscal_Year__c IN:years];
        
    }
    
    public  OpportunityLineItem[] previousFYOppProductQuery(Set<String> prodIds, list<Opportunity> opps)
    {
        list<String> accounts = new list<String>();
        list<Decimal> years = new list<Decimal>();
        for(Opportunity o : opps)
        {
            accounts.add(o.AccountId);
            years.add(o.Fiscal_Year__c-1);
        }
        
        //Query Opportunity Product records to identify previous Fiscal Year's records 
        
        return [SELECT Id, PricebookEntry.Product2Id, Station__c, Adopt_Date__c, Adopt_Status__c, Air_Onboard_Date__c, Air_Onboard_Status__c, Drop_Reason__c, Fiscal_Year__c  
                FROM OpportunityLineItem WHERE PricebookEntry.Product2Id in: prodIds AND
                Station__c IN:accounts AND Fiscal_Year__c IN:years];
    }   


    public void populateOppAccountMap()
    {
        if (accountOppMapPPF.size()>0)
        {
            Map<ID, Account> aMap = new Map<ID, Account>([SELECT Id, Minority_Status__c, Membership_Pricing_Status__c, Membership_Status_for_MSA__c 
                FROM Account where Id in: accountOppMapPPF.keySet()]);
        
            for (Id accountId : accountOppMapPPF.keySet())
            {
                if (aMap.containsKey(accountId))
                {
                    oppAccountMap.put(accountOppMapPPF.get(accountId).Id, aMap.get(accountId));
                }
            }
        }
        
        if (accountOppMapMSA.size()>0)
        {
            Map<ID, Account> aMap = new Map<ID, Account>([SELECT Id, Minority_Status__c, Membership_Pricing_Status__c, Membership_Status_for_MSA__c FROM Account where Id in: accountOppMapMSA.keySet()]);
        
            for (Id accountId : accountOppMapMSA.keySet())
            {
                if (aMap.containsKey(accountId))
                {
                    oppAccountMap.put(accountOppMapMSA.get(accountId).Id, aMap.get(accountId));
                }
            }
        }
        
    }
    
    public void populateAccountOppMapsBefore(List <Opportunity> oppList)
    {
        for (Opportunity opp: oppList)
        {
            if (opp.Type=='MSA') accountOppMapMSA.put(opp.AccountId, opp);
            if (opp.Type=='PPF') accountOppMapPPF.put(opp.AccountId, opp);
        }
        system.debug('\n\n accountOppMapPPF = '+accountOppMapPPF+'\n\n');
        system.debug('\n\n accountOppMapMSA = '+accountOppMapMSA+'\n\n');
    }
    
    public void populateAccountOppMaps(List <Opportunity> oppList)
    {
        list<String> oIdList = new list<String>{};
        for(Opportunity o : oppList)
        {
            oIdList.add(o.Id);
        }
        
        // LastViewedDate, LastReferencedDate, 
        list<Opportunity> qOppList = [Select Type, Total_TSR_MSA__c, Total_Override__c, Total_Override_Comments__c, 
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
            Account.Membership_Pricing_Status__c,Account.MSA_Member_Status__c,
            Year_Over_Year_Change__c, Year_over_Year_News_Mag_Change__c, Prior_Year_PPF_Contract_Price__c, News_Mag_Capped_Final_Price__c,
            Last_FY_Total_News_Mag_Price__c
            From Opportunity where Id IN: oIdList];
        
        //populate accountOppMap for PPF and MSA opportunities
        for(Opportunity opp: qOppList)
        {
            system.debug('\n\n opp.Type = '+opp.Type+'\n\n');
            if (opp.Type=='MSA') accountOppMapMSA.put(opp.AccountId, opp);
            if (opp.Type=='PPF') accountOppMapPPF.put(opp.AccountId, opp);
        }
        system.debug('\n\n accountOppMapPPF = '+accountOppMapPPF+'\n\n');
        system.debug('\n\n accountOppMapMSA = '+accountOppMapMSA+'\n\n');
        /*for (Opportunity opp: oppList)
        {
            if (opp.Type=='MSA') accountOppMapMSA.put(opp.AccountId, opp);
            if (opp.Type=='PPF') accountOppMapPPF.put(opp.AccountId, opp);
        }*/
    }



        
    public void populateStationsList()
    {
        accOppWrapperList.clear();
        oppStationsMap.clear();
        
        System.debug('\n\n\n In populateStationsList \n\n\n');
        System.debug('\n\n\n\n accountOppMapPPF is:' + accountOppMapPPF + '\n\n\n');
        System.debug('\n\n\n\n accountOppMapMSA is:' + accountOppMapMSA + '\n\n\n');
        
        //Populate stations1 lists
        stations1MSA = relatedStationsQuery1(accountOppMapMSA.keySet(), 'MSA');
        stations1PPF = relatedStationsQuery1(accountOppMapPPF.keySet(), 'PPF');
        
        System.debug('\n\n\n\n stations1MSA is:' + stations1MSA + '\n\n\n');
        
        stations1.addAll(stations1MSA);
        stations1.addAll(stations1PPF);
        system.debug('stations1===>>> '+stations1);
        
        //populate oppStationsMap with accounts from stations1
        for (Account a : stations1)
        {
            //System.debug('\n\n\n accountOppMapPPF.containsKey(a.ParentId) is: ' + accountOppMapPPF.containsKey(a.ParentId) + '\n\n\n'); 
            System.debug('\n\n\n accountOppMapPPF is: ' + accountOppMapPPF + '\n\n\n');
            System.debug('\n\n\n a.ParentId is: ' + a.ParentId + '\n\n\n'); 
            System.debug('\n\n\n stations1 is: ' + stations1 + '\n\n\n'); 
            //System.debug('\n\n\n accountOppMapPPF.get(a.ParentId).Id is: ' + accountOppMapPPF.get(a.ParentId).Id + '\n\n\n'); 
                    
            if (accountOppMapPPF.containsKey(a.ParentId))
            {
                addToAccountOppWrapperList(a, accountOppMapPPF.get(a.ParentId));
                
                System.debug('\n\n\n oppStationsMap.containsKey(accountOppMapPPF.get(a.ParentId) is: ' + oppStationsMap.containsKey(accountOppMapPPF.get(a.ParentId).Id) + '\n\n\n');
                
                if (oppStationsMap.containsKey(accountOppMapPPF.get(a.ParentId).Id) && accountOppMapPPF.get(a.ParentId).Id != null)
                        oppStationsMap.get(accountOppMapPPF.get(a.ParentId).Id).add(a);
                    else 
                    {   
                        //if (accountOppMapPPF.get(a.ParentId).Id != null)
                        {
                            System.debug('\n\n\nAdding new mapping to accountOppMapPPF for Account: ' + a + 'and Opportunity: ' + accountOppMapPPF.get(a.ParentId).Id);
                            oppStationsMap.put(accountOppMapPPF.get(a.ParentId).Id, new List<Account> { a });
                        }
                    }
                                    
                System.debug('\n\n\n oppStationsMap is: ' + oppStationsMap + '\n\n\n');
                System.debug('\n\n\n oppStationsMap.get(accountOppMapPPF.get(a.ParentId).Id) is: ' + oppStationsMap.get(accountOppMapPPF.get(a.ParentId).Id) + '\n\n\n');   
            }
                
            if (accountOppMapMSA.containsKey(a.ParentId))
            {
                addToAccountOppWrapperList(a, accountOppMapMSA.get(a.ParentId));
                
                if (accountOppMapMSA.get(a.ParentId).Id != null && oppStationsMap.containsKey(accountOppMapMSA.get(a.ParentId).Id))
                        oppStationsMap.get(accountOppMapMSA.get(a.ParentId).Id).add(a);
                    else //if (accountOppMapMSA.get(a.ParentId).Id != null)
                    {
                        system.debug('\n\n'+a+'\n\n');
                        oppStationsMap.put(accountOppMapMSA.get(a.ParentId).Id, new List<Account> { a });
                    }
                    
                    system.debug('oppStationsMap in populateStationsList====>>> '+oppStationsMap);
            }   
        }
        
        System.debug('\n\n\n oppStationsMap is: ' + oppStationsMap + '\n\n\n');
        
        stations2 = relatedStationsQuery2(stations1MSA);
        
        System.debug('\n\n\nOOOOOOOOOOOOOOOOOOOOOOOO stations 2 is: ' + stations2 + 'OOOOOOOOOOOOOOOOOOOOOO\n\n\n');
        
        //populate oppStationsMap with accounts from stations2
        for (Account a : stations2)
        {
            if (a.Parent!= null && a.Parent.ParentId!=null && accountOppMapMSA.containsKey(a.Parent.ParentId))
            {
                addToAccountOppWrapperList(a, accountOppMapMSA.get(a.Parent.ParentId));
                
                System.debug('\n\n\nOOOOOOOOOOOOOOOOOOOOOOOO adding stations2 to oppStationsMap');
                
                if (oppStationsMap.containsKey(accountOppMapMSA.get(a.Parent.ParentId).Id))
                        oppStationsMap.get(accountOppMapMSA.get(a.Parent.ParentId).Id).add(a);
                    else oppStationsMap.put(accountOppMapMSA.get(a.Parent.ParentId).Id, new List<Account> { a });
            }   
        }
        
        Set <Id> combinedSet = new Set<Id>();
        combinedSet.addAll(accountOppMapMSA.keySet());
        combinedSet.addAll(accountOppMapPPF.keySet());
        
        stations3 = oppAccountStationQuery(combinedSet);
        System.debug('\n\n\nOOOOOOOOOOOOOOOOOOOOOOOO stations 3 is: ' + stations3 + 'OOOOOOOOOOOOOOOOOOOOOO\n\n\n');
        
        //populate oppStationsMap with accounts from stations3
        for (Account a : stations3)
        {
            if (accountOppMapPPF.containsKey(a.Id))
            {
                if (oppStationsMap.containsKey(accountOppMapPPF.get(a.Id).Id))
                        oppStationsMap.get(accountOppMapPPF.get(a.Id).Id).add(a);
                    else oppStationsMap.put(accountOppMapPPF.get(a.Id).id, new List<Account> { a });
            }
                
            if (accountOppMapMSA.containsKey(a.Id))
            {
                if (oppStationsMap.containsKey(accountOppMapMSA.get(a.Id).Id))
                        oppStationsMap.get(accountOppMapMSA.get(a.Id).Id).add(a);
                    else oppStationsMap.put(accountOppMapMSA.get(a.Id).Id, new List<Account> { a });
            }   
        
        }       
        
        stationsFinal.addAll(stations1);
        stationsFinal.addAll(stations2);
        stationsFinal.addAll(stations3);
        
        System.debug('\n\n\n stationsFinal is: ' + stationsFinal + '\n\n\n');
        System.debug('\n\n\n oppStationsMap is: ' + oppStationsMap + '\n\n\n');
        system.debug('oppStationsMap at end====>>> '+oppStationsMap);
        System.debug('\n\n\n accOppWrapperList is: ' + accOppWrapperList + '\n\n\n');
    }
    
    public void populateStationsListBefore()
    {
        accOppWrapperList.clear();
        oppStationsMap.clear();
        
        //Populate stations1 lists
        stations1MSA = relatedStationsQuery1(accountOppMapMSA.keySet(), 'MSA');
        stations1PPF = relatedStationsQuery1(accountOppMapPPF.keySet(), 'PPF');
        
        stations1.addAll(stations1MSA);
        stations1.addAll(stations1PPF);
        
        //populate oppStationsMap with accounts from stations1
        for (Account a : stations1)
        {       
            if (accountOppMapPPF.containsKey(a.ParentId))
            {
                addToAccountOppWrapperList(a, accountOppMapPPF.get(a.ParentId));
                
                if (oppStationsMapBefore.containsKey(accountOppMapPPF.get(a.ParentId)) && accountOppMapPPF.get(a.ParentId) != null)
                    oppStationsMapBefore.get(accountOppMapPPF.get(a.ParentId)).add(a);
                else    
                    oppStationsMapBefore.put(accountOppMapPPF.get(a.ParentId), new List<Account> { a });
            }
                
            if (accountOppMapMSA.containsKey(a.ParentId))
            {
                addToAccountOppWrapperList(a, accountOppMapMSA.get(a.ParentId));
                
                if (oppStationsMapBefore.containsKey(accountOppMapMSA.get(a.ParentId)) && accountOppMapMSA.get(a.ParentId) != null)
                    oppStationsMapBefore.get(accountOppMapMSA.get(a.ParentId)).add(a);
                else    
                    oppStationsMapBefore.put(accountOppMapMSA.get(a.ParentId), new List<Account> { a });
                    
            }   
        }
        
        stations2 = relatedStationsQuery2(stations1MSA);
        
        //populate oppStationsMap with accounts from stations2
        for (Account a : stations2)
        {
            if (a.Parent!= null && a.Parent.ParentId!=null && accountOppMapMSA.containsKey(a.Parent.ParentId))
            {
                addToAccountOppWrapperList(a, accountOppMapMSA.get(a.Parent.ParentId));
                
                if (oppStationsMapBefore.containsKey(accountOppMapMSA.get(a.Parent.ParentId)) && accountOppMapMSA.get(a.Parent.ParentId) != null)
                    oppStationsMapBefore.get(accountOppMapMSA.get(a.Parent.ParentId)).add(a);
                else    
                    oppStationsMapBefore.put(accountOppMapMSA.get(a.Parent.ParentId), new List<Account> { a });
            }   
        }
        
        Set <Id> combinedSet = new Set<Id>();
        combinedSet.addAll(accountOppMapMSA.keySet());
        combinedSet.addAll(accountOppMapPPF.keySet());
        
        stations3 = oppAccountStationQuery(combinedSet);
        
        //populate oppStationsMap with accounts from stations3
        for (Account a : stations3)
        {
            if (accountOppMapPPF.containsKey(a.Id))
            {
                if (oppStationsMapBefore.containsKey(accountOppMapPPF.get(a.Id)) && accountOppMapPPF.get(a.Id) != null)
                    oppStationsMapBefore.get(accountOppMapPPF.get(a.Id)).add(a);
                else    
                    oppStationsMapBefore.put(accountOppMapPPF.get(a.Id), new List<Account> { a });
            }
                
            if (accountOppMapMSA.containsKey(a.Id))
            {
                if (oppStationsMapBefore.containsKey(accountOppMapMSA.get(a.Id)) && accountOppMapMSA.get(a.Id) != null)
                    oppStationsMapBefore.get(accountOppMapMSA.get(a.Id)).add(a);
                else    
                    oppStationsMapBefore.put(accountOppMapMSA.get(a.Id), new List<Account> { a });
            }   
        
        }       
        
        stationsFinal.addAll(stations1);
        stationsFinal.addAll(stations2);
        stationsFinal.addAll(stations3);
        
        if(oppStationsMapBefore.values()!=null && oppStationsMapBefore.size()>0)
        {
            oppStationsMap.put(null, oppStationsMapBefore.values()[0]);
        }
    }
    
    /*public void populateStationsListBeforeOld()
    {
        //Populate stations1 lists
        stations1MSA = relatedStationsQuery1(accountOppMapMSA.keySet(), 'MSA');
        stations1PPF = relatedStationsQuery1(accountOppMapPPF.keySet(), 'PPF');
        
        stations1.addAll(stations1MSA);
        stations1.addAll(stations1PPF);
        
        //populate oppStationsMapMSA with accounts from stations1MSA
        for (Account a : stations1MSA)
        {
            if (accountOppMapMSA.containsKey(a.ParentId))
            {
                if (oppStationsMapMSA.containsKey(accountOppMapMSA.get(a.ParentId)) && accountOppMapMSA.get(a.ParentId) != null)
                        oppStationsMapMSA.get(accountOppMapMSA.get(a.ParentId)).add(a);
                    else if (accountOppMapMSA.get(a.ParentId) != null)
                    {
                        oppStationsMapMSA.put(accountOppMapMSA.get(a.ParentId), new List<Account> { a });
                    }                   
            }   
        }
        
        stations2 = relatedStationsQuery2(stations1MSA);
        
    
        //populate oppStationsMap with accounts from stations2
        for (Account a : stations2)
        {
            if (a.Parent!= null && a.Parent.ParentId!=null && accountOppMapMSA.containsKey(a.Parent.ParentId))
            {
                if (oppStationsMapMSA.containsKey(accountOppMapMSA.get(a.Parent.ParentId)))
                        oppStationsMapMSA.get(accountOppMapMSA.get(a.Parent.ParentId)).add(a);
                    else oppStationsMapMSA.put(accountOppMapMSA.get(a.Parent.ParentId), new List<Account> { a });
            }   
        }
        
        Set <Id> combinedSet = new Set<Id>();
        combinedSet.addAll(accountOppMapMSA.keySet());
        combinedSet.addAll(accountOppMapPPF.keySet());
        
        stations3 = oppAccountStationQuery(combinedSet);
        
        //populate oppStationsMapMSA with accounts from stations3
        for (Account a : stations3)
        {
            if (accountOppMapMSA.containsKey(a.Id))
            {
                if (oppStationsMapMSA.containsKey(accountOppMapMSA.get(a.Id)))
                        oppStationsMapMSA.get(accountOppMapMSA.get(a.Id)).add(a);
                    else oppStationsMapMSA.put(accountOppMapMSA.get(a.Id), new List<Account> { a });
            }           
        }       
        
        stationsFinal.addAll(stations1);
        stationsFinal.addAll(stations2);
        stationsFinal.addAll(stations3);
    }*/
    
    public void oppInit()
    {
        //Update pricing values on Opportunities -------------------------------------
        System.debug('\n\n\nIn oppInit \n\n\n');        
        System.debug('\n\n\naccountOppMapPPF is: ' + accountOppMapPPF + '\n\n\n');
        System.debug('\n\n\naccountOppMapMSA is: ' + accountOppMapMSA + '\n\n\n');
        System.debug('\n\n\noppStationsMap is: ' + oppStationsMap + '\n\n\n');
                
        //check if maps are blank or not
        if (accountOppMapPPF.size()>0)
        {
            oppsToUpdatePPF = pu.populatePricingValuesOnPPFOpps(accountOppMapPPF);
            oppsToUpdatePPF = pu.determinePricingTeer(oppsToUpdatePPF, 'PPF');
            oppsToUpdatePPF = pu.determineAdminFee(oppsToUpdatePPF, accountOppMapPPF.keySet());
        }
                
        if (accountOppMapMSA.size()>0)
        {
            oppsToUpdateMSA = pu.populatePricingValuesOnMSAOpps(accountOppMapMSA, oppStationsMap);
            //oppsToUpdateMSA = pu.populatePricingValuesOnMSAOpps(oppStationsMapMSA);
                        
            oppsToUpdateMSA = pu.determinePricingTeer(oppsToUpdateMSA, 'MSA');
            system.debug('\n\n accountOppMapMSA = '+accountOppMapMSA+'\n\n');
            oppsToUpdateMSA = pu.determineLastFYMSAAnchorListPrice(accountOppMapMSA);
        }
        
    }
    
    public void linkNprProducts(list<Opportunity> newOpps)
    {
    	system.debug('****this calc NPR product 1st Year Discount detail design document enhancment NewOpportunity Class****');
        //Link new NPR Products to Previous FY NPR Products----------
        List <NPR_Product__c> currentYearNPRProductsToUpdate = new List <NPR_Product__c>();
        List<NPR_Product__c> prevYearNPRProducts = previousFYNPRProductQuery(oppAccountMap.values(), productToNprProdMap.keySet(), newOpps);
        
        System.debug('\n\n\nIn linkNPRProducts, productToOppAccountMap is:' + productToOppAccountMap + '\n\n\n');
        System.debug('\n\n\nprevYearNPRProducts.size() is: ' + prevYearNPRProducts.size());
            
        if (prevYearNPRProducts.size()>0)
        {
            for (NPR_Product__c prevYearNprProd : prevYearNPRProducts)
            {
                System.debug('\n\n\nIn for loop\n\n\n');

            //  System.debug('\n\n\nprevYearNprProd.Opportunity_Account_ID__c is: ' + prevYearNprProd.Opportunity_Account_ID__c + '\nproductToOppAccountMap.get(prevYearNprProd.Product__c).substring(0, 15) is: ' + productToOppAccountMap.get(prevYearNprProd.Product__c).substring(0, 15) + '\n\n\n');           
                System.debug('\n\n\nprevYearNprProd.Fiscal_Year__c is: ' + prevYearNprProd.Fiscal_Year__c + '\nproductToNprProdMap.get(prevYearNprProd.Product__c).Fiscal_Year__c is: ' + (productToNprProdMap.get(prevYearNprProd.Product__c).Fiscal_Year__c) + '\n\n\n');
                system.debug('\n\n productToOppAccountMap = '+productToOppAccountMap+'\n\n');
                if(productToOppAccountMap.get(prevYearNprProd.Product__c)!=null)
                {   
                    system.debug('\n\n'+prevYearNprProd+'\n'+prevYearNprProd.Product__c+'\n'+productToNprProdMap+'\n'+productToOppAccountMap+'\n'+productToNprProdMap.get(prevYearNprProd.Product__c)+'\n'+productToOppAccountMap.get(prevYearNprProd.Product__c)); 
                    system.debug('\n\n'+prevYearNprProd.Opportunity_Account_ID__c+'\n'+productToOppAccountMap.get(prevYearNprProd.Product__c).substring(0, 15)+'\n'+prevYearNprProd.Fiscal_Year__c+'\n'+(productToNprProdMap.get(prevYearNprProd.Product__c).Fiscal_Year__c-1));
                }
                
                if (prevYearNprProd!=null && prevYearNprProd.Product__c != null && productToNprProdMap!=null && productToOppAccountMap!=null && productToNprProdMap.get(prevYearNprProd.Product__c)!=null && productToOppAccountMap.get(prevYearNprProd.Product__c) != null &&
                //    productToNprProdMap.get(prevYearNprProd.Product__c).Fiscal_Year__c!=null && prevYearNprProd.Fiscal_Year__c == (productToNprProdMap.get(prevYearNprProd.Product__c).Fiscal_Year__c-1))
                    prevYearNprProd.Opportunity_Account_ID__c == productToOppAccountMap.get(prevYearNprProd.Product__c).substring(0, 15) &&
                    prevYearNprProd.Fiscal_Year__c == (productToNprProdMap.get(prevYearNprProd.Product__c).Fiscal_Year__c-1))
                {
                    System.debug('\n\n\nUpdating previous year NPR Product\n\n\n');
                    
                    //update previous year NPR Product record
                    prevYearNprProd.Next_FY_NPR_Product__c = productToNprProdMap.get(prevYearNprProd.Product__c).Id;
                    
                    System.debug('\n\n\nUpdating newly created NPR Product\n\n\n');
                    
                    //update new NPR Product record
                    productToNprProdMap.get(prevYearNprProd.Product__c).Previous_FY_NPR_Product__c = prevYearNprProd.Id;
                    
                    if (prevYearNprProd.Air_Onboard_Status__c=='Complete')
                    {
                        productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Status__c = prevYearNprProd.Adopt_Status__c;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Date__c = prevYearNprProd.Adopt_Date__c;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Date__c = prevYearNprProd.Air_Onboard_Date__c;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Status__c = prevYearNprProd.Air_Onboard_Status__c;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Include_In_PPF_MSA__c = true; 
                    }
                    else if (prevYearNprProd.Air_Onboard_Status__c=='Dropped')
                    {
                        productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Status__c = null;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Date__c = null;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Date__c = null;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Status__c = null;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Drop_Date__c = null;
                        productToNprProdMap.get(prevYearNprProd.Product__c).Drop_Reason__c = null;
                    }
                    if(prevYearNprProd.Air_Onboard_Status__c!='Dropped' && prevYearNprProd.Air_Onboard_Date__c>=system.today())
                    {
                        productToNprProdMap.get(prevYearNprProd.Product__c).Include_In_PPF_MSA__c = true;
                    }
                    
                    //PPF/MSA : Added by Suhas : These fields are added as part of 1st year discount detailed document. On 15th September 2015.
                    productToNprProdMap.get(prevYearNprProd.Product__c).Current_FY_Total_Discount__c = prevYearNprProd.Current_FY_Total_Discount__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).First_Discount_Pct__c = prevYearNprProd.First_Discount_Pct__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).First_Discount_Start__c = prevYearNprProd.First_Discount_Start__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).First_Discount_End__c = prevYearNprProd.First_Discount_End__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).Second_Discount_Pct__c = prevYearNprProd.Second_Discount_Pct__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).Second_Discount_Start__c = prevYearNprProd.Second_Discount_Start__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).Second_Discount_End__c = prevYearNprProd.Second_Discount_End__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).Third_Discount_Pct__c = prevYearNprProd.Third_Discount_Pct__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).Third_Discount_Start__c = prevYearNprProd.Third_Discount_Start__c; 
                    productToNprProdMap.get(prevYearNprProd.Product__c).Third_Discount_End__c = prevYearNprProd.Third_Discount_End__c; 
                    system.debug('productToNprProdMap.get(prevYearNprProd.Product__c).Current_FY_Total_Discount__c*****'+productToNprProdMap.get(prevYearNprProd.Product__c).Current_FY_Total_Discount__c);
                    system.debug('****this calc NPR product 1st Year Discount detail design document enhancment NewOpportunity Class****');
                    //PPF/MSA : Added by Suhas : These fields are added as part of 1st year discount detailed document. On 15th September 2015.
                    
                    currentYearNPRProductsToUpdate.add(productToNprProdMap.get(prevYearNprProd.Product__c));                                    
                }
            }
        }
        
        System.debug('\n\n\nBefore updating linked NPR Products \n\n\n');
        
        if (prevYearNPRProducts.size()>0) Database.update(prevYearNPRProducts, false);    
        if (currentYearNPRProductsToUpdate.size()>0) Database.update(currentYearNPRProductsToUpdate, false);
         
        System.debug('\n\n\nPrevious Year NPRProducts are: ' + prevYearNPRProducts + '\n\ncurrent year NPR Products are: ' + currentYearNPRProductsToUpdate + '\n\n\n');
    }
    
    //Link to Previous FY’s Opp Products
    public  void linkOppProducts(list<Opportunity> newOpps)
    {
        System.debug('\n\n\nIn linkOppProducts\n\n\n');
        
        //Link new Opportunity Products to Previous FY Opportunity Products----------
        Set<OpportunityLineItem> currentYearOppProductsToUpdate = new Set<OpportunityLineItem>();
        List<OpportunityLineItem> prevYearOppProducts = previousFYOppProductQuery(productToOppProdMap.keySet(), newOpps);
        list<OpportunityLineItem> prevYearToUpdate = new list<OpportunityLineItem>();
        
        for (OpportunityLineItem prevYearOppProd : prevYearOppProducts)
        {
            if (prevYearOppProd!=null && productToOppProdMap!=null && prevYearOppProd.PricebookEntry!=null && prevYearOppProd.PricebookEntry.Product2Id!=null && productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id)!=null && productToFYMap.get(prevYearOppProd.PricebookEntry.Product2Id)!=null)
            {
                if (prevYearOppProd.Station__c == productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Station__c &&
                    prevYearOppProd.Fiscal_Year__c == productToFYMap.get(prevYearOppProd.PricebookEntry.Product2Id)-1)
                {
                    //update previous year Opportunity Product record
                    prevYearOppProd.Next_FY_Opp_Product_ID__c = productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Id;
                    prevYearToUpdate.add(prevYearOppProd);
                    
                    //update new Opportunity Product record
                    productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Last_FY_Opp_Product_ID__c = prevYearOppProd.Id;
                    
                    if (prevYearOppProd.Air_Onboard_Status__c=='Complete')
                    {
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Adopt_Status__c = prevYearOppProd.Adopt_Status__c;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Adopt_Date__c = prevYearOppProd.Adopt_Date__c;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Air_Onboard_Date__c = prevYearOppProd.Air_Onboard_Date__c;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Air_Onboard_Status__c = prevYearOppProd.Air_Onboard_Status__c;
                    }
                    else if (prevYearOppProd.Air_Onboard_Status__c=='Dropped')
                    {
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Adopt_Status__c = null;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Adopt_Date__c = null;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Air_Onboard_Date__c = null;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Air_Onboard_Status__c = null;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Drop_Date__c = null;
                        productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id).Drop_Reason__c = null;
                    }
                    
                    if (productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id)!=null && !currentYearOppProductsToUpdate.contains(productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id)))
                        currentYearOppProductsToUpdate.add(productToOppProdMap.get(prevYearOppProd.PricebookEntry.Product2Id));                                 
                }
            }
        }
        
        System.debug('\n\n\nIn linkOppProducts, previous Year OppProducts are: ' + prevYearOppProducts + '\n\ncurrent year Opp Products are: ' + currentYearOppProductsToUpdate + '\n\n\n'); 
        
        if (prevYearToUpdate.size()>0) Database.update(prevYearToUpdate, false); 
        if (currentYearOppProductsToUpdate.size()>0) 
        {
            List<OpportunityLineItem> listToUpdate = new List<OpportunityLineItem>();
            listToUpdate.addAll(currentYearOppProductsToUpdate);
            
            Database.update(listToUpdate, false);
        }
        
        
    }
    
    public void calcOpp(List<Opportunity> newOpps)
    {
        // LastViewedDate, LastReferencedDate, 
        List<Opportunity> oppsToUpdate = [Select Type, Total_TSR_MSA__c, Total_Override__c, Total_Override_Comments__c, 
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
            Account.Membership_Pricing_Status__c, Year_Over_Year_Change__c, Year_over_Year_News_Mag_Change__c, Prior_Year_PPF_Contract_Price__c, News_Mag_Capped_Final_Price__c,
            Last_FY_Total_News_Mag_Price__c
            From Opportunity where Id in: newOpps];
        List<Opportunity> newSet = new List<Opportunity>();
        
        System.debug('\n\n\noppNprProdMap is: ' + oppNprProdMap + '\n\n\n');
        
        for (Opportunity opp : oppsToUpdate) 
        {
            System.debug('\n\n\nopp is: ' + opp + '\n\n\n');
            System.debug('\n\n\noppNprProdMap.get(opp) is: ' + oppNprProdMap.get(opp.Id) + '\n\n\n');
            
            if (opp!=null && oppNprProdMap!=null && oppNprProdMap.get(opp.Id)!=null)
                newSet.add(pu.calcOpportunity(opp, oppNprProdMap.get(opp.Id)));
        }
    
        if (newSet.size()>0) update newSet;
    }
    
    public void clearAll()
    {
        accountOppMapPPF.clear();
        accountOppMapMSA.clear();
        
        stations1MSA.clear();
        stations1PPF.clear();
        stations1.clear();
        stations2.clear();
        stations3.clear(); 
        stationsFinal.clear();
    }
    
    public void populateMapsForNprProdInitQuery(Opportunity[] newOpps)
    {
        populateOppAccountMap();
        oppFYMap = pu.FYPricingDetailQuery(newOpps);
        oppDiscountMap = pu.NPRDiscountQuery(newOpps, oppAccountMap.values());
        
        //check if have any PPF opps - set a flag
        pricingTables = pu.pricingTable(newOpps, allNprProducts, oppAccountMap.values());
        
        //check if have any MSA opps - set a flag
        pricingMsaLicenseFees = pu.MSALicenseFee(newOpps, allNprProducts, oppAccountMap.values());      
    }
    
    public void populateMapsForOppProdInitQuery(List<OpportunityLineItem> oppProductList, Opportunity[] msaOpps, List<NPR_Product__c> nprProducts, List<Product2> productListMSA, Map<Id,Id> pbeToProd)
    {
        if (oppProductList!=null && nprProducts!=null && msaOpps!=null && productListMSA!=null)
        {
            MSAIncStreamingList = pu.MSAIncrementalStreaming(oppProductList, nprProducts, msaOpps, productListMSA, pbeToProd, oppAccountMap);           
        }
        if (oppProductList!=null && nprProducts!=null && stationsFinal!=null)
        {
            MSAIncEmailList = pu.MSAIncrementalEmail(oppProductList, nprProducts, stationsFinal);
        }           
    }
    
    public void addToAccountOppWrapperList(Account a, Opportunity o)
    {
        accountOppWrapper wr = new accountOppWrapper();     
        wr.a = a;
        wr.o = o;
        
        accOppWrapperList.add(wr);      
    }
}