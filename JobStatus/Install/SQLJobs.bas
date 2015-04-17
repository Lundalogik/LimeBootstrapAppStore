Attribute VB_Name = "SQLJobs"
Option Explicit

Public Function GetJobStatus(JobName As String) As String
On Error GoTo ErrorHandler
    Dim oProc As lde.Procedure
    Dim sXml As String
    
    Dim sJobs() As String
    Dim job As Variant
    sJobs() = VBA.Split(JobName, ":")
    
    For Each job In sJobs
        Set oProc = Database.Procedures.Lookup("csp_getjobstatus", lkLookupProcedureByName)
        
        If Not oProc Is Nothing Then
            oProc.Parameters("@@job_name").InputValue = job
            oProc.Execute (False)
            sXml = sXml + oProc.Parameters("@@xml").OutputValue
        End If
    Next job
    GetJobStatus = "<jobstatus>" + sXml + "</jobstatus>"
     
Exit Function
ErrorHandler:
Call UI.ShowError("SQLJobs.GetJobStatus")
End Function

Public Function MemberOfGroup(groups As String) As Boolean
On Error GoTo ErrorHandler
    Dim sGroups() As String
    Dim group As Variant
    sGroups() = VBA.Split(groups, ":")
    
    For Each group In sGroups
        If Database.ActiveUser.MemberOfGroups.Lookup(VBA.Trim(group), lkLookupGroupByName) Is Nothing Then
            MemberOfGroup = False
        Else
            MemberOfGroup = True
            Exit Function
        End If
    Next group
    
Exit Function
ErrorHandler:
Call UI.ShowError("SQLJobs.MemberOfGroup")
End Function
