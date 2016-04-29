/*
*    Version            Date                Author                Description
*    
*    1.0                06/06/2014          Gaurav                Initial Draft
*/

public with sharing class ValidationUtility {
	
	private static final String SUCCESS_MESSAGE = 'Success';
	private String strErrorMessage = '';
	List<String> lstErrorMessage = new List<String>();
	
	public List<String> validateOpportunityField(Opportunity objOpportunity){
	
		strErrorMessage = '';
		lstErrorMessage.clear();
		
		/* Validation for object Opportunity and CloseDate Field */
		if(objOpportunity.CloseDate >= objOpportunity.End_Date__c ){
			strErrorMessage = 'The Start Date cannot be on or after the End Date. The End Date cannot be on or before the Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object Opportunity and End_Date__c Field */
		/*if(objOpportunity.End_Date__c < objOpportunity.CloseDate ){
			strErrorMessage = 'The End Date cannot be on or before the Start Date';
			return strErrorMessage;
		}*/	
		
		/* Validation for object Opportunity and Discount_Type__c Field */
		if(objOpportunity.Discount_Type__c == null && objOpportunity.Discount__c != null){
			strErrorMessage = 'Discount Type must be populated if the Discount field is populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object Opportunity and Discount_Comments__c Field */
		if(objOpportunity.Discount__c <> null && objOpportunity.Discount_Comments__c == null){
			strErrorMessage = 'Discount Comment must be populated if the Discount field is populated';
			lstErrorMessage.add(strErrorMessage);
		}
		
		/* Validation for object Opportunity and Total_Override_Comments__c Field */
		if(objOpportunity.Total_Override__c <> null && objOpportunity.Total_Override_Comments__c == null){
			strErrorMessage = 'Total Override Comments must be populated if Total Override is populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object Opportunity and Admin_Fee_Override_Comments__c Field */
		if(objOpportunity.Admin_Fee_Override__c <> null && objOpportunity.Admin_Fee_Override_Comments__c   == null){
			strErrorMessage = 'Admin Fee Override Comments must be populated if Admin Fee Override is populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		return lstErrorMessage;
	}
	
	//Validation for NPR Product Field
	public List<String> validateNPRProductField(NPR_Product__c objNPRProduct, NPR_Product__c objNPRProductOld){
	
		strErrorMessage = '';
		lstErrorMessage.clear();
		
		/* Validation for object NPR_Product__c and Override_Discount_Comments__c Field */
		if(objNPRProduct.Override_Discount__c   <> null && 
			objNPRProduct.Override_Discount_Comments__c   == null){
				strErrorMessage = 'Other Discount Override Comments required when Other Discount % is entered';
				lstErrorMessage.add(strErrorMessage);
		}
		
		/* Validation for object NPR_Product__c and Override_Fee_Comments__c Field */
		if(objNPRProduct.Override_Fee__c  <> null && 
			objNPRProduct.Override_Fee_Comments__c   == null){
				strErrorMessage = 'Price Override Comments must be populated if Price Override is populated';
				lstErrorMessage.add(strErrorMessage);
		}
		
		/* Validation for object NPR_Product__c and Adopt_Status__c Field */
		if(objNPRProduct.Adopt_Date__c  <> null && objNPRProduct.Adopt_Status__c  == null){
			strErrorMessage = 'Adopt Status must be populated if Adopt Date is populated';
			lstErrorMessage.add(strErrorMessage);
		}
		
		if(objNPRProduct.Adopt_Status__c=='Complete' && objNPRProduct.Adopt_Date__c == null){
			strErrorMessage = 'Adopt Date must be populated if the Adopt Status is set to \'Complete\'';
			lstErrorMessage.add(strErrorMessage);
		}
			
		/* Validation for object NPR_Product__c and Adopt_Date__c Field */	
		/* if(objNPRProduct.Adopt_Status__c <> null && objNPRProduct.Adopt_Date__c == null){
			strErrorMessage = 'Adopt Date must be populated if the Adopt Status is set to \'Complete\'';
			return strErrorMessage;
		}*/
		
		/* Validation for object NPR_Product__c and Air_Onboard_Date__c Field */
													//june- 5 -2014	
		if(objNPRProduct.Air_Onboard_Date__c < objNPRProduct.Opportunity_Name__r.CloseDate &&
		   objNPRProduct.Air_Onboard_Date__c != objNPRProductOld.Air_Onboard_Date__c)
		{
			strErrorMessage = 'The Air/Onboard Date cannot be before the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}											//6/16/2014
		else if(objNPRProduct.Air_Onboard_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c  ){
			strErrorMessage = 'The Air/Onboard Date cannot be after the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}	
	    else if(objNPRProduct.Air_Onboard_Date__c > objNPRProduct.Drop_Date__c   ){
			strErrorMessage = 'The Air/Onboard Date cannot be after the Drop Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objNPRProduct.Air_Onboard_Date__c == null &&  (objNPRProduct.Air_Onboard_Status__c == 'Complete' || objNPRProduct.Air_Onboard_Status__c == 'Dropped')){
			strErrorMessage = 'The Air/Onboard Date cannot be blank if the Air/Onboard Status is \'Complete\' or \'Dropped\' ';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object NPR_Product__c and Drop_Reason__c Field */
		if(objNPRProduct.Drop_Reason__c == null && objNPRProduct.Drop_Date__c != NULL ){
			strErrorMessage = 'Drop Reason must be populated if Drop Date is populated';
			lstErrorMessage.add(strErrorMessage);
		}
		
		/* Validation for object NPR_Product__c and Drop_Date__c Field */	
		if(objNPRProduct.Drop_Date__c <= objNPRProduct.Opportunity_Name__r.CloseDate){
			strErrorMessage = 'The Drop Date cannot be before the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objNPRProduct.Drop_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c){	
			strErrorMessage = 'The Drop Date cannot be after the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}
		else if(objNPRProduct.Drop_Date__c < objNPRProduct.Air_Onboard_Date__c){	
			strErrorMessage = 'The Drop Date cannot before the Air/Onboard Date';
			lstErrorMessage.add(strErrorMessage);
		}
		else if((objNPRProductOld.Drop_Date__c!=null && objNPRProduct.Drop_Date__c == null) &&  (objNPRProduct.Air_Onboard_Status__c == 'Complete' ||  objNPRProduct.Air_Onboard_Status__c ==  'Dropped' )){
				strErrorMessage = 'The Drop Date cannot be blank if the Air/Onboard Status is \'Complete\' or \'Dropped\' ';
				lstErrorMessage.add(strErrorMessage);
		}	
			
		/* Validation for object NPR_Product__c and Bill_Start_Date__c Field */
		if(objNPRProduct.Opportunity_Name__r.CloseDate != null &&
			objNPRProduct.Bill_Start_Date__c != null &&  objNPRProduct.Bill_Start_Date__c < objNPRProduct.Opportunity_Name__r.CloseDate - 90 ){
			strErrorMessage = 'The Bill Start Date must be no more than 90 days prior to the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if( objNPRProduct.Opportunity_Name__r.End_Date__c != null && 
				 objNPRProduct.Bill_Start_Date__c != null  && objNPRProduct.Bill_Start_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c + 90  ){
			strErrorMessage = 'The Bill Start Date must be no more than 90 days past the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objNPRProduct.Bill_Start_Date__c == null  ){
			strErrorMessage = 'The Bill Start Date must be populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object NPR_Product__c and Bill_End_Date__c Field */
		if(objNPRProduct.Opportunity_Name__r.CloseDate != null && objNPRProduct.Bill_End_Date__c < objNPRProduct.Opportunity_Name__r.CloseDate - 90 ){
			strErrorMessage = 'The Bill End Date must be no more than 90 days prior to the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objNPRProduct.Opportunity_Name__r.End_Date__c != null &&  objNPRProduct.Bill_End_Date__c > objNPRProduct.Opportunity_Name__r.End_Date__c + 90  ){
			strErrorMessage = 'The Bill End Date must be no more than 90 days past the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objNPRProduct.Bill_End_Date__c == null  ){
			strErrorMessage = 'The bill End Date must be populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object NPR_Product__c and Accelerated_Cap__c Field */
		if(objNPRProduct.Accelerated_Cap__c != null && objNPRProduct.Accelerated_Cap__c <= 0 ){
			strErrorMessage = 'The Accelerated Cap must be greater than 0. The Accelerated Cap will adjust the price up or down appropriately.';
			lstErrorMessage.add(strErrorMessage);
		}
		
		/* Validation for object NPR_Product__c and Accelerated_Cap_Comments__c Field */
		if(objNPRProduct.Accelerated_Cap__c <> null && objNPRProduct.Accelerated_Cap_Comments__c == null ){
			strErrorMessage = 'Accelerated Cap Comments must be populated if Accelerated Cap is populated';
			lstErrorMessage.add(strErrorMessage);
		}
		
		if(objNPRProduct.Air_Onboard_Date__c < objNPRProduct.Adopt_Date__c)
		{
			strErrorMessage = 'The Air/Onboard Date cannot be before the Adopt Date';
			lstErrorMessage.add(strErrorMessage);
		}
		
		if(objNPRProduct.Override_Discount__c<>NULL && objNPRProduct.Other_Discount_Type__c==NULL)
		{
			strErrorMessage = 'Other Discount Type required when Other Discount % entered';
			lstErrorMessage.add(strErrorMessage);
		}
		
		return lstErrorMessage;
	}
	
	/***********************Opportunity Product*************************/
	//Validation for OpportunityLineItem Field
	public List<String> validateOpportunityProduct(OpportunityLineItem objOpportunityLineItem, OpportunityLineItem objOpportunityLineItemOld){
		
		strErrorMessage = '';
		lstErrorMessage.clear();
		
		/* Validation for object OpportunityLineItem and Override_Fee_Comments__c Field */
		if(objOpportunityLineItem.Override_Fee__c != null && objOpportunityLineItem.Override_Fee_Comments__c  == null ){
			strErrorMessage = 'Price Override Comments must be populated if Price Override is populated';
			lstErrorMessage.add(strErrorMessage);
		}
			
		/* Validation for object OpportunityLineItem and Adopt_Status__c Field */	
		if((objOpportunityLineItem.Adopt_Date__c <> null && objOpportunityLineItem.Adopt_Status__c  == null)){ 
			strErrorMessage = 'Adopt Status must be populated if Adopt Date is populated';
			lstErrorMessage.add(strErrorMessage);
		}
		
		/* Validation for object OpportunityLineItem and Adopt_Date__c Field */	
		if(objOpportunityLineItem.Adopt_Status__c=='Complete' && objOpportunityLineItem.Adopt_Date__c==null){
			strErrorMessage = 'Adopt Date must be populated if the Adopt Status is set to \'Complete\'';
			lstErrorMessage.add(strErrorMessage);
		}
		
		
		/* Validation for object OpportunityLineItem and Air_Onboard_Date__c Field */	
		if( objOpportunityLineItem.Opportunity.CloseDate  != null  && 
		    objOpportunityLineItem.Air_Onboard_Date__c < objOpportunityLineItem.Opportunity.CloseDate &&
		   	objOpportunityLineItem.Air_Onboard_Date__c != objOpportunityLineItemOld.Air_Onboard_Date__c)
		{
			strErrorMessage = 'The Air/Onboard Date cannot be before the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objOpportunityLineItem.Opportunity.End_Date__c  != null && objOpportunityLineItem.Air_Onboard_Date__c > objOpportunityLineItem.Opportunity.End_Date__c  ){
			strErrorMessage = 'The Air/Onboard Date cannot be after the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}	
	    else if(objOpportunityLineItem.Air_Onboard_Date__c > objOpportunityLineItem.Drop_Date__c   ){
			strErrorMessage = 'The Air/Onboard Date cannot be after the Drop Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objOpportunityLineItem.Air_Onboard_Date__c == null &&  (objOpportunityLineItem.Air_Onboard_Status__c == 'Complete' || objOpportunityLineItem.Air_Onboard_Status__c == 'Dropped')){
			strErrorMessage = 'The Air/Onboard Date cannot be blank if the Air/Onboard Status is \'Complete\' or \'Dropped\' ';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object OpportunityLineItem and Drop_Reason__c Field */	
		if(objOpportunityLineItem.Drop_Reason__c == null && objOpportunityLineItem.Drop_Date__c <> NULL ){
			strErrorMessage = 'Drop Reason must be populated if Drop Date is populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object OpportunityLineItem and Bill_Start_Date__c Field */	
		if(objOpportunityLineItem.Opportunity.CloseDate  != null &&  objOpportunityLineItem.Bill_Start_Date__c < objOpportunityLineItem.Opportunity.CloseDate - 90 ){
			strErrorMessage = 'The Bill Start Date must be no more than 90 days prior to the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objOpportunityLineItem.Opportunity.End_Date__c  != null &&  objOpportunityLineItem.Bill_Start_Date__c > objOpportunityLineItem.Opportunity.End_Date__c + 90  ){
			strErrorMessage = 'The Bill Start Date must be no more than 90 days past the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objOpportunityLineItem.Bill_Start_Date__c == null  ){
			strErrorMessage = 'The Bill Start Date must be populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		
		/* Validation for object OpportunityLineItem and Bill_End_Date__c Field */	
		if(objOpportunityLineItem.Bill_End_Date__c == null ){
			strErrorMessage = 'The Bill End Date must be populated';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objOpportunityLineItem.Opportunity.CloseDate != null  && objOpportunityLineItem.Bill_End_Date__c < objOpportunityLineItem.Opportunity.CloseDate - 90 ){
			strErrorMessage = 'The Bill End Date must be no more than 90 days prior to the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objOpportunityLineItem.Opportunity.End_Date__c !=null  && objOpportunityLineItem.Bill_End_Date__c > objOpportunityLineItem.Opportunity.End_Date__c + 90 ){
			strErrorMessage = 'The Bill End Date must be no more than 90 days past the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}		
		
		
	    /* Validation for object objOpportunityLineItem and Drop_Date__c Field */	
		if(objOpportunityLineItem.Opportunity.CloseDate != null  && objOpportunityLineItem.Drop_Date__c <= objOpportunityLineItem.Opportunity.CloseDate){
			strErrorMessage = 'The Drop Date cannot be before the Opportunity\'s Start Date';
			lstErrorMessage.add(strErrorMessage);
		}	
		else if(objOpportunityLineItem.Opportunity.End_Date__c !=null  && objOpportunityLineItem.Drop_Date__c > objOpportunityLineItem.Opportunity.End_Date__c){	
			strErrorMessage = 'The Drop Date cannot be after the Opportunity\'s End Date';
			lstErrorMessage.add(strErrorMessage);
		}
		else if(objOpportunityLineItem.Drop_Date__c < objOpportunityLineItem.Air_Onboard_Date__c){	
			strErrorMessage = 'The Drop Date cannot before the Air/Onboard Date';
			lstErrorMessage.add(strErrorMessage);
		}
		else if(objOpportunityLineItem.Drop_Date__c == null && objOpportunityLineItemOld.Drop_Date__c!=null && (objOpportunityLineItem.Air_Onboard_Status__c == 'Complete' ||  objOpportunityLineItem.Air_Onboard_Status__c ==  'Dropped' )){
				strErrorMessage = 'The Drop Date cannot be blank if the Air/Onboard Status is \'Complete\' or \'Dropped\' ';
				lstErrorMessage.add(strErrorMessage);
		}	
		system.debug('**\n\n'+objOpportunityLineItem.Drop_Date__c+'\n\n**');
		system.debug('**\n\n'+objOpportunityLineItemOld.Drop_Date__c+'\n\n**');
		
		if(objOpportunityLineItem.Air_Onboard_Date__c < objOpportunityLineItem.Adopt_Date__c)
		{
			strErrorMessage = 'The Air/Onboard Date cannot be before the Adopt Date';
			lstErrorMessage.add(strErrorMessage);
		}
			
		return lstErrorMessage; 	
	}
	
}//end ValidationUtility Class