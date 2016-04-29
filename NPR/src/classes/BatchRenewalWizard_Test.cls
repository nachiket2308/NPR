/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BatchRenewalWizard_Test {

    static testMethod void unitTest1() 
    {
   	
    	//Create Account Data
        Account parentAccount = new Account(TSR_in_Hierarchy__c=10, Name='AccountABC999', Type2__c='Licensee',  Licensee_Type__c='State', LMA__c = false, NPR_Station_Status__c='Non-Member', Membership_Status_for_MSA__c='Non-Member');
    	insert parentAccount;
    	
        Account objAccount = new Account(Name = 'Test Account', ParentId=parentAccount.Id, TSR_in_Hierarchy__c=10,
                                            TSR__c = 10, type2__c='Station', LMA__c=false,  
                                            Minority_Status__c = 'Rural Station', NPR_Station_Status__c='Non-Member', Email_List_Size__c=1
                                           );                                          
        insert objAccount;
        
    	Opportunity opp = new Opportunity(Name='Test Opportunity PFY', AccountId=objAccount.Id, CloseDate=System.today(),
    		End_Date__c=System.today()+1, Type='PPF', StageName='Approved', Include_in_Next_FY_Renewal__c=true);
      	insert opp;
      	
      	Batch_Renewal__c br = new Batch_Renewal__c(Fiscal_Year__c='2014', Renewal_Type__c='PPF');
      	//insert br; 
      	
      	ApexPages.StandardController stdController = new ApexPages.StandardController(br);
       	BatchRenewalWizardController brwc = new BatchRenewalWizardController(stdController); 
	
		brwc.ProcessRenewals();
		
		
		List<Opportunity> opps = brwc.previousFYOppsQuery();
		system.debug('\n\n'+opps+'\n\n');
		brwc.createBatchRenewalOpportunities(opps);		
        
    }
}