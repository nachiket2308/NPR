public class BatchRenewalWizardViewController 
{
		private Batch_Renewal__c br;

		public BatchRenewalWizardViewController(ApexPages.StandardController stdController)
		{
			this.br = (Batch_Renewal__c)stdController.getRecord();
		}
}