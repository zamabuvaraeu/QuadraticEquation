#ifndef FULLSCREENWINDOW_BI
#define FULLSCREENWINDOW_BI

#include once "windows.bi"

Declare Function WinMain Alias "WinMain"( _
	Byval hInst As HINSTANCE, _
	ByVal hPrevInstance As HINSTANCE, _
	ByVal lpCmdLine As LPSTR, _
	ByVal iCmdShow As Long _
)As Long

#ifndef UNICODE
Declare Function tWinMain Alias "WinMain"( _
	Byval hInst As HINSTANCE, _
	ByVal hPrevInstance As HINSTANCE, _
	ByVal lpCmdLine As LPSTR, _
	ByVal iCmdShow As Long _
)As Long
#endif

Declare Function wWinMain Alias "wWinMain"( _
	Byval hInst As HINSTANCE, _
	ByVal hPrevInstance As HINSTANCE, _
	ByVal lpCmdLine As LPWSTR, _
	ByVal iCmdShow As Long _
)As Long

#ifdef UNICODE
Declare Function tWinMain Alias "wWinMain"( _
	Byval hInst As HINSTANCE, _
	ByVal hPrevInstance As HINSTANCE, _
	ByVal lpCmdLine As LPWSTR, _
	ByVal iCmdShow As Long _
)As Long
#endif

#endif
