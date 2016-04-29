/**
*	Description: A Helper class for the UpdateOpportunityProduct class 
*
*   Initial Draft          Author                   Date
*   Version 1.0 		  Dhirendra               5/8/2014
**/

public with sharing class UpdateOpportunityProductHandlerHelper {

    /** 
    *  A method that returns list of the SPP records which are not mapped with any of the 
    *  OpportunityLineItem
    **/ 
	public Map<Id,List<Station_Products_Programs__c>> getOpportunityRelatedSSPRec(Set<Id> pSetOpportunityStation, set<String> pSetOpportunityProduct){
		
		system.debug('\n\n pSetOpportunityStation = '+pSetOpportunityStation+'\n\n');
		system.debug('\n\n pSetOpportunityProduct = '+pSetOpportunityProduct+'\n\n');
		
		Map<Id,List<Station_Products_Programs__c>> mapStationProductsPgm = new Map<Id,List<Station_Products_Programs__c>>();
		for(Station_Products_Programs__c objStation: [Select Station_Products_Programs__c.Product_Program_Name__c,
															 Station_Products_Programs__c.Station__c
													  From Station_Products_Programs__c 
													  Where Product_Program_Name__c IN:pSetOpportunityProduct
													  AND  Station__c IN:pSetOpportunityStation
													  Order by Station_Products_Programs__c.CreatedDate Desc]){
			  if(mapStationProductsPgm <> null && mapStationProductsPgm.containsKey(objStation.Station__c)){
			  	   mapStationProductsPgm.get(objStation.Station__c).add(objStation);
			  }else{
			  	mapStationProductsPgm.put(objStation.Station__c,new List<Station_Products_Programs__c>{objStation});
			  }
		}
		
		if(mapStationProductsPgm != null){
			return mapStationProductsPgm;
		}
		return null;
	}
}