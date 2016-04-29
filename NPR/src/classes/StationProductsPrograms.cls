public with sharing class StationProductsPrograms 
{
	public static void handleInsert(Station_Products_Programs__c[] newSPPs)
	{
		list<Air_Onboard_History__c> adoptionHistoryRecsToInsert = new list<Air_Onboard_History__c>();
		map<String, Air_Onboard_History__c> sppToAHMap = new map<String, Air_Onboard_History__c>();
		
		for (Station_Products_Programs__c spp : newSPPs)
		{
			if (spp.Air_Onboard_Status__c == 'Complete' && spp.Active_Air_Onboard_History__c==null)
			{
				Air_Onboard_History__c ah = new Air_Onboard_History__c();
				
				ah.Air_Onboard_Status__c = 'Active'; 
				ah.Start_Date__c = spp.Start_Date__c;
				ah.Bill_Start_Date__c = spp.Bill_Start_Date__c;
				ah.Station_Products_Programs__c = spp.Id;
							
				adoptionHistoryRecsToInsert.add(ah);
				sppToAHMap.put(spp.Id, ah);					
			}
		}
		
		if (adoptionHistoryRecsToInsert.size()>0) 
		{
			insert adoptionHistoryRecsToInsert;
			
			list<Station_Products_Programs__c> sPPsToUpdate = querySPPs(sppToAHMap.keySet());
			
			//Set Active_Air_Onboard_History__c Lookup on Station_Products_Programs__c
			for(Station_Products_Programs__c spp : sPPsToUpdate)
			{
				if (sppToAHMap.containsKey(spp.Id))
				{
					spp.Active_Air_Onboard_History__c = sppToAHMap.get(spp.Id).Id;     
				}			
			}
							
			update sPPsToUpdate;
		} 
	}	

	public static void handleUpdate(Station_Products_Programs__c[] newSPPs, Station_Products_Programs__c[] oldSPPs)
	{
		list<Air_Onboard_History__c> adoptionHistoryRecsToInsert = new list<Air_Onboard_History__c>();		
		map<String, Air_Onboard_History__c> sppToAHMap = new map<String, Air_Onboard_History__c>();
		map<String, Station_Products_Programs__c> ahToSppMap = new map<String, Station_Products_Programs__c>();
	
		for (Integer i=0; i < newSPPs.size(); i++)
		{
			if (newSPPs[i].Air_Onboard_Status__c == 'Complete' && oldSPPs[i].Air_Onboard_Status__c != 'Complete' && newSPPs[i].Active_Air_Onboard_History__c == oldSPPs[i].Active_Air_Onboard_History__c)
			{
				Air_Onboard_History__c ah = new Air_Onboard_History__c();
				
				ah.Air_Onboard_Status__c = 'Active'; 
				ah.Start_Date__c = newSPPs[i].Start_Date__c;
				ah.Bill_Start_Date__c = newSPPs[i].Bill_Start_Date__c;
				ah.Station_Products_Programs__c = newSPPs[i].Id;
				
				adoptionHistoryRecsToInsert.add(ah);
				sppToAHMap.put(newSPPs[i].Id, ah);					
			}
			
			if ((newSPPs[i].Air_Onboard_Status__c == 'Dropped' && oldSPPs[i].Air_Onboard_Status__c != 'Dropped' && newSPPs[i].Active_Air_Onboard_History__c!=null) ||
			    (newSPPs[i].Air_Onboard_Status__c == oldSPPs[i].Air_Onboard_Status__c && newSPPs[i].Active_Air_Onboard_History__c!=null && 
			     (newSPPs[i].Start_Date__c!=oldSPPs[i].Start_Date__c || newSPPs[i].Bill_Start_Date__c!=oldSPPs[i].Bill_Start_Date__c || newSPPs[i].End_Date__c!=oldSPPs[i].End_Date__c || newSPPs[i].Bill_End_Date__c!=oldSPPs[i].Bill_End_Date__c))) 
			{
				ahToSppMap.put(newSPPs[i].Active_Air_Onboard_History__c, newSPPs[i]);
			}
				
		}
		
		if (adoptionHistoryRecsToInsert.size()>0) 
	    {
	      insert adoptionHistoryRecsToInsert;
	      
	      list<Station_Products_Programs__c> sPPsToUpdate = querySPPs(sppToAHMap.keySet());
	      
	      //Set Active_Air_Onboard_History__c Lookup on Station_Products_Programs__c
	      for(Station_Products_Programs__c spp : sPPsToUpdate)
	      {
	        if (sppToAHMap.containsKey(spp.Id))
	        {
	          spp.Active_Air_Onboard_History__c = sppToAHMap.get(spp.Id).Id;     
	        }      
	      }
	              
	      update sPPsToUpdate;
	    } 
	    
	    if (ahToSppMap.size()>0) 
		{
			list<Air_Onboard_History__c> ahToUpdate = queryAdoptionHistory(ahToSppMap.keySet());
			
			//Update Active Adoption History records
			for(Air_Onboard_History__c ah : ahToUpdate)
			{
				if (ahToSppMap.containsKey(ah.Id))
				{
					if (ahToSppMap.get(ah.Id).Air_Onboard_Status__c == 'Dropped')
					{
						ah.Air_Onboard_Status__c = 'Inactive';
						ah.Drop_Reason__c = ahToSppMap.get(ah.Id).Drop_Reason__c;
					}
					
					ah.End_Date__c = ahToSppMap.get(ah.Id).End_Date__c;					
					ah.Start_Date__c = ahToSppMap.get(ah.Id).Start_Date__c;
					ah.Bill_Start_Date__c = ahToSppMap.get(ah.Id).Bill_Start_Date__c;	
					ah.Bill_End_Date__c = ahToSppMap.get(ah.Id).Bill_End_Date__c;					 				    
				}			
			}
	
			update ahToUpdate;	
			
		} 
	    
	}

	public static list<Station_Products_Programs__c> querySPPs(Set<String> sppIds)
	{
		return [select Id, Air_Onboard_Status__c, Active_Air_Onboard_History__c from Station_Products_Programs__c where Id IN :sppIds];
	}
	
	public static list<Air_Onboard_History__c> queryAdoptionHistory(Set<String> ahIds)
	{
		return [select Id, Air_Onboard_Status__c, Start_Date__c, Drop_Reason__c, End_Date__c, Bill_Start_Date__c from Air_Onboard_History__c where Id IN :ahIds];
	} 
}