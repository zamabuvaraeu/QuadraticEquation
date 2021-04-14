#ifndef INPUTDATADIALOGPROC_BI
#define INPUTDATADIALOGPROC_BI

#include once "windows.bi"

Declare Function InputDataDialogProc( _
	ByVal hwndDlg As HWND, _
	ByVal uMsg As UINT, _
	ByVal wParam As WPARAM, _
	ByVal lParam As LPARAM _
)As INT_PTR

#endif
