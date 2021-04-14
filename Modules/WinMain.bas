#include once "windows.bi"
#include once "win\commctrl.bi"
#include once "InputDataDialogProc.bi"
#include once "Resources.RH"
#include once "DisplayError.bi"

Const COMMONCONTROLS_ERRORSTRING = __TEXT("Failed to register Common Controls")
Const DIALOGBOXPARAM_ERRORSTRING = __TEXT("Failed to show InputDataDialog")

Function wWinMain( _
		Byval hInst As HINSTANCE, _
		ByVal hPrevInstance As HINSTANCE, _
		ByVal lpCmdLine As LPWSTR, _
		ByVal iCmdShow As Long _
	)As Long
	
	Scope
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
		
		If InitCommonControlsEx(@icc) = False Then
			DisplayError(GetLastError(), COMMONCONTROLS_ERRORSTRING)
			Return 1
		End If
	End Scope
	
	Dim DialogBoxParamResult As INT_PTR = DialogBoxParam( _
		hInst, _
		MAKEINTRESOURCE(IDD_DLG_INPUTDATA), _
		NULL, _
		@InputDataDialogProc, _
		Cast(LPARAM, 0) _
	)
	If DialogBoxParamResult = -1 Then
		DisplayError(GetLastError(), DIALOGBOXPARAM_ERRORSTRING)
		Return 2
	End If
	
	Return 0
	
End Function
