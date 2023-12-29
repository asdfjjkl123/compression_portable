@echo off
chcp 65001
:path
call "%~dp0[0]set_path.bat"

:start
IF "%~1"=="" GOTO :end

if "%~x1"==mkv %eac3to% "%~1" "%~dpn1.flac" -log=nul
%qaac64% -v 192 --no-smart-padding --threading -o "%~dp1%~n1.aac" "%~dp1%~n1.flac"

SHIFT /1
GOTO :start

:end
pause