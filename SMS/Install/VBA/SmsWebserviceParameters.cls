VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SmsWebserviceParameters"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public sSmsSupplier As String
Public sSender As String
Public sUsername As String
Public sPassword As String
Public sPhoneNr As String
Public sMessage As String

' Link Mobility Soap Api
Public sServiceid As String

' Link Mobility Rest Api
Public sPlatformId As String
Public sPlatformPartnerId As String
Public sGateId As String
