/** 
* A trigger to update "OpportunityLineItem" and Populate field of SPP related to update OpportunityLineItem 
*
*    Initial Draft          Author              Date
*    version 1.0            Gaurav              7/5/2014
*
**/
public with sharing class PopulateSPPFields {
	
	//final varaibles
	private static final String INSERT_TRIGGER = 'Insert';
	private static final String UPDATE_TRIGGER = 'Update';
	private static final String COMPLETE_ONBOARD_STATUS = 'Complete';
	private static final String DROPPED_ONBOARD_STATUS = 'Dropped';
	
	//Populdate SPP Field when OpportunityLineItem updated
    public void populateSPPFieldInfo(List<OpportunityLineItem> pLstOpportunityLineItem, 
    	                                            Map<Id,OpportunityLineItem> pOldMapIdToOpportunityLineItem, String strTrigger){
        
        Map<Id, OpportunityLineItem> mapIdToOpportunityLineItem = new Map<Id, OpportunityLineItem>();
        List<Station_Products_Programs__c> lstStationProductProgram = new List<Station_Products_Programs__c>();
        List<Station_Products_Programs__c> lstUdpateSPP = new List<Station_Products_Programs__c>();
        List<OpportunityLineItem> lstUdpateOpportunityLineItem = new  List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOpportunityLineItem  = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOpportunityLineItemNextFY = new List<OpportunityLineItem>();
        Map<Decimal, OpportunityLineItem> mapFiscalyearToOpportunityLineItem = new Map<Decimal, OpportunityLineItem>();
        Set<Id> setOpportunityLineItemId =  new Set<Id>();
        Set<Decimal> setIntFiscalYear = new Set<Decimal>();
    	Set<Id> setProductId = new Set<Id>();
    	Set<Id> setStationId = new Set<Id>();
        Map<Id, Product2> mapIdToProduct = new Map<Id, Product2>();
        
        OpportunityProductTriggerHandlerHelper objOpportunityProductTriggerHandlerHelper = 
       		    new OpportunityProductTriggerHandlerHelper();
       	
        //if List is Empty then Return
        if((pLstOpportunityLineItem.isEmpty() && pOldMapIdToOpportunityLineItem.isEmpty() && strTrigger.equalsIgnoreCase(UPDATE_TRIGGER))
        	|| (pLstOpportunityLineItem.isEmpty() && strTrigger.equalsIgnoreCase(INSERT_TRIGGER)) )  
       	    return;
       	    
        for(OpportunityLineItem  objOpportunityLineItem: pLstOpportunityLineItem){
       		
       		setOpportunityLineItemId.add(objOpportunityLineItem.Id);
       	} 
       	
       	//Validate Opportunity Line Item with null check condition
       	if(setOpportunityLineItemId != null){
       	    
       	    lstOpportunityLineItem = objOpportunityProductTriggerHandlerHelper.getLstOpportunityLineItem(setOpportunityLineItemId);
       	   
       	   	// Get all Opportunity Line Item with validate
       	    if(strTrigger.equalsIgnoreCase(UPDATE_TRIGGER)){  
                lstOpportunityLineItem = validateOpportunityLineItemlist(lstOpportunityLineItem);
       	    }
       	    
       		if(lstOpportunityLineItem != null && !lstOpportunityLineItem.isEmpty())	
	       	for(OpportunityLineItem  objOpportunityLineItem: lstOpportunityLineItem){
	       		
	       		setProductId.add(objOpportunityLineItem.PricebookEntry.Product2Id);
	       	} 
            mapIdToProduct = new Map<Id, Product2>([Select Id,Name, MSA_Bundle__c From Product2 Where Id IN: setProductId]);
       	}
       	
        if(lstOpportunityLineItem != null && !lstOpportunityLineItem.isEmpty()){  
        	
        	Date todayDate = Date.today();
        	
	        for(OpportunityLineItem objOpportunityLineItem : lstOpportunityLineItem){
      
      	        if(strTrigger.equalsIgnoreCase(UPDATE_TRIGGER)){
      	        	
      	        	//Compare old values of OpportunityLineItem with new value 
	            	if(!pOldMapIdToOpportunityLineItem.isEmpty() && pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id) != null && 
	            	    (objOpportunityLineItem.Adopt_Status__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Adopt_Status__c ||
	            	    objOpportunityLineItem.Adopt_Date__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Adopt_Date__c ||
	            	    objOpportunityLineItem.Air_Onboard_Status__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Air_Onboard_Status__c ||
	            	    objOpportunityLineItem.Air_Onboard_Date__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Air_Onboard_Date__c || 
	            	    objOpportunityLineItem.Air_Onboard_Date__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Air_Onboard_Date__c ||
	            	    objOpportunityLineItem.Drop_Date__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Drop_Date__c || 
	            	    objOpportunityLineItem.Drop_Reason__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Drop_Reason__c ||
	            	    objOpportunityLineItem.Bill_Start_Date__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Bill_Start_Date__c ||
	            	    objOpportunityLineItem.Bill_End_Date__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Bill_End_Date__c ||
	            	    objOpportunityLineItem.Opportunity_Completed_Date__c != pOldMapIdToOpportunityLineItem.get(objOpportunityLineItem.Id).Opportunity_Completed_Date__c) &&
	            	    objOpportunityLineItem.Opportunity.IsWon == true && objOpportunityLineItem.SPP__c != null && 
	            	    (todayDate.month() >= 10 && todayDate.year() == (objOpportunityLineItem.Fiscal_Year__c -1) ||
	            	    todayDate.month() <= 9 && todayDate.year() == objOpportunityLineItem.Fiscal_Year__c)){
	            	    	
	            	        mapIdToOpportunityLineItem.put(objOpportunityLineItem.SPP__c, objOpportunityLineItem);
	            	        
		            }
		            
		           if(mapIdToProduct!= null && !mapIdToProduct.isEmpty() &&
		           	   mapIdToProduct.get(objOpportunityLineItem.PricebookEntry.Product2Id) != null &&
		           	   mapIdToProduct.get(objOpportunityLineItem.PricebookEntry.Product2Id).MSA_Bundle__c == false &&
		               objOpportunityLineItem.Opportunity.Type == 'MSA' ){	
		               	
		            	mapFiscalyearToOpportunityLineItem.put(objOpportunityLineItem.Fiscal_Year__c,objOpportunityLineItem );
		            	setIntFiscalYear.add(objOpportunityLineItem.Fiscal_Year__c + 1);
		            	setProductId.add(objOpportunityLineItem.PricebookEntry.Product2Id);
		            	setStationId.add(objOpportunityLineItem.Station__c);
		            }
		            
      	        }
	        }//End For 
	        
	        if(setIntFiscalYear != null && !setIntFiscalYear.isEmpty() 
	            && setProductId != null  && !setProductId.isEmpty()
	            && setStationId != null && !setStationId.isEmpty()){
	        	 lstOpportunityLineItemNextFY = 
	        	    getOpportunityLineItemlist(setIntFiscalYear,setProductId,setStationId);
	        }
	        
        }
         
        //Get all next year Opportunity Product and popualte value in the field  of next year Opportunity Product   
        if(lstOpportunityLineItemNextFY != null && !lstOpportunityLineItemNextFY.isEmpty() ) {
            for(OpportunityLineItem objOpportunityLineItem : lstOpportunityLineItemNextFY){
            	
            	OpportunityLineItem objPreviousOpportunityLineItem = 
            		mapFiscalyearToOpportunityLineItem.get(objOpportunityLineItem.Fiscal_Year__c -1); 
            	
            	if (objPreviousOpportunityLineItem.Air_Onboard_Status__c != null && 
            		    objPreviousOpportunityLineItem.Air_Onboard_Status__c.equalsIgnoreCase(COMPLETE_ONBOARD_STATUS)){
					    objOpportunityLineItem.Adopt_Status__c = objPreviousOpportunityLineItem.Adopt_Status__c;
					    objOpportunityLineItem.Adopt_Date__c = objPreviousOpportunityLineItem.Adopt_Date__c;
					    objOpportunityLineItem.Air_Onboard_Status__c = objPreviousOpportunityLineItem.Air_Onboard_Status__c;
					    objOpportunityLineItem.Air_Onboard_Date__c = objPreviousOpportunityLineItem.Air_Onboard_Date__c;
					    objOpportunityLineItem.Drop_Date__c = objPreviousOpportunityLineItem.Drop_Date__c;
					    objOpportunityLineItem.Drop_Reason__c = objPreviousOpportunityLineItem.Drop_Date__c != null ? objPreviousOpportunityLineItem.Drop_Reason__c :'';
					
            	}
				else if (objPreviousOpportunityLineItem.Air_Onboard_Status__c != null && 
						objPreviousOpportunityLineItem.Air_Onboard_Status__c.equalsIgnoreCase(DROPPED_ONBOARD_STATUS)){
						objOpportunityLineItem.Adopt_Status__c = NULL;
						objOpportunityLineItem.Adopt_Date__c = NULL;
						objOpportunityLineItem.Air_Onboard_Status__c = NULL;
						objOpportunityLineItem.Air_Onboard_Date__c = NULL;
						objOpportunityLineItem.Drop_Date__c = NULL;
						objOpportunityLineItem.Drop_Reason__c = NULL;
				}		
				else{
				        objOpportunityLineItem.Adopt_Status__c = objPreviousOpportunityLineItem.Adopt_Status__c;
				        objOpportunityLineItem.Adopt_Date__c = objPreviousOpportunityLineItem.Adopt_Date__c;
				}
				
				//Get all Next year opportunity Product
				lstUdpateOpportunityLineItem.add(objOpportunityLineItem);
            }
        	
        } 
        
        //Get SPP Record from Opportunity Product  
        if(!mapIdToOpportunityLineItem.isEmpty() && mapIdToOpportunityLineItem.keySet() != null)
            lstStationProductProgram = objOpportunityProductTriggerHandlerHelper.getSPPlist(mapIdToOpportunityLineItem.keySet());
         
        if(lstStationProductProgram != null && !lstStationProductProgram.isEmpty()){    
	        for(Station_Products_Programs__c objSPP : lstStationProductProgram){
	    	
	    	    OpportunityLineItem objOpportunityLineItem = mapIdToOpportunityLineItem.get(objSPP.Id);
	        	if(objOpportunityLineItem != null){
	        	    	
	                    objSPP.Adopt_Status__c = objOpportunityLineItem.Adopt_Status__c;
						objSPP.Adopt_Date__c = objOpportunityLineItem.Adopt_Date__c;
						objSPP.Air_Onboard_Status__c = objOpportunityLineItem.Air_Onboard_Status__c;
						if(objOpportunityLineItem.Air_Onboard_Status__c != null){
						
							if(objOpportunityLineItem.Air_Onboard_Status__c.equalsIgnoreCase(COMPLETE_ONBOARD_STATUS)){
								
						            objSPP.Bill_Start_Date__c = objOpportunityLineItem.Bill_Start_Date__c;
						            objSPP.Start_Date__c = objOpportunityLineItem.Air_Onboard_Date__c;
							}
							
							if(objOpportunityLineItem.Air_Onboard_Status__c.equalsIgnoreCase(DROPPED_ONBOARD_STATUS)){
								
						            objSPP.Bill_End_Date__c = objOpportunityLineItem.Bill_End_Date__c;
						            objSPP.End_Date__c = objOpportunityLineItem.Drop_Date__c;
						            objSPP.Drop_Reason__c = objOpportunityLineItem.Drop_Reason__c;    
							}
						}
					    
					    lstUdpateSPP.add(objSPP);
	        	}
		    }//End for
        }
        
	    //Update SPP record related to Opportunity Product
	    if(!lstUdpateSPP.isEmpty())
	        upsert lstUdpateSPP;
	        
	    //Update Nextyear OpportunityProduct record   
	    if(Utility.isFutureUpdate != true && !lstUdpateOpportunityLineItem.isEmpty()){
	    	Utility.isFutureUpdate = true;
	    	update lstUdpateOpportunityLineItem;
	    }
	    
	}
	
	//Get List of OpportunityLineItem Of Next Year 
	public List<OpportunityLineItem> getOpportunityLineItemlist( Set<Decimal> setIntFiscalYear , 
																 Set<Id> setProductId, 
																 Set<Id> setStationId){
				
		List<OpportunityLineItem> lstOpportunityLineItem  = [Select Id, 
																	Fiscal_year__c,
																	Opportunity.IsWon,
																	Opportunity.Type
															 From OpportunityLineItem
															 Where Opportunity.Fiscal_year__c IN: setIntFiscalYear
															 AND PricebookEntry.Product2Id IN: setProductId
															 AND Station__c IN: setStationId ];
		return 	lstOpportunityLineItem;												 
	}
	
	//Validate the all OpportunityLineItemList
	public List<OpportunityLineItem> validateOpportunityLineItemlist(List<OpportunityLineItem> pLstOpportunityLineItem){
		
		List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
		if(pLstOpportunityLineItem != null && !pLstOpportunityLineItem.isEmpty())
		{
			for(OpportunityLineItem objOpportunityLineItem : pLstOpportunityLineItem){
				
				if(objOpportunityLineItem != null && 
				   (objOpportunityLineItem.Adopt_Status__c != null  ||
					objOpportunityLineItem.Adopt_Date__c != null  ||
					objOpportunityLineItem.Air_Onboard_Status__c != null  ||
					objOpportunityLineItem.Air_Onboard_Date__c != null  ||
					objOpportunityLineItem.Drop_Date__c != null  ||
					objOpportunityLineItem.Drop_Reason__c != null  ||
					objOpportunityLineItem.Bill_Start_Date__c != null  ||
					objOpportunityLineItem.Bill_End_Date__c != null )){
					
					lstOpportunityLineItem.add(objOpportunityLineItem);
				}
			}
		}
		
		//Return List of NPR Product
		if(!lstOpportunityLineItem.isEmpty())
		    return lstOpportunityLineItem;
		return null;
	}
}//End populateSPPFieldInfo