@echo off
:path
call "%~dp0[0]set_path.bat"

%eac3to% "%~dpnx1"
set /p track=please select track to extract:
set /p extension=please set file extension:

:start
if "%~1"=="" goto :end

%eac3to% "%~dpnx1" %track%: "%~dpn1.%extension%" -log=nul

SHIFT /1
GOTO :start

:end
pause