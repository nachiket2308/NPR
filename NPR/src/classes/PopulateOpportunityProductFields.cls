/** 
* A trigger to update "NPR_Product__c" and Populate field of OpportunityLineItem related to update NPR Product 
*
*    Initial Draft          Author              Date
*    version 1.0            Gaurav              6/5/2014
*
**/
public with sharing class PopulateOpportunityProductFields {
	
	//final varaibles
	private static final String PRODUCTFAMILY_PPF = 'PPF';
	private static final String PRODUCTFAMILY_MSA = 'MSA';
                                
    public void populateOpportunityProductFieldInfo(List<NPR_Product__c> pLstNPRProduct, 
    	                                            Map<Id,NPR_Product__c> pOldMapIdToNPRProduct){
        
        List<OpportunityLineItem> lstUdpateOpportunityLineItem = new  List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        Map<Id, NPR_Product__c> mapIdToNPRProduct = new Map<Id, NPR_Product__c>();
        Set<Id> setNPRProductId = new Set<Id>();
        Set<Id> setNPRNextNPRProductId = new Set<Id>();
        List<NPR_Product__c> lstNPRProduct = new List<NPR_Product__c>();
        List<NPR_Product__c> lstNPRProductUpdate = new List<NPR_Product__c>();
        List<NPR_Product__c> lstNextFYNPRProduct = new List<NPR_Product__c>();
        Map<Id, NPR_Product__c> mapNextNPRProductIdToNPRProduct = new Map<Id, NPR_Product__c>();
        NPRProductTriggerHandlerHelper objNPRProductTriggerHandlerHelper= new NPRProductTriggerHandlerHelper();
        
        //if List is Empty then Return
        if(pLstNPRProduct.isEmpty() || pOldMapIdToNPRProduct.isEmpty())  
       	    return;
       	    
       	//Collect all Set of NPR Product Id
       	for(NPR_Product__c objNPRProduct : pLstNPRProduct){
       		
       	    setNPRProductId.add(objNPRProduct.Id);
       	    
       	    //Collect Next FY NPR Product
       	    if(objNPRProduct.Next_FY_NPR_Product__c != null)
       	       setNPRNextNPRProductId.add(objNPRProduct.Next_FY_NPR_Product__c);
       	}    
       	
       	if(setNPRNextNPRProductId != null){
       		//Get all NextFY NPR Product
       		lstNextFYNPRProduct = 
       				objNPRProductTriggerHandlerHelper.getNPRProductlist(setNPRNextNPRProductId);  
       	}
       	
       	//Get all NextFY NPR Product In Map
       	if(lstNextFYNPRProduct != null && !lstNextFYNPRProduct.isEmpty()){
       		
	       	for(NPR_Product__c objNPRProduct : lstNextFYNPRProduct){
	       		mapNextNPRProductIdToNPRProduct.put(objNPRProduct.Id, objNPRProduct);
	       	}
       	}
       	
       	if(setNPRProductId != null){
       		
       		//Populate the NPR Product and validate the null check condtion
       	    lstNPRProduct = objNPRProductTriggerHandlerHelper.getNPRProductlist(setNPRProductId);  
       	    lstNPRProduct = validateNPRProductlist(lstNPRProduct); 
       	}
       	
        if(lstNPRProduct != null && !lstNPRProduct.isEmpty()){  
        	
        	Date todayDate = Date.today();
        	
	        for(NPR_Product__c objNPRProduct : lstNPRProduct){
	        
	        	objNPRProduct.Fiscal_Year__c  = objNPRProduct.Fiscal_Year__c != null ? objNPRProduct.Fiscal_Year__c : 0;
	            if(objNPRProduct!= null && objNPRProduct.Product__r.Family!= null && 
	                ((objNPRProduct.Product__r.Family.equalsIgnoreCase(PRODUCTFAMILY_PPF)) ||
	                 ((objNPRProduct.Product__r.Family.equalsIgnoreCase(PRODUCTFAMILY_MSA)) &&
	                   objNPRProduct.Product__r.MSA_Bundle__c == true)) ){
	               
	               	//Check the condition if the NPR field changes
	            	if(!pOldMapIdToNPRProduct.isEmpty() && pOldMapIdToNPRProduct.get(objNPRProduct.Id) != null && 
	            	    (objNPRProduct.Adopt_Status__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Adopt_Status__c ||
		            	    objNPRProduct.Adopt_Date__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Adopt_Date__c ||
		            	    objNPRProduct.Air_Onboard_Status__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Air_Onboard_Status__c ||
		            	    objNPRProduct.Air_Onboard_Date__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Air_Onboard_Date__c || 
		            	    objNPRProduct.Air_Onboard_Date__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Air_Onboard_Date__c ||
		            	    objNPRProduct.Drop_Date__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Drop_Date__c || 
		            	    objNPRProduct.Drop_Reason__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Drop_Reason__c ||
		            	    objNPRProduct.Bill_Start_Date__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Bill_Start_Date__c ||
		            	    objNPRProduct.Bill_End_Date__c != pOldMapIdToNPRProduct.get(objNPRProduct.Id).Bill_End_Date__c)  && 
		            	    (todayDate.month() >= 10 && todayDate.year() == (objNPRProduct.Fiscal_Year__c -1) ||
		            	    todayDate.month() <= 12 && todayDate.year() == objNPRProduct.Fiscal_Year__c)){
	            	   
	            	        mapIdToNPRProduct.put(objNPRProduct.Id, objNPRProduct);
	            	   }
	            }
            }//End For 
        }
        
        //Populate the Opportunity Product 
        if(!mapIdToNPRProduct.isEmpty()){
            lstOpportunityLineItem = 
                objNPRProductTriggerHandlerHelper.getLstOpportunityLineItem(mapIdToNPRProduct); 
        }    
        if(lstOpportunityLineItem != null && !lstOpportunityLineItem.isEmpty()){    
	        for(OpportunityLineItem objOpportunityLineItem : lstOpportunityLineItem){
	        	
	        	if(!mapIdToNPRProduct.isEmpty() && mapIdToNPRProduct.get(objOpportunityLineItem.NPR_Product__c) != null ){
	        		
                    NPR_Product__c objNPRProduct = mapIdToNPRProduct.get(objOpportunityLineItem.NPR_Product__c);
                    if(objNPRProduct != null){
                    	
		                objOpportunityLineItem.Adopt_Status__c = objNPRProduct.Adopt_Status__c;
						objOpportunityLineItem.Adopt_Date__c = objNPRProduct.Adopt_Date__c;
					    objOpportunityLineItem.Air_Onboard_Status__c = objNPRProduct.Air_Onboard_Status__c;
					    objOpportunityLineItem.Air_Onboard_Date__c = objNPRProduct.Air_Onboard_Date__c;
					    objOpportunityLineItem.Drop_Date__c = objNPRProduct.Drop_Date__c;
					    objOpportunityLineItem.Drop_Reason__c = objNPRProduct.Drop_Reason__c;
					    objOpportunityLineItem.Bill_Start_Date__c = objNPRProduct.Bill_Start_Date__c;
					    objOpportunityLineItem.Bill_End_Date__c = objNPRProduct.Bill_End_Date__c;
                    }
					
					lstUdpateOpportunityLineItem.add(objOpportunityLineItem);
	        	}
	        }//end for
        }
        
        set<id> oppIds = new set<id>();
        for(NPR_Product__c objNPRProduct :pLstNPRProduct)
        {
        	oppIds.add(objNPRProduct.Opportunity_Name__c);
        }
        
        map<id, opportunity> oppMap = new map<id, opportunity>([SELECT id, Type from opportunity where Id IN: oppIds]);
        
        for(NPR_Product__c objNPRProduct :pLstNPRProduct){
        	if(objNPRProduct.Next_FY_NPR_Product__c != NULL){
        		
        		//Get NextFYNPR Product
        		NPR_Product__c objNextNPRProduct = mapNextNPRProductIdToNPRProduct.get(objNPRProduct.Next_FY_NPR_Product__c);
        		
        		system.debug('\n\n updateNextFYNPRProductrecordHelper = '+updateNextFYNPRProductrecordHelper(objNPRProduct, oppMap)+'\n\n');
        		system.debug('\n\n objNPRProduct.Air_Onboard_Status__c = '+objNPRProduct.Air_Onboard_Status__c+'\n\n');
        		
        		// Drop Update:
        		if(updateNextFYNPRProductrecordHelper(objNPRProduct, oppMap) && 
        		  ((objNPRProduct.Air_Onboard_Status__c=='Dropped') || (objNPRProduct.Drop_Date__c>system.today() && pOldMapIdToNPRProduct.get(objNPRProduct.Id).Drop_Date__c==null)))
        		{
        			objNextNPRProduct.Adopt_Status__c = null;
					objNextNPRProduct.Adopt_Date__c = null;
					objNextNPRProduct.Air_Onboard_Status__c = null;
					objNextNPRProduct.Air_Onboard_Date__c = null;
					objNextNPRProduct.Drop_Date__c = null;
					objNextNPRProduct.Drop_Reason__c = null;
					objNextNPRProduct.Include_In_PPF_MSA__c = false;
        		}
        		// Add Update:
        		else if(updateNextFYNPRProductrecordHelper(objNPRProduct, oppMap) &&
        		       ((objNPRProduct.Air_Onboard_Status__c=='Complete') || (objNPRProduct.Air_Onboard_Date__c>system.today() && pOldMapIdToNPRProduct.get(objNPRProduct.Id).Air_Onboard_Date__c==null)))
        		{
        			objNextNPRProduct.Adopt_Status__c = objNPRProduct.Adopt_Status__c;
					objNextNPRProduct.Adopt_Date__c = objNPRProduct.Adopt_Date__c;
					objNextNPRProduct.Air_Onboard_Status__c = objNPRProduct.Air_Onboard_Status__c;
					objNextNPRProduct.Air_Onboard_Date__c = objNPRProduct.Air_Onboard_Date__c;
					objNextNPRProduct.Include_In_PPF_MSA__c = true;
        		}
        		else 
        		{
        			objNextNPRProduct.Adopt_Status__c = objNPRProduct.Adopt_Status__c;
					objNextNPRProduct.Adopt_Date__c = objNPRProduct.Adopt_Date__c;
					objNextNPRProduct.Air_Onboard_Status__c = objNPRProduct.Air_Onboard_Status__c;
        		}
        		
        		lstNPRProductUpdate.add(objNextNPRProduct);
        		
        		/*if(objNextNPRProduct != null){
        			
	        		objNextNPRProduct.Adopt_Status__c = objNPRProduct.Adopt_Status__c;
					objNextNPRProduct.Adopt_Date__c = objNPRProduct.Adopt_Date__c;
					objNextNPRProduct.Air_Onboard_Status__c = objNPRProduct.Air_Onboard_Status__c;
					objNextNPRProduct.Air_Onboard_Date__c = objNPRProduct.Air_Onboard_Date__c;
					objNextNPRProduct.Drop_Date__c = objNPRProduct.Drop_Date__c;
					objNextNPRProduct.Drop_Reason__c = objNPRProduct.Drop_Reason__c;
					objNextNPRProduct.Bill_Start_Date__c = objNPRProduct.Bill_Start_Date__c;
					objNextNPRProduct.Bill_End_Date__c = objNPRProduct.Bill_End_Date__c;
        			
        		    lstNPRProductUpdate.add(objNextNPRProduct);
        		}*/
        	}
        	
        }
        
        //Upate the Opportunity Product
        if(!lstUdpateOpportunityLineItem.isEmpty())
            update lstUdpateOpportunityLineItem;
       
        //Upate the NextFY NPR Product
        if(Utility.isRecuriveUpdate != true && lstNPRProductUpdate != null && !lstNPRProductUpdate.isEmpty()){
        	Utility.isRecuriveUpdate = true;
            update lstNPRProductUpdate;
        } 
    }//end PopulateOpportunityProductFieldInfo

	public Boolean  updateNextFYNPRProductrecordHelper(NPR_Product__c pNPRProduct, map<id, opportunity> oppMap)
	{
		//system.debug('\n\n Year = '+system.today().year()+';'+pNPRProduct.Fiscal_Year__c+'\n\n');
		//system.debug('\n\n pNPRProduct.Opportunity_Name__r.Type = '+oppMap.get(pNPRProduct.Opportunity_Name__c).Type+'\n\n');
		Boolean returnBool = false;
		system.debug('pNPRProduct.Fiscal_Year__c = '+pNPRProduct.Fiscal_Year__c);
		if(((system.today().month()==10 || System.today().month()==11 || System.today().month()==12) && (pNPRProduct.Fiscal_Year__c!=null && system.today().year()==pNPRProduct.Fiscal_Year__c-1)) ||
		   (pNPRProduct.Fiscal_Year__c!=null && system.today().year()==pNPRProduct.Fiscal_Year__c) && (oppMap.get(pNPRProduct.Opportunity_Name__c).Type=='PPF' || (oppMap.get(pNPRProduct.Opportunity_Name__c).Type=='MSA' && pNPRProduct.Product__r.MSA_Bundle__c==true)))
		{
			returnBool = true;
		}
		
		return returnBool;
	}

	//Validate the all NPRProductList
	public List<NPR_Product__c> validateNPRProductlist(List<NPR_Product__c> pLstNPRProduct){
		
		List<NPR_Product__c> lstNPRProduct = new List<NPR_Product__c>();
		if(pLstNPRProduct != null && !pLstNPRProduct.isEmpty())
		{
			for(NPR_Product__c objNPRProduct : pLstNPRProduct){
				
				if(objNPRProduct != null && 
				   (objNPRProduct.Adopt_Status__c != null  ||
					objNPRProduct.Adopt_Date__c != null  ||
					objNPRProduct.Air_Onboard_Status__c != null  ||
					objNPRProduct.Air_Onboard_Date__c != null  ||
					objNPRProduct.Drop_Date__c != null  ||
					objNPRProduct.Drop_Reason__c != null  ||
					objNPRProduct.Bill_Start_Date__c != null  ||
					objNPRProduct.Bill_End_Date__c != null )){
					
					lstNPRProduct.add(objNPRProduct);
				}
			}
		}
		
		//Return List of NPR Product
		if(!lstNPRProduct.isEmpty())
		    return lstNPRProduct;
		return null;
	}
	
}//End PopulateOpportunityProductFields