/*
*    Description : ApexClass which is invokded from OpportunityTriggerHandler on Opportunity trigger event AfterUpdate
*                  The functionality updates the related OpportunityProduct records and creates SP & P records subject to 
*                  meeting the given conditions     
*
*    Version            Date                Author                Description
*    
*    1.0                05/06/2014          Siddharth Birari      Initial Draft
*	 1.1                07/10/2014          Andrew Mann			  Update UpdateOpportunityProductSppRecs method
*/

public class UpdateOpportunityProduct {
	

    private static Boolean blnIsExecuted = false; 

    List<Opportunity> listOldOpportunity = new List<Opportunity>();
    List<Opportunity> listNewOpportunity = new List<Opportunity>();
    List<OpportunityLineItem> listOpportunityLineItem = new List<OpportunityLineItem>();
    
    Set<String> setOpportunityProductId = new Set<String>();
    Set<Id> setOpportunityStation = new Set<Id>();
    
    //Mehtod gets invokded through OpportunityTriggerHandler on 'AfterUpdate' event of Opportunity
    //Method updates the related Opportunity records
    public void updateOpportunityProductRecords(Map<Id, Opportunity> pMapOldOpportunity, Map<Id, Opportunity> pMapNewOpportunity){
       if(test.isRunningTest()){
       		blnIsExecuted = false;
       }
        if(!blnIsExecuted){
            Map<Id,Opportunity> MapUpdateOpportunity = new Map<Id,Opportunity>();
            Map<Id,OpportunityLineItem> MapUpdateOpportunityLineItem = new Map<Id,OpportunityLineItem>();
            Map<Id,List<Station_Products_Programs__c>> MapUpdateStationProgram = new Map<Id,List<Station_Products_Programs__c>>();
            listNewOpportunity = pMapNewOpportunity.values();
            //fetch the records which satisfies the given requirement
            for(Opportunity objOpportunity:pMapOldOpportunity.values()){
            	if(pMapNewOpportunity.get(objOpportunity.Id).IsWon == true && objOpportunity.IsWon == false){
            	   MapUpdateOpportunity.put(objOpportunity.Id,objOpportunity);
            	}
            		
            }
            
            //If at least one Opportunity is being updated
            if((!listNewOpportunity.isEmpty()) && MapUpdateOpportunity != null){
            
            	system.debug('\n\n MapUpdateOpportunity.keySet()='+MapUpdateOpportunity.keySet()+'\n\n');
                
                for(OpportunityLineItem objOppLineItem:[select Id,Fiscal_Year__c,SPP__c,Station__c,PricebookEntry.Product2Id, OpportunityId
                                           from OpportunityLineItem 
                                           where OpportunityId IN : MapUpdateOpportunity.keySet()
                                           ]){
                     if(((system.today().month() >= 10 && system.today().month()<= 12) && 
                     								((objOppLineItem.Fiscal_Year__c -1)  == system.today().year()))
                     	 ||((system.today().month() >= 1 && system.today().month()<= 9) && 
                     								(objOppLineItem.Fiscal_Year__c  == system.today().year()))){
                     			MapUpdateOpportunityLineItem.put(objOppLineItem.Id,objOppLineItem);
                     			setOpportunityProductId.add(objOppLineItem.PricebookEntry.Product2Id);
                     			setOpportunityStation.add(objOppLineItem.Station__c);
                     		}//if ends                   	
                     }// for ends
            }// if ends
            
            UpdateOpportunityProductHandlerHelper objHelper = new UpdateOpportunityProductHandlerHelper();
            MapUpdateStationProgram = objHelper.getOpportunityRelatedSSPRec(setOpportunityStation, setOpportunityProductId);
            system.debug('\n\n MapUpdateStationProgram'+MapUpdateStationProgram+'\n\n');
            UpdateOpportunityProductSppRecs(MapUpdateOpportunityLineItem,MapUpdateStationProgram);
            
            //Set blnIsExecuted = true to ensure that the trigger would execute only once
            blnIsExecuted = true;    
        }
    }
    
