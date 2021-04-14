#ifndef DISPLAYERROR_BI
#define DISPLAYERROR_BI

#include once "windows.bi"

Declare Sub DisplayErrorA Alias "DisplayErrorA"( _
	ByVal dwErrorCode As DWORD, _
	ByVal Caption As LPCSTR _
)

#ifndef UNICODE
Declare Sub DisplayError Alias "DisplayErrorA"( _
	ByVal dwErrorCode As DWORD, _
	ByVal Caption As LPCSTR _
)
#endif

Declare Sub DisplayErrorW Alias "DisplayErrorW"( _
	ByVal dwErrorCode As DWORD, _
	ByVal Caption As LPCWSTR _
)

#ifdef UNICODE
Declare Sub DisplayError Alias "DisplayErrorW"( _
	ByVal dwErrorCode As DWORD, _
	ByVal Caption As LPCWSTR _
)
#endif

Declare Sub DisplayHresultA Alias "DisplayHresultA"( _
	ByVal dwErrorCode As HRESULT, _
	ByVal Caption As LPCSTR _
)

#ifndef UNICODE
Declare Sub DisplayHresult Alias "DisplayHresultA"( _
	ByVal dwErrorCode As HRESULT, _
	ByVal Caption As LPCSTR _
)
#endif

Declare Sub DisplayHresultW Alias "DisplayHresultW"( _
	ByVal dwErrorCode As HRESULT, _
	ByVal Caption As LPCWSTR _
)

#ifdef UNICODE
Declare Sub DisplayHresult Alias "DisplayHresultW"( _
	ByVal dwErrorCode As HRESULT, _
	ByVal Caption As LPCWSTR _
)
#endif

#endif
