public class PricingUtility {
    private List<NPR_Product__c> currentOpportunityNPRProduct;

    public decimal prorate(Decimal amount, Date startDate, Date endDate)
    {
        decimal proratedAmt = 0;
        decimal proratedMonths = 0;
        Date endDateUpdated;
        
        if(startDate!=null && endDate!=null)
        {
            endDateUpdated = endDate;
            //system.debug('\n\n end date 2: '+endDate+'\n\n');
            //system.debug('\n\n '+endDate.Day()+'\n\n');
            //system.debug('\n\n '+endDate.Year()+'\n\n');
            //system.debug('\n\n '+endDate.month()+'\n\n');
            Integer monthsBetween = 0;
            if(endDate.Day()!=date.daysInMonth(endDate.Year(), endDate.month()))
            {
                monthsBetween = startDate.monthsBetween(endDateUpdated);
                //endDateUpdated = endDate.addMonths(-1);
            }
            else
            {
                monthsBetween = startDate.monthsBetween(endDateUpdated)+1;
            }
            
            // Add 1 day 
            //endDateUpdated = endDate.addDays(1);
            
            //Integer monthsBetween = startDate.monthsBetween(endDateUpdated);
            
            system.debug('***\n\n'+monthsBetween+'\n\n***');
            system.debug('***\n\n'+amount+'\n\n***');
            if(amount==null) amount=0;
            proratedMonths = monthsBetween * (amount/12);
            // If the StartDate is not the first of the month (DD = 01), determine the # of  days in the partial month (‘Partial Days’) 
            // and # total days in the month ((Total Days’) 
            //i.e. if 6/20 then there are 11 days in the partial month and 30 total days in the month of June)
            /*decimal proratedStartDays = 0;
            if(startDate.day()!=1)
            {
                Integer partialDays = date.daysInMonth(startDate.year(), startDate.month())-(startDate.day()-1);
                // Calculate  (‘Partial Days’ / ‘Total Days’) x  (Amount / 12)
                proratedStartDays = (partialDays/date.daysInMonth(startDate.year(), startDate.month()))*(amount/12);
            }*/
            
            // If the endDate is not the last day of the month , determine the # of  days in the partial month  (‘Partial Days’) and 
            // # total days in the month (‘Total Days’) 
            // i.e. if 6/20  is the End Date then there are 20 days in the partial month and 30 total days in the month of June)
            decimal proratedEndDays = 0;
            //system.debug('***\n\n End Day = '+endDate.Day()+'\n\n***');
            //system.debug('***\n\n Days in month = '+date.daysInMonth(endDate.Year(), endDate.month())+'\n\n***');
            if((endDate.Day()!=date.daysInMonth(endDate.Year(), endDate.month())) || (monthsBetween<1))
            {
                // Calculate  (‘Partial Days’ / ‘Total Days’) x  (Amount / 12)
                Decimal pDays = endDate.Day();
                Decimal tDays = date.daysInMonth(endDate.Year(), endDate.month());
                proratedEndDays = (pDays/tDays)*(amount/12);
            }
            
            system.debug('***\n\n'+proratedMonths+'\n\n***');
            system.debug('***\n\n'+proratedEndDays+'\n\n***');
            proratedAmt = proratedMonths + proratedEndDays;
        }
        system.debug('***\n\n'+proratedAmt+'\n\n***');
        return proratedAmt;
    }
    
    public Opportunity calcOpportunity(Opportunity o, NPR_Product__c nprProdNew, NPR_Product__c nprProdOld)
    {
        system.debug('*******\n\n IN CALC OPP \n\n********');
        system.debug('**\n\n'+nprProdNew.Include_in_PPF_MSA__c+'\n\n**');
        system.debug('**\n\n'+nprProdOld.Include_in_PPF_MSA__c+'\n\n**');
        
        if(nprProdNew.Final_Fee__c==null) nprProdNew.Final_Fee__c=0;
        if(nprProdOld.Final_Fee__c==null) nprProdOld.Final_Fee__c=0;
        Decimal delta = nprProdNew.Final_Fee__c - nprProdOld.Final_Fee__c;
        if (nprProdNew.Include_in_PPF_MSA__c == true)
        {
            if(nprProdOld.Include_in_PPF_MSA__c == true)
            {
                system.debug('\n\n'+nprProdNew.Final_Fee__c+'\n\n');
                system.debug('\n\n'+nprProdOld.Final_Fee__c+'\n\n');
                /*if(nprProdNew.Final_Fee__c==null) nprProdNew.Final_Fee__c=0;
                if(nprProdOld.Final_Fee__c==null) nprProdOld.Final_Fee__c=0;
                Decimal delta = nprProdNew.Final_Fee__c - nprProdOld.Final_Fee__c;*/
                system.debug('\n\n'+delta+'\n\n');

                if(o.Sub_Total_Price__c==null) o.Sub_Total_Price__c=0;
                o.Sub_Total_Price__c = o.Sub_Total_Price__c+delta;
                
                /*Added By Suhas on 24/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
                system.debug('nprProdNew.Product_PPF_Type__c======>>>> '+nprProdNew.Product_PPF_Type__c);
                if(nprProdNew.Product_PPF_Type__c != null && nprProdNew.Product_PPF_Type__c == 'Non-News') {
                    if(nprProdNew.List_Fee_Annualized__c==null) nprProdNew.List_Fee_Annualized__c=0;
                    if(nprProdOld.List_Fee_Annualized__c==null) nprProdOld.List_Fee_Annualized__c=0;
                    Decimal deltaListFeeAnnualized = nprProdNew.List_Fee_Annualized__c - nprProdOld.List_Fee_Annualized__c;
                    if(o.Total_Non_News_List_Price__c==null) o.Total_Non_News_List_Price__c=0;
                    o.Total_Non_News_List_Price__c = o.Total_Non_News_List_Price__c+deltaListFeeAnnualized;
                    
                    if(o.Total_Non_News_Final_Price__c==null) o.Total_Non_News_Final_Price__c=0;
                    o.Total_Non_News_Final_Price__c = o.Total_Non_News_Final_Price__c+delta;
                }
                /*Added Code ends here*/
                system.debug('\n\n'+o.Sub_Total_Price__c+'\n\n');
            }
            else if(nprProdOld.Include_in_PPF_MSA__c == false)
            {
                system.debug('\n\n'+nprProdNew.Final_Fee__c+'\n\n');
                system.debug('\n\n'+nprProdOld.Final_Fee__c+'\n\n');
                if(nprProdNew.Final_Fee__c==null) nprProdNew.Final_Fee__c=0;
                if(nprProdOld.Final_Fee__c==null) nprProdOld.Final_Fee__c=0;
                if(o.Sub_Total_Price__c==null) o.Sub_Total_Price__c=0;
                o.Sub_Total_Price__c = o.Sub_Total_Price__c+nprProdNew.Final_Fee__c;
                system.debug('\n\n'+o.Sub_Total_Price__c+'\n\n');

                /*Added by Suhas 01/08/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
                if(nprProdNew.Product_PPF_Type__c != null && nprProdNew.Product_PPF_Type__c == 'Non-News') {
                    if(o.Total_Non_News_List_Price__c==null) o.Total_Non_News_List_Price__c=0;
                    if(nprProdNew.List_Fee_Annualized__c == null)  nprProdNew.List_Fee_Annualized__c=0;
                    system.debug('before co.Total_Non_News_List_Price__c when nprProdOld.Include_in_PPF_MSA__c is false o.Total_Non_News_List_Price__c===>>>'+o.Total_Non_News_List_Price__c);
                    o.Total_Non_News_List_Price__c = o.Total_Non_News_List_Price__c  + nprProdNew.List_Fee_Annualized__c;
                    system.debug('after c o.Total_Non_News_List_Price__c when nprProdOld.Include_in_PPF_MSA__c is false o.Total_Non_News_List_Price__c===>>>'+o.Total_Non_News_List_Price__c);
    
                    if(o.Total_Non_News_Final_Price__c==null) o.Total_Non_News_Final_Price__c=0;
                    if(nprProdNew.Final_Fee__c==null) nprProdNew.Final_Fee__c=0;
                    system.debug('before c o.Total_Non_News_Final_Price__c when nprProdOld.Include_in_PPF_MSA__c is false o.Total_Non_News_List_Price__c===>>>'+o.Total_Non_News_Final_Price__c);
                    o.Total_Non_News_Final_Price__c = o.Total_Non_News_Final_Price__c + nprProdNew.Final_Fee__c;
                    system.debug('after c  o.Total_Non_News_Final_Price__c when nprProdOld.Include_in_PPF_MSA__c is false o.Total_Non_News_List_Price__c===>>>'+ o.Total_Non_News_Final_Price__c);
                }
                /*Code added ends here*/
            }
        }
        else
        {
            
            if(nprProdOld.Include_in_PPF_MSA__c == true)
            {   
                if(nprProdNew.Final_Fee__c==null) nprProdNew.Final_Fee__c=0;
                if(nprProdOld.Final_Fee__c==null) nprProdOld.Final_Fee__c=0;
                if(o.Sub_Total_Price__c==null) o.Sub_Total_Price__c=0;
                o.Sub_Total_Price__c = o.Sub_Total_Price__c-nprProdNew.Final_Fee__c;         

                /*Added by Suhas 01/08-2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
                if(nprProdNew.Product_PPF_Type__c != null && nprProdNew.Product_PPF_Type__c == 'Non-News') {
                    if(o.Total_Non_News_List_Price__c==null) o.Total_Non_News_List_Price__c=0;
                    system.debug('before co.Total_Non_News_List_Price__c when nprProdOld.Include_in_PPF_MSA__c is true o.Total_Non_News_List_Price__c===>>>'+o.Total_Non_News_List_Price__c);
                    o.Total_Non_News_List_Price__c = o.Total_Non_News_List_Price__c  - nprProdOld.List_Fee_Annualized__c;
                    system.debug('after c  o.Total_Non_News_List_Price__c when nprProdOld.Include_in_PPF_MSA__c is true o.Total_Non_News_List_Price__c===>>>'+o.Total_Non_News_List_Price__c);
                    if(o.Total_Non_News_Final_Price__c==null) o.Total_Non_News_Final_Price__c=0;
                    system.debug('before co.Total_Non_News_List_Price__c when nprProdOld.Include_in_PPF_MSA__c is true o.Total_Non_News_List_Price__c===>>>'+o.Total_Non_News_Final_Price__c);
                    o.Total_Non_News_Final_Price__c = o.Total_Non_News_Final_Price__c - nprProdOld.Final_Fee__c;
                    system.debug('after c  o.Total_Non_News_Final_Price__c when nprProdOld.Include_in_PPF_MSA__c is true o.Total_Non_News_List_Price__c===>>>'+ o.Total_Non_News_Final_Price__c);
                }
                /*Code added ends here*/
                //PPF/MSA : Code added by Suhas for Include PPF/MSA enhancement. 
                if(!String.isBlank(String.valueOf(o.Contract_Executed_Date__c)) && o.Type == 'PPF') {
                    if(o.Original_Contract_Price__c == null) o.Original_Contract_Price__c=0; 
                    o.Original_Contract_Price__c = o.Original_Contract_Price__c - nprProdNew.Final_Fee__c;
                }  
                //Code added by Suhas for Include PPF/MSA enhancement ends here.
            }
        }
        if(o.Total_Override__c!=null)
        {
            o.Sub_Total_Price_2__c = o.Total_Override__c;
        }
        else if(o.Discount__c!=null)
        {
            o.Sub_Total_Price_2__c = o.Sub_Total_Price__c - (o.Sub_Total_Price__c * o.Discount__c);
        }
        else
        {
            o.Sub_Total_Price_2__c = o.Sub_Total_Price__c;
        }
        
        if(o.Admin_Fee_Override__c!=null)
        {
            o.Total_Contract_Price__c = o.Sub_Total_Price_2__c + o.Admin_Fee_Override__c;
        }
        else if(o.Admin_Fee__c!=null)
        {
            o.Total_Contract_Price__c = o.Sub_Total_Price_2__c + o.Admin_Fee__c;
        }
        else
        {
            o.Total_Contract_Price__c = o.Sub_Total_Price_2__c;
        }
        /*Added By Suhas on 24/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
        if(nprProdNew.Product_PPF_Type__c != null && nprProdNew.Product_PPF_Type__c =='News') 
        {
            system.debug('nprProdNew.ATC_Uncapped_Price__c====>>>> '+nprProdNew.ATC_Uncapped_Price__c);
            system.debug('nprProdOld.ATC_Uncapped_Price__c == null====>>>> '+nprProdOld.ATC_Uncapped_Price__c);
            if(nprProdNew.ATC_Uncapped_Price__c == null) nprProdNew.ATC_Uncapped_Price__c=0;
            if(nprProdOld.ATC_Uncapped_Price__c == null) nprProdOld.ATC_Uncapped_Price__c=0;
            system.debug('nprProdNew.ATC_Uncapped_Price__c after ====>>>> '+nprProdNew.ATC_Uncapped_Price__c);
            system.debug('nprProdOld.ATC_Uncapped_Price__c == null afeter====>>>> '+nprProdOld.ATC_Uncapped_Price__c);
            Decimal deltaATCUncappedPrice = nprProdNew.ATC_Uncapped_Price__c - nprProdOld.ATC_Uncapped_Price__c;
            if(deltaATCUncappedPrice ==0) {
                o.News_Mag_Uncapped_Price__c = nprProdNew.ATC_Uncapped_Price__c;
            }else {
                o.News_Mag_Uncapped_Price__c = o.News_Mag_Uncapped_Price__c + deltaATCUncappedPrice;
            }
            system.debug('o.News_Mag_Uncapped_Price__c=====>>>>>>>>'+o.News_Mag_Uncapped_Price__c);
            
            if (o.News_Mag_Capped_Final_Price__c == null) o.News_Mag_Capped_Final_Price__c = 0;
            o.News_Mag_Capped_Final_Price__c = o.News_Mag_Capped_Final_Price__c + delta;
        }
        system.debug('o.Total_Contract_Price__c===>>>'+o.Total_Contract_Price__c+ 'o.Prior_Year_PPF_Contract_Price__c====>>> '+o.Prior_Year_PPF_Contract_Price__c);
        if(o.Total_Contract_Price__c != null && o.Prior_Year_PPF_Contract_Price__c != null && o.Prior_Year_PPF_Contract_Price__c != 0) {
            o.Year_Over_Year_Change__c = ((o.Total_Contract_Price__c - o.Prior_Year_PPF_Contract_Price__c) / o.Prior_Year_PPF_Contract_Price__c) * 100;
        }
        system.debug('o.News_Mag_Capped_Final_Price__c===>>>'+o.News_Mag_Capped_Final_Price__c+ 'o.Last_FY_Total_News_Mag_Price__c====>>> '+o.Prior_Year_PPF_Contract_Price__c);
        if(o.News_Mag_Capped_Final_Price__c != null && o.Last_FY_Total_News_Mag_Price__c!= null && o.Last_FY_Total_News_Mag_Price__c != 0) {
            o.Year_over_Year_News_Mag_Change__c = ((o.News_Mag_Capped_Final_Price__c - o.Last_FY_Total_News_Mag_Price__c) / o.Last_FY_Total_News_Mag_Price__c) * 100;
        }
        /*Added Code ends here*/
        
        return o;
    }
    
