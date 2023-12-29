@echo off

:path
call "%~dp0[0]set_path.bat"

:start
IF "%~1"=="" GOTO :end

if not exist "%~dp1\torrent" mkdir "%~dp1\torrent%
%py% %tu% --preset %tu_json% -m create -p 0 -y "%~nx1"
move "%~nx1.torrent" ".\torrent"

:check
SHIFT /1
GOTO :start

:End
pause