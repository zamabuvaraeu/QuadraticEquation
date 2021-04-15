# QuadraticEquation

Решение квадратного уравнения

## Компиляция

Стандартная команда:

```BatchFile
mingw32-make WITHOUT_RUNTIME_FLAG=true WITHOUT_CRITICAL_SECTIONS_FLAG=true UNICODE_FLAG=true
```

### Необходимые пререквизиты

Я использую кодогенератор `-gen gcc`, поэтому для x86 версии необходимо дополнительно поставить `gcc`.

Также ставим `mingw`, в которой есть утилита `make` (там она называется `mingw32-make`). В подарок получаем отладчик `gdb`, отсутствующий в x64 версии FreeBASIC.

### Путь к компилятору и инструментам

По умолчанию считается, что FreeBASIC лежит в папке `%ProgramFiles%\FreeBASIC`. Если это не так, необходимо установить переменные среды:

```BatchFile
set GCC_VERSION_SUFFIX=GCC520
set UNICODE_FLAG=true
set WITHOUT_RUNTIME_FLAG=true
set WITHOUT_CRITICAL_SECTIONS_FLAG=true
set PERFORMANCE_TESTING_FLAG=false
set MULTITHREAD_RUNTIME_FLAG=false
set FREEBASIC_COMPILER="%ProgramFiles%\FreeBASIC\fbc.exe"
set GCC_COMPILER=      "%ProgramFiles%\FreeBASIC\bin\win64\gcc.exe"
set GCC_ASSEMBLER=     "%ProgramFiles%\FreeBASIC\bin\win64\as.exe"
set GCC_LINKER=        "%ProgramFiles%\FreeBASIC\bin\win64\ld.exe"
set ARCHIVE_COMPILER=  "%ProgramFiles%\FreeBASIC\bin\win64\ar.exe"
set DLL_TOOL=          "%ProgramFiles%\FreeBASIC\bin\win64\dlltool.exe"
set RESOURCE_COMPILER= "%ProgramFiles%\FreeBASIC\bin\win64\GoRC.exe"
set COMPILER_LIB_PATH= "%ProgramFiles%\FreeBASIC\lib\win64"
set FB_EXTRA=          "%ProgramFiles%\FreeBASIC\lib\win64\fbextra.x"
```
