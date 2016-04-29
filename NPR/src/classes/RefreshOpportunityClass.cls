public class RefreshOpportunityClass 
{
	public Map<Id, Opportunity> accountOppMapPPF {set; get;}
	public Map<Id, Opportunity> accountOppMapMSA {set; get;}
	public Map<Id, Account> oppAccountMap {set; get;}
	public Map<Id, Account> oppAccountMapMSA {set; get;}
	public List<NPR_Product__c> allNprProducts {set; get;}
	public List<Opportunity> oppsToUpdate {set; get;}
	public List<Product2> productListMSA {set; get;}
	public Map<Id,Id> pbeToProd = new Map<Id,Id>();
		
	public Map<String, list<FY_Pricing_Detail__c>> oppFYMap {set; get;}
	public Map<String, list<Discounts__c>> oppDiscountMap {set; get;}
	public List <Pricing_Table__c> pricingTables {set; get;}
	public List<Pricing_MSA_License_Fee__c> pricingMsaLicenseFees {set; get;}
	public List<MSA_Incremental__c> MSAIncStreamingList {set; get;}
	public List<MSA_Incremental__c> MSAIncEmailList {set; get;}
		
	public List<Opportunity> oppsToUpdatePPF {set; get;}
	public List<Opportunity> oppsToUpdateMSA {set; get;}
	public List<Product2> combinedProductList {set; get;}
	
	public  Map<String, List<Account>> oppStationsMap {set; get;}
	public  Map<Opportunity, List<NPR_Product__c>> oppNprProdMap {set; get;}
	
	public  Map<String, NPR_Product__c> productToNprProdMap {set; get;}
	public  Map<String, OpportunityLineItem> productToOppProdMap {set; get;}
	public  PricingUtility pu {set; get;}
				
	public  List<Account> stations1PPF {set; get;}
	public  List<Account> stations1MSA {set; get;}
	public  List<Account> stations1 {set; get;}
	public  List<Account> stations2 {set; get;}
	public  List<Account> stations3 {set; get;}
	public  List<Account> stationsFinal {set; get;}
	
	public List<NPR_Product__c> oldNprProductsList {set; get;}
	public List<OpportunityLineItem> oldOppProductsList {set; get;}
	
	public List<NPR_Product__c> currentNPRProducts {set; get;}
	public List<OpportunityLineItem> currentOppProducts {set; get;}
	public List<Product2> currentProductList {set; get;}
			
	public RefreshOpportunityClass()
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
		oppsToUpdate = new List<Opportunity>();
		combinedProductList = new List<Product2>();
	
		oppStationsMap = new Map<String, List<Account>>();
		oppNprProdMap = new Map<Opportunity, List<NPR_Product__c>>();
	
		productToNprProdMap = new Map<String, NPR_Product__c>();
		productToOppProdMap = new Map<String, OpportunityLineItem>();
		pu = new PricingUtility();
		oppAccountMapMSA = new Map<Id, Account>();
		
		pbeToProd = new Map<Id,Id>(); 
						
		stations1PPF = new List<Account>();
		stations1MSA = new List<Account>();
		stations1 = new List<Account>();
		stations2 = new List<Account>();
		stations3 = new List<Account>();
		stationsFinal = new List<Account>();
	}
		
	//Will completely refresh the Opportunity, including the determination of child stations, 
	//PPF programs to include, and list pricing.  All existing overrides and discounts will be wiped out.
	public  void refreshOpportunityNoOverrides(Opportunity opp)
	{
		system.debug('\n\n\n********* IN refreshOpportunityNoOverrides **********\n\n\n');
		
		populateAccountOppMaps(new List<Opportunity>{opp});
		
		populateStationsList();
		
		if (accountOppMapMSA.size()>0)
		{
			oppsToUpdateMSA = pu.populatePricingValuesOnMSAOpps(accountOppMapMSA, oppStationsMap);
			system.debug('\n\n oppsToUpdateMSA:'+oppsToUpdateMSA+'\n\n');
			update oppsToUpdateMSA;
		}
		
		currentNPRProducts = evaluateNprProductsCurList(opp);		
		
		//currentNPRProducts = getCurrentNPRProducts(opp.Id);
		map<String, NPR_Product__c> productToNprProdMap = new map<String, NPR_Product__c>();
		for(NPR_Product__c npr : currentNPRProducts)
		{
			productToNprProdMap.put(npr.Product__c, npr);
		}
		oppNprProdMap.put(opp, currentNPRProducts);
		system.debug('\n\n'+oppNprProdMap+'\n\n');
		
		evaluateOppProducts(opp, productToNprProdMap);
		
		evaluateNprProductsDel(opp);

		removeOppOverrides(opp);
		
		oppInit();
		
		//initialize NPR Products for this Opportunity
		List<Opportunity> oppList = new List<Opportunity>();
		oppList.add(opp);
		
		// Update opp for npr query
		//update oppList;
		
		currentOppProducts = getCurrentOppProducts(opp.Id);
		currentProductList = productsQuery(currentNPRProducts, opp);
		
		populateMapsForNprProdInitQuery(oppList);
		system.debug('\n\n\n currentNPRProducts = '+currentNPRProducts+'\n\n\n');
		List<NPR_Product__c> nprProductsToInit = pu.initNPRProds(opp, oppAccountMap.get(opp.Id), currentNPRProducts, oppFYMap.get(opp.Id), oppDiscountMap.get(opp.Id), combinedProductList, pricingTables, pricingMsaLicenseFees);
		system.debug('\n\n\n nprProductsToInit = '+nprProductsToInit+'\n\n\n');
		//if (nprProductsToInit.size()>0) update nprProductsToInit; 
		 
		//initialize Opportunity Product
		List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
		List<OpportunityLineItem> updatedOLIList = new List<OpportunityLineItem>();
		List<Opportunity> msaOpps = new List<Opportunity>();
		
		List<OpportunityLineItem> oppProductsToInit = new list<OpportunityLineItem>{};
		if (opp.Type=='MSA')
		{
			Opportunity[] msaOppList = new Opportunity[]{opp};
			populateMapsForOppProdInitQuery(currentOppProducts, msaOppList, currentNPRProducts, currentProductList);	

			List<PricebookEntry> pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :currentProductList AND Pricebook2.isStandard=true];
					
			oppProductsToInit = pu.initOLIs(opp, currentOppProducts, currentNPRProducts, currentProductList, oppStationsMap.get(opp.Id), MSAIncStreamingList, MSAIncEmailList, pbeList);
			//if (oppProductsToInit.size()>0) update oppProductsToInit; 
		}
				
		nprProductsToInit = removeNprProdOverrides(nprProductsToInit);
		
		oppProductsToInit = removeOppProdOverrides(oppProductsToInit);

		//calc for old NPR Products and OLIs
		list<NPR_Product__c> lstNPRProdToUpdate = new list<NPR_Product__c>{};
		for(NPR_Product__c npr : nprProductsToInit)
		{
			lstNPRProdToUpdate.add(pu.calcNPRProd(npr));
		}		
		try{ update lstNPRProdToUpdate; }
		catch (DmlException x)
		{
		  System.debug(x.getMessage());
		}
		
		list<OpportunityLineItem> lstOLIsToUpdate = new list<OpportunityLineItem>{};
		for(OpportunityLineItem oli : oppProductsToInit)
		{
			lstOLIsToUpdate.add(pu.calcOLI(oli));
		}
		
		try{ update lstOLIsToUpdate; }
		catch (DmlException x)
		{
		  System.debug(x.getMessage());
		}
		
		calcOpp(opp, lstNPRProdToUpdate);		
		
	}
	
	//Will completely refresh the Opportunity, including the determination of child stations, 
	//PPF programs to include, and list pricing.  This version will maintain any discounts/overrides
	public  void refreshOpportunityKeepOverrides(Opportunity opp)
	{
		system.debug('\n\n\n********* IN refreshOpportunityKeepOverrides **********\n\n\n');
		populateAccountOppMaps(new List<Opportunity>{opp});
		
		populateStationsList();
		
		if (accountOppMapMSA.size()>0)
		{
			oppsToUpdateMSA = pu.populatePricingValuesOnMSAOpps(accountOppMapMSA, oppStationsMap);
			system.debug('\n\n oppsToUpdateMSA:'+oppsToUpdateMSA+'\n\n');
			update oppsToUpdateMSA;
		}
		
		currentNPRProducts = evaluateNprProductsCurList(opp);
		
		//currentNPRProducts = getCurrentNPRProducts(opp.Id);
		system.debug('\n\n currentNPRProducts = '+currentNPRProducts+'\n\n');
		map<String, NPR_Product__c> productToNprProdMap = new map<String, NPR_Product__c>();
		for(NPR_Product__c npr : currentNPRProducts)
		{
			productToNprProdMap.put(npr.Product__c, npr);
		}
		oppNprProdMap.put(opp, currentNPRProducts);
	
		evaluateOppProducts(opp, productToNprProdMap);
		
		evaluateNprProductsDel(opp);
		
		//init for Opp and all NPR Products and OLIs
		oppInit();
		
		//initialize NPR Products for this Opportunity
		List<Opportunity> oppList = new List<Opportunity>();
		oppList.add(opp);
		
		// Update opp for npr query
		//update oppList;
		
		currentOppProducts = getCurrentOppProducts(opp.Id);
		currentProductList = productsQuery(currentNPRProducts, opp);
		
		populateMapsForNprProdInitQuery(oppList);
		system.debug('\n\n\n currentNPRProducts = '+currentNPRProducts+'\n\n\n');
		List<NPR_Product__c> nprProductsToInit = pu.initNPRProds(opp, oppAccountMap.get(opp.Id), currentNPRProducts, oppFYMap.get(opp.Id), oppDiscountMap.get(opp.Id), combinedProductList, pricingTables, pricingMsaLicenseFees);
		system.debug('\n\n\n nprProductsToInit = '+nprProductsToInit+'\n\n\n');
		//if (nprProductsToInit.size()>0) update nprProductsToInit; 
		 
		//initialize Opportunity Products for this Opportunity
		List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
		List<OpportunityLineItem> updatedOLIList = new List<OpportunityLineItem>();
		List<Opportunity> msaOpps = new List<Opportunity>();
		
		List<OpportunityLineItem> oppProductsToInit = new List<OpportunityLineItem>{};
		if (opp.Type=='MSA')
		{
			Opportunity[] msaOppList = new Opportunity[]{opp};
			populateMapsForOppProdInitQuery(currentOppProducts, msaOppList, currentNPRProducts, currentProductList);	

			List<PricebookEntry> pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :currentProductList AND Pricebook2.isStandard=true];
					
			oppProductsToInit = pu.initOLIs(opp, currentOppProducts, currentNPRProducts, currentProductList, oppStationsMap.get(opp.Id), MSAIncStreamingList, MSAIncEmailList, pbeList);
			//if (oppProductsToInit.size()>0) update oppProductsToInit; 
		}
		
		//calc for old NPR Products and OLIs

		list<NPR_Product__c> lstNPRProdToUpdate = new list<NPR_Product__c>{};
		for(NPR_Product__c npr : nprProductsToInit)
		{
			lstNPRProdToUpdate.add(pu.calcNPRProd(npr));
		}		
		try{ update lstNPRProdToUpdate; }
		catch (DmlException x)
		{
  			System.debug(x.getMessage());
		}
		
		list<OpportunityLineItem> lstOLIsToUpdate = new list<OpportunityLineItem>{};
		for(OpportunityLineItem oli : oppProductsToInit)
		{
			lstOLIsToUpdate.add(pu.calcOLI(oli));
		}
		
		try { update lstOLIsToUpdate; }
		catch (DmlException x)
		{
		  System.debug(x.getMessage());
		}
		
		//calc for Opportunity
		calcOpp(opp, lstNPRProdToUpdate);
	}
	
	public  void populateAccountOppMaps(List <Opportunity> oppList)
	{
		//populate accountOppMap for PPF and MSA opportunities
		for (Opportunity opp: oppList)
		{
			if (opp!=null && opp.Type=='MSA') 
			{
				accountOppMapMSA.put(opp.AccountId, opp);
				//oppAccountMapMSA.put(opp.Id, opp.Account);
			}
			if (opp.Type=='PPF') accountOppMapPPF.put(opp.AccountId, opp);
		}
	}
	
	public  void populateStationsList()
	{
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
				if (oppStationsMap.containsKey(accountOppMapPPF.get(a.ParentId).Id))
						oppStationsMap.get(accountOppMapPPF.get(a.ParentId).Id).add(a);
					else oppStationsMap.put(accountOppMapPPF.get(a.ParentId).Id, new List<Account> { a });
			}
				
			if (accountOppMapMSA.containsKey(a.ParentId))
			{
				if (oppStationsMap.containsKey(accountOppMapMSA.get(a.ParentId).Id))
						oppStationsMap.get(accountOppMapMSA.get(a.ParentId).Id).add(a);
					else oppStationsMap.put(accountOppMapMSA.get(a.ParentId).Id, new List<Account> { a });
			}	
		}
		
		stations2 = relatedStationsQuery2(stations1MSA);
		
		//populate oppStationsMap with accounts from stations2
		for (Account a : stations2)
		{
			if (accountOppMapMSA.containsKey(a.Parent.ParentId))
			{
				if (oppStationsMap.containsKey(accountOppMapMSA.get(a.Parent.ParentId).Id))
						oppStationsMap.get(accountOppMapMSA.get(a.Parent.ParentId).Id).add(a);
					else oppStationsMap.put(accountOppMapMSA.get(a.Parent.ParentId).Id, new List<Account> { a });
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
	}
	
	public void evaluateNprProductsDel(Opportunity opp)
	{
		List<NPR_Product__c> newNprProducts = new List<NPR_Product__c>();
		
		//get product lists for the opportunity
		List<Product2> productListPPF = productsQuery('PPF', opp);
		productListMSA = productsQuery('MSA', opp);
		
		combinedProductList.addAll(productListPPF);
		combinedProductList.addAll(productListMSA);
		
		Set<Id> combinedProductIds = new Set<Id>();
		for (Product2 pr : combinedProductList)
		{
			combinedProductIds.add(pr.Id);
		}
				
		//get existing NPR Products for the Opportunity	
		oldNprProductsList = getCurrentNPRProducts(opp.Id);
		system.debug('***\n\n oldNprProductsList: '+oldNprProductsList+'\n\n***');

		List<NPR_Product__c> nprProductsToDelete = new List<NPR_Product__c>();
		for (Integer i=0; i<oldNprProductsList.size(); i++) 
		{
			//if there’s an NPR Product record that doesn’t have a match in the 'Products' list, 
			//then delete the NPR Product record 
			//NOTE: this will automatically delete any related opportunity product records via the custom trigger

			if (!combinedProductIds.contains(oldNprProductsList[i].Product__c) && oldNprProductsList[i].Product__r.Product_Version__c == 'Core' )
			{
				nprProductsToDelete.add(oldNprProductsList[i]);
				oldNprProductsList.remove(i);
			}	
		}
		system.debug('\n\n nprProductsToDelete = '+nprProductsToDelete+'\n\n');
		if (nprProductsToDelete.size()>0) delete nprProductsToDelete;
	}
	
	public list<NPR_Product__c> evaluateNprProductsCurList(Opportunity opp)
	{
		List<NPR_Product__c> newNprProducts = new List<NPR_Product__c>();
		
		//get product lists for the opportunity
		List<Product2> productListPPF = productsQuery('PPF', opp);
		productListMSA = productsQuery('MSA', opp);
		
		combinedProductList.addAll(productListPPF);
		combinedProductList.addAll(productListMSA);
		
		Set<Id> combinedProductIds = new Set<Id>();
		for (Product2 pr : combinedProductList)
		{
			combinedProductIds.add(pr.Id);
		}
				
		//get existing NPR Products for the Opportunity	
		oldNprProductsList = getCurrentNPRProducts(opp.Id);
		Set<Id> prodIds = new Set<Id>();
		
		for (NPR_Product__c np: oldNprProductsList)
		{
			prodIds.add(np.Product__c);
		}
		
		//For each product in the 'Products' list, compare to the list of existing 
		//NPR Products based on NPR_Product__r.Product__c = Product.Id (from the 'Products' list)
		for (Product2 pr : combinedProductList)
		{
			//if there’s a product on the 'Products' list that doesn’t have a match with an 
			//existing NPR Product record, then create a new NPR Product record			
			if (!prodIds.contains(pr.Id))
			{
				NPR_Product__c nprProd = createNewNprProduct(opp, pr);
				if (nprProd != null) newNprProducts.add(nprProd);
			}
		}
		system.debug('\n\n newNprProducts = '+newNprProducts+'\n\n');
		if (newNprProducts.size()>0) insert newNprProducts;
		
		List<NPR_Product__c> nprProductsToDelete = new List<NPR_Product__c>();
		for (Integer i=0; i<oldNprProductsList.size(); i++) 
		{
			//if there’s an NPR Product record that doesn’t have a match in the 'Products' list, 
			//then delete the NPR Product record 
			//NOTE: this will automatically delete any related opportunity product records via the custom trigger

			if (!combinedProductIds.contains(oldNprProductsList[i].Product__c) && oldNprProductsList[i].Product__r.Product_Version__c == 'Core' )
			{
				nprProductsToDelete.add(oldNprProductsList[i]);
				oldNprProductsList.remove(i);
			}	
		}
		system.debug('\n\n nprProductsToDelete = '+nprProductsToDelete+'\n\n');
		//if (nprProductsToDelete.size()>0) delete nprProductsToDelete;
		
		list<NPR_Product__c> returnList = new list<NPR_Product__c>();
		returnList.addAll(oldNprProductsList);
		returnList.addAll(newNprProducts);
		
		system.debug('\n\n returnList = '+returnList+'\n\n');
		return returnList;
	}
	
	public  void evaluateOppProducts(Opportunity opp, map<String, NPR_Product__c> ProdIdToNPRProdMap)
	{
		//get existing Opportunity Products for the Opportunity	
		oldOppProductsList = [select Id, OpportunityId, PricebookEntryId, Set_up_fee__c, Annualized_Price__c, Bill_Start_Date__c, Bill_End_Date__c, Override_Fee__c,
			Final_Price__c, Subtotal_Fee__c, Station__c, NPR_Product__c from OpportunityLineItem where OpportunityId =: opp.Id];
		
		system.debug('\n\n ProdIdToNPRProdMap = '+ProdIdToNPRProdMap+'\n\n');
		system.debug('\n\n ProdIdToNPRProdMap size = '+ProdIdToNPRProdMap.size()+'\n\n');
		//determine the proper set of new Opportunity Product records that should exist on the opportunity
		List<OpportunityLineItem> newOppProductsList = determineOpportunityProducts(opp,ProdIdToNPRProdMap);
		system.debug('\n\n newOppProductsList = '+newOppProductsList+'\n\n');
		system.debug('\n\n newOppProductsList size = '+newOppProductsList.size()+'\n\n');

		List<OpportunityLineItem> oppProductsToDelete = new List<OpportunityLineItem>();
		List<OpportunityLineItem> oppProductsToInsert = new List<OpportunityLineItem>();
			
		//create a Map of Product + Station__c to OpportunityLineItem for both lists
		Map<String, OpportunityLineItem> mapForNewList = createPSToOppProductMap(newOppProductsList);
		Map<String, OpportunityLineItem> mapForOldList = createPSToOppProductMap(oldOppProductsList);

		system.debug('\n\n mapForNewList = '+mapForNewList.size()+'\n\n');
		system.debug('\n\n mapForOldList = '+mapForOldList.size()+'\n\n');
		oldOppProductsList = new list<OpportunityLineItem>();
		for (String oldId : mapForOldList.keySet()) 
		{
			//If there’s an existing Opportunity Product record that shouldn’t exist, then 
			//delete the Opportunity Product record.
			if (!mapForNewList.containsKey(oldId))
			{
				oppProductsToDelete.add(mapForOldList.get(oldId));
				//oldOppProductsList.remove(i);
			}
			else
			{
				oldOppProductsList.add(mapForOldList.get(oldId));
			}
		}
		system.debug('\n\n oppProductsToDelete = '+oppProductsToDelete+'\n\n');
		if (oppProductsToDelete.size()>0) delete oppProductsToDelete;
		
		for (OpportunityLineItem oli : newOppProductsList)
		{
			//if there’s an Opportunity Product record that should be created, then create a new Opportunity Product record
			if (!mapForOldList.containsKey(String.valueOf(oli.PricebookEntryId) + String.valueOf(oli.Station__c)))
			{
				oppProductsToInsert.add(oli);
			}					
		}
		system.debug('\n\n oppProductsToInsert = '+oppProductsToInsert+'\n\n');
		if (oppProductsToInsert.size()>0) insert oppProductsToInsert;
	}	
	
	public  void removeOppOverrides(Opportunity op)
	{
		//On the Opportunity record, make NULL the following fields:
		op.Discount__c = null;
		op.Discount_Type__c = null;
		op.Discount_Comments__c = null; 
		op.Total_Override__c = null;
		op.Total_Override_Comments__c = null;
		op.Admin_Fee_Override__c = null;
		op.Admin_Fee_Override_Comments__c = null;
	
		update op;
	}	
	
		
	public list<NPR_Product__c> removeNprProdOverrides(list<NPR_Product__c> nprProductsList)
	{
		//Update the following field values on all NPR Product records to NULL:
		//get existing NPR Products for the Opportunity	
		//List<NPR_Product__c> nprProductsList = [select Id, Opportunity_Name__c, Override_Discount__c, Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Accelerated_Cap__c, Accelerated_Cap_Comments__c from NPR_Product__c where Opportunity_Name__c =: op.Id];
		for (NPR_Product__c nprProd : nprProductsList)
		{
			nprProd.Override_Discount__c = null;
			nprProd.Override_Discount_Comments__c = null;
			nprProd.Override_Fee__c = null;
			nprProd.Override_Fee_Comments__c = null;
			nprProd.Accelerated_Cap__c = null;
			nprProd.Accelerated_Cap_Comments__c = null;
		}
		
		return nprProductsList;
		/*try{ 
			update nprProductsList; 
			List<NPR_Product__c> nprProductsList2 = [select Id, Opportunity_Name__c, Override_Discount__c, Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Accelerated_Cap__c, Accelerated_Cap_Comments__c from NPR_Product__c where Opportunity_Name__c =: op.Id];
			system.debug('\n\n nprProductsList2: '+nprProductsList2[0].Override_Discount__c+'\n\n');
			system.debug('\n\n nprProductsList3: '+nprProductsList2+'\n\n');
		}
		catch (DmlException x)
		{
  			System.debug('\n\n ERROR:'+x.getMessage()+'\n\n');
		}*/
		//system.debug('\n\n nprProductsList3: '+nprProductsList+'\n\n'); 
	}
	
	public List<OpportunityLineItem> removeOppProdOverrides(List<OpportunityLineItem> existingOppProductsList)
	{	
		//Update the following field values on all Opportunity Product records to NULL:
		//get existing Opportunity Products for the Opportunity	
		//List<OpportunityLineItem> existingOppProductsList = [select Id, OpportunityId, Override_Fee__c, Override_Fee_Comments__c from OpportunityLineItem where OpportunityId =: op.Id];
		
		for (OpportunityLineItem oli : existingOppProductsList)
		{
			oli.Override_Fee__c = null;
			oli.Override_Fee_Comments__c = null;
		}
		
		return existingOppProductsList;
		//update existingOppProductsList;					
	}
	
	public  void calcOpp(Opportunity opp, list<NPR_Product__c> nprProds)
	{
		system.debug('\n\n'+oppNprProdMap.keySet()+'\n\n');
		//for (Opportunity opp : oppNprProdMap.keySet())
		//{
			//oppsToUpdate.add(pu.calcOpportunity(opp, oppNprProdMap.get(opp)));
		//}
	
		oppsToUpdate.add(pu.calcOpportunity(opp, nprProds));
		if (oppsToUpdate.size()>0) update oppsToUpdate;
	}
	
	public  NPR_Product__c createNewNprProduct(Opportunity opp, Product2 product)
	{
		if (product.Active_Start_Date__c <= opp.CloseDate && product.Active_End_Date__c >= opp.CloseDate && product.Family == opp.Type)
		{
			NPR_Product__c nprProd = new NPR_Product__c();
			nprProd.Name = 'NPR Product for Opp ' + opp.Name;
			nprProd.Opportunity_Name__c = opp.Id;
			nprProd.Product__c = product.Id;
			nprProd.Bill_Start_Date__c = opp.CloseDate;
			nprProd.Bill_End_Date__c = opp.End_Date__c;
			nprProd.Fiscal_Year__c = opp.Fiscal_Year__c;
				
			return nprProd;
		}
		else return null;
	}
	
	public  void oppInit()
	{
		//Update pricing values on Opportunities -------------------------------------				
		//check if maps are blank or not
		if (accountOppMapPPF.size()>0)
		{
			oppsToUpdatePPF = pu.populatePricingValuesOnPPFOpps(accountOppMapPPF);
			oppsToUpdatePPF = pu.determinePricingTeer(oppsToUpdatePPF, 'PPF');
			oppsToUpdatePPF = pu.determineAdminFee(oppsToUpdatePPF, accountOppMapPPF.keySet());
		}
				
		if (accountOppMapMSA.size()>0)
		{
			//oppsToUpdateMSA = pu.populatePricingValuesOnMSAOpps(accountOppMapMSA, oppStationsMap);
			//update oppsToUpdateMSA;
			oppsToUpdateMSA = pu.determinePricingTeer(oppsToUpdateMSA, 'MSA');
			oppsToUpdateMSA = pu.determineLastFYMSAAnchorListPrice(accountOppMapMSA);
		}
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
			return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c, TSR__c, Email_List_Size__c, Licensee__c
				from Account
				Where Parent.Id in: accIds AND 
					Type2__c includes ('Associate')];
			// Type2__c excludes ('LMA Station')
			// Type2__c includes ('Station') OR 
		}
		else if (oppType == 'MSA')
		{
			return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c, TSR__c, Email_List_Size__c, Licensee__c 
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
		return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c, TSR__c, Email_List_Size__c, Parent.ParentId, Licensee__c 
				FROM Account
				WHERE Parent.Id in: q1Accounts AND 
				(Type2__c includes ('Station') OR Type2__c includes ('Associate')) AND 
				MSA_Opt_Out__c = false]; 		
	}
	
	public  Account[] oppAccountStationQuery(Set<Id> accIds)
	{
		//Determine if the Opportunity.Account is a station account and if so, add to the 'Stations' list.
		return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, TSR__c, LMA__c, Email_List_Size__c, Licensee__c 
				FROM Account
				Where Id in: accIds AND (Type2__c includes ('Station') OR Type2__c includes ('Associate'))];
	}
	
	public  Product2[] productsQuery(String productFamily, Opportunity opp)
	{
		//Identify products that should be pulled into the opportunity.  
		//This list of products will be used to create NPR_Product__c records and, in combination with 
		//'Stations' list, will help create Opportunity Products.
		
		return [Select Id, Name, MSA_Type__c, Product_Version__c, Active_Start_Date__c, Active_End_Date__c, MSA_Incremental_Type__c, Family, 
				ME__c, ATC__c, PPF_Type__c, MSA_Bundle__c
				FROM Product2 
				WHERE Product_Version__c = 'Core' AND Family=:productFamily
				AND Active_Start_Date__c<=:opp.CloseDate AND Active_End_Date__c>=:opp.CloseDate];			
	}
	
	public  List<OpportunityLineItem> determineOpportunityProducts(Opportunity opp, map<String, NPR_Product__c> ProdIdToNPRProdMap)
	{
		//For each record in the nprProducts list and each account in the stations list, 
		//add an Opportunity Product record except where Product.MSA_Type__c = ‘Member’
		//AND Account.LMA__c = TRUE.
		
		List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
	
		//create a Prodiuct2id to PriceBookEntry.Id Map
		List<PricebookEntry> pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :combinedProductList AND Pricebook2.isStandard=true]; 
		Map<Id,Id> prodToPbe = new Map<Id,Id>(); 
		
		for (PricebookEntry pbEntry: pbeList) 
		{ 
			prodToPbe.put(pbEntry.Product2Id, pbEntry.Id);
			pbeToProd.put(pbEntry.Id, pbEntry.Product2Id); 
		} 
		
		system.debug('\n\n oppStationsMap = '+oppStationsMap+'\n\n');
		system.debug('\n\n oppStationsMap size = '+oppStationsMap.size()+'\n\n');
		for (Product2 pr : combinedProductList)
		{
			if(ProdIdToNPRProdMap.get(pr.Id)!=null)
			{
				if (oppStationsMap!=null && opp.Id != null && oppStationsMap.containsKey(opp.Id))
				{
					for (Account st : oppStationsMap.get(opp.Id))
					{
						if (pr.MSA_Type__c != 'Member' || st.LMA__c == false)
						{ 						
							OpportunityLineItem oppProduct = new OpportunityLineItem();
									
							oppProduct.OpportunityId = opp.Id;
							oppProduct.PricebookEntryId = prodToPbe.get(pr.Id);						
							oppProduct.Station__c = st.Id;
							oppProduct.Bill_Start_Date__c = opp.CloseDate;
							oppProduct.Bill_End_Date__c = opp.End_Date__c;
							oppProduct.Quantity = 1;
							oppProduct.NPR_Product__c = ProdIdToNPRProdMap.get(pr.Id).Id;
							oppProduct.UnitPrice = 0;		
							
							oppProductList.add(oppProduct);
						}
					}
				}
			}
		}
		
		return oppProductList;				
	}
	
	public  Map<String, OpportunityLineItem> createPSToOppProductMap(List<OpportunityLineItem> oppProductList)
	{
		//create a Map of PricebookEntryId + Station__c to OpportunityLineItem for both lists
		Map<String, OpportunityLineItem> tmpMap = new Map<String, OpportunityLineItem>();
		
		for (OpportunityLineItem op : oppProductList)
		{
			String psKey = String.valueOf(op.PricebookEntryId) + String.valueOf(op.Station__c);
			tmpMap.put(psKey, op);
		}
		
		return tmpMap;
	}
	
	public  List<NPR_Product__c> getCurrentNPRProducts(String oppId)
	{
		return [select Id, Product__c, Opportunity_Name__c, Product__r.Product_Version__c, Opportunity_Name__r.Type, Product__r.PPF_Type__c,
			Product__r.MSA_Bundle__c, Bill_Start_Date__c, Bill_End_Date__c, License_Fee_Factor__c, Product__r.Family, Accelerated_Cap__c, 
			Last_FY_Fee_Override__c, ATC_Capped_Final_Fee__c, ATC_Last_FY_Price__c, List_Price_PPF_Annualized__c, List_Fee_Non_News_Annualized__c, 
			Base_Fee_Annualized__c, Opportunity_Name__r.Total_TSR_MSA__c, MSA_Cap__c, Last_FY_MSA_Price_Override__c, 
			Final_Last_FY_MSA_Anchor_Price__c, List_Fee_Annualized__c, Previous_FY_Fee_Threshold_Min__c, Previous_FY_Fee_Threshold_Max__c, 
			Annual_FY_Increase__c, Discount_From_Anchor__c, Subtotal_Fee__c, List_Fee_Prorated__c, Discount_Percent__c, Override_Discount__c, 
			Final_Fee__c, Opportunity_Name__r.Last_FY_MSA_Anchor_List_Price__c, Include_in_PPF_MSA__c, Product__r.ME__c, 
			Product__r.ATC__c, Product_PPF_Type__c, Override_Fee__c 
			from NPR_Product__c where Opportunity_Name__c =: oppId];
	}
	
	public  List<OpportunityLineItem> getCurrentOppProducts(String oppId)
	{
		return [select Id, OpportunityId, PricebookEntryId, Set_up_fee__c, Annualized_Price__c, Bill_Start_Date__c, Bill_End_Date__c, Override_Fee__c,
			Final_Price__c, Subtotal_Fee__c, Station__c, NPR_Product__c from OpportunityLineItem where OpportunityId =: oppId];
	}
	
	public void populateOppAccountMap()
	{
		if (accountOppMapPPF.size()>0)
		{
			Map<ID, Account> aMap = new Map<ID, Account>([SELECT Id, Minority_Status__c, Membership_Pricing_Status__c, Membership_Status_for_MSA__c, Email_List_Size__c FROM Account where Id in: accountOppMapPPF.keySet()]);
		
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
			Map<ID, Account> aMap = new Map<ID, Account>([SELECT Id, Minority_Status__c, Membership_Pricing_Status__c, Membership_Status_for_MSA__c, Email_List_Size__c FROM Account where Id in: accountOppMapMSA.keySet()]);
		
			for (Id accountId : accountOppMapMSA.keySet())
			{
				if (aMap.containsKey(accountId))
				{
					oppAccountMap.put(accountOppMapMSA.get(accountId).Id, aMap.get(accountId));
				}
			}
		}
	}
		
		public void populateMapsForNprProdInitQuery(Opportunity[] newOpps)
		{
			populateOppAccountMap();
			oppFYMap = pu.FYPricingDetailQuery(newOpps);
			oppDiscountMap = pu.NPRDiscountQuery(newOpps, oppAccountMap.values());
			
			// allNprProducts is empty
			//check if have any PPF opps - set a flag
			pricingTables = pu.pricingTable(newOpps, currentNPRProducts, oppAccountMap.values());
			
			//check if have any MSA opps - set a flag
			pricingMsaLicenseFees = pu.MSALicenseFee(newOpps, currentNPRProducts, oppAccountMap.values());		
		}
		
		
		public void populateMapsForOppProdInitQuery(List<OpportunityLineItem> oppProductList, Opportunity[] msaOpps, List<NPR_Product__c> nprProducts, List<Product2> productListMSA)
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
		
		public Product2[] productsQuery(List<NPR_Product__c> nprProdList, Opportunity opp)
		{
			Set<Id> prodIds = new Set<Id>();
			
			//Identify current products associated to an opportunity  
			for (NPR_Product__c nprProd : nprProdList)
			{
				prodIds.add(nprProd.Product__c);
			}
			
			return [Select Id, Name, MSA_Type__c, Product_Version__c, Active_Start_Date__c, Active_End_Date__c, PPF_Type__c, MSA_Incremental_Type__c, Family,
					ME__c, ATC__c
					FROM Product2 
					WHERE Product_Version__c = 'Core' AND Family=:'MSA' AND Id IN: prodIds
					AND Active_Start_Date__c<=:opp.CloseDate AND Active_End_Date__c>=:opp.CloseDate];			
		}
	
	}