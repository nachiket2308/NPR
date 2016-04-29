if(window.location.pathname.substring(1, 4)=='006' && window.location.pathname.split('/')[1].length>=15)
{
	var result = sforce.connection.query("select Type from Opportunity where Id='" + window.location.pathname.split('/')[1] + "'");
	var records = result.getArray("records");
	
	if(records[0].Type=='PPF' || records[0].Type=='MSA')
	{
		window.location.replace("/apex/OpportunityViewOverride?id="+window.location.pathname.split('/')[1]);
	}
}

$( document ).ready(function() {
   $("#sidebarComponentLocator").closest(".sidebarModule").hide().prev().hide();	
});