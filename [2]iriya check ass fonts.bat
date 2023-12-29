@echo off
:path
call "%~dp0[0]set_path.bat"
echo checking if there is missing character
:start
IF "%~1"=="" GOTO :end

%py% -miriya --log-level warn "%~dpnx1" 2>>ass_warn.log

SHIFT /1
GOTO :start

:end
@echo.

call :filesize ass_warn.log
:filesize
set filesize=%~z1
if %filesize%==0 echo no missing characters

for /f "tokens=*" %%a in (ass_warn.log) do (
	if not %filesize%==0 echo %%a
)

del ass_warn.log
@echo.
pause