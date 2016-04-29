public class OpportunityTrigger2 
{
	/*
	public static Map<Id, Opportunity> accountOppMapPPF = new Map<Id, Opportunity>();
	public static Map<Id, Opportunity> accountOppMapMSA = new Map<Id, Opportunity>();
	public static List<Opportunity> oppsToUpdatePPF = new List<Opportunity>();
	public static List<Opportunity> oppsToUpdateMSA = new List<Opportunity>();
	public static List<Product2> combinedProductList = new List<Product2>();
	
	public static Map<String, List<Account>> oppStationsMap = new Map<String, List<Account>>();
	public static Map<Opportunity, List<Product2>> oppProductsMapPPF = new Map<Opportunity, List<Product2>>();
	public static Map<Opportunity, List<Product2>> oppProductsMapMSA = new Map<Opportunity, List<Product2>>();
	
	public static Map<String, NPR_Product__c> productToNprProdMap = new Map<String, NPR_Product__c>();
	public static PricingUtility pu = new PricingUtility();
				
	public static List<Account> stations1PPF = new List<Account>();
	public static List<Account> stations1MSA = new List<Account>();
	public static List<Account> stations1 = new List<Account>();
	public static List<Account> stations2 = new List<Account>();
	public static List<Account> stations3 = new List<Account>();
	public static List<Account> stationsFinal = new List<Account>();
					
	public static void opportunityCreationProcess(Opportunity[] newOpps)
	{
		populateAccountOppMaps(newOpps);
		
		populateStationsList();
						
		updatePricingValuesOnOpportunities();
						
		/*createNprProducts();			
		linkNprProducts();						
					
		//Create Opportunity Products--------------------------------
		createOpportunityProducts(oppProductsMapMSA);
		createOpportunityProducts(oppProductsMapPPF);	
		
		//CALC OPPORTUNITY - Run pricing calculation on Opportunity	
		calcOpp();
		*/   /*	
	}
	
	public static void opportunityCreationProcessAfter(Opportunity[] newOpps)
	{
		createNprProducts();			
		linkNprProducts();						
					
		//Create Opportunity Products--------------------------------
		createOpportunityProducts(oppProductsMapMSA);
		createOpportunityProducts(oppProductsMapPPF);	
		/*
		//CALC OPPORTUNITY - Run pricing calculation on Opportunity	
		calcOpp();
		*/	/*
	}
	
	public static Account[] relatedStationsQuery1(Set<Id> accIds, String oppType)
	{
		//Capture a list of accounts that should be included in the opportunity
		//this list will be used to create Opportunity Product records
		
		//The query will identify child accounts related to the Opportunity.Account based on the 
		//standard Salesforce account hierarchy.  The results of this list will be used as the 
		//basis for 'Related Stations Query 2' below
		
		if (oppType == 'PPF')
		{
			return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c, TSR__c from Account
				Where Parent.Id in: accIds AND 
					Type2__c includes ('Station') AND 
					LMA__c = false];
		}
		else if (oppType == 'MSA')
		{
			return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c from Account
				Where Parent.Id in: accIds AND 
					Type2__c includes ('Station') AND 
					MSA_Opt_Out__c = false];
		}	 
		else return null;
	}
	
	public static Account[] relatedStationsQuery2(Account[] q1Accounts)
	{
		//Capture a list of accounts that should be included in the opportunity
		//this list will be used to create Opportunity Product records.  
		
		//The query will identify child accounts related to the accounts identified in the 
		//'Related Stations Query 1’, based on the standard Salesforce account hierarchy.  
		//This will only be run for Type = MSA opportunities.
		return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, Parent.Id, LMA__c, TSR__c FROM Account
				WHERE Parent.Id in: q1Accounts AND 
				Type2__c includes ('Station') AND 
				MSA_Opt_Out__c = false]; 		
	}
	
	public static Account[] oppAccountStationQuery(Set<Id> accIds)
	{
		//Determine if the Opportunity.Account is a station account and if so, add to the 'Stations' list.
		return [Select Id, Name, Type, Type2__c, NPR_Station_Status__c, TSR__c, LMA__c FROM Account
				Where Id in: accIds AND Type2__c includes ('Station')];
	}

	public static Product2[] productsQuery(String productFamily)
	{
		//Identify products that should be pulled into the opportunity.  
		//This list of products will be used to create NPR_Product__c records and, in combination with 
		//'Stations' list, will help create Opportunity Products.
		
		return [Select Id, Name, MSA_Type__c, Product_Version__c, Active_Start_Date__c, Active_End_Date__c FROM Product2 
				WHERE Product_Version__c = 'Core' AND Family=:productFamily];			
	}
	
		
	public static void createNprProducts()
	{		
		List<NPR_Product__c> nprProducts = new List<NPR_Product__c>();
		
		List<Product2> productListPPF = productsQuery('PPF');
		List<Product2> productListMSA = productsQuery('MSA');		
		combinedProductList.addAll(productListPPF);
		combinedProductList.addAll(productListMSA);
		
		//populate Opp to Product List Map
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
					
					if (oppProductsMapPPF.containsKey(opp))
						oppProductsMapPPF.get(opp).add(pr);
					else oppProductsMapPPF.put(opp, new List<Product2> { pr });
										
					nprProducts.add(nprProd);
					productToNprProdMap.put(pr.Id, nprProd);
				}
			}
		}
		
		for (Opportunity opp: accountOppMapMSA.values())
		{
			for (Product2 pr: productListMSA)
			{		
				if (pr.Active_Start_Date__c <= opp.CloseDate && pr.Active_End_Date__c >= opp.CloseDate)
				{
					NPR_Product__c nprProd = new NPR_Product__c();
					nprProd.Name = 'NPR Product for Opp ' + opp.Name;
					nprProd.Opportunity_Name__c = opp.Id;
					nprProd.Product__c = pr.Id;
					nprProd.Bill_Start_Date__c = opp.CloseDate;
					nprProd.Bill_End_Date__c = opp.End_Date__c;
					
					if (oppProductsMapMSA.containsKey(opp))
						oppProductsMapMSA.get(opp).add(pr);
					else oppProductsMapMSA.put(opp, new List<Product2> { pr });
										
					nprProducts.add(nprProd);
					productToNprProdMap.put(pr.Id, nprProd);
				}
			}
		}
		
		//Insert NPR Products
		if (nprProducts.size()>0) 
			insert nprProducts;
	}	
	
	public static void createOpportunityProducts(Map<Opportunity, List<Product2>> oppProdMap)
	{
		//For each record in the nprProducts list and each account in the stations list, 
		//create an Opportunity Product record except where Product.MSA_Type__c = ‘Member’
		//AND Account.LMA__c = TRUE.
		
		List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
	
		//create a Prodiuct2id to PriceBookEntry.Id Map
		List<PricebookEntry> pbeList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :combinedProductList AND Pricebook2.isStandard=true]; 
		Map<Id,Id> prodToPbe = new Map<Id,Id>(); 
		for (PricebookEntry pbEntry: pbeList) 
		{ 
			prodToPbe.put(pbEntry.Product2Id, pbEntry.Id); 
		} 
		
		for (Opportunity opp : oppProdMap.keySet())
		{
			if(opp != null){
			for (Product2 pr : oppProdMap.get(opp))
			{
				if(oppStationsMap!=null && opp.Id != null && oppStationsMap.get(opp.Id) != null){
				for (Account st : oppStationsMap.get(opp.Id))
				{
					if (pr.MSA_Type__c != 'Member' && st.LMA__c == false)
					{ 						
						OpportunityLineItem oppProduct = new OpportunityLineItem();
						
						oppProduct.OpportunityId = opp.Id;
						oppProduct.PricebookEntryId = prodToPbe.get(pr.Id);						
						oppProduct.Station__c = st.Id;
						oppProduct.Bill_Start_Date__c = opp.CloseDate;
						oppProduct.Bill_End_Date__c = opp.End_Date__c;
					
						oppProductList.add(oppProduct);
					}
				}}
			}}
		}
		
		//Insert Opportunity Products
		if (oppProductList.size()>0) 
			insert oppProductList;
				
	}
	
	public static List<OpportunityLineItem> determineOpportunityProducts(Map<Opportunity, List<Product2>> oppProdMap)
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
		} 
		
		for (Opportunity opp : oppProdMap.keySet())
		{
			for (Product2 pr : oppProdMap.get(opp))
			{
				for (Account st : oppStationsMap.get(opp.Id))
				{
					if (pr.MSA_Type__c != 'Member' && st.LMA__c == false)
					{ 						
						OpportunityLineItem oppProduct = new OpportunityLineItem();
						
						oppProduct.OpportunityId = opp.Id;
						oppProduct.PricebookEntryId = prodToPbe.get(pr.Id);						
						oppProduct.Station__c = st.Id;
						oppProduct.Bill_Start_Date__c = opp.CloseDate;
						oppProduct.Bill_End_Date__c = opp.End_Date__c;
						
						//check with Scott on these two required fields
						//oppProduct.Quantity = 1;
						//oppProduct.TotalPrice = 10;
						//NPR_Product__c nprpr = new NPR_Product__c(Name=opp.Name, Opportunity_Name__c = opp.Id);
						//insert nprpr;
						
						//oppProduct.NPR_Product__c = nprpr.Id;
												
						oppProductList.add(oppProduct);
					}
				}
			}
		}
		
		return oppProductList;				
	}

	public static NPR_Product__c[] previousFYNPRProductQuery(Set<String> prodIds)
	{
		//Query NPR_Product__c records to identify previous Fiscal Year's records 
		
		return [SELECT  Adopt_Date__c, Adopt_Status__c, Air_Onboard_Date__c, Air_Onboard_Status__c, Drop_Reason__c, Opportunity_Account_ID__c, Product__c, Fiscal_Year__c  
				FROM NPR_Product__c 
				WHERE Product__c in: prodIds];
		
	}
	
	public static OpportunityLineItem[] previousFYOppProductQuery(Set<String> prodIds)
	{
		//Query Opportunity Product records to identify previous Fiscal Year's records 
		
		return [SELECT  Id, Adopt_Date__c, Adopt_Status__c, Air_Onboard_Date__c, Air_Onboard_Status__c, Drop_Reason__c  
				FROM OpportunityLineItem]; 
				//WHERE Product2 in: prodIds];
	}	

	//Will completely refresh the Opportunity, including the determination of child stations, 
	//PPF programs to include, and list pricing.  All existing overrides and discounts will be wiped out.
	public static void refreshOpportunityNoOverrides(Opportunity opp)
	{
		populateAccountOppMaps(new List<Opportunity>{opp});
		
		populateStationsList();
		
		evaluateNprProducts(opp);		
		
		evaluateOppProducts(opp);
		
		removeOppOverrides(opp);
		
		updatePricingValuesOnOpportunities();
		
		//Run INIT NPR Product
		//PricingUtility pu = new PricingUtility();
		//list<NPR_Product__c> returnNPRList = pu.initNPRProds(o, nprProdList);
		 
		//Run INIT Opportunity Product
		//list<OpportunityLineItem> returnOLIList = pu.initOLIs(o, oliList, nprProd)
				
		removeNprProdOverrides(opp);
		
		removeOppProdOverrides(opp);

		//Run CALC Opp Product and CALC NPR Product for all records
		calcOpp();			
		
	}
	
	//Will completely refresh the Opportunity, including the determination of child stations, 
	//PPF programs to include, and list pricing.  This version will maintain any discounts/overrides
	public static void refreshOpportunityKeepOverrides(Opportunity opp)
	{
		populateAccountOppMaps(new List<Opportunity>{opp});
		
		populateStationsList();
		
		evaluateNprProducts(opp);
	
		evaluateOppProducts(opp);
		
		//Run CALC Opp Product and CALC NPR Product for all records
		calcOpp();
	}
	
	public static void populateAccountOppMaps(List <Opportunity> oppList)
	{
		//populate accountOppMap for PPF and MSA opportunities
		for (Opportunity opp: oppList)
		{
			if (opp.Type=='MSA') accountOppMapMSA.put(opp.AccountId, opp);
			if (opp.Type=='PPF') accountOppMapPPF.put(opp.AccountId, opp);
		}
	}
	
	public static void populateStationsList()
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
			if (accountOppMapMSA.containsKey(a.ParentId))
			{
				if (oppStationsMap.containsKey(accountOppMapMSA.get(a.ParentId).Id))
						oppStationsMap.get(accountOppMapMSA.get(a.ParentId).Id).add(a);
					else oppStationsMap.put(accountOppMapMSA.get(a.ParentId).Id, new List<Account> { a });
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
	
	public static void updatePricingValuesOnOpportunities()
	{
		//Update pricing values on Opportunities -------------------------------------				
		oppsToUpdatePPF = pu.populatePricingValuesOnPPFOpps(accountOppMapPPF);
		oppsToUpdateMSA = pu.populatePricingValuesOnMSAOpps(accountOppMapMSA, oppStationsMap);
				
		oppsToUpdatePPF = pu.determinePricingTeer(oppsToUpdatePPF, 'PPF');
		oppsToUpdateMSA = pu.determinePricingTeer(oppsToUpdateMSA, 'MSA');
		
		oppsToUpdatePPF = pu.determineAdminFee(oppsToUpdatePPF, accountOppMapPPF.keySet());
		
		System.debug('Opps are:' + oppsToUpdatePPF);
			
		//if (oppsToUpdatePPF.size()>0) update oppsToUpdatePPF;
		//if (oppsToUpdateMSA.size()>0) update oppsToUpdateMSA;
	}
	
	public static void linkNprProducts()
	{
		//Link new NPR Products to Previous FY NPR Products----------
		List <NPR_Product__c> currentYearNPRProductsToUpdate = new List <NPR_Product__c>();
		List<NPR_Product__c> prevYearNPRProducts = previousFYNPRProductQuery(productToNprProdMap.keySet());
		
		for (NPR_Product__c prevYearNprProd : prevYearNPRProducts)
		{
			if (prevYearNprProd.Opportunity_Account_ID__c == productToNprProdMap.get(prevYearNprProd.Product__c).Opportunity_Account_ID__c &&
			    prevYearNprProd.Fiscal_Year__c == (productToNprProdMap.get(prevYearNprProd.Product__c).Fiscal_Year__c+1))
			{
				//update previous year NPR Product record
				prevYearNprProd.Next_FY_NPR_Product__c = productToNprProdMap.get(prevYearNprProd.Product__c).Id;
				
				//update new NPR Product record
				productToNprProdMap.get(prevYearNprProd.Product__c).Previous_FY_NPR_Product__c = prevYearNprProd.Id;
				
				if (prevYearNprProd.Air_Onboard_Status__c=='Completed')
				{
					productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Status__c = prevYearNprProd.Adopt_Status__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Date__c = prevYearNprProd.Adopt_Date__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Date__c = prevYearNprProd.Air_Onboard_Date__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Status__c = prevYearNprProd.Air_Onboard_Status__c;
				}
				else if (prevYearNprProd.Air_Onboard_Status__c=='Dropped')
				{
					productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Status__c = prevYearNprProd.Adopt_Status__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Adopt_Date__c = prevYearNprProd.Adopt_Date__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Date__c = prevYearNprProd.Air_Onboard_Date__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Air_Onboard_Status__c = prevYearNprProd.Air_Onboard_Status__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Drop_Date__c = prevYearNprProd.Drop_Date__c;
					productToNprProdMap.get(prevYearNprProd.Product__c).Drop_Reason__c = prevYearNprProd.Drop_Reason__c;
				}
				
				currentYearNPRProductsToUpdate.add(productToNprProdMap.get(prevYearNprProd.Product__c));									
			}
		}
		
		if (prevYearNPRProducts.size()>0) update prevYearNPRProducts; 
		if (currentYearNPRProductsToUpdate.size()>0) update currentYearNPRProductsToUpdate;
		 
	}
	
	public static void calcOpp()
	{
		oppsToUpdatePPF = pu.calcOpportunity(oppProductsMapPPF, productToNprProdMap);
		oppsToUpdateMSA = pu.calcOpportunity(oppProductsMapMSA, productToNprProdMap);
		
		if (oppsToUpdatePPF.size()>0) update oppsToUpdatePPF;
		if (oppsToUpdateMSA.size()>0) update oppsToUpdateMSA;
	}
	
	public static void evaluateNprProducts(Opportunity opp)
	{
		List<NPR_Product__c> newNprProducts = new List<NPR_Product__c>();
		
		//get product lists for the opportunity
		List<Product2> productListPPF = productsQuery('PPF');
		List<Product2> productListMSA = productsQuery('MSA');
		
		combinedProductList.addAll(productListPPF);
		combinedProductList.addAll(productListMSA);
		
		Set<Id> combinedProductIds = new Set<Id>();
		for (Product2 pr : combinedProductList)
		{
			combinedProductIds.add(pr.Id);
		}
				
		//get existing NPR Products for the Opportunity	
		List<NPR_Product__c> nprProductsList = [select Id, Product__c, Opportunity_Name__c from NPR_Product__c where Opportunity_Name__c =: opp.Id];
		Set<Id> prodIds = new Set<Id>();
		
		for (NPR_Product__c np: nprProductsList)
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
		
		if (newNprProducts.size()>0) insert newNprProducts;
		
		List<NPR_Product__c> nprProductsToDelete = new List<NPR_Product__c>();
		for (NPR_Product__c nprProd : nprProductsList)
		{
			//if there’s an NPR Product record that doesn’t have a match in the 'Products' list, 
			//then delete the NPR Product record 
			//NOTE: this will automatically delete any related opportunity product records via the custom trigger

			if (!combinedProductIds.contains(nprProd.Product__c))
			{
				nprProductsToDelete.add(nprProd);
			}	
		}
		if (nprProductsToDelete.size()>0) delete nprProductsToDelete;
		
	}
	
	public static NPR_Product__c createNewNprProduct(Opportunity opp, Product2 product)
	{
		if (product.Active_Start_Date__c <= opp.CloseDate && product.Active_End_Date__c >= opp.CloseDate)
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
	
	public static void evaluateOppProducts(Opportunity opp)
	{
		//get existing Opportunity Products for the Opportunity	
		List<OpportunityLineItem> existingOppProductsList = [select Id, OpportunityId from OpportunityLineItem where OpportunityId =: opp.Id];
		
		//determine the proper set of new Opportunity Product records that should exist on the opportunity
		List<OpportunityLineItem> oppProdMSA = determineOpportunityProducts(oppProductsMapMSA);
		List<OpportunityLineItem> oppProdPPF = determineOpportunityProducts(oppProductsMapPPF);
		List<OpportunityLineItem> newOppProductsList = new List<OpportunityLineItem>();
		List<OpportunityLineItem> oppProductsToDelete = new List<OpportunityLineItem>();
		List<OpportunityLineItem> oppProductsToInsert = new List<OpportunityLineItem>();
		
		newOppProductsList.addAll(oppProdMSA);
		newOppProductsList.addAll(oppProdPPF);
		
		//create a Map of Product + Station__c to OpportunityLineItem for both lists
		Map<String, OpportunityLineItem> mapForNewList = createPSToOppProductMap(newOppProductsList);
		Map<String, OpportunityLineItem> mapForOldList = createPSToOppProductMap(existingOppProductsList);

		for (OpportunityLineItem oli : existingOppProductsList)
		{
			//If there’s an existing Opportunity Product record that shouldn’t exist, then 
			//delete the Opportunity Product record.
			if (!mapForNewList.containsKey(String.valueOf(oli.PricebookEntryId) + String.valueOf(oli.Station__c)))
			{
				oppProductsToDelete.add(oli);
			}					
		}
		if (oppProductsToDelete.size()>0) delete oppProductsToDelete;
		
		for (OpportunityLineItem oli : newOppProductsList)
		{
			//if there’s an Opportunity Product record that should be created, then create a new Opportunity Product record
			if (!mapForOldList.containsKey(String.valueOf(oli.PricebookEntryId) + String.valueOf(oli.Station__c)))
			{
				oppProductsToInsert.add(oli);
			}					
		}
				
		if (oppProductsToInsert.size()>0) insert oppProductsToInsert;
	}	
	
	public static Map<String, OpportunityLineItem> createPSToOppProductMap(List<OpportunityLineItem> oppProductList)
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
	
	public static void removeOppOverrides(Opportunity op)
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
	
	public static void removeNprProdOverrides(Opportunity op)
	{
		//Update the following field values on all NPR Product records to NULL:
		//get existing NPR Products for the Opportunity	
		List<NPR_Product__c> nprProductsList = [select Id, Opportunity_Name__c, Override_Discount__c, Override_Discount_Comments__c, Override_Fee__c, Override_Fee_Comments__c, Accelerated_Cap__c, Accelerated_Cap_Comments__c from NPR_Product__c where Opportunity_Name__c =: op.Id];
		for (NPR_Product__c nprProd : nprProductsList)
		{
			nprProd.Override_Discount__c = null;
			nprProd.Override_Discount_Comments__c = null;
			nprProd.Override_Fee__c = null;
			nprProd.Override_Fee_Comments__c = null;
			nprProd.Accelerated_Cap__c = null;
			nprProd.Accelerated_Cap_Comments__c = null;
		}
		
		update nprProductsList;
	}
	
	public static void removeOppProdOverrides(Opportunity op)
	{	
		//Update the following field values on all Opportunity Product records to NULL:
		//get existing Opportunity Products for the Opportunity	
		List<OpportunityLineItem> existingOppProductsList = [select Id, OpportunityId from OpportunityLineItem where OpportunityId =: op.Id];
		
		for (OpportunityLineItem oli : existingOppProductsList)
		{
			oli.Override_Fee__c = null;
			oli.Override_Fee_Comments__c = null;
		}
		
		update existingOppProductsList;					
	} */
}