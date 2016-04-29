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
private class OpportunityTriger2_Test {

    static testMethod void unitTest1() 
    {
    	Test.startTest();
    	
    	Account a1 = new Account(Name='AccountABC1');
    	insert a1;
    	
    	Account a2 = new Account(Name='AccountABC2', Type2__c='Station', LMA__c = false, ParentId=a1.Id);
    	insert a2;
    	
    	Opportunity opp = new Opportunity(Name='oppABC1', StageName='Prospecting', Type='PPF', AccountId=a1.Id, CloseDate=System.today()-3);
    	insert opp;
    	
    	Product2 pr = new Product2(name='prABC1', Product_Version__c = 'Core', Family='PPF', Active_Start_Date__c=System.today()-5, Active_End_Date__c=System.today()-1, IsActive=true);
    	insert pr;

		PricebookEntry pbe = new PricebookEntry(Product2Id=pr.Id);
		//insert pbe;     	
    	
    	Test.stopTest();
    }
}