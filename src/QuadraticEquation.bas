#include once "crt.bi"
#include once "crt\limits.bi"
#include once "windows.bi"
#include once "win\commctrl.bi"
#include once "win\ole2.bi"
#include once "win\oleauto.bi"
#include once "Resources.RH"

Const TCHARFIXEDVECTOR_CAPACITY As Integer = 512
Const RESOURCE_STRING_BUFFER_CAPACITY = 255

Enum QuadraticEquationStatus
	NoSolution
	TwoRoots
	OneRoot
	ComplexRoots
End Enum

Type DialogData
	hInst As HINSTANCE
	hToolTop As HWND
End Type

Type TCharFixedVector
	Buffer(TCHARFIXEDVECTOR_CAPACITY - 1) As TCHAR
End Type

Type ResourceStringBuffer
	szText(RESOURCE_STRING_BUFFER_CAPACITY) As TCHAR
End Type

Type Root2D
	X1 As Double
	X2 As Double
End Type

Type ErrorBuffer
	szText(RESOURCE_STRING_BUFFER_CAPACITY) As TCHAR
End Type

Private Sub DisplayError( _
		ByVal hInst As HINSTANCE, _
		ByVal hWin As HWND, _
		ByVal dwErrorCode As DWORD, _
		ByVal CaptionId As UINT _
	)
	
	Dim FormatString As ResourceStringBuffer = Any
	LoadString( _
		hInst, _
		IDS_ERRORFORMAT, _
		@FormatString.szText(0), _
		RESOURCE_STRING_BUFFER_CAPACITY _
	)
	
	Dim buf As ErrorBuffer = Any
	Dim BufLen As Integer = wsprintf( _
		@buf.szText(0), _
		@FormatString.szText(0), _
		dwErrorCode _
	)
	
	If BufLen Then
		Dim wBuffer As ErrorBuffer = Any
		Dim BufLen2 As Integer = (RESOURCE_STRING_BUFFER_CAPACITY - 1) - BufLen
		Dim CharsCount As DWORD = FormatMessage( _
			FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_MAX_WIDTH_MASK, _
			NULL, _
			dwErrorCode, _
			0, _
			@buf.szText(BufLen), _
			BufLen2, _
			NULL _
		)
		
		If CharsCount Then
			Dim MsgCaption As ResourceStringBuffer = Any
			LoadString( _
				hInst, _
				CaptionId, _
				@MsgCaption.szText(0), _
				RESOURCE_STRING_BUFFER_CAPACITY _
			)
			MessageBox( _
				hWin, _
				@buf.szText(0), _
				@MsgCaption.szText(0), _
				MB_OK Or MB_ICONERROR _
			)
		End If
	End If
	
End Sub

Private Sub DisplaySuccess( _
		ByVal hInst As HINSTANCE, _
		ByVal hWin As HWND, _
		ByVal CaptionId As UINT, _
		ByVal MsgTextId As UINT _
	)
	
	Dim MsgText As ResourceStringBuffer = Any
	LoadString( _
		hInst, _
		MsgTextId, _
		@MsgText.szText(0), _
		RESOURCE_STRING_BUFFER_CAPACITY _
	)
	
	Dim MsgCaption As ResourceStringBuffer = Any
	LoadString( _
		hInst, _
		CaptionId, _
		@MsgCaption.szText(0), _
		RESOURCE_STRING_BUFFER_CAPACITY _
	)
	
	MessageBox( _
		hWin, _
		@MsgText.szText(0), _
		@MsgCaption.szText(0), _
		MB_OK Or MB_ICONINFORMATION _
	)
	
End Sub

Private Function SolveQuadraticEquation( _
		ByVal a As Double, _
		ByVal b As Double, _
		ByVal c As Double, _
		ByVal pRoot2D As Root2D Ptr _
	)As QuadraticEquationStatus
	
	If a = 0.0 Then
		pRoot2D->X1 = 0.0
		pRoot2D->X2 = 0.0
		Return QuadraticEquationStatus.NoSolution
	End If
	
	Dim Status As QuadraticEquationStatus = Any
	
	Dim Discriminant As Double = b * b - 4.0 * a * c
	
	Select Case Discriminant
		Case Is < 0.0
			Status = QuadraticEquationStatus.ComplexRoots
			
		Case 0.0
			Status = QuadraticEquationStatus.OneRoot
			
		Case Else
			Status = QuadraticEquationStatus.TwoRoots
			
	End Select
	
	Dim DiscriminantAbsolute As VARIANT = Any
	Scope
		Dim tmp As VARIANT = Any
		tmp.vt = VT_R8
		tmp.dblVal = Discriminant
		VarAbs(@tmp, @DiscriminantAbsolute)
	End Scope
	
	Dim DiscriminantRadix As VARIANT = Any
	Scope
		Dim tmpLeft As VARIANT = Any
		tmpLeft.vt = VT_R8
		tmpLeft.dblVal = Discriminant
		
		Dim tmpRight As VARIANT = Any
		tmpRight.vt = VT_R8
		tmpRight.dblVal = 0.5
		
		VarPow(@tmpLeft, @tmpRight, @DiscriminantRadix)
	End Scope
	
	Dim NegativeB As Double = -1.0 * b
	
	Dim X1 As Double = ((NegativeB + DiscriminantRadix.dblVal) * 0.5) / a
	Dim X2 As Double = ((NegativeB - DiscriminantRadix.dblVal) * 0.5) / a
	
	pRoot2D->X1 = X1
	pRoot2D->X2 = X2

	Return Status
	
