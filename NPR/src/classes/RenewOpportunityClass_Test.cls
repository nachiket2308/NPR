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
@isTest (seeAllData=true)
private class RenewOpportunityClass_Test 
{

    static testMethod void myUnitTest() 
    {
    	Test.startTest();
    	
    	Account a1 = new Account(TSR_in_Hierarchy__c=10, Name='AccountABC999', Type2__c='Licensee',  Licensee_Type__c='State', LMA__c = false, NPR_Station_Status__c='Non-Member', Membership_Status_for_MSA__c='Non-Member');
    	insert a1;
    	
        Account a2 = new Account( Name = 'Test Account', ParentId=a1.Id,
                                            TSR_in_Hierarchy__c=20, TSR__c = 10, type2__c='Station', LMA__c=false,  
                                            Minority_Status__c = 'Rural Station', NPR_Station_Status__c='Non-Member', Email_List_Size__c=1
                                           );                                          
        insert a2;
    	
    	Opportunity opp = new Opportunity(Name='oppABC1', StageName='Prospecting', Type='MSA', AccountId=a1.Id, CloseDate=System.today()-3, End_Date__c=system.today().addMonths(1));
    	insert opp;
    	
    	Product2 pr = new Product2(name='prABC1', Product_Version__c = 'Core', Family='MSA', Active_Start_Date__c=System.today()-5, Active_End_Date__c=System.today()-1, IsActive=true);
    	insert pr;

		Pricebook2 pb = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=pr.Id, UnitPrice=1, isActive=true);
 		insert pbe;     	
 		
 		Test.stopTest();
 		
 		RenewOpportunityClass ro = new RenewOpportunityClass();
 		ro.generateRenewal(opp);
    }
}