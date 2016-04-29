public with sharing class OpporunityEditOverride {

    public Opportunity opp{get; set;}
    public Opportunity oldOpp{get; set;}
    
    public Date todaysDate{get; set;}
    
    public list<NPR_Product__c> nrpBundles{get; set;}
    public list<NPR_Product__c> nrpBundlesOld{get; set;}
    
    // Holds dynamically seleted OLI for MSA
    public OpportunityLineItem selectedOli{get; set;}
    public OpportunityLineItem selectedOliOld{get; set;}
    
    // Holds dynamically seleted NPR Product for MSA
    public NPR_Product__c selectedNPRProd{get; set;}
    public NPR_Product__c selectedNPRProdOld{get; set;}
    
    // Boolean that will show detial section if true
    public Boolean showDetails{get; set;}
    public Boolean showRefreshPopUp{get; set;}
    
    public set<String> stationNames{get; set;}
    
    public list<NPR_Product__c> nprProducts{get; set;}
    public list<list<OpportunityLineItem>> oliListList{get; set;}
    
    public map<String, NPR_Product__c> nprBundleMap{get; set;}
    public map<String, NPR_Product__c> nprBundleOldMap{get; set;}
    
    public Boolean applyNullCheck {get; set;}
    
    public String bundleName {get; set;}
    
    private ApexPages.StandardController viewstdController;
    
    public OpporunityEditOverride(ApexPages.StandardController stdController) {
        
        todaysDate = system.Today();
        nprBundleMap = new map<String, NPR_Product__c>{};
        nprBundleOldMap = new map<String, NPR_Product__c>{};
        stationNames = new set<String>{};
        oliListList = new list<list<OpportunityLineItem>>{};
        showDetails = false;
        nrpBundles = new list<NPR_Product__c>();
        nrpBundlesOld = new list<NPR_Product__c>();
        selectedNPRProdOld = new NPR_Product__c();
        selectedOliOld = new OpportunityLineItem();
        applyNullCheck = false;
        viewstdController = stdController;
        //if(queryOpportunity((Opportunity)stdController.getRecord()) != null) {
        //    this.opp = queryOpportunity((Opportunity)stdController.getRecord());
        //} else {
            this.opp = (Opportunity)stdController.getRecord();
        //}
        
        system.debug('this.opp=====>>>'+this.opp);
        oldOpp = opp.clone(true, true);
        
        stationNames = includedStationsQuery();
        
        // If type is MSA
        if(opp.type=='MSA')
        {
            oliListList = getOliLists();
            system.debug('oliListList in edit===>>> '+oliListList.size()+'======>>> '+oliListList);
            getBundleNameOnPageLoad();
            nrpBundles = queryNPRBundle();
            system.debug('nrpBundles in edit===>>> '+nrpBundles.size()+ '====>>> '+nrpBundles);
            for(NPR_Product__c npr : nrpBundles)
            {
                nprBundleMap.put(npr.Id, npr);
            }
            //nrpBundles = nprBundleMap.values();
            // Save off old npr bundles
            nrpBundlesOld.addAll(nrpBundles);
            for(NPR_Product__c npr : nrpBundlesOld)
            {
                nprBundleOldMap.put(npr.Id, npr.clone(true, true));
            }
        }
        if(opp.type=='PPF')
        {
            nprProducts = nprProductListQueryPPF();
        }
        system.debug('\n\n nprBundleOldMap = '+nprBundleOldMap+'\n\n');
    }
    /*Added by Suhas Here the changes are mostly of adding the new fields for Non news and news. 
                            According to Opportunity New, Repositioned and Relabeled Fields Detailed Design doc*/
    //Query Opportunity 
    public Opportunity queryOpportunity(Opportunity opp) {
        String opportunityQuery = '';
        String opportunityId = opp.Id;
        if(!String.isBlank(formOpportunityQuery('Opportunity'))) {
            opportunityQuery = formOpportunityQuery('Opportunity');
            opportunityQuery += ' Where ';
            opportunityQuery += ' id =: opportunityId';
        }
        Opportunity opportunity = Database.query(opportunityQuery);
        if(opportunity!= null ) {
            return opportunity;
        } else {
            return null;
        }
    }

    //Generate the basic query with all the fields from the object being queried.
    public String formOpportunityQuery(String objectName) {
        String selectStr = ' Select ';
        String fromStr = ' from ';
        String fieldsStr = getObjectFields(objectName);
        
        String queryString = '';
        if(!String.isBlank(fieldsStr)) {
            queryString = selectStr;
            queryString += fieldsStr;
            queryString += fromStr;
            queryString += ' '+ objectName + ' ';
        } 
        return queryString;
    }

    //Get all the fields of the fields and form a comma seperated string.
     private string getObjectFields(string objectName)
    {
        Map<String, Schema.SObjectField> objectFieldsMap = new Map<String, Schema.SObjectField>();
        objectFieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        string opportunityFields = '';
        for (String s : objectFieldsMap.keySet()) {
            if ((objectFieldsMap.get(s).getDescribe().isAccessible())) {
                opportunityFields += String.escapeSingleQuotes(s);
                opportunityFields += ',';
            }
        }
    
        opportunityFields = opportunityFields.removeEnd(',');
        return opportunityFields;
    }
    /*Added code ends here*/
    /*Added by Suhas*/
    public void getBundleNameOnPageLoad() {
        List<NPR_Product__c> nprProdList = new List<NPR_Product__c>();

        nprProdList = [select Id, Product__r.Name from NPR_Product__c 
                        where Opportunity_Name__c=:opp.Id and MSA_Bundle__c=true and Include_In_PPF_MSA__c = true];

        if(nprProdList != null && nprProdList.size() > 0) {
            system.debug('nprProdList[0].Product__r.Name=====>>> '+nprProdList[0].Product__r.Name);
            bundleName = nprProdList[0].Product__r.Name;
        }
        system.debug('bundleName==>>> '+bundleName);
        System.debug ('Suhas::::: #93 onload '+String.isNotBlank(bundleName));
    }
    /*Ends here Suhas*/

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
        system.debug('stationNameList====>>> '+stationNameList);
        return stationNameList;
    }
    
    public String convertOliType(String strType)
    {
        String returnString = '';
        returnString = strType.replaceAll(';', ', ');
        system.debug('returnString====>>> '+returnString);
        return returnString;
    }
    
    //This method gets the NPR bundle name. 
    public list<NPR_Product__c> queryNPRBundle()
    {
        return [select Id, Name, Include_in_PPF_MSA__c, List_Fee__c, Discount_Type__c, Discount_Percent__c, Subtotal_Fee__c, Override_Discount__c, 
            Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Air_Onboard_Date__c, Air_Onboard_Status__c, 
            Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c, ATC_Uncapped_Price__c,
            ATC_Last_FY_Price__c, Cap_Percent__c, ATC_Capped_Final_Fee__c, Last_FY_Fee_Override__c, Accelerated_Cap__c, 
            Accelerated_Cap_Comments__c, Final_Fee__c, Product__r.PPF_Type__c, Product__r.Name, Opportunity_Name__r.CloseDate, 
            Opportunity_Name__r.End_Date__c, List_Fee_Annualized__c, List_Fee_Prorated__c, Product__r.Family, Product_Name__c, 
            List_Fee_Non_News_Annualized__c, Base_Fee_Annualized__c, License_Fee_Annualized__c, MSA_Cap__c,
            Last_FY_MSA_Anchor_List_Price__c, Last_FY_MSA_Price_Override__c, Final_Last_FY_MSA_Anchor_Price__c, Product__r.MSA_Bundle__c,
            Opportunity_Name__r.Total_TSR_MSA__c, Opportunity_Name__r.Last_FY_MSA_Anchor_List_Price__c, License_Fee_Factor__c, 
            Previous_FY_Fee_Threshold_Min__c, Previous_FY_Fee_Threshold_Max__c, Annual_FY_Increase__c, Discount_From_Anchor__c,
            LastModifiedBy.Name, LastModifiedDate, Other_Discount_Type__c, Final_Air_Date__c 
            from NPR_Product__c where Opportunity_Name__c=:opp.Id and MSA_Bundle__c=true/* and Include_In_PPF_MSA__c = true*/]; 
    }
    
    public list<NPR_Product__c> nprProductListQueryPPF()
    {
        return [select Id, Name, Product__r.Name, NPR_Product_Link__c
            from NPR_Product__c where Opportunity_Name__c=:opp.Id order by Product__r.PPF_Type__c, Product__r.Name];    
    }
    
    public NPR_Product__c nprProductQueryPPF(String id)
    {
        return [select Id, Name, Include_in_PPF_MSA__c, List_Fee__c, Discount_Type__c, Discount_Percent__c, Subtotal_Fee__c, Override_Discount__c, 
            Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Air_Onboard_Date__c, Air_Onboard_Status__c, 
            Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c, ATC_Uncapped_Price__c,
            ATC_Last_FY_Price__c, Cap_Percent__c, ATC_Capped_Final_Fee__c, Last_FY_Fee_Override__c, Accelerated_Cap__c, 
            Accelerated_Cap_Comments__c, Final_Fee__c, Product__r.PPF_Type__c, Product__r.Name, Opportunity_Name__r.CloseDate, 
            Opportunity_Name__r.End_Date__c, List_Fee_Annualized__c, List_Fee_Prorated__c, Product__r.Family, Product_Name__c, 
            List_Fee_Non_News_Annualized__c, NPR_Product_Link__c, LastModifiedBy.Name, LastModifiedDate, Other_Discount_Type__c, 
            Final_Air_Date__c,
            /* Added by Suhas 
                            According to Opportunity New, Repositioned and Relabeled Fields Detailed Design doc*/
            Year_over_Year_Change__c,
            Delta_Uncapped_and_Final_Price__c,
            Prior_Year_Price__c,
            Prior_Year_Discount__c,
            Prior_Year_Discount_Type__c, 
            Product_PPF_Type__c
            /*Added Code ends here*/
            from NPR_Product__c where Id=:id];  
    }
    
    public list<OpportunityLineItem> OLIListQueryMSA()
    {
        return [select Id, Name, Station__r.Name, NPR_Product__c, NPR_Product__r.Product__r.Name, Opportunity_Product_Link__c
                    , NPR_Product__r.Product__r.Bundle__c /*Added By Suhas*/
                from OpportunityLineItem where OpportunityId=:opp.Id and Product2.MSA_Bundle__c=false 
                order by NPR_Product__r.Product__r.Name, Opportunity_Product_Link__c];    
    }
    
    public OpportunityLineItem OLIQueryMSA(String id)
    {
        return [select Id, Name, Interested_In_Product__c, Recurrence_Price__c, Recurrence_Type__c, Annualized_Price__c, Set_up_Fee__c,
                    Subtotal_Fee__c, Override_Fee__c, Override_Fee_Comments__c, Final_Price__c, Bill_Start_Date__c, Bill_End_Date__c, Email_List_Size__c,
                    Adopt_Status__c, Adopt_Date__c, Air_Onboard_Date__c, Air_Onboard_Status__c, Drop_Date__c, Drop_Reason__c,
                    Product2.MSA_Incremental_Type__c, Station__r.Name, Opportunity.CloseDate, Opportunity.End_Date__c, NPR_Product__r.Product__r.Name,
                    Opportunity_Product_Link__c, LastModifiedBy.Name, LastModifiedDate
                from OpportunityLineItem where Id=:id]; 
    }
    
    public list<list<OpportunityLineItem>> getOliLists()
    {
        list<list<OpportunityLineItem>> oliLists = new list<list<OpportunityLineItem>>{};
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>{};
        
        Boolean firstTime = true;
        String lastNPRProdId = '';
        
        system.debug('OLIListQueryMSA()===>>>> '+OLIListQueryMSA().size() + '===>>> '+OLIListQueryMSA());
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
        
        system.debug('oliLists====>>> '+oliLists);
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
        selectedOliOld = selectedOli.clone(true, true);
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
        // Save off current state of NPR prod so we can get delta later
        selectedNPRProdOld = selectedNPRProd.clone(true, true);
        showDetails=true;
    }
    
    public void closeDetails()
    {
        if(opp.Type=='PPF')
        {
            ValidationUtility vu = new ValidationUtility();
            list<String> errors = vu.validateNPRProductField(selectedNPRProd, selectedNPRProdOld);
            
            if(errors.size()>0)
            {
                for(String error : errors)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, error));
                }
            }
            else 
            {
                PricingUtility ut = new PricingUtility();
                //opp = ut.beforeCalcOpportunity(opp, selectedNPRProd, selectedNPRProdOld); //Added by Suhas on 31/7/2015 
                opp = ut.calcOpportunity(opp, selectedNPRProd, selectedNPRProdOld);
                
                // give me all npr prods for this opp
                /*list<NPR_Product__c> lstNprProd = [select Id, Name, Include_in_PPF_MSA__c, List_Fee__c, Discount_Type__c, Discount_Percent__c, Subtotal_Fee__c, Override_Discount__c, 
                    Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Air_Onboard_Date__c, Air_Onboard_Status__c, 
                    Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c, ATC_Uncapped_Price__c,
                    ATC_Last_FY_Price__c, Cap_Percent__c, ATC_Capped_Final_Fee__c, Last_FY_Fee_Override__c, Accelerated_Cap__c, 
                    Accelerated_Cap_Comments__c, Final_Fee__c, Product__r.PPF_Type__c, Product__r.Name, Opportunity_Name__r.CloseDate, 
                    Opportunity_Name__r.End_Date__c, List_Fee_Annualized__c, List_Fee_Prorated__c, Product__r.Family, Product_Name__c, 
                    List_Fee_Non_News_Annualized__c from NPR_Product__c where Opportunity_Name__c=:opp.Id];
            
                PricingUtility ut = new PricingUtility();
                opp = ut.calcOpportunity(opp, lstNprProd);
        */
                    
                selectedNPRProd = null;
                showDetails=false;
            }
        }
        else if(opp.Type=='MSA')
        {
            ValidationUtility vu = new ValidationUtility();
            list<String> errors = vu.validateOpportunityProduct(selectedOlI, selectedOlIOld);
            
            if(errors.size()>0)
            {
                for(String error : errors)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, error));
                }
            }
            else 
            {
                selectedOlI = null;
                showDetails=false;
            }   
        }
    }
    
    public PageReference saveWrapper()
    {
        // if closedate or End_Date__c changed
        if(oldOpp.CloseDate != opp.CloseDate || oldOpp.End_Date__c != opp.End_Date__c)
        {
            showRefreshPopUp = true;
            return null;
        }
        else
        {
            PageReference pr = save();
            return pr;
        }
    }
    
    public Boolean redirectPage{get; set;}
    public PageReference save()
    {   
        system.debug('\n\n nrpBundles = '+nrpBundles+'\n\n');
        system.debug('\n\n nrpBundleMap = '+nprBundleMap+'\n\n');
        redirectPage = false;
        system.debug('**\n\n Save \n\n**');
        system.debug('\n\n opp = '+opp+'\n\n');
        system.debug('\n\n oldopp = '+(Opportunity)viewstdController.getRecord()+'\n\n');
        // Validate
        ValidationUtility vu = new ValidationUtility();
        list<String> errors = vu.validateOpportunityField(opp);
        list<String> nprErrors = new list<String>{};
        for(NPR_Product__c nrpBundle : nrpBundles)
        {
            nprErrors = vu.validateNPRProductField(nrpBundle, nprBundleOldMap.get(nrpBundle.Id));
        }
        
        if(errors.size()>0)
        {
            for(String error : errors)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, error));
            }
        }
        else if(nprErrors.size()>0)
        {
            for(String nprError : nprErrors)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, nprError));
            }
        }
        else
        {
            try 
            {
            	system.debug('\n\n opp = '+opp+'\n\n');
                //opp.StageName = opp.Status2__c;
                update opp;
                
                if(opp.Type=='MSA' && oliMap.size()>0)
                {
                    update(oliMap.Values());
                }
                if(opp.Type=='PPF' && nprProdMap.size()>0)
                {
                    update(nprProdMap.Values());
                }
                if(nprBundleMap.size()>0)
                {
                    system.debug('\n\n nrpBundles = '+nprBundleMap+'\n\n');
                    update nprBundleMap.values();
                }
                
                
                redirectPage = true;
                // redirect to next step of wizard
                PageReference oppPage = new PageReference('/apex/OpportunityViewOverride?id='+opp.Id);
                return oppPage;
            }
            catch (DmlException x)
            {
                System.debug(x.getMessage());
            }
        }
        return null;
    }
    
    public void oppFieldChanged()
    {
        String fieldName = ApexPages.CurrentPage().getParameters().get('fieldName');
        
        if(fieldName=='Discount__c' || fieldName=='Total_Override__c' || fieldName=='Admin_Fee_Override__c')
        {
            // give me all npr prods for this opp
            list<NPR_Product__c> lstNprProd = [select Id, Name, Include_in_PPF_MSA__c, List_Fee__c, Discount_Type__c, Discount_Percent__c, Subtotal_Fee__c, Override_Discount__c, 
                Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Air_Onboard_Date__c, Air_Onboard_Status__c, 
                Adopt_Status__c, Adopt_Date__c, Drop_Date__c, Drop_Reason__c, Bill_Start_Date__c, Bill_End_Date__c, ATC_Uncapped_Price__c,
                ATC_Last_FY_Price__c, Cap_Percent__c, ATC_Capped_Final_Fee__c, Last_FY_Fee_Override__c, Accelerated_Cap__c, 
                Accelerated_Cap_Comments__c, Final_Fee__c, Product__r.PPF_Type__c, Product__r.Name, Opportunity_Name__r.CloseDate, 
                Opportunity_Name__r.End_Date__c, List_Fee_Annualized__c, List_Fee_Prorated__c, Product__r.Family, Product_Name__c, 
                List_Fee_Non_News_Annualized__c from NPR_Product__c where Opportunity_Name__c=:opp.Id /*and include_in_ppf_msa__c = true*/];/*Change made here by Suhas. Commented the field*/
            
            PricingUtility ut = new PricingUtility();
            opp = ut.calcOpportunity(opp, lstNprProd);
        }
    }
    
    public void NPRProdFieldChanged()
    {
        // Get passed params
        String fieldName = ApexPages.CurrentPage().getParameters().get('fieldName');
        
        if(fieldName=='Include_In_PPF_MSA__c')
        {
            if(selectedNPRProd.Include_In_PPF_MSA__c==true)
            {
                selectedNPRProd.Adopt_Date__c = opp.CloseDate;
                selectedNPRProd.Air_Onboard_Date__c = opp.CloseDate;
                //selectedNPRProd.Bill_Start_Date__c = opp.CloseDate;
                //selectedNPRProd.Bill_End_Date__c = opp.End_Date__c;
                selectedNPRProd.Adopt_Status__c = 'Complete';
            }
            else if(selectedNPRProd.Include_In_PPF_MSA__c==false)
            {
                selectedNPRProd.Adopt_Date__c = null;
                selectedNPRProd.Adopt_Status__c = null;
                selectedNPRProd.Air_Onboard_Date__c = null;
                selectedNPRProd.Air_Onboard_Status__c = null;
            }
            PricingUtility ut = new PricingUtility();
            selectedNPRProd = ut.calcNPRProd(selectedNPRProd);
        }
        else if(fieldName=='Override_Discount__c')
        {
            selectedNPRProd.Override_Fee__c = null;
            PricingUtility ut = new PricingUtility();
            selectedNPRProd = ut.calcNPRProd(selectedNPRProd);
        }
        else if(fieldName=='Override_Fee__c')
        {
            selectedNPRProd.Override_Discount__c = null;
            PricingUtility ut = new PricingUtility();
            selectedNPRProd = ut.calcNPRProd(selectedNPRProd);
        }
        else if(fieldName=='Air_Onboard_Date__c')
        {
            if(selectedNPRProd.Air_Onboard_Date__c!=null)
            {
                selectedNPRProd.Include_in_PPF_MSA__c = true;
                if(selectedNPRProd.Air_Onboard_Date__c<system.today())
                {
                    selectedNPRProd.Air_Onboard_Status__c = 'Complete';
                    // Add bill date defualts
                }
                selectedNPRProd.Bill_Start_Date__c=findBillDate(selectedNPRProd.Air_Onboard_Date__c);
                
                PricingUtility ut = new PricingUtility();
                selectedNPRProd = ut.calcNPRProd(selectedNPRProd);
                //System.currentPagereference().getParameters().put('fieldName', 'Include_In_PPF_MSA__c');
                //NPRProdFieldChanged();
            }
        }
        else if(fieldName=='Drop_Date__c' && selectedNPRProd.Drop_Date__c!=null)
        {
            if(selectedNPRProd.Drop_Date__c<=system.today())
            {
                selectedNPRProd.Air_Onboard_Status__c = 'Dropped';
            }
            selectedNPRProd.Bill_End_Date__c=selectedNPRProd.Drop_Date__c+90;
            
            PricingUtility ut = new PricingUtility();
            selectedNPRProd = ut.calcNPRProd(selectedNPRProd);
        }
        else if(fieldName=='Bill_Start_Date__c' || fieldName=='Bill_End_Date__c' || fieldName=='Accelerated_Cap__c' || 
            fieldName=='Last_FY_Fee_Override__c')
        {
            PricingUtility ut = new PricingUtility();
            selectedNPRProd = ut.calcNPRProd(selectedNPRProd);
        }
        
    }
    
    public void OLIFieldChanged()
    {
        // Get passed params
        String fieldName = ApexPages.CurrentPage().getParameters().get('fieldName');
        
        if(fieldName=='Override_Fee__c' || fieldName=='Bill_Start_Date__c' || fieldName=='Bill_End_Date__c')
        {
            PricingUtility ut = new PricingUtility();
            selectedOli = ut.calcOLI(selectedOli);
        }
        else if(fieldName=='Air_Onboard_Date__c')
        {
            if(selectedOli.Air_Onboard_Date__c!=null)
            {
                if(selectedOli.Air_Onboard_Date__c<system.today())
                {
                    selectedOli.Air_Onboard_Status__c = 'Complete';
                }
                selectedOli.Bill_Start_Date__c=findBillDate(selectedOli.Air_Onboard_Date__c);
            }   
        }
        else if(fieldName=='Drop_Date__c')
        {
            if(selectedOli.Drop_Date__c!=null)
            {
                if(selectedOli.Drop_Date__c<=system.today())
                {
                    selectedOli.Air_Onboard_Status__c = 'Dropped'; 
                }
                selectedOli.Bill_End_Date__c=selectedOli.Drop_Date__c+90;
            }
        }
    }
    
    public void nrpBundleFieldChanged()
    {
    	system.debug('This is the nrpBundleFieldChanged method being executed right now ====>>>>> ');
        // Get passed params
        String fieldName = ApexPages.CurrentPage().getParameters().get('fieldName');
        String fieldId =  ApexPages.CurrentPage().getParameters().get('fieldId');
        //bundleName = '';
        system.debug('bundleName above chk chk=====>>' +bundleName);
        System.debug ('Suhas::::: #521 if condition '+bundleName);
        if(String.isNotBlank(bundleName)) {         
            applyNullCheck = false;
            bundleName = null;
            system.debug('Bundle is made blank ===>>> '+bundleName);
        } else {
            bundleName = ApexPages.currentPage().getParameters().get('bundleName');
            system.debug('Bundle is assigned ===>>> '+bundleName);
            applyNullCheck = true;
        }
        system.debug('bundleName Suhas #533 after chk chk=====>>' +bundleName);
        //system.debug('bundleName above chk chk chk=====>>' +bundleName);
       /* if(!String.isBlank(bundleName)) {
            applyNullCheck = false;
        } else {
            applyNullCheck = true;
        } */
        system.debug('applyNullCheck in nrpBundleFieldChanged==>> '+applyNullCheck);
        //bundleName = ApexPages.currentPage().getParameters().get('bundleName');
        //String bundleName = ApexPages.currentPage().getParameters().get('bundleName'); /*Suhas 7/9/2015*/
        system.debug('fieldId===>>> '+fieldId);
        system.debug('bundleName===>>>> '+bundleName);
        
        NPR_Product__c nrpBundle = nprBundleMap.get(fieldId);
        NPR_Product__c nrpBundleOld = nprBundleOldMap.get(fieldId); 
        system.debug('\n\n nprBundleOldMap = '+nprBundleOldMap+'\n\n');
                
        if(fieldName=='Include_In_PPF_MSA__c')
        {
            if(nrpBundle.Include_In_PPF_MSA__c==true)
            {
                nrpBundle.Adopt_Date__c = opp.CloseDate;
                nrpBundle.Air_Onboard_Date__c = opp.CloseDate;
                //nrpBundle.Bill_Start_Date__c = opp.CloseDate;
                //nrpBundle.Bill_End_Date__c = opp.End_Date__c;
                nrpBundle.Adopt_Status__c = 'Complete';
                bundleName = ApexPages.currentPage().getParameters().get('bundleName');/*Added by Suhas 7/13/2015*/
            }
            else if(nrpBundle.Include_In_PPF_MSA__c==false)
            {
                nrpBundle.Adopt_Date__c = null;
                nrpBundle.Adopt_Status__c = null;
                nrpBundle.Air_Onboard_Date__c = null;
                nrpBundle.Air_Onboard_Status__c = null;
                bundleName = '';                                                        /*Added by Suhas 7/13/2015*/
            }
            
            PricingUtility ut = new PricingUtility();
            nrpBundle = ut.calcNPRProd(nrpBundle);
        }
        else if(fieldName=='Override_Discount__c')
        {
            nrpBundle.Override_Fee__c = null;
            PricingUtility ut = new PricingUtility();
            nrpBundle = ut.calcNPRProd(nrpBundle);
        }
        else if(fieldName=='Override_Fee__c')
        {
            nrpBundle.Override_Discount__c = null;
            PricingUtility ut = new PricingUtility();
            nrpBundle = ut.calcNPRProd(nrpBundle);
        }
        else if(fieldName=='Air_Onboard_Date__c')
        {
            if(nrpBundle.Air_Onboard_Date__c!=null)
            {
                nrpBundle.Include_in_PPF_MSA__c = true;
                if(nrpBundle.Air_Onboard_Date__c<system.today())
                {
                    nrpBundle.Air_Onboard_Status__c = 'Complete';
                }
                
                nrpBundle.Bill_Start_Date__c=findBillDate(nrpBundle.Air_Onboard_Date__c);
                
                PricingUtility ut = new PricingUtility();
                nrpBundle = ut.calcNPRProd(nrpBundle);
                system.debug('\n\n nrpBundle = '+nrpBundle+'\n\n');
            }
        }
        else if(fieldName=='Drop_Date__c')
        {
            if(nrpBundle.Drop_Date__c<=system.today())
            {
                nrpBundle.Air_Onboard_Status__c = 'Dropped';
            }
            nrpBundle.Bill_End_Date__c=nrpBundle.Drop_Date__c+90;
        }
        else if(fieldName=='Bill_Start_Date__c' || fieldName=='Bill_End_Date__c' || fieldName=='Accelerated_Cap__c' || fieldName=='Last_FY_MSA_Price_Override__c')
        {
            PricingUtility ut = new PricingUtility();
            nrpBundle = ut.calcNPRProd(nrpBundle);
        }
        
        PricingUtility ut = new PricingUtility();
        opp = ut.calcOpportunity(opp, nrpBundle, nrpBundleOld);
        
        nprBundleOldMap = nprBundleMap.deepclone();
        system.debug('nprBundleMap= size'+nprBundleMap.keySet().size());
        system.debug('\n\n nprBundleMap='+nprBundleMap+'\n\n');
    }
    
    public Date findBillDate(Date d)
    {
        Date returnDate;
        date newD = date.newInstance(d.year(), d.month(), 01);
        if(d.day()<=15)
        {
            returnDate = newD;
        }
        else
        {
            returnDate = newD.addMonths(1);
        }
        return returnDate;
    }
    
    public PageReference refresh()
    {
        String keepOverrides = ApexPages.currentPage().getParameters().get('keepOverrides'); 
        
        // Save records
        save();
        
        // Lock record
        opp.Record_Locked__c = true;
        update opp;
        // Call async refresh method
        refreshAsync(opp.Id, keepOverrides);
    
        showRefreshPopUp = false;
        
        return null;
    }
    
    @future 
    public static void refreshAsync(String oppId, String keepOverrides)
    {
        Opportunity o = [select Id, Name, Record_Locked__c, AccountId, Type, closeDate, End_Date__c, Fiscal_Year__c
            from Opportunity where Id=:oppId];
        
        RefreshOpportunityClass roc = new RefreshOpportunityClass();
        
        // Call refresh method
        if(keepOverrides=='true')
        {
            roc.refreshOpportunityKeepOverrides(o);
        }
        else
        {
            roc.refreshOpportunityNoOverrides(o);
        }
        
        // Unlock record
        o.Record_Locked__c = false;
        update o;
    }
    
    public pageReference closeRefreshPopupPanel()
    {
        showRefreshPopUp = false;
        pageReference pr = save();
        return pr;
    }
    
    public pageReference refreshClick()
    {
        showRefreshPopUp = true;
        return null;
    }
}