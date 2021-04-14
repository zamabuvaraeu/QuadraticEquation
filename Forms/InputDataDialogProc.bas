#include once "InputDataDialogProc.bi"
#include once "win\ole2.bi"
#include once "win\oleauto.bi"
#include once "DisplayError.bi"
#include once "Resources.RH"
#include once "crt.bi"

Const DIALOGBOXPARAM_ERRORSTRING = __TEXT("Failed to show OutputDataDialog")
Const CONVERT_ERRORSTRING = __TEXT("Failed to convert String to Double")

Function GetDlgItemDoubletW( _
		ByVal hwndDlg As HWND, _
		ByVal resID As ULONG _
	)As Double
	
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
		Return 0.0
	End If
	
	Return Value
	
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
			
		Case WM_COMMAND
			Select Case LOWORD(wParam)
				
				Case IDOK
					SetDlgItemTextW( _
						hwndDlg, _
						IDC_EDT_ROOTX1, _
						NULL _
					)
					SetDlgItemTextW( _
						hwndDlg, _
						IDC_EDT_ROOTX2, _
						NULL _
					)
					
					Dim CoefficientA As Double = GetDlgItemDoubletW(hwndDlg, IDC_EDT_COEFFICIENTA)
					
					If CoefficientA = 0.0 Then
						Dim tszCoefficientAIsZero(1023) As TCHAR = Any
						Dim ret As Long = LoadString( _
							GetModuleHandle(NULL), _
							IDS_COEFFICIENTAZERO, _
							@tszCoefficientAIsZero(0), _
							1023 _
						)
						tszCoefficientAIsZero(ret) = 0
						MessageBox(hwndDlg, @tszCoefficientAIsZero(0), NULL, MB_OK Or MB_ICONERROR)
					Else
						Dim CoefficientB As Double = GetDlgItemDoubletW(hwndDlg, IDC_EDT_COEFFICIENTB)
						Dim CoefficientC As Double = GetDlgItemDoubletW(hwndDlg, IDC_EDT_COEFFICIENTC)
						
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
							MessageBox(hwndDlg, @tszDiscriminantLessZero(0), NULL, MB_OK Or MB_ICONERROR)
						Else
							Dim X1 As Double = (-1.0 * CoefficientB + sqrt(D)) / (2.0 * CoefficientA)
							Dim X2 As Double = (-1.0 * CoefficientB - sqrt(D)) / (2.0 * CoefficientA)
							
							Dim bstrX1 As BSTR = Any
							VarBstrFromR8(X1, 0, 0, @bstrX1)
							
							Dim bstrX2 As BSTR = Any
							VarBstrFromR8(X2, 0, 0, @bstrX2)
							
							If bstrX1 <> NULL Then
								SetDlgItemTextW( _
									hwndDlg, _
									IDC_EDT_ROOTX1, _
									bstrX1 _
								)
							End If
							
							If bstrX2 <> NULL Then
								SetDlgItemTextW( _
									hwndDlg, _
									IDC_EDT_ROOTX2, _
									bstrX2 _
								)
							End If
							
							SysFreeString(bstrX1)
							SysFreeString(bstrX2)
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
