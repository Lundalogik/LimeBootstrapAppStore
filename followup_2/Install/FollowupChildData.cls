VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "FollowupChildData"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' Ids
Public sId As String

Public lngTargetValue As Long
Public lngCurrentValue As Long

Public Function GetTargetMonthToDateValue(ByVal dGivenDate As Date) As Long
    Dim dblMonthToDatePercentage As Double
    Dim lngMonthDiff As Long
    lngMonthDiff = VBA.DateDiff("m", VBA.Date, dGivenDate)
    
    If lngMonthDiff > 0 Then
        dblMonthToDatePercentage = 0
    ElseIf lngMonthDiff < 0 Then
        dblMonthToDatePercentage = 1
    Else
        dblMonthToDatePercentage = Followup.GetNrWorkingDaysGivenMonthSoFar(VBA.Date) / Followup.GetNrWorkingDaysGivenMonth(dGivenDate)
    End If
    
    
    GetTargetMonthToDateValue = VBA.Round(lngTargetValue * dblMonthToDatePercentage, 0)
Exit Function
ErrorHandler:
    Call UI.ShowError("FollowupChildData.GetTargetMonthToDateValue")
End Function
