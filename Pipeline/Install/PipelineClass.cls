VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PipelineClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const sStandardColor As String = "83BA1F" ' Used if no color on option
Public Name As String
Public TotalValue As Double
Public SortOrder As Long
Public idstring As String
Public color As String
Public ShadowValue As Double
 
Public Sub AddToTotal(dblValue As Double, dblShadowValue As Variant)
    On Error GoTo ErrorHandler
    TotalValue = TotalValue + dblValue
    If VBA.IsNull(dblShadowValue) = False Then
        ShadowValue = ShadowValue + dblShadowValue
    End If
    Exit Sub
ErrorHandler:
    Call UI.ShowError("PiplineClass.AddToTotal")
End Sub
 

Public Sub SetColor(sColorValue As String)
    On Error GoTo ErrorHandler
    Dim v As Variant
    Dim i As Integer
    Dim hexStringBGR As String
    Dim hexStringRGB As String
     If VBA.Len(sColorValue) > 0 Then
        'Limes databas lagrar färg i BGR (Long)
        'konvertera först till hexa
        hexStringBGR = VBA.Hex(sColorValue)
        'konvertera från BGR till RGB
        hexStringBGR = VBA.Right("0000" & hexStringBGR, 6)
        hexStringRGB = VBA.Right(hexStringBGR, 2) & VBA.Mid(hexStringBGR, 3, 2) & VBA.Left(hexStringBGR, 2)
        color = GetRGBValue(hexStringRGB)
     Else
        color = GetRGBValue(sStandardColor)
     End If

    Exit Sub
ErrorHandler:
    Call UI.ShowError("PiplineClass.SetColor")
End Sub


Function GetRGBValue(ByVal value As String) As String
On Error GoTo ErrorHandler
    Dim R As String
    Dim G As String
    Dim B As String

    R = VBA.Val("&H" & VBA.Mid(value, 1, 2))
    G = VBA.Val("&H" & VBA.Mid(value, 3, 2))
    B = VBA.Val("&H" & VBA.Mid(value, 5, 2))
    
    GetRGBValue = "rgb(" + R & "," & G & "," & B + ")"
    Exit Function
ErrorHandler:
    GetRGBValue = "rgb(0,59,161)"
    Call UI.ShowError("PiplineClass.GetRGBValue")
End Function