    // take in opportunity and all its line items and store on opporutniy 
    

    // Take all olis and all npr prods for all opps
    /*public map<String, list<OpportunityLineItem>> initOLIs(map<String, list<OpportunityLineItem>> nprIdOliMap, map<String, NPR_Product__c> nprProdMap)
    {
        list<OpportunityLineItem> streamingOLIs = new list<OpportunityLineItem>{};
        list<OpportunityLineItem> EmailOLIs = new list<OpportunityLineItem>{};
        
        for(list<OpportunityLineItem> olis : nprIdOliMap.Values())
        {
            for(OpportunityLineItem oli : olis)
            {
                if(oli.Product2.MSA_Incremental_Type__c=='Streaming')
                {
                    streamingOLIs.add(oli);
                }
                if(oli.Product2.MSA_Incremental_Type__c=='Email')
                {
                    EmailOLIs.add(oli);
                }
            }
        }
        
        Date billDateLow;
        Date billDateHigh;
        Boolean firstTime = true;
        for(NPR_Product__c npr : nprProdMap.values())
        {
            if(firstTime)
            {
                billDateLow = npr.Bill_Start_Date__c;
                billDateHigh = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_Start_Date__c<billDateLow)
            {
                billDateLow = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_Start_Date__c>billDateHigh)
            {
                billDateHigh = npr.Bill_Start_Date__c;
            }
        }
        
        // ---------- Email ----------
        firstTime = true;
        Decimal minEmailListSize = 0;
        Decimal maxEmailListSize = 0;
        // Find min and max email list size for query
        for(OpportunityLineItem oli : EmailOLIs)
        {
            if(firstTime)
            {
                minEmailListSize = oli.Station__r.Email_List_Size__c;
                maxEmailListSize = oli.Station__r.Email_List_Size__c;
            }
            if(oli.Station__r.Email_List_Size__c<minEmailListSize)
            {
                minEmailListSize = oli.Station__r.Email_List_Size__c;
            }
            if(oli.Station__r.Email_List_Size__c>maxEmailListSize)
            {
                maxEmailListSize = oli.Station__r.Email_List_Size__c;
            }
        }
        
        // Query for type email
        list<MSA_Incremental__c> MSAIncEmailList = [SELECT Setup_Fee__c, Annualized_Fee__c, Recurrence_Fee__c, Recurrence_Type__c, 
            Email_List_Size_Low__c, Email_List_Size_High__c
            FROM MSA_Incremental__c
            WHERE Effective_Date__c<=:billDateLow and Expiration_Date__c>=:billDateHigh and Product_Type__c='Email'
            and Email_List_Size_Low__c<=:minEmailListSize and Email_List_Size_High__c>=:maxEmailListSize];
        
        // -------- Streaming -----------
        list<String> memberTypes = new list<String>{};
        list<String> prodVersions = new list<String>{};
        for(OpportunityLineItem oli : streamingOLIs)
        {
            memberTypes.add(oli.Station__r.Membership_Pricing_Status__c);
            prodVersions.add(oli.Product2.Product_Version__c);
        }
        
        // Query for type streaming
        list<MSA_Incremental__c> MSAIncStreamingList = [SELECT Setup_Fee__c, Annualized_Fee__c, Recurrence_Fee__c, Recurrence_Type__c, 
            Membership_Type__c, Product_Version__c 
            FROM MSA_Incremental__c
            WHERE Effective_Date__c<=:billDateLow and Expiration_Date__c>=:billDateHigh and Product_Type__c='Streaming'
            and Membership_Type__c IN:memberTypes and Product_Version__c IN:prodVersions];
            
        // Create map for easy look up
        map<String, list<MSA_Incremental__c>> streamingMap = new map<String, list<MSA_Incremental__c>>{};
        for(MSA_Incremental__c msai : MSAIncStreamingList)
        {
            if(streamingMap.containsKey(msai.Membership_Type__c+msai.Product_Version__c))
            {
                list<MSA_Incremental__c> msaiList = streamingMap.get(msai.Membership_Type__c+msai.Product_Version__c);
                msaiList.add(msai);
                streamingMap.remove(msai.Membership_Type__c+msai.Product_Version__c);
                streamingMap.put(msai.Membership_Type__c+msai.Product_Version__c, msaiList);
            }
            else
            {
                list<MSA_Incremental__c> msaiList = new list<MSA_Incremental__c>{msai};
                streamingMap.put(msai.Membership_Type__c+msai.Product_Version__c, msaiList);
            }
        }
        
        for(String nprId : nprIdOliMap.keySet())
        {
            // get all olis for this npr prod
            for(OpportunityLineItem oli : nprIdOliMap.get(nprId))
            {
                if(oli.Product2.MSA_Incremental_Type__c=='Streaming')
                {
                    list<MSA_Incremental__c> msaiList = streamingMap.get(oli.Station__r.Membership_Pricing_Status__c+oli.Product2.Product_Version__c);
                    
                    if(msaiList.size()>0)
                    {
                        for(MSA_Incremental__c msai : msaiList)
                        {
                            if(msai.Effective_Date__c<=nprProdMap.get(nprId).Bill_Start_Date__c && 
                               msai.Expiration_Date__c>nprProdMap.get(nprId).Bill_Start_Date__c)
                            {
                                oli.Annualized_Price__c = msai.Annualized_Fee__c;
                                oli.Set_up_fee__c = msai.Setup_Fee__c;
                                oli.Recurrence_Type__c = msai.Recurrence_Type__c;
                                oli.Recurrence_Price__c = msai.Recurrence_Fee__c;
                                oli.Email_List_Size__c = oli.Station__r.Email_List_Size__c;
                            }
                        }
                    }    
                }
                
                if(oli.Product2.MSA_Incremental_Type__c=='Email')
                {
                    for(MSA_Incremental__c msai : MSAIncEmailList)
                    {
                        if(msai.Email_List_Size_Low__c<=oli.Station__r.Email_List_Size__c && 
                            msai.Email_List_Size_High__c>=oli.Station__r.Email_List_Size__c &&
                            msai.Effective_Date__c<=nprProdMap.get(nprId).Bill_Start_Date__c &&
                            msai.Expiration_Date__c>=nprProdMap.get(nprId).Bill_Start_Date__c)
                        {
                            oli.Annualized_Price__c = msai.Annualized_Fee__c;
                            oli.Set_up_fee__c = msai.Setup_Fee__c;
                            oli.Recurrence_Type__c = msai.Recurrence_Type__c;
                            oli.Recurrence_Price__c = msai.Recurrence_Fee__c;
                            oli.Email_List_Size__c = oli.Station__r.Email_List_Size__c;
                        }
                    }    
                }
            }
        }
        
        return nprIdOliMap;
    }*/
    
