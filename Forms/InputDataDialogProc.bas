#include once "InputDataDialogProc.bi"
#include once "win\commctrl.bi"
#include once "win\ole2.bi"
#include once "win\oleauto.bi"
#include once "crt.bi"
#include once "crt\limits.bi"
#include once "DisplayError.bi"
#include once "Resources.RH"

Const TCHARFIXEDVECTOR_CAPACITY As Integer = 1023

Type TCharFixedVector
	Buffer(TCHARFIXEDVECTOR_CAPACITY - 1) As TCHAR
End Type

Sub ProcessErrorDouble( _
		ByVal hwndDlg As HWND, _
		ByVal ControlID As ULONG, _
		ByVal hr As HRESULT _
	)
	
	Dim ResourceId As UINT = Any
	Dim TitleResourceId As UINT = Any
	
	Select Case hr
		Case DISP_E_OVERFLOW
			ResourceId = IDS_OVERFLOWTEXT
			TitleResourceId = IDS_OVERFLOWTITLE
			
		Case DISP_E_TYPEMISMATCH
			ResourceId = IDS_INVALIDCHARTEXT
			TitleResourceId = IDS_INVALIDCHARTITLE
			
		Case E_OUTOFMEMORY
			ResourceId = IDS_OUTOFMEMORYTEXT
			TitleResourceId = IDS_OUTOFMEMORYTITLE
			
		Case E_INVALIDARG
			ResourceId = IDS_COEFFICIENTAZEROTEXT
			TitleResourceId = IDS_COEFFICIENTAZEROTITLE
			
		' Case DISP_E_BADVARTYPE
			'The input parameter is not a valid type of variant
			
		Case Else
			ResourceId = IDS_INVALIDARGTEXT
			TitleResourceId = IDS_INVALIDARGTITLE
			
	End Select
	
	Dim tszTitle As TCharFixedVector = Any
	Dim ret2 As Long = LoadString( _
		GetModuleHandle(NULL), _
		TitleResourceId, _
		@tszTitle.Buffer(0), _
		TCHARFIXEDVECTOR_CAPACITY _
	)
	tszTitle.Buffer(ret2) = 0
	
	Dim tszErrorText As TCharFixedVector = Any
	Dim ret1 As Long = LoadString( _
		GetModuleHandle(NULL), _
		ResourceId, _
		@tszErrorText.Buffer(0), _
		TCHARFIXEDVECTOR_CAPACITY _
	)
	tszErrorText.Buffer(ret1) = 0
	
	If hr = DISP_E_TYPEMISMATCH Then
		Dim tszDecimalSeparator As TCharFixedVector = Any
		GetLocaleInfo( _
			0, _
			LOCALE_SDECIMAL, _
			@tszDecimalSeparator.Buffer(0), _
			TCHARFIXEDVECTOR_CAPACITY _
		)
		lstrcat( _
			@tszErrorText.Buffer(0), _
			@tszDecimalSeparator.Buffer(0) _
		)
	End If
	
	Dim tInfo As EDITBALLOONTIP = Any
	tInfo.cbStruct = SizeOf(EDITBALLOONTIP)
	tInfo.pszTitle = @tszTitle.Buffer(0)
	tInfo.pszText = @tszErrorText.Buffer(0)
	tInfo.ttiIcon = TTI_ERROR
	
	Dim hwndTool As HWND = GetDlgItem(hwndDlg, ControlID)
	
	Edit_ShowBalloonTip(hwndTool, @tInfo)
	
End Sub

