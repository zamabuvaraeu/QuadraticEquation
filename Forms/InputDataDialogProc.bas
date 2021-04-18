#include once "InputDataDialogProc.bi"
#include once "win\commctrl.bi"
#include once "win\ole2.bi"
#include once "win\oleauto.bi"
#include once "crt.bi"
#include once "DisplayError.bi"
#include once "Resources.RH"

Const DIALOGBOXPARAM_ERRORSTRING = __TEXT("Failed to show OutputDataDialog")
Const CONVERT_ERRORSTRING = __TEXT("Failed to convert String to Double")

' Function CreateToolTip( _
		' ByVal hwndDlg As HWND, _
		' ByVal resID As ULONG, _
		' ByVal pszText As LPTSTR _
	' )As HWND
	
	' Dim hwndTool As HWND = GetDlgItem(hwndDlg, resID)
	
	' Dim hwndTip As HWND = CreateWindowEx( _
		' WS_EX_TOOLWINDOW, _
		' TOOLTIPS_CLASS, _
		' NULL, _
		' WS_POPUP Or TTS_ALWAYSTIP Or TTS_BALLOON, _
		' CW_USEDEFAULT, CW_USEDEFAULT, _
		' CW_USEDEFAULT, CW_USEDEFAULT, _
		' hwndDlg, _
		' NULL, _
		' GetModuleHandle(0), _
		' NULL _
	' )
    ' If hwndTip = NULL Then
		' Return NULL
	' End If
	
	' Dim tInfo As TOOLINFO = Any
	' ZeroMemory(@tInfo, SizeOf(TOOLINFO))
	
	' tInfo.cbSize = SizeOf(TOOLINFO)
	' tInfo.hwnd = hwndDlg
	' tInfo.uFlags = TTF_IDISHWND Or TTF_SUBCLASS
	' tInfo.uId = Cast(UINT_PTR, hwndTool)
	' tInfo.lpszText = pszText
	
	' SendMessage(hwndTip, TTM_ADDTOOL, 0, CPtr(LPARAM, @tInfo))
	
	' Return hwndTip
	
' End Function

Sub ProcessErrorDouble( _
		ByVal hwndDlg As HWND, _
		ByVal resID As ULONG, _
		ByVal hr As HRESULT _
	)
	Dim tszTitle(1023) As TCHAR = Any
	Dim ret2 As Long = LoadString( _
		GetModuleHandle(NULL), _
		IDS_INCORRECTDATATITLE, _
		@tszTitle(0), _
		1023 _
	)
	tszTitle(ret2) = 0
	
	Dim tszDecimalSeparator(1023) As TCHAR = Any
	GetLocaleInfo( _
		0, _
		LOCALE_SDECIMAL, _
		@tszDecimalSeparator(0), _
		1023 _
	)
	
	Dim tszErrorText(1023) As TCHAR = Any
	Dim ResourceId As UINT = Any
	
	Select Case hr
		Case DISP_E_OVERFLOW
			ResourceId = IDS_INCORRECTDATAOVERFLOW
		Case DISP_E_TYPEMISMATCH
			ResourceId = IDS_INCORRECTDATACHAR
		Case E_OUTOFMEMORY
			ResourceId = IDS_OUTOFMEMORY
		' Case DISP_E_BADVARTYPE
			'The input parameter is not a valid type of variant.
		' Case E_INVALIDARG
			'One of the arguments is not valid.
			' ResourceId = IDS_INVALIDARG
		Case Else
			ResourceId = IDS_INVALIDARG
	End Select
	
	Dim ret1 As Long = LoadString( _
		GetModuleHandle(NULL), _
		ResourceId, _
		@tszErrorText(0), _
		1023 _
	)
	tszErrorText(ret1) = 0
	
	If hr = DISP_E_TYPEMISMATCH Then
		lstrcat( _
			@tszErrorText(0), _
			@tszDecimalSeparator(0) _
		)
	End If
	
	MessageBox( _
		hwndDlg, _
		@tszErrorText(0), _
		@tszTitle(0), _
		MB_OK Or MB_ICONERROR _
	)
	
End Sub

Function GetDlgItemDouble( _
		ByVal hwndDlg As HWND, _
		ByVal resID As ULONG, _
		ByVal pValue As Double Ptr _
	)As HRESULT
	
	Dim wszValue As WString * 1024 = Any
	GetDlgItemTextW( _
		hwndDlg, _
		resID, _
		@wszValue, _
		1023 _
	)
	Dim Value As Double = Any
	Dim hr As HRESULT = VarR8FromStr( _
		@wszValue, _
		0, _
		0, _
		@Value _
	)
	If FAILED(hr) Then
		Return hr
	End If
	
	*pValue = Value
	
	Return S_OK
	
End Function

