#Notify

We know you have customers that are more important than others. With Notify nothing slips through your fingers. It gives you full control of the latest actions made on your most precious companies.
You get total control and who wouldn't want that?

This is what you get:
<ul>
	<li>Notifications from chosen companies</li>
	<li>Not missing out on important actions you are not involved in</li>
	<li>Help with getting your priorities straight</li>
</ul>

##Basic usage

Keep calm and let Notify notify

##Installation

###Requirements for Notify:
<ul>
	<li>A new table in LISA - subscription</li>
	<li>Relations from subscription to company and to coworker</li>
	<li>A yes/no field named unsubscribe on the subscription table</li>
	<br>
	<li>Add procedure [dbo].[csp_get_subscriptions]</li>
</ul>

###Standard configuration of Notify

<ul>
	<li>Time = 7 days back. This can be edited in the [dbo].[cps_get_subscriptions]</li>
</ul>

###Add the following code to company.html

	<ul class="menu expandable collapsed"><li class="menu-header", data-bind=" text:'Länkar'"></li>  	
	<button class="btn btn-default btn-lime"  data-bind="vba:'Globals.CreateSubscription', text:'Notify', icon:'fa-check'"></button>	</ul>
	
	
###Add the following code to index.html:

	<div data-app="{app:'subscriptions',config:{}}"></div>

###Add the following code in VBA to Globals:

	Public Sub createSubscription()
		On Error GoTo ErrorHandler
		
		Dim oRecords As LDE.Records
		Dim oRecord As LDE.Record
		Dim oFilter As LDE.Filter
		Set oFilter = New LDE.Filter
		
		Call oFilter.AddCondition("company", lkOpEqual, ActiveInspector.Record.ID)
		Call oFilter.AddCondition("coworker", lkOpEqual, ActiveUser.Record.ID)
		Call oFilter.AddOperator(lkOpAnd)
		Call oFilter.AddCondition("unsubscribe", lkOpEqual, 0)
		Call oFilter.AddOperator(lkOpAnd)
		
		Set oRecords = New LDE.Records
		Set oRecord = New LDE.Record
		
		If oFilter.HitCount(Database.Classes("subscription")) > 0 Then
			If Lime.MessageBox("Du följer redan på detta företag. Vill du sluta följa?", vbYesNo) = vbYes Then
				
				Call oRecords.Open(Database.Classes("subscription"), oFilter)
				For Each oRecord In oRecords
					oRecord.Value("unsubscribe") = 1
					oRecord.Update
				Next
			Else
				Exit Sub
			End If
		Else
		   
	  
			If Lime.MessageBox("Du kommer nu att signa upp för att följa detta företag. Vill du fortsätta?", vbYesNo) = vbYes Then
				Call oRecord.Open(Database.Classes("subscription"))
				oRecord.Value("coworker") = ActiveUser.Record.ID
				oRecord.Value("company") = ActiveInspector.Record.ID
				oRecord.Update
			   
			End If
	 
			
		End If
		
		Exit Sub
	ErrorHandler:
		Call UI.ShowError("Globals.createSubscription")
	End Sub
 
 
	Public Function GetSubscriptions() As String
		On Error GoTo ErrorHandler
		Dim oProc As LDE.Procedure
		Dim xml As String
		Set oProc = Database.Procedures.Lookup("csp_get_subscriptions", lkLookupProcedureByName)
		If Not oProc Is Nothing Then
			oProc.Parameters("@@idcoworker").InputValue = ActiveUser.Record.ID
			Call oProc.Execute(False)
			xml = oProc.Parameters("@@xml").OutputValue
		Else
			xml = ""
		End If
		GetSubscriptions = "<items>" + xml + "</items>"
		
		Exit Function
	ErrorHandler:
		Call UI.ShowError("Globals.GetSubscriptions")
	End Function


