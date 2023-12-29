@echo off
:path
call "%~dp0[0]set_path.bat"

%eac3to% "%~dpnx1"
set /p track=please select track to extract:
set /a track=%track%-1
set /p extension=please set file extension:

:start
if "%~1"=="" goto :end

%mkvextract% "%~dpnx1" tracks %track%:"%~dpn1.%extension%"

SHIFT /1
GOTO :start

:end
pause