Function SetDlgItemDouble( _
		ByVal hwndDlg As HWND, _
		ByVal resID As ULONG, _
		ByVal Value As Double _
	)As HRESULT
	
	Dim bstrText As BSTR = Any
	
	Dim hr As HRESULT = VarBstrFromR8(Value, 0, 0, @bstrText)
	If FAILED(hr) Then
		Return hr
	End If
	
	SetDlgItemTextW( _
		hwndDlg, _
		resID, _
		bstrText _
	)
	
	SysFreeString(bstrText)
	
	Return S_OK
	
End Function

Function InputDataDialogProc( _
		ByVal hwndDlg As HWND, _
		ByVal uMsg As UINT, _
		ByVal wParam As WPARAM, _
		ByVal lParam As LPARAM _
	)As INT_PTR
	
	Select Case uMsg
		
		Case WM_INITDIALOG
			Dim hInst As HINSTANCE = GetModuleHandle(NULL)
			Dim hIcon As HICON = LoadIcon(hInst, CPtr(LPCTSTR, IDI_MAIN))
			SendMessage(hwndDlg, WM_SETICON, ICON_BIG, Cast(LPARAM, hIcon))
			
			SetDlgItemDouble(hwndDlg, IDC_EDT_ROOTX1, 2.0)
			SetDlgItemDouble(hwndDlg, IDC_EDT_ROOTX2, -0.25)
			
		Case WM_COMMAND
			Select Case LOWORD(wParam)
				
				Case IDOK
					Dim CoefficientA As Double = Any
					Dim hrCoefficientA As HRESULT = GetDlgItemDouble( _
						hwndDlg, _
						IDC_EDT_COEFFICIENTA, _
						@CoefficientA _
					)
					IF FAILED(hrCoefficientA) Then
						ProcessErrorDouble( _
							hwndDlg, _
							IDC_EDT_COEFFICIENTA, _
							hrCoefficientA _
						)
					Else
						If CoefficientA = 0.0 Then
							Dim tszCoefficientAIsZero(1023) As TCHAR = Any
							Dim ret As Long = LoadString( _
								GetModuleHandle(NULL), _
								IDS_COEFFICIENTAZERO, _
								@tszCoefficientAIsZero(0), _
								1023 _
							)
							tszCoefficientAIsZero(ret) = 0
							MessageBox( _
								hwndDlg, _
								@tszCoefficientAIsZero(0), _
								NULL, _
								MB_OK Or MB_ICONERROR _
							)
						Else
							Dim CoefficientB As Double = Any
							Dim hrCoefficientB As HRESULT = GetDlgItemDouble( _
								hwndDlg, _
								IDC_EDT_COEFFICIENTB, _
								@CoefficientB _
							)
							If FAILED(hrCoefficientB) Then
								ProcessErrorDouble( _
									hwndDlg, _
									IDC_EDT_COEFFICIENTB, _
									hrCoefficientB _
								)
							Else
								Dim CoefficientC As Double = Any
								Dim hrCoefficientC As HRESULT = GetDlgItemDouble( _
									hwndDlg, _
									IDC_EDT_COEFFICIENTC, _
									@CoefficientC _
								)
								If FAILED(hrCoefficientC) Then
									ProcessErrorDouble( _
										hwndDlg, _
										IDC_EDT_COEFFICIENTC, _
										hrCoefficientC _
									)
								Else
									Dim D As Double = CoefficientB * CoefficientB - 4 * CoefficientA * CoefficientC
									If D < 0.0 Then
										Dim tszDiscriminantLessZero(1023) As TCHAR = Any
										Dim ret As Long = LoadString( _
											GetModuleHandle(NULL), _
											IDS_DISCRIMINANTLESSZERO, _
											@tszDiscriminantLessZero(0), _
											1023 _
										)
										tszDiscriminantLessZero(ret) = 0
										MessageBox( _
											hwndDlg, _
											@tszDiscriminantLessZero(0), _
											NULL, _
											MB_OK Or MB_ICONERROR _
										)
									Else
										Dim X1 As Double = (-1.0 * CoefficientB + sqrt(D)) / (2.0 * CoefficientA)
										Dim X2 As Double = (-1.0 * CoefficientB - sqrt(D)) / (2.0 * CoefficientA)
										
										SetDlgItemDouble(hwndDlg, IDC_EDT_ROOTX1, X1)
										SetDlgItemDouble(hwndDlg, IDC_EDT_ROOTX2, X2)
									End If
								End If
							End If
						End If
					End If
					
				Case IDCANCEL
					EndDialog(hwndDlg, 0)
					
			End Select
			
		Case WM_CLOSE
			EndDialog(hwndDlg, 0)
			
		Case Else
			Return False
			
	End Select
	
	Return True
	
End Function
