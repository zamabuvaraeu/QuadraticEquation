#include once "DisplayError.bi"

#ifdef UNICODE
Sub DisplayErrorW Alias "DisplayErrorW"( _
		ByVal dwErrorCode As DWORD, _
		ByVal Caption As LPCWSTR _
	)
	
	Dim Buffer(511) As WCHAR = Any
	_itow(dwErrorCode, @Buffer(0), 10)
	
	MessageBoxW(0, @Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif

#ifndef UNICODE
Sub DisplayErrorA Alias "DisplayErrorA"( _
		ByVal dwErrorCode As DWORD, _
		ByVal Caption As LPCSTR _
	)
	
	Dim Buffer(511) As CHAR = Any
	_itoa(dwErrorCode, @Buffer(0), 10)
	
	MessageBoxA(0, @Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif

#ifdef UNICODE
Sub DisplayHresultW Alias "DisplayHresultW"( _
		ByVal dwErrorCode As HRESULT, _
		ByVal Caption As LPCWSTR _
	)
	
	Dim Buffer(511) As WCHAR = Any
	_itow(dwErrorCode, @Buffer(0), 16)
	
	MessageBoxW(0, @Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif

#ifndef UNICODE
Sub DisplayHresultA Alias "DisplayHresultA"( _
		ByVal dwErrorCode As HRESULT, _
		ByVal Caption As LPCSTR _
	)
	
	Dim Buffer(511) As CHAR = Any
	_itoa(dwErrorCode, @Buffer(0), 16)
	
	MessageBoxA(0, @Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif
