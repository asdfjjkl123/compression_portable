@echo off
chcp 65001
:path
call "%~dp0[0]set_path.bat"

:branch
set files=0

:start
IF "%~1"=="" GOTO :end

if exist "%~dp1outfonts.txt" del "%~dp1outfonts.txt"

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
%assfontsubset% %sc% %tc%

:listfonts
::list output fonts
for %%a in ("%~dp1output\*.ttf") do echo %%a >> "%~dp1outfonts.txt"
for %%a in ("%~dp1output\*.otf") do echo %%a >> "%~dp1outfonts.txt"
set line=0
set linenum=1
for /f "delims=[,] tokens=1" %%a in ('find "" "%~dp1outfonts.txt" /v /n') do (set line=%%a)
set /p fontstemp=<"%~dp1outfonts.txt"
set subsetcommand=--attachment-mime-type application/x-truetype-font --attach-file "%fontstemp%"

:readfonts
more +1 "%~dp1outfonts.txt" > "%~dp1outfonts.tmp"
del "%~dp1outfonts.txt"
ren "%~dp1outfonts.tmp" outfonts.txt

set /p fontstemp=<"%~dp1outfonts.txt"
set subsetcommand=%subsetcommand% --attachment-mime-type application/x-truetype-font --attach-file "%fontstemp%"

set /a linenum+=1
if %linenum%==%line% goto :mux
goto :readfonts

:mux
del "%~dp1outfonts.txt"
%mmg% -o "%~dpn1_subset.mkv" --language 0:und --no-subtitles --no-attachments "%~dpn1.mkv" --language 0:und --default-track 0:yes --track-name "0:SC" %sc% --language 0:und --default-track 0:yes --track-name "0:TC" %tc% %subsetcommand%

SHIFT /1
GOTO :start

:end
echo subset finish
pause