Function GetDlgItemDouble( _
		ByVal hwndDlg As HWND, _
		ByVal ControlID As ULONG, _
		ByVal pValue As Double Ptr _
	)As HRESULT
	
	Dim wszValue As WString * 1024 = Any
	GetDlgItemTextW( _
		hwndDlg, _
		ControlID, _
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
		ByVal ControlID As ULONG, _
		ByVal Value As Double _
	)As HRESULT
	
	Dim bstrText As BSTR = Any
	
	Dim hr As HRESULT = VarBstrFromR8(Value, 0, 0, @bstrText)
	If FAILED(hr) Then
		Return hr
	End If
	
	SetDlgItemTextW( _
		hwndDlg, _
		ControlID, _
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
			
			SendMessage(GetDlgItem(hwndDlg, IDC_UPD_COEFFICIENTA), UDM_SETRANGE32, INT_MIN, Cast(LPARAM, INT_MAX))
			SendMessage(GetDlgItem(hwndDlg, IDC_UPD_COEFFICIENTA), UDM_SETPOS32, 0, Cast(LPARAM, 4))
			
			SendMessage(GetDlgItem(hwndDlg, IDC_UPD_COEFFICIENTB), UDM_SETRANGE32, INT_MIN, Cast(LPARAM, INT_MAX))
			SendMessage(GetDlgItem(hwndDlg, IDC_UPD_COEFFICIENTB), UDM_SETPOS32, 0, Cast(LPARAM, -7))
			
			SendMessage(GetDlgItem(hwndDlg, IDC_UPD_COEFFICIENTC), UDM_SETRANGE32, INT_MIN, Cast(LPARAM, INT_MAX))
			SendMessage(GetDlgItem(hwndDlg, IDC_UPD_COEFFICIENTC), UDM_SETPOS32, 0, Cast(LPARAM, -2))
			
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
					IF SUCCEEDED(hrCoefficientA) Then
						If CoefficientA <> 0.0 Then
							Dim CoefficientB As Double = Any
							Dim hrCoefficientB As HRESULT = GetDlgItemDouble( _
								hwndDlg, _
								IDC_EDT_COEFFICIENTB, _
								@CoefficientB _
							)
							If SUCCEEDED(hrCoefficientB) Then
								Dim CoefficientC As Double = Any
								Dim hrCoefficientC As HRESULT = GetDlgItemDouble( _
									hwndDlg, _
									IDC_EDT_COEFFICIENTC, _
									@CoefficientC _
								)
								If SUCCEEDED(hrCoefficientC) Then
									Dim D As Double = CoefficientB * CoefficientB - 4 * CoefficientA * CoefficientC
									If D < 0.0 Then
										Dim tszDiscriminantLessZero As TCharFixedVector = Any
										Dim ret1 As Long = LoadString( _
											GetModuleHandle(NULL), _
											IDS_DISCRIMINANTLESSZEROTEXT, _
											@tszDiscriminantLessZero.Buffer(0), _
											TCHARFIXEDVECTOR_CAPACITY _
										)
										tszDiscriminantLessZero.Buffer(ret1) = 0
										
										Dim tszTitle As TCharFixedVector = Any
										Dim ret2 As Long = LoadString( _
											GetModuleHandle(NULL), _
											IDS_DISCRIMINANTLESSZEROTITLE, _
											@tszTitle.Buffer(0), _
											TCHARFIXEDVECTOR_CAPACITY _
										)
										tszTitle.Buffer(ret2) = 0
										
										MessageBox( _
											hwndDlg, _
											@tszDiscriminantLessZero.Buffer(0), _
											@tszTitle.Buffer(0), _
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
					
				Case IDC_EDT_COEFFICIENTA
					Select Case HIWORD(wParam)
						
						Case EN_KILLFOCUS
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
									ProcessErrorDouble( _
										hwndDlg, _
										IDC_EDT_COEFFICIENTA, _
										E_INVALIDARG _
									)
								End If
							End If
							
					End Select
					
				Case IDC_EDT_COEFFICIENTB
					Select Case HIWORD(wParam)
						
						Case EN_KILLFOCUS
							Dim CoefficientB As Double = Any
							Dim hrCoefficientB As HRESULT = GetDlgItemDouble( _
								hwndDlg, _
								IDC_EDT_COEFFICIENTB, _
								@CoefficientB _
							)
							IF FAILED(hrCoefficientB) Then
								ProcessErrorDouble( _
									hwndDlg, _
									IDC_EDT_COEFFICIENTB, _
									hrCoefficientB _
								)
							End If
							
					End Select
					
				Case IDC_EDT_COEFFICIENTC
					Select Case HIWORD(wParam)
						
						Case EN_KILLFOCUS
							Dim CoefficientC As Double = Any
							Dim hrCoefficientC As HRESULT = GetDlgItemDouble( _
								hwndDlg, _
								IDC_EDT_COEFFICIENTC, _
								@CoefficientC _
							)
							IF FAILED(hrCoefficientC) Then
								ProcessErrorDouble( _
									hwndDlg, _
									IDC_EDT_COEFFICIENTC, _
									hrCoefficientC _
								)
							End If
							
					End Select
					
			End Select
			
		Case WM_CLOSE
			EndDialog(hwndDlg, 0)
			
		Case Else
			Return False
			
	End Select
	
	Return True
	
End Function
