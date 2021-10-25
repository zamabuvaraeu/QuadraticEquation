#include once "DisplayError.bi"

Const WCHARFIXEDVECTOR_CAPACITY As Integer = 512

Type WCharFixedVector
	Buffer(WCHARFIXEDVECTOR_CAPACITY - 1) As WCHAR
End Type

Type CharFixedVector
	Buffer(WCHARFIXEDVECTOR_CAPACITY - 1) As CHAR
End Type

#ifdef UNICODE
Sub DisplayErrorW Alias "DisplayErrorW"( _
		ByVal dwErrorCode As DWORD, _
		ByVal Caption As LPCWSTR _
	)
	
	Dim Buffer As WCharFixedVector = Any
	_itow(dwErrorCode, @Buffer.Buffer(0), 10)
	
	MessageBoxW(0, @Buffer.Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif

#ifndef UNICODE
Sub DisplayErrorA Alias "DisplayErrorA"( _
		ByVal dwErrorCode As DWORD, _
		ByVal Caption As LPCSTR _
	)
	
	Dim Buffer As CharFixedVector = Any
	_itoa(dwErrorCode, @Buffer.Buffer(0), 10)
	
	MessageBoxA(0, @Buffer.Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif

#ifdef UNICODE
Sub DisplayHresultW Alias "DisplayHresultW"( _
		ByVal dwErrorCode As HRESULT, _
		ByVal Caption As LPCWSTR _
	)
	
	Dim Buffer As WCharFixedVector = Any
	_itow(dwErrorCode, @Buffer.Buffer(0), 10)
	
	MessageBoxW(0, @Buffer.Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif

#ifndef UNICODE
Sub DisplayHresultA Alias "DisplayHresultA"( _
		ByVal dwErrorCode As HRESULT, _
		ByVal Caption As LPCSTR _
	)
	
	Dim Buffer As CharFixedVector = Any
	_itoa(dwErrorCode, @Buffer.Buffer(0), 10)
	
	MessageBoxA(0, @Buffer.Buffer(0), Caption, MB_ICONERROR)
	
End Sub
#endif
