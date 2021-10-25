#include once "windows.bi"
#include once "WinMain.bi"

#ifdef WITHOUT_RUNTIME
Sub EntryPoint()
#else
Function main Alias "main"()As Long
#endif
	
	Dim RetCode As Long = tWinMain( _
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
