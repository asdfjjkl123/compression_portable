@echo off
chcp 65001
:path
call "%~dp0[0]set_path.bat"

:branch
set files=0

:start
IF "%~1"=="" GOTO :end

if exist "ass_warn.log" del "ass_warn.log"
if exist "temp.bat" del "temp.bat"

set /a files+=1
set continue=0
set mkv="%~1"
set sc=""
set tc=""
set jpsc=0
set jptc=0
if exist "%~n1.SC.ass" set sc="%~n1.SC.ass"
if exist "%~n1.TC.ass" set tc="%~n1.TC.ass"
if exist "%~n1.CHS.ass" set sc="%~n1.CHS.ass"
if exist "%~n1.CHT.ass" set tc="%~n1.CHT.ass"
if exist "%~n1.JPSC.ass" set sc="%~n1.JPSC.ass"
if exist "%~n1.JPTC.ass" set tc="%~n1.JPTC.ass"
if exist "%~n1.JPSC.ass" set jpsc=1
if exist "%~n1.JPTC.ass" set jptc=1

@echo.
echo start muxing file no%files%. "%~n1"
@echo.
::check ass file
if %sc%=="" set /p continue=there is no sc ass do you want to continue (0: yes, 1:no):
if %continue%==1 goto :end
if %tc%=="" set /p continue=there is no tc ass do you want to continue (0: yes, 1:no):
if %continue%==1 goto :end

::check fonts file dir
if not exist "%~dp1fonts\" set %continue%=1
if %continue%==1 echo fonts files does not exist please check
if %continue%==1 goto :end

::check input ass character missing
echo checking if there is missing character
%py% -miriya --log-level warn %sc% %tc% 2>>ass_warn.log
for %%i in (ass_warn.log) do set filesize=%%~zi
if %filesize%==0 echo no missing characters
for /f "tokens=*" %%a in (ass_warn.log) do (
	if not %filesize%==0 echo %%a
)
del ass_warn.log
echo.
if not %filesize%==0 set /p continue=find missing character do you want to continue (0: yes, 1:no):
if %continue%==1 goto :end

%assfontsubset% %sc% %tc%

:checkoutput
set sc=""
set tc=""
if exist "%~dp1output\%~n1.CHS.ass" set sc="%~dp1output\%~n1.CHS.ass"
if exist "%~dp1output\%~n1.CHT.ass" set tc="%~dp1output\%~n1.CHT.ass"
if exist "%~dp1output\%~n1.SC.ass" set sc="%~dp1output\%~n1.SC.ass"
if exist "%~dp1output\%~n1.TC.ass" set tc="%~dp1output\%~n1.TC.ass"
if exist "%~dp1output\%~n1.JPSC.ass" set sc="%~dp1output\%~n1.JPSC.ass"
if exist "%~dp1output\%~n1.JPTC.ass" set tc="%~dp1output\%~n1.JPTC.ass"
::check assfontsubset error
if %sc%=="" set /p continue=assfontsubset output sc ass error do you want to continue (0: yes, 1:no):
if %continue%==1 goto :end
if %tc%=="" set /p continue=assfontsubset output tc ass error do you want to continue (0: yes, 1:no):
if %continue%==1 goto :end
:loadoutputfonts
setlocal enabledelayedexpansion
set com=
for %%a in ("%~dp1output\*.ttf") do (set com=!com! "%%a")
for %%a in ("%~dp1output\*.otf") do (set com=!com! "%%a")
echo chcp 65001>>temp.bat
echo %fontloader% !com!>>temp.bat
echo exit>>temp.bat
endlocal
start temp.bat
timeout 10

::check output ass character missing
echo checking if there is missing character

%py% -miriya --log-level warn %sc% %tc% 2>>ass_warn.log
for %%i in (ass_warn.log) do set filesize=%%~zi
if %filesize%==0 echo no missing characters
for /f "tokens=*" %%a in (ass_warn.log) do (
	if not %filesize%==0 echo %%a
)

taskkill /im FontLoader.exe
timeout 2
if exist "temp.bat" del "temp.bat"

echo.
if not %filesize%==0 echo if ass contains \N or \h or somethings like them, finding missing character "\" is totally normal.
if not %filesize%==0 set /p continue=find missing character do you want to continue (0: yes, 1:no):
if %continue%==1 goto :end

del ass_warn.log

:mux
if exist "%~dpn1_subset.mkv" set /p continue=find "%~n1_subset.mkv" do you want to continue (0: yes, 1:no(stop)):
if %continue%==1 goto :end
if %continue%==0 del "%~dpn1_subset.mkv"

%mmg% -o "%~dpn1_subset.mkv" --language 0:und --no-subtitles --no-attachments "%~dpn1.mkv" --language 0:und --default-track 0:yes --track-name "0:SC" %sc% --language 0:und --default-track 0:yes --track-name "0:TC" %tc% %subsetcommand%


SHIFT /1
GOTO :start

:end
pause
