#include once "windows.bi"

Declare Function wWinMain( _
	Byval hInst As HINSTANCE, _
	ByVal hPrevInstance As HINSTANCE, _
	ByVal lpCmdLine As LPWSTR, _
	ByVal iCmdShow As Long _
)As Long

#ifdef WITHOUT_RUNTIME
Sub EntryPoint()
#else
Function main Alias "main"()As Long
#endif
	
	Dim RetCode As Long = wWinMain( _
		GetModuleHandle(0), _
		NULL, _
		GetCommandLineW(), _
		SW_SHOW _
	)
	
	ExitProcess(RetCode)
	
#ifdef WITHOUT_RUNTIME
End Sub
#else
End Function
#endif
