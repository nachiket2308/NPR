@isTest
public class StationProductPrograms_Test 
{
    static testMethod void unitTest() 
    {
    	Account a = new Account(TSR_in_Hierarchy__c=10, Name='AccountABC999', Type2__c='Licensee',  Licensee_Type__c='State', LMA__c = false, NPR_Station_Status__c='Non-Member', Membership_Status_for_MSA__c='Non-Member');
    	insert a;
    	
    	Product2 p = new Product2(name='prABC1', Product_Version__c = 'Core', Family='PPF', Active_Start_Date__c=System.today()-5, Active_End_Date__c=System.today()+1, IsActive=true, MSA_Incremental_Type__c='Streaming', Contract_Type__c='PPF (recurring)');
    	insert p;
    	
    	Station_Products_Programs__c spp = new Station_Products_Programs__c(Name='Test', Air_Onboard_Status__c='Complete', Station__c=a.Id, Product_Program_Name__c=p.Id, Start_Date__c=System.today());
		insert spp;
		
		spp.Air_Onboard_Status__c='Dropped';
		spp.Drop_Reason__c = 'Testing Drop';
		spp.End_Date__c = System.today();
		update spp;
		
		system.assertEquals(spp.Active_Air_Onboard_History__c, null);
		
    }
}