    public list<OpportunityLineItem> initOLIs(Opportunity o, list<OpportunityLineItem> olis, list<NPR_Product__c> nprProds, list<Product2> prods, list<Account> accounts,
        list<MSA_Incremental__c> MSAIncStreamingList, list<MSA_Incremental__c> MSAIncEmailList, list<PricebookEntry> pbes)
    {
        //list<OpportunityLineItem> streamingOLIs = new list<OpportunityLineItem>{};
        //list<OpportunityLineItem> EmailOLIs = new list<OpportunityLineItem>{};
        
        // Move outside of this method
        /*for(OpportunityLineItem oli : olis)
        {
            // query for the following Opp Products only:OpportunityProduct.Product.MSA_Incremental__c = “Streaming” OR “Email”
            if(oli.Product2.MSA_Incremental_Type__c=='Streaming')
            {
                streamingOLIs.add(oli);
            }
            if(oli.Product2.MSA_Incremental_Type__c=='Email')
            {
                EmailOLIs.add(oli);
            }
        }*/
        
        System.debug('\n\n\nIn initOLIs\n\n\n');
        System.debug('\n\n\nOpportunity is: ' + o + '\n\n\nolis are: ' + olis + '\n\nnprProds are: ' + nprProds + '\n\nprods are: ' + prods + '\n\n\n');
        //list<Account> accounts,
        //list<MSA_Incremental__c> MSAIncStreamingList, list<MSA_Incremental__c> MSAIncEmailList, list<PricebookEntry> pbes');
        
        map<String, PricebookEntry> pbeMap = new map<String, PricebookEntry>{};
        for(PricebookEntry pbe : pbes)
        {
            pbeMap.put(pbe.Id, pbe);
        }
        
        map<String, Account> accountMap = new map<String, Account>{};
        system.debug('accounts====>>> '+accounts);
        if(accounts != null && accounts.size() > 0) {
            for(Account a : accounts)
            {
                accountMap.put(a.Id, a);
            }
        }
        map<string, Product2> prodMap = new map<String, Product2>{};
        for(Product2 p : prods)
        {
            prodMap.put(p.Id, p);
        }
        
        map<String, NPR_Product__c> nprProdMap = new map<String, NPR_Product__c>{};
        if(nprProds!=null)
        {
            for(NPR_Product__c npr : nprProds)
            {
                nprProdMap.put(npr.Id, npr);
            }
        }
            
        System.debug('\n\n\nMSAIncStreamingList is: ' + MSAIncStreamingList + '\n\n\n');    
            
        // Create map for easy look up
        map<String, list<MSA_Incremental__c>> streamingMap = new map<String, list<MSA_Incremental__c>>{};
        for(MSA_Incremental__c msai : MSAIncStreamingList)
        {
            if(streamingMap.containsKey(msai.Membership_Type__c+msai.Product_Version__c))
            {
                list<MSA_Incremental__c> msaiList = streamingMap.get(msai.Membership_Type__c+msai.Product_Version__c);
                msaiList.add(msai);
                streamingMap.remove(msai.Membership_Type__c+msai.Product_Version__c);
                streamingMap.put(msai.Membership_Type__c+msai.Product_Version__c, msaiList);
            }
            else
            {
                list<MSA_Incremental__c> msaiList =  new list<MSA_Incremental__c>{};
                msaiList.add(msai);
                streamingMap.put(msai.Membership_Type__c+msai.Product_Version__c, msaiList);
            }
        }
        
        for(OpportunityLineItem oli : olis)
        {
            System.debug('\n\n$$$$$$$$$$$$$$$$$$$$$$$$$$$$In for loop for olis$$$$$$$$$$$$$$$$$$$\n\n');
            
            system.debug('***\n\n'+oli.PricebookEntryId+'\n\n***');
            
            System.debug('\n\n\noli.PricebookEntryId is: ' + oli.PricebookEntryId + '\n\n\n');
            //System.debug('\n\n\npbeMap.get(oli.PricebookEntryId).Product2Id is: ' + pbeMap.get(oli.PricebookEntryId).Product2Id + '\n\n\n');
            //System.debug('\n\n\nprodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id) is: ' + prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id) + '\n\n\n');
            //System.debug('\n\n\nMSA_Incremental_Type__c is: ' + prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id).MSA_Incremental_Type__c + '\n\n\n');
            
            if(pbeMap.get(oli.PricebookEntryId)!=null && pbeMap.get(oli.PricebookEntryId).Product2Id!=null && 
               prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id)!=null && 
               prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id).MSA_Incremental_Type__c=='Streaming')
            {
                System.debug('\n\n\nZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ\n\n\n');
                System.debug('\n\n\nstreamingMap is: ' + streamingMap + '\n\n\n');
                System.debug('\n\n\nMembership_Pricing_Status__c: ' + o.Account.Membership_Pricing_Status__c + '\n\n\n');
                System.debug('\n\n\nProduct_Version__c: ' + prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id).Product_Version__c + '\n\n\n');
                list<MSA_Incremental__c> msais = streamingMap.get(o.Account.Membership_Pricing_Status__c+prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id).Product_Version__c);
                system.debug('***\n\n'+msais+'\n\n***');
                if(msais!=null && msais.size()>0)
                {
                    for(MSA_Incremental__c msai : msais)
                    {
                        if(nprProdMap.get(oli.NPR_Product__c)!=null)
                        {
                            System.debug('\n\n\nmsai.Effective_Date__c: ' + msai.Effective_Date__c + '\n\n\n');
                            System.debug('\n\n\nnprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c: ' + nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c + '\n\n\n');
                            System.debug('\n\n\nmsai.Expiration_Date__c: ' + msai.Expiration_Date__c + '\n\n\n');
                            System.debug('\n\n\nnprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c: ' + nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c + '\n\n\n');
                        }
                        
                        if(nprProdMap.get(oli.NPR_Product__c)!=null && msai.Effective_Date__c<=nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c && 
                           msai.Expiration_Date__c>=nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c)
                        {
                            System.debug('\n\n\n IN OLI STREAMING \n\n\n');
                            oli.Annualized_Price__c = msai.Annualized_Fee__c;
                            oli.Set_up_fee__c = msai.Setup_Fee__c;
                            oli.Recurrence_Type__c = msai.Recurrence_Type__c;
                            oli.Recurrence_Price__c = msai.Recurrence_Fee__c;
                            oli.Email_List_Size__c = oli.Station__r.Email_List_Size__c;
                        }    
                    }
                }
            }
            if(pbeMap.get(oli.PricebookEntryId)!=null && pbeMap.get(oli.PricebookEntryId).Product2Id!=null && prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id)!=null &&
               prodMap.get(pbeMap.get(oli.PricebookEntryId).Product2Id).MSA_Incremental_Type__c=='Email')
            {
                system.debug('\n\n MSAIncEmailList = '+MSAIncEmailList+'\n\n');
                for(MSA_Incremental__c msai : MSAIncEmailList)
                {
                    system.debug('\n\n msai.Email_List_Size_Low__c = '+msai.Email_List_Size_Low__c+'\n\n');
                
                    if (accountMap!=null && accountMap.get(oli.Station__c)!=null)
                        system.debug('\n\n accountMap.get(oli.Station__c).Email_List_Size__c = '+accountMap.get(oli.Station__c).Email_List_Size__c+'\n\n');
                
                    system.debug('\n\n msai.Email_List_Size_High__c = '+msai.Email_List_Size_High__c+'\n\n');
                                
                    if(oli.NPR_Product__c!=null && nprProdMap!=null && accountMap!=null && accountMap.get(oli.Station__c)!=null && msai.Email_List_Size_Low__c<=accountMap.get(oli.Station__c).Email_List_Size__c && 
                        msai.Email_List_Size_High__c>=accountMap.get(oli.Station__c).Email_List_Size__c)
                    {
                        system.debug('\n\n msai.Effective_Date__c = '+msai.Effective_Date__c+'\n\n');
                        system.debug('\n\n nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c = '+nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c+'\n\n');
                    
                        system.debug('\n\n msai.Expiration_Date__c = '+msai.Expiration_Date__c+'\n\n');
                        system.debug('\n\n nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c = '+nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c+'\n\n');
                        if(msai.Effective_Date__c<=nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c && 
                           msai.Expiration_Date__c>=nprProdMap.get(oli.NPR_Product__c).Bill_Start_Date__c)
                        {
                            oli.Annualized_Price__c = msai.Annualized_Fee__c;
                            oli.Set_up_fee__c = msai.Setup_Fee__c;
                            oli.Recurrence_Type__c = msai.Recurrence_Type__c;
                            oli.Recurrence_Price__c = msai.Recurrence_Fee__c;
                            oli.Email_List_Size__c = accountMap.get(oli.Station__c).Email_List_Size__c;
                        }
                    }
                }
            }
        }
        
        return olis;
    }
    
    // Only take OLIs with Product2.MSA_Incremental_Type__c=='Streaming'
    public list<MSA_Incremental__c> MSAIncrementalStreaming(list<OpportunityLineItem> olis, list<NPR_Product__c> nprProds, 
        list<Opportunity> opps, list<Product2> prods, Map<Id,Id> pbeToProd, Map<Id, Account> oppAccountMap)
    {
        System.debug('\n\n\nIn pu.MSAIncrementalStreaming, olis are: ' + olis + '\nnprProds are: ' + nprProds + '\nopps are: ' + opps + '\nprods are: ' + prods + ' \n\n\n');
        
        /*map<String, Account> accountMap = new map<String, Account>{};
        for(Account a : accounts)
        {
            accountMap.put(a.Id, a);
        }*/
        
        map<string, Product2> prodMap = new map<String, Product2>{};
        for(Product2 p : prods)
        {
            prodMap.put(p.Id, p);
        }
        
        //list<String> memberTypes = new list<String>{};
        list<String> prodVersions = new list<String>{};
        for(OpportunityLineItem oli : olis)
        {
            System.debug('\n\n\noli.PricebookEntryId is: ' + oli.PricebookEntryId + '\n\n\n');
            //System.debug('\n\n\npbeToProd is: ' + pbeToProd + '\n\n\n');
            System.debug('\n\n\nnoli.Product2Id (converted) is: ' + pbeToProd.get(oli.PricebookEntryId) + '\n\n\n');
            System.debug('\n\n\n' + prodMap.get(pbeToProd.get(oli.PricebookEntryId)) + '\n\n\n');
            //System.debug('\n\n\n' + prodMap.get(pbeToProd.get(oli.PricebookEntryId)).Product_Version__c + '\n\n\n');
                    
            //memberTypes.add(accountMap.get(oli.Station__c).Membership_Pricing_Status__c);
            if(pbeToProd.get(oli.PricebookEntryId)!=null && prodMap.get(pbeToProd.get(oli.PricebookEntryId))!=null && prodMap.get(pbeToProd.get(oli.PricebookEntryId)).Product_Version__c!=null)
            {
                prodVersions.add(prodMap.get(pbeToProd.get(oli.PricebookEntryId)).Product_Version__c);
            }
        }
        
        list<String> membershipStatus = new list<String>{};
        for(Opportunity opp : opps)
        {
            System.debug('\n\n\n' + oppAccountMap.get(opp.Id) + '\n\n\n');
            System.debug('\n\n\n' + oppAccountMap.get(opp.Id).Membership_Pricing_Status__c + '\n\n\n');
            //membershipStatus.add(oppAccountMap.get(opp.Id).Membership_Status_for_MSA__c);
            membershipStatus.add(oppAccountMap.get(opp.Id).Membership_Pricing_Status__c);
        }
        
        Date startDate;
        Date endDate;
        Boolean firstTime=true;
        for(NPR_Product__c npr : nprProds)
        {
            if(firstTime)
            {
                firstTime = false;
                startDate = npr.Bill_Start_Date__c;
                endDate = npr.Bill_End_Date__c;
            }
            if(npr.Bill_Start_Date__c<startDate)
            {
                startDate = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_End_Date__c>endDate)
            {
                endDate = npr.Bill_End_Date__c;
            }
        }
        
        System.debug('\n\n\nstart date is: ' + startDate + '\n\nendDate is: ' + endDate + 'membershipStatus is: ' + membershipStatus + 'prodVersions are: ' + prodVersions + ' \n\n\n');
        
        // Query for type streaming
        list<MSA_Incremental__c> MSAIncStreamingList = [SELECT Setup_Fee__c, Annualized_Fee__c, Recurrence_Fee__c, Recurrence_Type__c, 
            Membership_Type__c, Product_Version__c, Effective_Date__c, Expiration_Date__c
            FROM MSA_Incremental__c
            WHERE Effective_Date__c<=:startDate and Expiration_Date__c>=:endDate and Product_Type__c='Streaming'
            and Membership_Type__c IN:membershipStatus and Product_Version__c IN:prodVersions];
            
        System.debug('\n\n\nMSAIncStreamingList is: ' + MSAIncStreamingList + '\n\n\n');
            
        return MSAIncStreamingList;
    }
    
    // Only take OLIs with Product2.MSA_Incremental_Type__c=='Email'
    public list<MSA_Incremental__c> MSAIncrementalEmail(list<OpportunityLineItem> olis, list<NPR_Product__c> nprProds, list<Account> accounts)
    {    
        map<String, Account> accountMap = new map<String, Account>{};
        for(Account a : accounts)
        {
            accountMap.put(a.Id, a);
        }
        
        Boolean firstTime = true;
        Decimal minEmailListSize = 0;
        Decimal maxEmailListSize = 0;
        // Find min and max email list size for query
        for(OpportunityLineItem oli : olis)
        {
            if(firstTime)
            {
                firstTime = false;
                if (oli.Station__c!=null && accountMap.get(oli.Station__c)!=null) 
                {
                    minEmailListSize = accountMap.get(oli.Station__c).Email_List_Size__c;
                    maxEmailListSize = accountMap.get(oli.Station__c).Email_List_Size__c;
                }
            }
            if(accountMap.get(oli.Station__c)!=null && accountMap.get(oli.Station__c).Email_List_Size__c<minEmailListSize)
            {
                minEmailListSize = accountMap.get(oli.Station__c).Email_List_Size__c;
            }
            if(accountMap.get(oli.Station__c)!=null && accountMap.get(oli.Station__c).Email_List_Size__c>maxEmailListSize)
            {
                maxEmailListSize = accountMap.get(oli.Station__c).Email_List_Size__c;
            }
        }
        
        Date startDate;
        Date endDate;
        firstTime=true;
        for(NPR_Product__c npr : nprProds)
        {
            if(firstTime)
            {
                firstTime = false;
                startDate = npr.Bill_Start_Date__c;
                endDate = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_Start_Date__c<startDate)
            {
                startDate = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_Start_Date__c>endDate)
            {
                endDate = npr.Bill_Start_Date__c;
            }
        }
        
        //system.debug('***\n\n startDate = '+startDate+'\n\n***');
        //system.debug('***\n\n endDate = '+endDate+'\n\n***');
        //system.debug('***\n\n minEmailListSize = '+minEmailListSize+'\n\n***');
        //system.debug('***\n\n maxEmailListSize = '+maxEmailListSize+'\n\n***');
        // Query for type email
        list<MSA_Incremental__c> MSAIncEmailList = [SELECT Setup_Fee__c, Annualized_Fee__c, Recurrence_Fee__c, Recurrence_Type__c, 
            Email_List_Size_Low__c, Email_List_Size_High__c, Effective_Date__c, Expiration_Date__c
            FROM MSA_Incremental__c
            WHERE Effective_Date__c<=:startDate and Expiration_Date__c>=:endDate and Product_Type__c='Email'
            and Email_List_Size_Low__c<=:minEmailListSize and Email_List_Size_High__c>=:maxEmailListSize];
            
        return     MSAIncEmailList;
    }
    
    public OpportunityLineItem calcOLI(OpportunityLineItem oli)
    {
        if(oli!=null)
        {
            if(oli.Set_up_fee__c==null) oli.Set_up_fee__c=0;
            if(oli.Annualized_Price__c==null) oli.Annualized_Price__c=0;
            
            // Subtotal_Fee__c
            oli.Subtotal_Fee__c = prorate(oli.Annualized_Price__c, oli.Bill_Start_Date__c, oli.Bill_End_Date__c);
            
            // Final_Price__c
            if(oli.Override_Fee__c!=NULL)
            {
                oli.Final_Price__c = oli.Override_Fee__c;
            }
            else
            {
                oli.Final_Price__c = oli.Subtotal_Fee__c + oli.Set_up_fee__c;
            }
        }    
        return oli;
    }
    
    // Take one opp per list of things needed
    public list<NPR_Product__c> initNPRProds(Opportunity o, Account a, list<NPR_Product__c> nprProds, list<FY_Pricing_Detail__c> fypds, 
        list<Discounts__c> discList, list<Product2> prodList, list<Pricing_Table__c> pts, list<Pricing_MSA_License_Fee__c> MSALicenseFees)
    {
        system.debug('*************************\n\n IN initNprProds Method \n\n**************************');
        system.debug('\n\n PTS = '+pts+'\n\n');
        system.debug('\n\n fypds = '+fypds+'\n\n');
        list<NPR_Product__c> PPFProgNPRProds = new list<NPR_Product__c>{};
        list<NPR_Product__c> MSAProgNPRProds = new list<NPR_Product__c>{};
        
        map<string, Discounts__c> discountNewNonNewsMap = new map<String, Discounts__c>{};
        if (discList!=null && discList.size()>0) {
            for(Discounts__c d : discList)
            {
                discountNewNonNewsMap.put(d.News_Non_News__c, d);
            }
        }
        
        list<Id> Prod2Ids = new list<Id>{};
        for(NPR_Product__c npr : nprProds)
        {
            Prod2Ids.add(npr.Product__c);
        }
        
        Map<Id, Product2> prodMap = new Map<Id, Product2>{};
        if(prodList!=null && prodList.size()>0)
        {
            for(Product2 p : prodList)
            {
                prodMap.put(p.Id, p);
            }
        }
        system.debug('nprProds====>>>>' +nprProds.size() + '   nprProds====>>>> '+nprProds);
        for(NPR_Product__c npr : nprProds)
        {
            system.debug('npr====>>>>>>> '+npr);
            if(fypds!=null && fypds.size()>0)
            {
                // use first fypd we find
                system.debug('\n\n npr.Product__c: '+npr.Product__c+'\n\n');
                system.debug('\n\n prodMap.get(npr.Product__c): '+prodMap.get(npr.Product__c)+'\n\n');
                //npr.Product__c!=null && prodMap.get(npr.Product__c)!=null && 
                if(prodMap.get(npr.Product__c).ME__c==true)
                {
                    npr.ATC_Uncapped_Price__c=fypds[0].ME_Uncapped_Price__c;
                    npr.ATC_Last_FY_Price__c=fypds[0].ME_Last_FY_Price__c;
                    //npr.Last_FY_Fee_Override__c=fypd.ME_Last_FY_Price_Override__c;
                    /*Added by Suhas NPR-186*/
                    system.debug('fypds[0].ME_Cap_Factor_Used__c===>>>' +fypds[0].ME_Cap_Factor_Used__c);
                    system.debug('fypds[0].ME_Cap_Factor_Used_Discount__c===>>>' +fypds[0].ME_Cap_Factor_Used_Discount__c);
                    if(a.Minority_Status__c == null) {
                        npr.Cap_Percent__c=fypds[0].ME_Cap_Factor_Used__c;         
                    } else {
                        npr.Cap_Percent__c=fypds[0].ME_Cap_Factor_Used_Discount__c;
                    }
                    /*Ends here*/
                    //npr.Cap_Percent__c=fypds[0].ME_Cap_Factor_Used__c;         /*Change made by Suhas*/
                    npr.ATC_Capped_Price__c=fypds[0].ME_Capped_Price__c;
                    npr.ATC_Capped_Final_Fee__c=fypds[0].ME_Capped_Price__c;
                }
                // npr.Product__c!=null && prodMap.get(npr.Product__c)!=null && 
                else if(prodMap.get(npr.Product__c).ATC__c==true)
                {
                    npr.ATC_Uncapped_Price__c=fypds[0].ATC_Uncapped_Price__c;
                    npr.ATC_Last_FY_Price__c=fypds[0].ATC_Last_FY_Price__c;
                    //npr.Last_FY_Fee_Override__c=fypd.ATC_Last_FY_Fee_Override__c;
                    /*Added by Suhas NPR-186*/
                    system.debug('fypds[0].ATC_Cap_Factor_Used__c===>>>' +fypds[0].ATC_Cap_Factor_Used__c);
                    system.debug('fypds[0].ATC_Cap_Factor_Used_Discount__c===>>>' +fypds[0].ATC_Cap_Factor_Used_Discount__c);
                    if(a.Minority_Status__c == null) {
                        npr.Cap_Percent__c=fypds[0].ATC_Cap_Factor_Used__c;         
                    } else {
                        npr.Cap_Percent__c=fypds[0].ATC_Cap_Factor_Used_Discount__c;
                    }
                    /*Ends here*/
                    //npr.Cap_Percent__c=fypds[0].ATC_Cap_Factor_Used__c;        /*Change made by Suhas*/
                    npr.ATC_Capped_Price__c=fypds[0].ATC_Capped_Price__c;
                    npr.ATC_Capped_Final_Fee__c=fypds[0].ATC_Capped_Price__c;
                }
            }
        
            if(npr!=null && discountNewNonNewsMap!=null && prodMap!=null && npr.Product__c!=null && prodMap.get(npr.Product__c)!=null 
                && prodMap.get(npr.Product__c).PPF_Type__c!=null && discountNewNonNewsMap.get(prodMap.get(npr.Product__c).PPF_Type__c)!=null 
                && prodMap.get(npr.Product__c).PPF_Type__c == 'Non-News')
            {
                system.debug(discountNewNonNewsMap.get(prodMap.get(npr.Product__c).PPF_Type__c));
                Discounts__c disc = discountNewNonNewsMap.get(prodMap.get(npr.Product__c).PPF_Type__c);
                if (disc!=null && disc.Discount_Percent__c!=null)
                {
                    npr.Discount_Percent__c = disc.Discount_Percent__c;
                }
                npr.Discount_Type__c = a.Minority_Status__c;
            }
            system.debug('npr.Product__c====>>> '+npr.Product__c);
            if(prodMap.get(npr.Product__c).PPF_Type__c == 'News')
            {
                npr.Discount_Type__c = a.Minority_Status__c;
            }
            
            // query for the following NPR Products only: NPR_Product__r.Opportunity.Type = PPF AND NPR_Product__r.Product.PPF_Type__c = “Non-News”
            if(o.Type=='PPF' && prodMap.get(npr.Product__c)!=null && prodMap.get(npr.Product__c).PPF_Type__c=='Non-News')
            {
                PPFProgNPRProds.add(npr);
            }
            // query for the following NPR Products only: NPR_Product__r.Opportunity.Type = MSA AND NPR_Product__r.Product.MSA_Bundle__c = TRUE
            if(o.Type=='MSA' && prodMap.get(npr.Product__c)!=null && prodMap.get(npr.Product__c).MSA_Bundle__c==true)
            {
                MSAProgNPRProds.add(npr);
            }
        }
        
        //system.debug('****\n\n'+o.Type+'\n\n****');
        if(o.Type=='PPF')
        {
            // Query 11A
            //map<String, list<Pricing_Table__c>> prodIdPTMap = pricingTable(PPFProgNPRProds, o);
            Boolean firstTime=true;
            list<Pricing_Table__c> ptList = new list<Pricing_Table__c>{};
            map<String, list<Pricing_Table__c>> prodIdPTMap = new map<String, list<Pricing_Table__c>>{};
            String lastProdId;
            for(Pricing_Table__c pt : pts)
            {
                if(firstTime)
                {
                    lastProdId = pt.Product__c;
                    firstTime=false;
                }
                if(lastProdId != pt.Product__c)
                {
                    prodIdPTMap.put(lastProdId, ptList);
                    ptList = new list<Pricing_Table__c>{};
                }
                ptlist.add(pt);
                lastProdId = pt.Product__c;
            }
            prodIdPTMap.put(lastProdId, ptList);
            
            for(NPR_Product__c npr : nprProds)
            {
                //system.debug('****\n\n'+prodMap.get(npr.Product__c).Name+'\n\n****');
                system.debug('****\n\n'+npr.Product__c+'\n\n****');
                system.debug('****\n\n'+prodIdPTMap+'\n\n****');
                system.debug('****\n\n'+prodIdPTMap.get(npr.Product__c)+'\n\n****');
                if(prodIdPTMap.get(npr.Product__c)!=null)
                {
                    for(Pricing_Table__c pt : prodIdPTMap.get(npr.Product__c))
                    {
                        //system.debug('****\n\n'+a.Membership_Pricing_Status__c+'\n\n****');
                        system.debug('****\n\n'+npr.Bill_Start_Date__c+'\n\n****');
                        system.debug('****\n\n'+npr.Bill_End_Date__c+'\n\n****');
                        system.debug('****\n\n'+pt.TSR_Low__c+'\n'+pt.TSR_High__c+'\n\n****');
                        system.debug('****\n\n'+o.TSR_In_Hierarchy_PPF__c+'\n\n****');
                        // pt.Membership_Pricing_Status__c==a.Membership_Pricing_Status__c &&
                        if(pt.Effective_Date__c<=npr.Bill_Start_Date__c && pt.Expiration_Date__c>=npr.Bill_End_Date__c &&
                           pt.TSR_Low__c<=o.TSR_In_Hierarchy_PPF__c && pt.TSR_High__c>=o.TSR_In_Hierarchy_PPF__c)
                        {
                            //npr.List_Fee_Annualized__c=pt.List_Fee__c;
                            system.debug('****\n\n'+pt.List_Fee__c+'\n\n****');
                            npr.List_Fee_Non_News_Annualized__c=pt.List_Fee__c;
                            //system.debug('****\n\n'+npr.List_Fee_Non_News_Annualized__c+'\n\n****');
                        }
                    }
                }
            }
            system.debug('\n\n nprProds = '+nprProds+'\n\n');
        }
        else if(o.Type=='MSA')
        {
            // Query 11B
            //list<Pricing_MSA_License_Fee__c> MSALicenseFees = MSALicenseFee(MSAProgNPRProds, o);
            /*[select Id, Base_Fee__c, License_Fee_Factor__c, MSA_Cap__c 
            from Pricing_MSA_License_Fee__c
            where Effective_Date__c<=:startDate and Expiration_Date__c>=:endDate and TSR_Low__c<=:o.Total_TSR_MSA__c 
            and TSR_High__c>=:o.Total_TSR_MSA__c and Member_Pricing_Status__c=:o.Account.Membership_Pricing_Status__c];
            */
            
            system.debug('****\n\n'+nprProds+'\n\n****');
            for(NPR_Product__c npr : nprProds)
            {
                system.debug('****\n\n'+MSALicenseFees+'\n\n****');
                for(Pricing_MSA_License_Fee__c msa : MSALicenseFees)
                {
                    system.debug('****\n\n'+msa.Member_Pricing_Status__c+'\n\n****');
                    system.debug('****\n\n'+a.Membership_Pricing_Status__c+'\n\n****');
                    
                    system.debug('****\n\n'+msa.Effective_Date__c+'\n\n****');
                    system.debug('****\n\n'+npr.Bill_Start_Date__c+'\n\n****');
                    
                    system.debug('****\n\n'+msa.Expiration_Date__c+'\n\n****');
                    system.debug('****\n\n'+npr.Bill_Start_Date__c+'\n\n****');
                    
                    system.debug('****\n\n'+msa.TSR_Low__c+'\n\n****');
                    system.debug('****\n\n'+o.Total_TSR_MSA__c+'\n\n****');
                    
                    system.debug('****\n\n'+msa.TSR_High__c+'\n\n****');
                    system.debug('****\n\n'+o.Total_TSR_MSA__c+'\n\n****');
                    
                    system.debug('****\n\n'+msa.Product__c+'\n\n****');
                    system.debug('****\n\n'+npr.Product__c+'\n\n****');
                    
                    if(msa.Member_Pricing_Status__c==a.Membership_Pricing_Status__c &&
                       msa.Effective_Date__c<=npr.Bill_Start_Date__c && msa.Expiration_Date__c>=npr.Bill_Start_Date__c &&
                       msa.TSR_Low__c<=o.Total_TSR_MSA__c && msa.TSR_High__c>=o.Total_TSR_MSA__c &&
                       msa.Product__c==npr.Product__c)
                    {
                        npr.License_Fee_Factor__c = msa.License_Fee_Factor__c;
                        npr.MSA_Cap__c = msa.MSA_Cap__c;
                        npr.Base_Fee_Annualized__c = msa.Base_Fee__c;
                        npr.Previous_FY_Fee_Threshold_Min__c = msa.Previous_FY_Fee_Threshold_Min__c;
                        npr.Previous_FY_Fee_Threshold_Max__c = msa.Previous_FY_Fee_Threshold_Max__c;
                        npr.Anchor__c = msa.Anchor__c;
                        npr.Annual_FY_Increase__c = msa.Annual_FY_Increase__c;
                        npr.Discount_From_Anchor__c = msa.Discount_From_Anchor__c;
                    }
                }
            }
        }
        
        //system.debug('\n\n nprProds = '+nprProds+'\n\n');
        
        return nprProds;
    }
    
    // OLD METHOD
    // take fy pricing detail and dicount
    /*public list<NPR_Product__c> initNPRProds(Opportunity o, list<NPR_Product__c> nprProds)
    {
        system.debug('*************************\n\n IN initNprProds Method \n\n**************************');
        list<NPR_Product__c> PPFProgNPRProds = new list<NPR_Product__c>{};
        list<NPR_Product__c> MSAProgNPRProds = new list<NPR_Product__c>{};
        
        map<string, Discounts__c> discountNewNonNewsMap = new map<String, Discounts__c>{};
        
        list<FY_Pricing_Detail__c> fypd = FYPricingDetailQuery(String.valueOf(o.Fiscal_Year__c), o.AccountId);
        
        list<Discounts__c> discList = NPRDiscountQuery(o);
        for(Discounts__c d : discList)
        {
            discountNewNonNewsMap.put(d.News_Non_News__c, d);
        }
        
        list<Id> Prod2Ids = new list<Id>{};
        for(NPR_Product__c npr : nprProds)
        {
            Prod2Ids.add(npr.Product__c);
        }
        
        // Query for products since we cant get to product fields from NPR prod since it has not been inserted yet
        Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id, PPF_Type__c, MSA_Bundle__c FROM Product2 where Id IN:Prod2Ids]);
        
        for(NPR_Product__c npr : nprProds)
        {
            system.debug('***\n\n'+npr+'\n\n***');
            if(fypd.size()>0)
            {
                // use first fypd we find
                MapFYPricingDetailFields(npr, fypd[0]);
            }
            
            if(discountNewNonNewsMap.get(prodMap.get(npr.Product__c).PPF_Type__c)!=null)
            {
                Discounts__c disc = discountNewNonNewsMap.get(npr.Product__r.PPF_Type__c);
                npr.Discount_Percent__c = disc.Discount_Percent__c;
                o.Account.Minority_Status__c = npr.Discount_Type__c;
            }
            
            // query for the following NPR Products only: NPR_Product__r.Opportunity.Type = PPF AND NPR_Product__r.Product.PPF_Type__c = “Non-News”
            if(o.Type=='PPF' && prodMap.get(npr.Product__c).PPF_Type__c=='Non-News')
            {
                PPFProgNPRProds.add(npr);
            }
            // query for the following NPR Products only: NPR_Product__r.Opportunity.Type = MSA AND NPR_Product__r.Product.MSA_Bundle__c = TRUE
            if(o.Type=='MSA' && prodMap.get(npr.Product__c).MSA_Bundle__c==true)
            {
                MSAProgNPRProds.add(npr);
            }
        }
        
        system.debug('***\n\n'+o.Type+'\n\n***');
        if(o.Type=='PPF')
        {
            // Query 11A
            map<String, list<Pricing_Table__c>> prodIdPTMap = pricingTable(PPFProgNPRProds, o);
            system.debug('***\n\n'+prodIdPTMap+'\n\n***');
            
            for(NPR_Product__c npr : nprProds)
            {
                system.debug('***\n\n'+prodIdPTMap.get(npr.Product__c)+'\n\n***');
                if(prodIdPTMap.get(npr.Product__c)!=null)
                {
                    for(Pricing_Table__c pt : prodIdPTMap.get(npr.Product__c))
                    {
                        if(pt.Effective_Date__c<=npr.Bill_Start_Date__c && pt.Expiration_Date__c>=npr.Bill_End_Date__c)
                        {
                            system.debug('***\n\n'+pt.List_Fee__c+'\n\n***');
                            npr.List_Fee_Annualized__c=pt.List_Fee__c;
                        }
                    }
                }
            }
        }
        else if(o.Type=='MSA')
        {
            // Query 11B
            list<Pricing_MSA_License_Fee__c> MSALicenseFees = MSALicenseFee(MSAProgNPRProds, o);
            
            for(NPR_Product__c npr : nprProds)
            {
                for(Pricing_MSA_License_Fee__c msa : MSALicenseFees)
                {
                    if(msa.Effective_Date__c<=npr.Bill_Start_Date__c && msa.Expiration_Date__c>=npr.Bill_Start_Date__c)
                    {
                        npr.License_Fee_Factor__c = msa.License_Fee_Factor__c;
                        npr.MSA_Cap__c = msa.MSA_Cap__c;
                        npr.Base_Fee__c = msa.Base_Fee__c;
                    }
                }
            }
        }
        
        return nprProds;
    }*/
    
    public NPR_Product__c calcNPRProd(NPR_Product__c nprProd)
    {            
        //system.debug('\n\n********* IN CALC NPR PROD METHOD *************\n\n');
        system.debug('\n\n nprProd: '+nprProd+'\n\n');
        
        if (nprProd.List_Fee_Annualized__c==null) nprProd.List_Fee_Annualized__c = 0;
        
        if(nprProd!=null)
        {
            if(nprProd.License_Fee_Factor__c==null) nprProd.License_Fee_Factor__c = 0;
            // License_Fee__c
            //nprProd.License_Fee__c = nprProd.Total_TSR_MSA__c * nprProd.License_Fee_Factor__c;
            
            // Subtotal_Fee__c
            //system.debug('\n\n List_Fee_Annualized__c: '+nprProd.List_Fee_Annualized__c+'\n\n');
            // IF PPF
            if(nprProd.Product__r.Family=='PPF')
            {
                // List_Price_PPF_Annualized__c
                if(nprProd.Product__r.PPF_Type__c=='News' && nprProd.Accelerated_Cap__c!=NULL && nprProd.Last_FY_Fee_Override__c==NULL && nprProd.ATC_Capped_Final_Fee__c < nprProd.ATC_Last_FY_Price__c)
                {
                    nprProd.List_Price_PPF_Annualized__c = nprProd.ATC_Last_FY_Price__c - (nprProd.ATC_Last_FY_Price__c * (nprProd.Accelerated_Cap__c/100));
                }
                else if(nprProd.Product__r.PPF_Type__c=='News' && nprProd.Accelerated_Cap__c!=NULL && nprProd.Last_FY_Fee_Override__c==NULL && nprProd.ATC_Capped_Final_Fee__c > nprProd.ATC_Last_FY_Price__c)
                {
                    nprProd.List_Price_PPF_Annualized__c = nprProd.ATC_Last_FY_Price__c + (nprProd.ATC_Last_FY_Price__c * (nprProd.Accelerated_Cap__c/100));
                }
                else if(nprProd.Product__r.PPF_Type__c=='News' && nprProd.Accelerated_Cap__c!=NULL && nprProd.Last_FY_Fee_Override__c!=NULL && nprProd.ATC_Capped_Final_Fee__c < nprProd.ATC_Last_FY_Price__c)
                {
                    nprProd.List_Price_PPF_Annualized__c = nprProd.Last_FY_Fee_Override__c - (nprProd.Last_FY_Fee_Override__c * (nprProd.Accelerated_Cap__c/100));
                }
                else if(nprProd.Product__r.PPF_Type__c=='News' && nprProd.Accelerated_Cap__c!=NULL && nprProd.Last_FY_Fee_Override__c!=NULL && nprProd.ATC_Capped_Final_Fee__c > nprProd.ATC_Last_FY_Price__c)
                {
                    nprProd.List_Price_PPF_Annualized__c = nprProd.Last_FY_Fee_Override__c + (nprProd.Last_FY_Fee_Override__c * (nprProd.Accelerated_Cap__c/100));
                }
                else if(nprProd.Product__r.PPF_Type__c=='News')
                {
                    nprProd.List_Price_PPF_Annualized__c = nprProd.ATC_Capped_Final_Fee__c;
                }
                else if(nprProd.Product__r.PPF_Type__c=='Non-News')
                {
                    nprProd.List_Price_PPF_Annualized__c = nprProd.List_Fee_Non_News_Annualized__c;
                }
                
                //system.debug('\n\n List_Price_PPF_Annualized__c: '+nprProd.List_Price_PPF_Annualized__c+'\n\n');
                // List_Fee_Annualized__c
                nprProd.List_Fee_Annualized__c = nprProd.List_Price_PPF_Annualized__c;
            }
            
            // IF MSA
             if(nprProd.Product__r.Family=='MSA' && nprProd.Product__r.MSA_Bundle__c==true)
             {
                 if(nprProd.Base_Fee_Annualized__c==null) nprProd.Base_Fee_Annualized__c=0;
                 if(nprProd.License_Fee_Factor__c==null) nprProd.License_Fee_Factor__c=0;
                 if(nprProd.Opportunity_Name__r.Total_TSR_MSA__c==null) nprProd.Opportunity_Name__r.Total_TSR_MSA__c=0;
                 if(nprProd.MSA_Cap__c==null) nprProd.MSA_Cap__c=0;
                 
                 // License_Fee_Annualized__c
                 if(nprProd.Product__r.MSA_Bundle__c==true && (nprProd.Base_Fee_Annualized__c + (nprProd.License_Fee_Factor__c * nprProd.Opportunity_Name__r.Total_TSR_MSA__c))  < nprProd.MSA_Cap__c)
                 {
                     system.debug('\n\n nprProd.License_Fee_Factor__c = '+nprProd.License_Fee_Factor__c+'\n\n');
                     system.debug('\n\n nprProd.Opportunity_Name__r.Total_TSR_MSA__c = '+nprProd.Opportunity_Name__r.Total_TSR_MSA__c+'\n\n');
                     nprProd.License_Fee_Annualized__c = nprProd.Base_Fee_Annualized__c + (nprProd.License_Fee_Factor__c * nprProd.Opportunity_Name__r.Total_TSR_MSA__c);
                 }
                 else if(nprProd.Product__r.MSA_Bundle__c==true)
                 {
                     nprProd.License_Fee_Annualized__c = nprProd.MSA_Cap__c;
                 }
                 system.debug('\n\n nprProd.License_Fee_Annualized__c = '+nprProd.License_Fee_Annualized__c+'\n\n');

                 // Final_Last_FY_MSA_Anchor_Price__c
                 if(nprProd.Product__r.MSA_Bundle__c==true && nprProd.Last_FY_MSA_Price_Override__c > 0)
                 {
                     nprProd.Final_Last_FY_MSA_Anchor_Price__c = nprProd.Last_FY_MSA_Price_Override__c; 
                 }
                 else if(nprProd.Product__r.MSA_Bundle__c==true)
                 {
                     nprProd.Final_Last_FY_MSA_Anchor_Price__c = nprProd.Opportunity_Name__r.Last_FY_MSA_Anchor_List_Price__c;
                 }

                 // List_Fee_Annualized__c
                 system.debug('\n\n'+nprProd.Opportunity_Name__r.Total_TSR_MSA__c+'\n'+nprProd.Previous_FY_Fee_Threshold_Min__c+'\n\n');
                 system.debug('\n\n'+nprProd.Opportunity_Name__r.Total_TSR_MSA__c+'\n'+nprProd.Previous_FY_Fee_Threshold_Max__c+'\n\n');
                 system.debug('\n\n'+nprProd.Final_Last_FY_MSA_Anchor_Price__c+'\n'+nprProd.Annual_FY_Increase__c+'\n'+nprProd.Final_Last_FY_MSA_Anchor_Price__c+'\n'+nprProd.Discount_From_Anchor__c+'\n\n');
                 if(nprProd.Opportunity_Name__r.Total_TSR_MSA__c>=nprProd.Previous_FY_Fee_Threshold_Min__c && 
                    nprProd.Opportunity_Name__r.Total_TSR_MSA__c<=nprProd.Previous_FY_Fee_Threshold_Max__c &&
                    nprProd.Final_Last_FY_MSA_Anchor_Price__c!=null && nprProd.Annual_FY_Increase__c!=null && 
                    nprProd.Final_Last_FY_MSA_Anchor_Price__c!=null && nprProd.Discount_From_Anchor__c!=null)
                 {
                     system.debug('\n\n IN IF \n\n');
                     //nprProd.List_Fee_Annualized__c = (nprProd.Final_Last_FY_MSA_Anchor_Price__c*nprProd.Annual_FY_Increase__c)-(nprProd.Final_Last_FY_MSA_Anchor_Price__c*nprProd.Discount_From_Anchor__c);
                     //nprProd.List_Fee_Annualized__c = (nprProd.Final_Last_FY_MSA_Anchor_Price__c +(nprProd.Final_Last_FY_MSA_Anchor_Price__c*(nprProd.Annual_FY_Increase__c/100)))-(nprProd.Final_Last_FY_MSA_Anchor_Price__c*(nprProd.Discount_From_Anchor__c/100));
                     nprProd.List_Fee_Annualized__c = (nprProd.Final_Last_FY_MSA_Anchor_Price__c +(nprProd.Final_Last_FY_MSA_Anchor_Price__c*(nprProd.Annual_FY_Increase__c/100)))-((nprProd.Final_Last_FY_MSA_Anchor_Price__c +(nprProd.Final_Last_FY_MSA_Anchor_Price__c*(nprProd.Annual_FY_Increase__c/100)))*(nprProd.Discount_From_Anchor__c/100));
                 }
                 else if(nprProd.Opportunity_Name__r.Total_TSR_MSA__c>=nprProd.Previous_FY_Fee_Threshold_Max__c)
                 {
                     nprProd.List_Fee_Annualized__c = nprProd.License_Fee_Annualized__c - (nprProd.License_Fee_Annualized__c*(nprProd.Discount_From_Anchor__c/100));
                 }
                 else
                 {
                     nprProd.List_Fee_Annualized__c = nprProd.License_Fee_Annualized__c;
                 }
             }
             
             system.debug('\n\n List_Fee_Annualized__c: '+nprProd.List_Fee_Annualized__c+'\n\n');
             //system.debug('\n\n start date: '+nprProd.Bill_Start_Date__c+'\n\n');
             //system.debug('\n\n end date: '+nprProd.Bill_End_Date__c+'\n\n');
             // List_Fee_Prorated__c
             nprProd.List_Fee_Prorated__c = prorate(nprProd.List_Fee_Annualized__c, nprProd.Bill_Start_Date__c, nprProd.Bill_End_Date__c);
             system.debug('\n\n nprProd.List_Fee_Prorated__c: '+nprProd.List_Fee_Prorated__c+'\n\n');
            system.debug('\n\n nprProd.Discount_Percent__c: '+nprProd.Discount_Percent__c+'\n\n');
             // Subtotal_Fee__c
             if(nprProd.Discount_Percent__c!=NULL)
             {
                 nprProd.Subtotal_Fee__c = nprProd.List_Fee_Prorated__c - (nprProd.List_Fee_Prorated__c * (nprProd.Discount_Percent__c/100));
             }
             else
             {
                 nprProd.Subtotal_Fee__c = nprProd.List_Fee_Prorated__c;
             }
             
             system.debug('\n\n Subtotal_Fee__c: '+nprProd.Subtotal_Fee__c+'\n\n');
             system.debug('\n\n Override_Discount__c: '+nprProd.Override_Discount__c+'\n\n');
             system.debug('\n\n nprProd.Override_Fee__c: '+nprProd.Override_Fee__c+'\n\n');
             // Final_Fee__c
             if(nprProd.Override_Discount__c!=NULL)
             {
                 nprProd.Final_Fee__c = nprProd.Subtotal_Fee__c - (nprProd.Subtotal_Fee__c * (nprProd.Override_Discount__c/100));
             }
             else if(nprProd.Override_Fee__c!=NULL)
             {
                 nprProd.Final_Fee__c = nprProd.Override_Fee__c;
             }
             else
             {
                 nprProd.Final_Fee__c = nprProd.Subtotal_Fee__c;
             }
             
             //PPF/MSA : Added by Suhas : These fields are added as part of 1st year discount detailed document. On 15th September 2015.
             if (nprProd.Include_In_PPF_MSA__c == true) 
             {
             	system.debug('****this calc NPR product 1st Year Discount detail design document enhancment****');
                Map<Date, double> monthlyStartDateAmount = new Map<Date, double>(); 
                Double monthlyAmount;
                Integer contractNumberOfDays = nprProd.Bill_Start_Date__c.daysBetween(nprProd.Bill_End_Date__c); 
                if(nprProd.Final_Fee__c == null) nprProd.Final_Fee__c = 0;
                system.debug('contractNumberOfDays==========>>>>>> '+contractNumberOfDays);
                Integer contractNumberOfMonths;
    
                //Here if the start and end bill dates fall in the same month. In that case we consider contractNumberOfMonths = 1 else the number of months calculated.
                if(nprProd.Bill_Start_Date__c.monthsBetween(nprProd.Bill_End_Date__c) == 0) {
                    contractNumberOfMonths = 1;
                } else {
                    contractNumberOfMonths = Integer.valueOf(contractNumberOfDays/30);   //nprProdNew.Bill_Start_Date__c.monthsBetween(nprProdNew.Bill_End_Date__c);
                }
                system.debug('contractNumberOfMonths==========>>>>>> '+contractNumberOfMonths);
                system.debug('nprProdNew.List_Fee_Prorated__c==========>>>>>> '+nprProd.List_Fee_Prorated__c);
                system.debug('nprProdNew.List_Fee_Prorated__c/contractNumberOfMonths==========>>>>>> '+nprProd.List_Fee_Prorated__c/contractNumberOfMonths);
    
                if(nprProd.List_Fee_Prorated__c != null) {
                    monthlyAmount = nprProd.List_Fee_Prorated__c/contractNumberOfMonths;
                }
    
                //Loop through the number of months and fill the map of month start day and monthly amount.
                for(Integer i=0; i<contractNumberOfMonths; i++) {
                    monthlyStartDateAmount.put(nprProd.Bill_Start_Date__c.addMonths(i).toStartOfMonth(), monthlyAmount);
                }
                system.debug('monthlyStartDateAmount.size()=======>>>>>>>>> '+monthlyStartDateAmount.keySet().size() + '  monthlyStartDateAmount=======>>>>>>>>> '+monthlyStartDateAmount);
               
                Boolean updateFinalFee = false;
                
                //Calculate new monthly amounts based on discounts
                for(Date monthlyDate : monthlyStartDateAmount.keySet()) 
                {
                    system.debug('monthlyDate in monthlyStartDateAmount in loop==== >>> '+monthlyDate);
                    if (nprProd.First_Discount_Pct__c != null  && nprProd.First_Discount_Start__c != null && nprProd.First_Discount_End__c != null) 
                    {
                        system.debug('nprProdNew.First_Discount_Pct__c====>>>>'+nprProd.First_Discount_Pct__c);
                        system.debug('nprProdNew.First_Discount_Start__c====>>>>'+nprProd.First_Discount_Start__c);
                        system.debug('nprProdNew.First_Discount_End__c====>>>>'+nprProd.First_Discount_End__c);
                        if (nprProd.First_Discount_Start__c <= monthlyDate && nprProd.First_Discount_End__c >= monthlyDate) 
                        {
                            system.debug('This is first discount Check ====>>');
                            Double monthlyAmountAppliedDiscount =  monthlyStartDateAmount.get(monthlyDate) - (monthlyStartDateAmount.get(monthlyDate) * (nprProd.First_Discount_Pct__c/100));
                            monthlyStartDateAmount.put(monthlyDate, monthlyAmountAppliedDiscount);
                            
                            //finalFee += monthlyStartDateAmount.get(monthlyDate) - (monthlyStartDateAmount.get(monthlyDate) * (nprProd.First_Discount_Pct__c/100));
                            //finalFee += monthlyAmountAppliedDiscount;
                            updateFinalFee = true;
                        }                        
                    } 
                                        
                    if(nprProd.Second_Discount_Pct__c != null  && nprProd.Second_Discount_Start__c != null && nprProd.Second_Discount_End__c != null) 
                    {
                        system.debug('nprProdNew.Second_Discount_Pct__c====>>>>'+nprProd.Second_Discount_Pct__c);
                        system.debug('nprProdNew.Second_Discount_Start__c====>>>>'+nprProd.Second_Discount_Start__c);
                        system.debug('nprProdNew.Second_Discount_End__c====>>>>'+nprProd.Second_Discount_End__c);
                        if (nprProd.Second_Discount_Start__c <= monthlyDate && nprProd.Second_Discount_End__c >= monthlyDate) 
                        {
                            system.debug('This is second discount Check ====>>');
                            Double monthlyAmountAppliedDiscount =  monthlyStartDateAmount.get(monthlyDate) - (monthlyStartDateAmount.get(monthlyDate) * (nprProd.Second_Discount_Pct__c/100));
                            monthlyStartDateAmount.put(monthlyDate, monthlyAmountAppliedDiscount);
                       
                            //finalFee += monthlyStartDateAmount.get(monthlyDate) - (monthlyStartDateAmount.get(monthlyDate) * (nprProd.First_Discount_Pct__c/100));
                            //finalFee += monthlyAmountAppliedDiscount;
                            updateFinalFee = true;
                        }
                    } 
                
                     
                    if(nprProd.Third_Discount_Pct__c != null  && nprProd.Third_Discount_Start__c != null && nprProd.Third_Discount_End__c != null) 
                    {
                        system.debug('nprProdNew.Third_Discount_Pct__c====>>>>'+nprProd.Third_Discount_Pct__c);
                        system.debug('nprProdNew.Third_Discount_Start__c====>>>>'+nprProd.Third_Discount_Start__c);
                        system.debug('nprProdNew.Third_Discount_End__c====>>>>'+nprProd.Third_Discount_End__c);
                    
                        if (nprProd.Third_Discount_Start__c <= monthlyDate && nprProd.Third_Discount_End__c >= monthlyDate) 
                        {
                            system.debug('This is third discount Check ====>>');
                            Double monthlyAmountAppliedDiscount =  monthlyStartDateAmount.get(monthlyDate) - (monthlyStartDateAmount.get(monthlyDate) * (nprProd.Third_Discount_Pct__c/100));
                            monthlyStartDateAmount.put(monthlyDate, monthlyAmountAppliedDiscount);
                            
                            //finalFee += monthlyStartDateAmount.get(monthlyDate) - (monthlyStartDateAmount.get(monthlyDate) * (nprProd.First_Discount_Pct__c/100));
                            //finalFee += monthlyAmountAppliedDiscount;
                            updateFinalFee = true;
                        }
                    } 
                                      
                    system.debug('monthlyStartDateAmount after applying the discount inside loop==== >>> '+monthlyDate);
                    system.debug('monthlyStartDateAmount after applying the discount inside loop==== >>> '+monthlyStartDateAmount.get(monthlyDate));
                }
                 
                system.debug('monthlyStartDateAmount after applying the discount outside loop==== >>> '+monthlyStartDateAmount);
                
                if (updateFinalFee)
                {
                	//Calculate Final Fee
                	Double finalFee = 0;
                	for(Date monthlyDate : monthlyStartDateAmount.keySet()) 
                	{
                		finalFee += monthlyStartDateAmount.get(monthlyDate);                		
                	}
                	
                	system.debug('finalFee ====================>>>>>>>>> '+finalFee);
                	
                	//Populate Final Fee
                	nprProd.Final_Fee__c = finalFee;
                	Double currentFYTotalDiscount = 0;
                	if(nprProd.List_Fee_Prorated__c <> 0) nprProd.Current_FY_Total_Discount__c = ((nprProd.List_Fee_Prorated__c - finalFee) / nprProd.List_Fee_Prorated__c) * 100;
                	system.debug('currentFYTotalDiscount after the calculation is completed===>>> '+currentFYTotalDiscount);
                }
            }
            //PPF/MSA : Ends here : These fields are added as part of 1st year discount detailed document.
        }
        system.debug('\n\n nprProd = '+nprProd+'\n\n');
        return nprProd;
    }

    // Return map of OppId to list of FY Pricing Detail
    public map<String, list<FY_Pricing_Detail__c>> FYPricingDetailQuery(list<Opportunity> oppList)
    {
        map<String, list<FY_Pricing_Detail__c>> returnMap = new map<String, list<FY_Pricing_Detail__c>>{};
        list<String> FiscalYears = new list<String>{};
        list<String> accountIds = new list<String>{};
        map<String, Opportunity> oppMap = new map<String, Opportunity>{};
        
        for(Opportunity o : oppList)
        {
            FiscalYears.add(String.valueOf(o.Fiscal_Year__c));
            accountIds.add(o.AccountId);
            oppMap.put(String.valueOf(o.Fiscal_Year__c)+o.AccountId, o);
        }
        
        system.debug('**\n\n'+fiscalYears+'\n\n**');
        system.debug('**\n\n'+accountIds+'\n\n**');
        list<FY_Pricing_Detail__c> fypds = [select Id, ME_Uncapped_Price__c, ATC_Uncapped_Price__c, ME_Last_FY_Price__c, ATC_Last_FY_Price__c, ATC_Cap_Factor_Used__c, ME_Cap_Factor_Used__c,
             ME_Ceiling_Cap_Factor__c, ME_Floor_Cap_Factor__c /*ME_Cap_Factor__c*/, ATC_Ceiling_Cap_Factor__c, ATC_Floor_Cap_Factor__c /*ATC_Cap_Factor__c*/ , ME_Capped_Price__c,ATC_Capped_Price__c, Fiscal_Year__c, Station__c
             ,ME_Cap_Factor_Used_Discount__c/*Added by Suhas NPR-186*/
             ,ATC_Cap_Factor_Used_Discount__c/*Added by Suhas NPR-186*/
             ,Last_FY_Total_Fees__c /*Added by Suhas on 23/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
             from FY_Pricing_Detail__c where Fiscal_Year__c IN: fiscalYears and Station__c IN: accountIds];  /*Change made by Suhas*/
        
        for(FY_Pricing_Detail__c fypd : fypds)
        {    
            Opportunity o = oppMap.get(fypd.Fiscal_Year__c+fypd.Station__c);
            if(o!=null && o.Id!=null)
            {
                if(returnMap.containsKey(o.Id))
                {
                    list<FY_Pricing_Detail__c> fypdList = returnMap.get(o.Id);
                    fypdList.add(fypd);
                    returnMap.remove(o.Id);
                    returnMap.put(o.Id, fypdList);
                }
                else
                {
                    list<FY_Pricing_Detail__c> fypdList = new list<FY_Pricing_Detail__c>{};
                    fypdList.add(fypd);
                    returnMap.put(o.Id, fypdList);
                }
            }
        }
        
        return returnMap;
    }

    // OLD METHOD
    /*public list<FY_Pricing_Detail__c> FYPricingDetailQuery(String fiscalYear, String accountId)
    {
        return [select Id, ME_Uncapped_Price__c, ATC_Uncapped_Price__c, ME_Last_FY_Price__c, ATC_Last_FY_Price__c,
             ME_Cap_Factor__c, ATC_Cap_Factor__c , ME_Capped_Price__c,ATC_Capped_Price__c 
             from FY_Pricing_Detail__c where Fiscal_Year__c=:fiscalYear and Station__c=:accountId]; 
    }*/
    
    // Only run if type is PPF
    /*public decimal AccountTSRQueryPPF(String AccountId)
    {
        return [select TSR_In_Hierarchy__c from Account where Id=:AccountId].TSR_In_Hierarchy__c;
    }*/
    
    
    public map<String, list<Discounts__c>> NPRDiscountQuery(list<Opportunity> oppList, list<Account> Accounts)
        {
            system.debug('**\n\n'+Accounts+'\n\n**');
            map<String, list<Discounts__c>> returnMap = new map<String, list<Discounts__c>>{};
            Date dateLow;
            Date dateHigh;
            
            Boolean firstTime = true;
            for(Opportunity o : oppList)
            {
                if(firstTime)
                {
                    firstTime = false;
                    dateLow = o.CloseDate;
                    dateHigh = o.CloseDate;
                }
                if(o.CloseDate<dateLow)
                {
                    dateLow = o.closeDate;
                }
                if(o.closeDate>dateHigh)
                {
                    dateHigh = o.closeDate;
                }
            }
            
            list<String> msList = new list<String>{};
            map<String, Account> accountMap = new map<String, Account>{};
            for(Account a : accounts)
            {
                msList.add(a.Minority_Status__c);
                accountMap.put(a.Id, a);
            }
            
            system.debug('**\n\n'+dateLow+'\n\n**');
            system.debug('**\n\n'+dateHigh+'\n\n**');
            system.debug('**\n\n'+msList+'\n\n**');
            list<Discounts__c> Discounts = [select Discount_Percent__c, News_Non_News__c, Effective_Date__c, Expiration_Date__c, Discount_Type__c 
                from Discounts__c where 
                Effective_Date__c<=:dateLow and Expiration_Date__c>=:dateHigh and Discount_Type__c IN: msList];
            
            for(Discounts__c d : Discounts)
            {    
                for(Opportunity o : oppList)
                {
                    if(d.Effective_Date__c<=o.closeDate && d.Expiration_Date__c>=o.closeDate)
                    {
                        if(accountMap.get(o.AccountId).Minority_Status__c==d.Discount_Type__c)
                        {
                            if(returnMap.containsKey(o.Id))
                            {
                                list<Discounts__c> dList = returnMap.get(o.Id);
                                dList.add(d);
                                returnMap.remove(o.Id);
                                returnMap.put(o.Id, dList);
                            }
                            else
                            {
                                list<Discounts__c> dList = new list<Discounts__c>{};
                                dList.add(d);
                                returnMap.put(o.Id, dList);
                            }
                        }
                    }
                }
            }
            
            return returnMap;
    }
    
    // OLD METHOD
    /*public list<Discounts__c> NPRDiscountQuery(Opportunity o)
    {
        return [select Discount_Percent__c, News_Non_News__c from Discounts__c where 
            Effective_Date__c<=:o.closeDate and Expiration_Date__c>=:o.closeDate and Discount_Type__c=:o.Account.Minority_Status__c];
    }*/
    
    // Can I just take a list of all NPR prods and a list of all accounts for all opps?
    public list<Pricing_Table__c> pricingTable(list<Opportunity> opps, list<NPR_Product__c> nprProds, list<Account> accounts)
    {
        system.debug('**\n\n'+opps+'\n\n**');
        system.debug('**\n\n'+nprProds+'\n\n**');
        system.debug('**\n\n'+accounts+'\n\n**');
        
        // Get products, startDate and endDate for Pricing table query
        Set<String> prodIds = new Set<String>{};
        Date startDate;
        Date endDate;
        Boolean firstTime=true;
        for(NPR_Product__c npr : nprProds)
        {
            if(firstTime)
            {
                firstTime = false;
                startDate = npr.Bill_Start_Date__c;
                endDate = npr.Bill_End_Date__c;
            }
            if(npr.Bill_Start_Date__c<startDate)
            {
                startDate = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_End_Date__c>endDate)
            {
                endDate = npr.Bill_End_Date__c;
            }

            // Get list of prodcut ids
            prodIds.add(npr.Product__c);
        }
        
        // Get tsr high and tsr low from opportunity
        Decimal tsrHigh;
        Decimal tsrLow;
        firstTime=true;
        for(Opportunity o : opps)
        {
            if(firstTime)
            {
                firstTime = false;
                tsrLow = o.TSR_In_Hierarchy_PPF__c;
                tsrHigh = o.TSR_In_Hierarchy_PPF__c;
            }
            if(o.TSR_In_Hierarchy_PPF__c<tsrLow)
            {
                tsrLow = o.TSR_In_Hierarchy_PPF__c;
            }
            if(o.TSR_In_Hierarchy_PPF__c>tsrHigh)
            {
                tsrHigh = o.TSR_In_Hierarchy_PPF__c;
            }
        }
        
        // Get list of Membership_Pricing_Status__c from accounts
        list<String> mpsList = new list<String>{};
        for(Account a : accounts)
        {
            mpsList.add(a.Membership_Pricing_Status__c);
        }
        
        system.debug('**\n\n'+prodIds+'\n\n**');
        system.debug('**\n\n'+startDate+'\n\n**');
        system.debug('**\n\n'+endDate+'\n\n**');
        system.debug('**\n\n'+tsrLow+'\n\n**');
        system.debug('**\n\n'+tsrHigh+'\n\n**');
        system.debug('**\n\n'+mpsList+'\n\n**');
        list<Pricing_Table__c> pts = [select Id, List_Fee__c, Product__c, Membership_Pricing_Status__c, TSR_High__c, TSR_Low__c, 
            Expiration_Date__c, Effective_Date__c
            from Pricing_Table__c 
            where Product__c IN:prodIds and Effective_Date__c<=:startDate and Expiration_Date__c>=:endDate and 
            TSR_Low__c<=:tsrLow and TSR_High__c>=:tsrHigh
            order by Product__c];
            //and Membership_Pricing_Status__c IN:mpsList
            
        return pts;
    }
    
    // OLD METHOD
    /*public map<String, list<Pricing_Table__c>> pricingTable(list<NPR_Product__c> nprProds, Opportunity o)
    {    
        // Get products, startDate and endDate for Pricing table query
        Set<String> prodIds = new Set<String>{};
        Date startDate;
        Date endDate;
        Boolean firstTime=true;
        
        for(NPR_Product__c npr : nprProds)
        {
            if(firstTime)
            {
                startDate = npr.Bill_Start_Date__c;
                endDate = npr.Bill_End_Date__c;
            }
            if(npr.Bill_Start_Date__c<startDate)
            {
                startDate = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_End_Date__c>endDate)
            {
                endDate = npr.Bill_End_Date__c;
            }
            prodIds.add(npr.Product__c);
        }
        
        Account a = [select Membership_Pricing_Status__c from Account where Id=:o.AccountId];

        list<Pricing_Table__c> pts = [select Id, List_Fee__c from Pricing_Table__c 
            where Product__c IN:prodIds and Effective_Date__c<=:startDate and Expiration_Date__c>=:endDate and 
            TSR_Low__c<=:o.TSR_In_Hierarchy_PPF__c and TSR_High__c>=:o.TSR_In_Hierarchy_PPF__c 
            and Membership_Pricing_Status__c=:a.Membership_Pricing_Status__c
            order by Product__c];
        
        firstTime=true;
        list<Pricing_Table__c> ptList = new list<Pricing_Table__c>{};
        map<String, list<Pricing_Table__c>> prodIdPTMap = new map<String, list<Pricing_Table__c>>{};
        String lastProdId;
        for(Pricing_Table__c pt : pts)
        {
            if(firstTime)
            {
                lastProdId = pt.Product__c;
                firstTime=false;
            }
            if(lastProdId != pt.Product__c)
            {
                prodIdPTMap.put(lastProdId, ptList);
                ptList.clear();
            }
            ptlist.add(pt);
        }
        prodIdPTMap.put(lastProdId, ptList);
        
        return prodIdPTMap;
    }*/
    
    
    public list<Pricing_MSA_License_Fee__c> MSALicenseFee(list<Opportunity> opps, list<NPR_Product__c> nprProds, list<Account> accounts)
    {
        system.debug('**\n\n'+opps+'\n\n**');
        system.debug('**\n\n'+nprProds+'\n\n**');
        system.debug('**\n\n'+accounts+'\n\n**');
        
        list<String> productIds = new list<String>{};
        
        Date startDate;
        Date endDate;
        Boolean firstTime=true;
        for(NPR_Product__c npr : nprProds)
        {
            if(firstTime)
            {
                startDate = npr.Bill_Start_Date__c;
                endDate = npr.Bill_End_Date__c;
            }
            if(npr.Bill_Start_Date__c<startDate)
            {
                startDate = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_End_Date__c>endDate)
            {
                endDate = npr.Bill_End_Date__c;
            }
            productIds.add(npr.Product__c);
        }
        
        // Get tsr high and tsr low from opportunity
        Decimal tsrHigh;
        Decimal tsrLow;
        firstTime=true;
        for(Opportunity o : opps)
        {
            if(firstTime)
            {
                firstTime = false;
                tsrLow = o.Total_TSR_MSA__c;
                tsrHigh = o.Total_TSR_MSA__c;
            }
            if(o.TSR_In_Hierarchy_PPF__c<tsrLow)
            {
                tsrLow = o.Total_TSR_MSA__c;
            }
            if(o.TSR_In_Hierarchy_PPF__c>tsrHigh)
            {
                tsrHigh = o.Total_TSR_MSA__c;
            }
        }
        
        list<String> mpsList = new list<String>{};
        for(Account a : accounts)
        {
            mpsList.add(a.Membership_Pricing_Status__c);
        }
        
        
        system.debug('***\n\n startDate = '+startDate+'\n\n***');
        system.debug('***\n\n endDate = '+endDate+'\n\n***');
        system.debug('***\n\n tsrLow = '+tsrLow+'\n\n***');
        system.debug('***\n\n tsrHigh = '+tsrHigh+'\n\n***');
        system.debug('***\n\n mpsList = '+mpsList+'\n\n***');
        system.debug('***\n\n productIds = '+productIds+'\n\n***');
        list<Pricing_MSA_License_Fee__c> MSALicenseFees = [select Id, Base_Fee__c, License_Fee_Factor__c, MSA_Cap__c,
            Previous_FY_Fee_Threshold_Min__c, Previous_FY_Fee_Threshold_Max__c, Anchor__c, Annual_FY_Increase__c, Discount_From_Anchor__c,
            Member_Pricing_Status__c, Effective_Date__c, Expiration_Date__c, TSR_Low__c, TSR_High__c, Product__c
            from Pricing_MSA_License_Fee__c
            where Effective_Date__c<=:startDate and Expiration_Date__c>=:endDate 
            and TSR_Low__c<=:tsrLow and TSR_High__c>=:tsrHigh 
            and Product__c IN:productIds
            and Member_Pricing_Status__c IN:mpsList];
        system.debug('***\n\n MSALicenseFees = '+MSALicenseFees+'\n\n***');
        return MSALicenseFees;
    }
    
    // OLD METHOD
    /*public list<Pricing_MSA_License_Fee__c> MSALicenseFee(list<NPR_Product__c> nprProds, Opportunity o)
    {
        Date startDate;
        Date endDate;
        Boolean firstTime=true;
        for(NPR_Product__c npr : nprProds)
        {
            if(firstTime)
            {
                startDate = npr.Bill_Start_Date__c;
                endDate = npr.Bill_End_Date__c;
            }
            if(npr.Bill_Start_Date__c<startDate)
            {
                startDate = npr.Bill_Start_Date__c;
            }
            if(npr.Bill_End_Date__c>endDate)
            {
                endDate = npr.Bill_End_Date__c;
            }
        }
        
        list<Pricing_MSA_License_Fee__c> MSALicenseFees = [select Id, Base_Fee__c, License_Fee_Factor__c, MSA_Cap__c 
            from Pricing_MSA_License_Fee__c
            where Effective_Date__c<=:startDate and Expiration_Date__c>=:endDate and TSR_Low__c<=:o.Total_TSR_MSA__c 
            and TSR_High__c>=:o.Total_TSR_MSA__c and Member_Pricing_Status__c=:o.Account.Membership_Pricing_Status__c];
        
            
        return MSALicenseFees;
    }*/

    //*******************************************************************************
    //INIT OPP - Retrieve pricing values to populate on Opportunity    
    public List<Account> AccountTSRQueryPPF(Set<Id> accIds)
    {
        // TSR_in_Hierarchy__c
        return [select Id, Licensee__c, Minority_Status__c, TSR_in_Hierarchy__c from Account Where Id in: accIds];
    }
    /*Added by Suhas on 23/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
    public Map<Id, FY_Pricing_Detail__c> previousYearFyPricingQuery(Set<Id> accountId, List<String> lastFiscalYears) {
        Map<Id, FY_Pricing_Detail__c> accountLastFiscalYearFYPricing = new Map<Id, FY_Pricing_Detail__c>(); 
        List<FY_Pricing_Detail__c> fypds = [select Id, ME_Uncapped_Price__c, ATC_Uncapped_Price__c, ME_Last_FY_Price__c, ATC_Last_FY_Price__c, ATC_Cap_Factor_Used__c, ME_Cap_Factor_Used__c,
             ME_Ceiling_Cap_Factor__c, ME_Floor_Cap_Factor__c, ATC_Ceiling_Cap_Factor__c, ATC_Floor_Cap_Factor__c  , ME_Capped_Price__c,ATC_Capped_Price__c, Fiscal_Year__c, Station__c
             ,ME_Cap_Factor_Used_Discount__c
             ,ATC_Cap_Factor_Used_Discount__c
             ,Last_FY_Total_Fees__c
             from FY_Pricing_Detail__c where Fiscal_Year__c IN: lastFiscalYears and Station__c IN: accountId LIMIT 1];
        for(FY_Pricing_Detail__c fypd : fypds) {
            accountLastFiscalYearFYPricing.put(fypd.Station__c, fypd);
        }
        return accountLastFiscalYearFYPricing;
    }
     /*Added code ends here*/
    public List<Opportunity> populatePricingValuesOnPPFOpps(Map<Id, Opportunity> accOppMapPPF)
    {
        List<Opportunity> oppList = new List<Opportunity>();
        /*Added By Suhas on 23/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
        Set <Id> accountIdSet = new Set <Id>();
        list<String> lastFiscalYears = new list<String>{};
        for(Id id : accOppMapPPF.keySet()) {
            accountIdSet.add(id);
            lastFiscalYears.add(String.valueOf(accOppMapPPF.get(id).Fiscal_Year__c - 1));
        } 
        system.debug('accountIdSet123===>>>> '+accountIdSet);
        system.debug('lastFiscalYears321===>>>> '+lastFiscalYears);
        Map<Id, FY_Pricing_Detail__c> accountLastFiscalYearFYPricingMap = previousYearFyPricingQuery(accountIdSet, lastFiscalYears);
        system.debug('accountLastFiscalYearFYPricingMap=========>>>>>>>> '+accountLastFiscalYearFYPricingMap);
        /*Added code ends here*/
        system.debug('accOppMapPPF===>>>>asdfda  '+accOppMapPPF);
        //extract TSR pricing determinants from the Opportunity’s Account record    
        for (Account a: AccountTSRQueryPPF(accOppMapPPF.keySet()))
        {
            if (accOppMapPPF.containsKey(a.Id))
            {
                Opportunity opp = accOppMapPPF.get(a.Id);
                opp.TSR_In_Hierarchy_PPF__c = a.TSR_in_Hierarchy__c;
                opp.Licensee__c = a.Licensee__c;
                opp.Discount_Type__c = a.Minority_Status__c;
                system.debug('accountLastFiscalYearFYPricingMap.get(a.id).Last_FY_Total_Fees__c===>>>> '+accountLastFiscalYearFYPricingMap.get(a.id));
                //Added By Suhas on 23/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc
                if(accountLastFiscalYearFYPricingMap.containsKey(a.Id) 
                    //&& accountLastFiscalYearFYPricingMap.get(a.id).Last_FY_Total_Fees__c != null 
                    && accountLastFiscalYearFYPricingMap.get(a.Id).ATC_Capped_Price__c != null 
                    && accountLastFiscalYearFYPricingMap.get(a.Id).ME_Capped_Price__c != null){
                    opp.Last_FY_Total_News_Mag_Price__c = accountLastFiscalYearFYPricingMap.get(a.Id).ATC_Capped_Price__c + accountLastFiscalYearFYPricingMap.get(a.Id).ME_Capped_Price__c;//accountLastFiscalYearFYPricingMap.get(a.id).Last_FY_Total_Fees__c;
                }
                //Added code ends here
                oppList.add(opp);
            }            
        }
        
        return oppList;
    }
    
    public List<Opportunity> populatePricingValuesOnMSAOpps(Map<Id, Opportunity> accOppMapMSA, Map<String, List<Account>> oppStMap)
    {
        List<Opportunity> oppList = new List<Opportunity>();
        
        for (Opportunity o : accOppMapMSA.values())
        {
            o.Total_TSR_MSA__c = 0;
            system.debug('\n\n\n'+o+'\n\n\n');
            system.debug('\n\n\n'+o.Total_TSR_MSA__c+'\n\n\n');
            //if (o.Total_TSR_MSA__c==null) o.Total_TSR_MSA__c=0;
            
            if (oppStMap.containsKey(o.Id))
            {
                //extract TSR pricing determinants from all station accounts
                for (Account a : oppStMap.get(o.Id))
                {
                    o.Licensee__c = a.Licensee__c;
                    system.debug('\n\n\n a.Id = '+a.Id+'\n\n\n');
                    system.debug('\n\n\n a.TSR__c = '+a.TSR__c+'\n\n\n');
                    if (a.TSR__c!=null)
                    {
                        //Calculate the sum of TSR__c values
                        o.Total_TSR_MSA__c += a.TSR__c;
                    }
                }
            }
            oppList.add(o);
        }
        system.debug('\n\n\noppList: '+oppList+'\n\n\n');
        return oppList;
    }
    
    public List<Opportunity> populatePricingValuesOnMSAOpps(Map<Opportunity, List<Account>> oppStMapMSA)
    {
        List<Opportunity> oppList = new List<Opportunity>();
        
        for (Opportunity o : oppStMapMSA.keySet())
        {
            o.Total_TSR_MSA__c=0;
            //if (o.Total_TSR_MSA__c==null) o.Total_TSR_MSA__c=0;
    
            if (oppStMapMSA.get(o)!=null)
            {
                //extract TSR pricing determinants from all station accounts
                for (Account a : oppStMapMSA.get(o))
                {
                    if (a.TSR__c!=null)
                    {
                        //Calculate the sum of TSR__c values
                        o.Total_TSR_MSA__c += a.TSR__c;
                    }
                }
            }
            oppList.add(o);
        }
                    
        return oppList;
    }
    
    public List<Pricing_Tier__c> getPricingTier()
    {
        // need where clause
        return [select Effective_Date__c, Expiration_Date__c, TSR_Low__c, TSR_High__c, Type__c, Tier__c from Pricing_Tier__c];
    }
        
    public List<Opportunity> determinePricingTeer(List<Opportunity> oppList, String oppType)
    {
        List<Pricing_Tier__c> pricingTr = getPricingTier();
        
        if (oppType == 'PPF')
        {
            for (Opportunity o : oppList)
            {
                for (Pricing_Tier__c ptr : pricingTr)
                {
                    if (ptr.Effective_Date__c <= o.CloseDate && 
                        ptr.Expiration_Date__c >= o.CloseDate && ptr.TSR_Low__c <= o.TSR_In_Hierarchy_PPF__c &&
                        ptr.TSR_High__c >= o.TSR_In_Hierarchy_PPF__c && ptr.Type__c == o.Type)
                    {                
                        system.debug('\n\n'+ptr.Tier__c+'\n\n');
                        system.debug('\n\n'+ptr.Id+'\n\n');
                        o.Pricing_Tier__c = ptr.Tier__c;
                    }
                }                
            }
        }
        else if (oppType == 'MSA')
        {
            for (Opportunity o : oppList)
            {
                for (Pricing_Tier__c ptr : getPricingTier())
                {
                    if (ptr.Effective_Date__c <= o.CloseDate && 
                        ptr.Expiration_Date__c >= o.CloseDate && ptr.TSR_Low__c <= o.Total_TSR_MSA__c &&
                        ptr.TSR_High__c >= o.Total_TSR_MSA__c && ptr.Type__c == o.Type)
                    {                
                        o.Pricing_Tier__c = ptr.Tier__c;
                    }
                }                
            }
        }
        
        return oppList;
    }
    
    
    public List<Admin_Fee__c> getAdminFee()
    {
        // need where clause
        return [select Fee__c, Effective_Date__c , Expiration_Date__c, TSR_Low__c, TSR_High__c FROM Admin_Fee__c];        
    }
    
    public String[] getNonMemberAccounts(Set<Id> accIds)
    {
        list<String> lstAccountIds =  new list<String>{};
        for(Account a : [Select Id, Membership_Pricing_Status__c FROM Account Where Id in: accIds AND  NPR_Station_Status__c = 'Non-Member'])
        {
            lstAccountIds.add(a.Id);
        }
        return lstAccountIds;
    }
    
    public List<Opportunity> determineAdminFee(List<Opportunity> oppList, Set<Id> accIds)
    {
        Set<String> nonMemberAccounts = new Set<String>(getNonMemberAccounts(accIds));
        
        for (Opportunity o : oppList)
        {
            if (nonMemberAccounts.contains(o.AccountId))
            {
                for (Admin_Fee__c af : getAdminFee())
                {
                    if (af.Effective_Date__c <= o.CloseDate && 
                        af.Expiration_Date__c >= o.CloseDate && af.TSR_Low__c <= o.TSR_In_Hierarchy_PPF__c &&
                        af.TSR_High__c >= o.TSR_In_Hierarchy_PPF__c)
                    {                
                        o.Admin_Fee__c = af.Fee__c;
                    }
                }
            }                
        }        
        
        return oppList;
    }
    
    public List<Opportunity> determineLastFYMSAAnchorListPrice(Map<Id, Opportunity> accountOppMapMSA)
    {        
        //capture the value of the List Price value from the ‘anchor MSA’ product record 
        //on the previous year’s MSA opportunity
        List<NPR_Product__c> nprProducts = [SELECT License_Fee_Annualized__c, Opportunity_Name__c, Opportunity_Name__r.Fiscal_Year__c, Opportunity_Account_ID__c, Product__c, Product__r.MSA_Bundle__c, Product__r.Anchor__c 
            FROM NPR_Product__c WHERE Opportunity_Name__r.AccountId IN: accountOppMapMSA.keySet() AND 
            Product__r.MSA_Bundle__c = true AND 
            Product__r.Anchor__c = true];
            //Opportunity_Account_ID__c

        //Populate List_Fee__c into new opportunity’s Opportunity.Last_FY_MSA_Anchor_List_Price__c
        for (NPR_Product__c nprProd : nprProducts)
        {
            system.debug('**\n\n'+accountOppMapMSA.get(nprProd.Opportunity_Account_ID__c)+'\n\n**');
            system.debug('**\n\n'+accountOppMapMSA.get(nprProd.Opportunity_Account_ID__c).Fiscal_Year__c+'\n\n**');
            system.debug('**\n\n'+nprProd.Opportunity_Name__r.Fiscal_Year__c+'\n\n**');
            //decimal d = accountOppMapMSA.get(nprProd.Opportunity_Account_ID__c).Fiscal_Year__c - 1;
            //system.debug('**\n\n'+d+'\n\n**');
            if (accountOppMapMSA.get(nprProd.Opportunity_Account_ID__c)!=null && 
                accountOppMapMSA.get(nprProd.Opportunity_Account_ID__c).Fiscal_Year__c!=null && 
                nprProd.Opportunity_Name__r.Fiscal_Year__c == accountOppMapMSA.get(nprProd.Opportunity_Account_ID__c).Fiscal_Year__c - 1)
            {
                accountOppMapMSA.get(nprProd.Opportunity_Account_ID__c).Last_FY_MSA_Anchor_List_Price__c = nprProd.License_Fee_Annualized__c; 
            }            
        }

        return accountOppMapMSA.values();        
    }

    public Opportunity calcOpportunity(Opportunity newOpp, List<NPR_Product__c> nprProducts)
    {
        System.debug('\n\n\n In calcOpportunity \n\n\n');
        System.debug('\n\n\n newOpp is: ' + newOpp + '\n\n\n');
        System.debug('\n\n\n nprProducts are: ' + nprProducts + '\n\n\n');

        if (newOpp!=null && nprProducts!=null)
        {
            newOpp.Sub_Total_Price__c = 0;
            newOpp.News_Mag_Uncapped_Price__c = 0;
            newOpp.News_Mag_Capped_Final_Price__c =0;
            newOpp.Total_Non_News_List_Price__c =0;
            newOpp.Total_Non_News_Final_Price__c =0;
        
            for (NPR_Product__c nprProd : nprProducts)
            {
                if (nprProd.List_Fee_Annualized__c==null) nprProd.List_Fee_Annualized__c = 0;
                System.debug('\n\n\n nprProd.Include_in_PPF_MSA__c is: ' + nprProd.Include_in_PPF_MSA__c + '\n\n\n');
                /*Added By Suhas on 23/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
                if(nprProd.Product_PPF_Type__c != null && nprProd.Product_PPF_Type__c=='News') {
                    if(nprProd.ATC_Uncapped_Price__c != null) {
                        newOpp.News_Mag_Uncapped_Price__c += nprProd.ATC_Uncapped_Price__c;
                    }
                    if(nprProd.Final_Fee__c != null) {
                        newOpp.News_Mag_Capped_Final_Price__c += nprProd.Final_Fee__c;
                    }
                }
                /*Added code ends here*/
                if (nprProd.Include_in_PPF_MSA__c == true)
                {
                    System.debug('\n\n\n calculating opp... \n\n\n');
                    System.debug('\n\n\n'+newOpp.Sub_Total_Price__c+'\n\n\n');
                    System.debug('\n\n\n'+nprProd.Final_Fee__c+'\n\n\n');
                    if(nprProd.Final_Fee__c==null) nprProd.Final_Fee__c = 0;
                    newOpp.Sub_Total_Price__c += nprProd.Final_Fee__c;
                    /*Added By Suhas on 23/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
                    if(nprProd.Product_PPF_Type__c != null && nprProd.Product_PPF_Type__c =='Non-News') {
                        if(nprProd.List_Fee_Annualized__c == null) nprProd.List_Fee_Annualized__c =0;
                        newOpp.Total_Non_News_List_Price__c += nprProd.List_Fee_Annualized__c;
                        newOpp.Total_Non_News_Final_Price__c += nprProd.Final_Fee__c;
                    }
                    /*Added code ends here*/
                    /*if (newOpp.Total_Override__c != NULL)
                        newOpp.Sub_Total_Price_2__c = newOpp.Total_Override__c;
                    else if (newOpp.Discount__c != NULL)
                        newOpp.Sub_Total_Price_2__c = newOpp.Sub_Total_Price__c - (newOpp.Sub_Total_Price__c * (newOpp.Discount__c/100));
                    else newOpp.Sub_Total_Price_2__c = newOpp.Sub_Total_Price__c;
                        
                    if (newOpp.Admin_Fee_Override__c != NULL)
                        newOpp.Total_Contract_Price__c = newOpp.Sub_Total_Price_2__c + newOpp.Admin_Fee_Override__c;
                    else newOpp.Total_Contract_Price__c = newOpp.Sub_Total_Price_2__c;
                    */
                }
            }
        }
        
        if(newOpp.Total_Override__c!=null)
        {
            newOpp.Sub_Total_Price_2__c = newOpp.Total_Override__c;
        }
        else if(newOpp.Discount__c!=null)
        {
            newOpp.Sub_Total_Price_2__c = newOpp.Sub_Total_Price__c - (newOpp.Sub_Total_Price__c * newOpp.Discount__c);
        }
        else
        {
            newOpp.Sub_Total_Price_2__c = newOpp.Sub_Total_Price__c;
        }

        if(newOpp.Admin_Fee_Override__c!=null)
        {
            newOpp.Total_Contract_Price__c = newOpp.Sub_Total_Price_2__c + newOpp.Admin_Fee_Override__c;
        }
        else if(newOpp.Admin_Fee__c!=null)
        {
            newOpp.Total_Contract_Price__c = newOpp.Sub_Total_Price_2__c + newOpp.Admin_Fee__c;
        }
        else
        {
            newOpp.Total_Contract_Price__c = newOpp.Sub_Total_Price_2__c;
        }
    
        system.debug('This is newOpp.Total_Contract_Price__c===>>>> ' +newOpp.Total_Contract_Price__c);
        system.debug('This is newOpp.News_Mag_Capped_Final_Price__c===>>>> ' +newOpp.News_Mag_Capped_Final_Price__c);
        system.debug('This is newOpp.Prior_Year_PPF_Contract_Price__c===>>>> ' +newOpp.Prior_Year_PPF_Contract_Price__c);
        system.debug('This is newOpp.Last_FY_Total_News_Mag_Price__c===>>>> ' +newOpp.Last_FY_Total_News_Mag_Price__c);
        /*Added By Suhas on 23/7/2015 according to Opportunity New, Repositioned and Relabeled Fields Detailed Design Doc*/
        if(newOpp.Total_Contract_Price__c != null && newOpp.Prior_Year_PPF_Contract_Price__c != null && newOpp.Prior_Year_PPF_Contract_Price__c !=0) {
            newOpp.Year_Over_Year_Change__c = ((newOpp.Total_Contract_Price__c - newOpp.Prior_Year_PPF_Contract_Price__c) / newOpp.Prior_Year_PPF_Contract_Price__c) * 100;
            system.debug('This is Year_Over_Year_Change__c===>>>> ' +newOpp.Year_Over_Year_Change__c);
        } else {
            newOpp.Year_Over_Year_Change__c =0;
        }
        if(newOpp.News_Mag_Capped_Final_Price__c != null && newOpp.Last_FY_Total_News_Mag_Price__c != null && newOpp.Last_FY_Total_News_Mag_Price__c != 0) {
            newOpp.Year_over_Year_News_Mag_Change__c = ((newOpp.News_Mag_Capped_Final_Price__c - newOpp.Last_FY_Total_News_Mag_Price__c)/ newOpp.Last_FY_Total_News_Mag_Price__c) * 100;
            system.debug('This is newOpp.Year_over_Year_News_Mag_Change__c===>>>> ' +newOpp.Year_over_Year_News_Mag_Change__c);
        } else {
            newOpp.Year_over_Year_News_Mag_Change__c=0;
        }
        
              
        /*Added Code ends here*/
        System.debug('\n\n\n After calcOpportunity, newOpp is: ' + newOpp + '\n\n\n');
            
        return newOpp;    
    }
    
}