End Function

Private Sub ProcessErrorDouble( _
		ByVal hWin As HWND, _
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
	
	Dim ModuleHandle As HMODULE = GetModuleHandle(NULL)
	
	Dim tszTitle As TCharFixedVector = Any
	Dim ret2 As Long = LoadString( _
		ModuleHandle, _
		TitleResourceId, _
		@tszTitle.Buffer(0), _
		TCHARFIXEDVECTOR_CAPACITY _
	)
	tszTitle.Buffer(ret2) = 0
	
	Dim tszErrorText As TCharFixedVector = Any
	Dim ret1 As Long = LoadString( _
		ModuleHandle, _
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
	
	Dim hwndTool As HWND = GetDlgItem(hWin, ControlID)
	
	Edit_ShowBalloonTip(hwndTool, @tInfo)
	
End Sub

Private Function GetDlgItemDouble( _
		ByVal hWin As HWND, _
		ByVal ControlID As ULONG, _
		ByVal pValue As Double Ptr _
	)As HRESULT
	
	Dim wszValue As WString * 1024 = Any
	GetDlgItemTextW( _
		hWin, _
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

Private Function SetDlgItemDouble( _
		ByVal hWin As HWND, _
		ByVal ControlID As ULONG, _
		ByVal Value As Double, _
		ByVal IsComplex As Boolean _
	)As HRESULT
	
	Dim bstrValue As BSTR = Any
	
	Dim hr As HRESULT = VarBstrFromR8(Value, 0, 0, @bstrValue)
	If FAILED(hr) Then
		Return hr
	End If
	
	Dim bstrImaginaryUnitSuffix As BSTR = Any
	If IsComplex Then
		bstrImaginaryUnitSuffix = SysAllocString(WStr(" * i"))
	Else
		bstrImaginaryUnitSuffix = NULL
	End If
	
	Dim bstrText As BSTR = Any
	VarBstrCat( _
		bstrValue, _
		bstrImaginaryUnitSuffix, _
		@bstrText _
	)
	
	SetDlgItemTextW( _
		hWin, _
		ControlID, _
		bstrText _
	)
	
	SysFreeString(bstrText)
	SysFreeString(bstrImaginaryUnitSuffix)
	SysFreeString(bstrValue)
	
	Return S_OK
	
End Function

Private Sub DialogMain_OnLoad( _
		ByVal this As DialogData Ptr, _
		ByVal hWin As HWND _
	)
	
	Dim hIcon As HICON = LoadIcon(this->hInst, CPtr(LPCTSTR, IDI_MAIN))
	SendMessage(hWin, WM_SETICON, ICON_BIG, Cast(LPARAM, hIcon))
	
	SendDlgItemMessage(hWin, IDC_UPD_COEFFICIENTA, UDM_SETRANGE32, INT_MIN, Cast(LPARAM, INT_MAX))
	SendDlgItemMessage(hWin, IDC_UPD_COEFFICIENTA, UDM_SETPOS32, 0, Cast(LPARAM, 4))
	
	SendDlgItemMessage(hWin, IDC_UPD_COEFFICIENTB, UDM_SETRANGE32, INT_MIN, Cast(LPARAM, INT_MAX))
	SendDlgItemMessage(hWin, IDC_UPD_COEFFICIENTB, UDM_SETPOS32, 0, Cast(LPARAM, -7))
	
	SendDlgItemMessage(hWin, IDC_UPD_COEFFICIENTC, UDM_SETRANGE32, INT_MIN, Cast(LPARAM, INT_MAX))
	SendDlgItemMessage(hWin, IDC_UPD_COEFFICIENTC, UDM_SETPOS32, 0, Cast(LPARAM, -2))
	
	SetDlgItemDouble(hWin, IDC_EDT_ROOTX1, 2.0, False)
	SetDlgItemDouble(hWin, IDC_EDT_ROOTX2, -0.25, False)
	
End Sub

Private Sub IDOK_OnClick( _
		ByVal this As DialogData Ptr, _
		ByVal hWin As HWND _
	)
	
	Dim CoefficientA As Double = Any
	Dim hrCoefficientA As HRESULT = GetDlgItemDouble( _
		hWin, _
		IDC_EDT_COEFFICIENTA, _
		@CoefficientA _
	)
	IF SUCCEEDED(hrCoefficientA) Then
		Dim CoefficientB As Double = Any
		Dim hrCoefficientB As HRESULT = GetDlgItemDouble( _
			hWin, _
			IDC_EDT_COEFFICIENTB, _
			@CoefficientB _
		)
		If SUCCEEDED(hrCoefficientB) Then
			Dim CoefficientC As Double = Any
			Dim hrCoefficientC As HRESULT = GetDlgItemDouble( _
				hWin, _
				IDC_EDT_COEFFICIENTC, _
				@CoefficientC _
			)
			If SUCCEEDED(hrCoefficientC) Then
				Dim Roots As Root2D = Any
				Dim Status As QuadraticEquationStatus = SolveQuadraticEquation( _
					CoefficientA, _
					CoefficientB, _
					CoefficientC, _
					@Roots _
				)
				If Status = QuadraticEquationStatus.NoSolution Then
					' Dim tszDiscriminantLessZero As TCharFixedVector = Any
					' Dim ret1 As Long = LoadString( _
						' GetModuleHandle(NULL), _
						' IDS_DISCRIMINANTLESSZEROTEXT, _
						' @tszDiscriminantLessZero.Buffer(0), _
						' TCHARFIXEDVECTOR_CAPACITY _
					' )
					' tszDiscriminantLessZero.Buffer(ret1) = 0
					
					' Dim tszTitle As TCharFixedVector = Any
					' Dim ret2 As Long = LoadString( _
						' GetModuleHandle(NULL), _
						' IDS_DISCRIMINANTLESSZEROTITLE, _
						' @tszTitle.Buffer(0), _
						' TCHARFIXEDVECTOR_CAPACITY _
					' )
					' tszTitle.Buffer(ret2) = 0
					
					' MessageBox( _
						' hWin, _
						' @tszDiscriminantLessZero.Buffer(0), _
						' @tszTitle.Buffer(0), _
						' MB_OK Or MB_ICONERROR _
					' )
				Else
					Dim IsComplex As Boolean = (Status = QuadraticEquationStatus.ComplexRoots)

					SetDlgItemDouble(hWin, IDC_EDT_ROOTX1, Roots.X1, IsComplex)
					SetDlgItemDouble(hWin, IDC_EDT_ROOTX2, Roots.X2, IsComplex)
				End If
			End If
		End If
	End If
	
End Sub

Private Sub IDCANCEL_OnClick( _
		ByVal this As DialogData Ptr, _
		ByVal hWin As HWND _
	)
	
	EndDialog(hWin, IDCANCEL)
	
End Sub

Private Sub DialogMain_OnUnload( _
		ByVal this As DialogData Ptr, _
		ByVal hWin As HWND _
	)
	
	EndDialog(hWin, IDCANCEL)
	
End Sub

Private Sub Control_OnKillFocus( _
		ByVal this As DialogData Ptr, _
		ByVal hWin As HWND, _
		ByVal ControlId As WORD _
	)
	
	Dim Coefficient As Double = Any
	Dim hrCoefficient As HRESULT = GetDlgItemDouble( _
		hWin, _
		ControlId, _
		@Coefficient _
	)
	IF FAILED(hrCoefficient) Then
		ProcessErrorDouble( _
			hWin, _
			ControlId, _
			hrCoefficient _
		)
	Else
		If Coefficient = 0.0 AndAlso ControlId = IDC_EDT_COEFFICIENTA Then
			ProcessErrorDouble( _
				hWin, _
				IDC_EDT_COEFFICIENTA, _
				E_INVALIDARG _
			)
		End If
	End If
	
End Sub

Private Function InputDataDialogProc( _
		ByVal hWin As HWND, _
		ByVal uMsg As UINT, _
		ByVal wParam As WPARAM, _
		ByVal lParam As LPARAM _
	)As INT_PTR
	
	Dim pParam As DialogData Ptr = Any
	
	If uMsg = WM_INITDIALOG Then
		pParam = Cast(DialogData Ptr, lParam)
		DialogMain_OnLoad(pParam, hWin)
		SetWindowLongPtr(hWin, GWLP_USERDATA, Cast(LONG_PTR, pParam))
		
		Return True
	End If
	
	pParam = Cast(DialogData Ptr, GetWindowLongPtr(hWin, GWLP_USERDATA))
	
	Select Case uMsg
		
		Case WM_COMMAND
			
			Dim Reason As WORD = HIWORD(wParam)
			Dim ControlId As WORD = LOWORD(wParam)
			
			Select Case Reason
				
				Case BN_CLICKED
					Select Case ControlId
						
						Case IDOK
							IDOK_OnClick(pParam, hWin)
							
					Case IDCANCEL
							IDCANCEL_OnClick(pParam, hWin)
							
					End Select
					
				Case EN_KILLFOCUS
					
					Select Case ControlId
						
						Case IDC_EDT_COEFFICIENTA, IDC_EDT_COEFFICIENTB, IDC_EDT_COEFFICIENTC
							Control_OnKillFocus(pParam, hWin, ControlId)
							
					End Select
			End Select
			
		Case WM_CLOSE
			DialogMain_OnUnload(pParam, hWin)
			
		Case Else
			Return False
			
	End Select
	
	Return True
	
End Function

Private Function EnableVisualStyles()As HRESULT
	
	' Only for Win95
	' InitCommonControls()
	
	Dim icc As INITCOMMONCONTROLSEX = Any
	icc.dwSize = SizeOf(INITCOMMONCONTROLSEX)
	icc.dwICC = ICC_ANIMATE_CLASS Or _
		ICC_BAR_CLASSES Or _
		ICC_COOL_CLASSES Or _
		ICC_DATE_CLASSES Or _
		ICC_HOTKEY_CLASS Or _
		ICC_INTERNET_CLASSES Or _
		ICC_LINK_CLASS Or _
		ICC_LISTVIEW_CLASSES Or _
		ICC_NATIVEFNTCTL_CLASS Or _
		ICC_PAGESCROLLER_CLASS Or _
		ICC_PROGRESS_CLASS Or _
		ICC_STANDARD_CLASSES Or _
		ICC_TAB_CLASSES Or _
		ICC_TREEVIEW_CLASSES Or _
		ICC_UPDOWN_CLASS Or _
		ICC_USEREX_CLASSES Or _
	ICC_WIN95_CLASSES
	
	Dim res As BOOL = InitCommonControlsEx(@icc)
	If res = 0 Then
		Dim dwError As DWORD = GetLastError()
		Return HRESULT_FROM_WIN32(dwError)
	End If
	
	Return S_OK
	
End Function

Private Function tWinMain Alias "tWinMain"( _
		Byval hInst As HINSTANCE, _
		ByVal hPrevInstance As HINSTANCE, _
		ByVal lpCmdLine As LPTSTR, _
		ByVal iCmdShow As Long _
	)As Long
	
	Dim hrVisualStyles As HRESULT = EnableVisualStyles()
	If FAILED(hrVisualStyles) Then
		Dim dwError As DWORD = GetLastError()
		DisplayError(hInst, NULL, dwError, IDS_COMMONCONTROLS_ERR)
		Return 1
	End If
	
	Dim Parameter As DialogData = Any
	Parameter.hInst = hInst
	
	Dim DialogBoxParamResult As INT_PTR = DialogBoxParam( _
		hInst, _
		MAKEINTRESOURCE(IDD_DLG_INPUTDATA), _
		NULL, _
		@InputDataDialogProc, _
		Cast(LPARAM, @Parameter) _
	)
	
	If DialogBoxParamResult = -1 Then
		Dim dwError As DWORD = GetLastError()
		DisplayError(hInst, NULL, dwError, IDS_DIALOGBOXPARAM_ERR)
		Return 1
	End If
	
	Return 0
	
End Function

#ifndef WITHOUT_RUNTIME
Private Function EntryPoint()As Integer
#else
Public Function EntryPoint Alias "EntryPoint"()As Integer
#endif
	
	Dim hInst As HMODULE = GetModuleHandle(NULL)
	
	' The program does not process command line parameters
	Dim Arguments As LPTSTR = NULL
	Dim RetCode As Integer = tWinMain( _
		hInst, _
		NULL, _
		Arguments, _
		SW_SHOW _
	)
	
	#ifdef WITHOUT_RUNTIME
		ExitProcess(RetCode)
	#endif
	
	Return RetCode
	
End Function

#ifndef WITHOUT_RUNTIME
Dim RetCode As Long = CLng(EntryPoint())
End(RetCode)
#endif