    /** 
    * 	A method to which the maps of opportunitylineItem and map of spp records having the same station id 
    *   and product id as that of opportunitylineItem have been passed down as parameters which associates 
    *   the spp with tht OpportunityLineItems
    **/
    public void UpdateOpportunityProductSppRecs(Map<Id,OpportunityLineItem> pMapUpdateOppLineItem, Map<Id,List<Station_Products_Programs__c>> pMapStationProductsPgm)
    {
    	//List<OpportunityLineItem> lstOppLineItemtobeUpdated = new List<OpportunityLineItem>();
    	map<String, OpportunityLineItem> oliUpdateMap = new map<String, OpportunityLineItem>();	
    	//list<Station_Products_Programs__c> lstSpp = new list<Station_Products_Programs__c>();
    	map<String, Station_Products_Programs__c> oliIdSppMap = new map<String, Station_Products_Programs__c>{};
    	
    	system.debug('\n\n pMapUpdateOppLineItem.values : '+pMapUpdateOppLineItem.values()+'\n\n');
    	system.debug('\n\n pMapStationProductsPgm : '+pMapStationProductsPgm+'\n\n');
    	for(OpportunityLineItem objLineItem:pMapUpdateOppLineItem.values())
    	{	
    	    if(pMapStationProductsPgm != null && pMapStationProductsPgm.containsKey(objLineItem.Station__c))
    	    {
    	   		for(Station_Products_Programs__c objSpp:pMapStationProductsPgm.get(objLineItem.Station__c))
    	    	{
    	    		//system.debug('\n\n Matching : '+objLineItem.PricebookEntry.Product2Id + ' ; ' + objspp.Product_Program_Name__c +'\n\n');
    	    		if(objLineItem.PricebookEntry.Product2Id == objspp.Product_Program_Name__c )
    		   		{
    		   			objLineItem.SPP__c = objspp.Id;	
    		   			system.debug('\n\n'+oliUpdateMap.containsKey(objLineItem.Id)+'\n\n');
    		   			oliUpdateMap.put(objLineItem.Id, objLineItem);
    		   			//lstOppLineItemtobeUpdated.add(objLineItem);
    		   		}
    		   	}
    		   	if(objLineItem.SPP__c == NULL)
    		   	{
    		    	Station_Products_Programs__c objStation = new Station_Products_Programs__c();
			    	objStation.Product_Program_Name__c = objLineItem.PricebookEntry.Product2Id;
			    	objStation.Station__c = objLineItem.Station__c;
			    			   		    
			    	//lstSpp.add(objStation);
			    	oliIdSppMap.put(objLineItem.Id, objStation);
			    	/*try{
			    		insert objStation;
			    	}Catch(Exception ex){
			    		system.debug('Exception******'+ex);
			    	}*/
			    	//objLineItem.SPP__c = objStation.Id;
    		    }		
			}
    		else
    		{
				Station_Products_Programs__c objStation = new Station_Products_Programs__c();
			    objStation.Product_Program_Name__c = objLineItem.PricebookEntry.Product2Id;
			    objStation.Station__c = objLineItem.Station__c;
			    //lstSpp.add(objStation);
			    oliIdSppMap.put(objLineItem.Id, objStation);
			    /*try{
    			   	insert objStation;
    			}Catch(Exception ex){
    				system.debug('Exception******'+ex);
    			}*/
    			//objLineItem.SPP__c = objStation.Id;
			}
    		objLineItem.Opportunity_Completed_Date__c  = system.today();	 
    		//lstOppLineItemtobeUpdated.add(objLineItem);	
    	}
    	
    	if(oliIdSppMap!=null && oliIdSppMap.size()>0)
    	{
    		insert oliIdSppMap.values();
    		for(OpportunityLineItem objLineItem:pMapUpdateOppLineItem.values())
    		{
    			if(oliIdSppMap.get(objLineItem.Id)!=null)
    			{
    				objLineItem.SPP__c = oliIdSppMap.get(objLineItem.Id).Id;
    				//lstOppLineItemtobeUpdated.add(objLineItem);
    				if(oliUpdateMap.containsKey(objLineItem.Id))
    				{
    					oliUpdateMap.remove(objLineItem.Id);
    					oliUpdateMap.put(objLineItem.Id, objLineItem);
    				}
    				else
    				{
    					oliUpdateMap.put(objLineItem.Id, objLineItem);
    				}
    			}
    		}
    	}
    	
    	if(oliUpdateMap != null && oliUpdateMap.size() > 0)
    	{								 
    		update oliUpdateMap.Values();
    	}
    }
}