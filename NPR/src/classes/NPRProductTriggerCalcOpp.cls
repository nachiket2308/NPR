public class NPRProductTriggerCalcOpp {

	public void calcOpp(set<String> OppIds)
	{
		list<NPR_Product__c> nprList = [select Id, Name, Include_in_PPF_MSA__c, Final_Fee__c, Opportunity_Name__c from NPR_Product__c 
			where Opportunity_Name__c IN: OppIds order by Opportunity_Name__c];
		
		Boolean firstTime = true;
		string lastOppId;
		list<NPR_Product__c> nprs = new list<NPR_Product__c>{};
		map<String, list<NPR_Product__c>> oppIdNPRMap = new map<String, list<NPR_Product__c>>{};
		for(NPR_Product__c npr : nprList)
		{
			if(firstTime)
			{
				firstTime = false;
				lastOppId = npr.Opportunity_Name__c;
			}
			if(lastOppId != npr.Opportunity_Name__c)
			{
				oppIdNPRMap.put(lastOppId, nprs);
				nprs = new list<NPR_Product__c>{};
			}
			nprs.add(npr);
			lastOppId = npr.Opportunity_Name__c;
		}	
		oppIdNPRMap.put(lastOppId, nprs);
		
			
		//system.debug('*******\n\n'+oppIds+'\n\n*********');
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, Sub_Total_Price__c, Total_Override__c, Sub_Total_Price_2__c, Discount__c,
			Admin_Fee_Override__c, Total_Contract_Price__c from Opportunity where Id IN:oppIds]);
		//system.debug('*******\n\n'+oppMap+'\n\n*********');
		
		list<Opportunity> oppsToUpdate = new list<Opportunity>{};
		for(String oppId : OppIds)
		{
			PricingUtility pu = new PricingUtility();
			//system.debug('*******\n\n'+oppMap.get(OppId)+'\n\n*********');
			oppsToUpdate.add(pu.calcOpportunity(oppMap.get(OppId), oppIdNPRMap.get(oppId)));
		}
		
		update oppsToUpdate;
	}

}