@echo off
:path
call "%~dp0[0]set_path.bat"

:branch
set /p resolution=Please select output videos' resolution (0: 1080p, 1: 720p, 2:1080p+720p):
set /p subfilter=Please select subfilter (0:assrender , 1: xyvsf, 2:vsfm):
if %subfilter%==0 set subfilter=assrender.TextSub
if %subfilter%==1 set subfilter=xyvsf.TextSub
if %subfilter%==2 set subfilter=vsfm.TextSubMod

set x264info=--demuxer y4m --threads 16 --preset slow --crf 23 --deblock 1:-1 --keyint 300 --min-keyint 1 --ref 6 --qpmax 36 --chroma-qp-offset 2 --me hex --psy-rd 0.60:0.15 --no-fast-pskip --colormatrix bt709 --colorprim bt709 --transfer bt709

set files=0
set sconly=0
set tconly=0


:start
if "%~1"=="" goto :end
set /a files+=1
set mkv="%~1"
set sc=0
set tc=0
set jpsc=0
set jptc=0
if exist "%~dpn1.SC.ass" set sc="%~dpn1.SC.ass"
if exist "%~dpn1.TC.ass" set tc="%~dpn1.TC.ass"
if exist "%~dpn1.CHS.ass" set sc="%~dpn1.CHS.ass"
if exist "%~dpn1.CHT.ass" set tc="%~dpn1.CHT.ass"
if exist "%~dpn1.JPSC.ass" set sc="%~dpn1.JPSC.ass"
if exist "%~dpn1.JPTC.ass" set tc="%~dpn1.JPTC.ass"
if exist "%~dpn1.JPSC.ass" set jpsc=1
if exist "%~dpn1.JPTC.ass" set jptc=1

set Audio_Quality=192

::check mp4 exist
set f720sexist=0
set f720texist=0
set f1080sexist=0
set f1080texist=0
if exist "%~n1_720p_tc.mp4" set f720texist=1
if exist "%~n1_720p_jptc.mp4" set f720texist=1
if exist "%~n1_720p_sc.mp4" set f720sexist=1
if exist "%~n1_720p_jpsc.mp4" set f720sexist=1
if exist "%~n1_1080p_tc.mp4" set f1080texist=1
if exist "%~n1_1080p_jptc.mp4" set f1080texist=1
if exist "%~n1_1080p_sc.mp4" set f1080sexist=1
if exist "%~n1_1080p_jpsc.mp4" set f1080sexist=1

set f720tcover=1
set f720scover=1
set f1080tcover=1
set f1080scover=1
if %f720texist%==1 set /p f720tcover=%~n1 720tc already exist cover it?(0:no, 1:yes):
if %f720sexist%==1 set /p f720scover=%~n1 720sc already exist cover it?(0:no, 1:yes):
if %f1080texist%==1 set /p f1080tcover=%~n1 1080tc already exist cover it?(0:no, 1:yes):
if %f1080sexist%==1 set /p f1080scover=%~n1 1080sc already exist cover it?(0:no, 1:yes):

::audio
set name="%~nx1"
set flac=0
echo %name% |findstr /i "FLAC" >nul
if %errorlevel%==0 set flac=1

if not exist "%~dpn1.aac" (
	if exist "%~dpn1.flac" echo not find aac file start generating aac file
	if exist "%~dpn1.flac" %qaac64% -v %Audio_Quality% --no-smart-padding --threading -o "%~dpn1.aac" "%~dpn1.flac"
)

if not exist "%~dpn1.aac" (
	echo not find aac file start generating aac file
	if %flac%==1 %eac3to% "%~dpnx1" 2:"%~dpn1.flac" -log=nul
	if %flac%==1 %qaac64% -v %Audio_Quality% --no-smart-padding --threading -o "%~dpn1.aac" "%~dpn1.flac"
	if %flac%==0 %eac3to% "%~dpnx1" 2:"%~dpn1.aac" -log=nul
)

::check ass exist
set continue=3
if %tconly%==0 (
	if %sc%==0 set /p continue=there is no sc ass do you want to continue [0: yes, 1:no, 2: tc only]:
)
if %continue%==1 goto :end
if %continue%==2 set tconly=1
if %tconly%==1 set continue=0


if %sconly%==0 (
	if %tc%==0 set /p continue=there is no tc ass do you want to continue [0: yes, 1:no, 2: sc only]:
)
if %continue%==1 goto :end
if %continue%==2 set sconly=1
if %sconly%==1 set continue=0

::check character missing
echo checking if there is missing character
if %tc%==0 %py% -miriya --log-level warn %sc% 2>>ass_warn.log
if %sc%==0 %py% -miriya --log-level warn %tc% 2>>ass_warn.log
if not %sc% ==0 (
	if not %tc%==0 %py% -miriya --log-level warn %sc% %tc% 2>>ass_warn.log
)
for %%i in (ass_warn.log) do set filesize=%%~zi
if %filesize%==0 echo no missing characters
for /f "tokens=*" %%a in (ass_warn.log) do (
	if not %filesize%==0 echo %%a
)
del ass_warn.log
echo.
if not %filesize%==0 set /p continue=find missing character do you want to continue (0: yes, 1:no):
if %continue%==1 goto :end

::resolution
if %resolution%==0 goto :1080p
if %resolution%==1 goto :720p
if %resolution%==2 goto :1080p

::------------------------------------------------------------------------------------------
:writecode_pre
if exist "%~dpnx1_%resst%.vpy" del "%~dpnx1_%resst%.vpy"
(
echo import vapoursynth as vs
echo import sys
echo import mvsfunc as mvf
echo from vapoursynth import core
echo source = r%mkv%
echo src = core.lsmas.LWLibavSource^(source,format="yuv420p10",cache=0^)
echo src = mvf.Depth^(src,depth=8^)
)>>"%~dpnx1_%resst%.vpy"
goto :callback_pre%resst%
::------------------------------------------------------------------------------------------
:writecode_post
if %res720%==0 echo res = core.%subfilter%(src,ass).set_output() >>"%~dpnx1_%resst%.vpy"
if %res720%==1 echo res = core.%subfilter%(src,ass).fmtc.resample(1280,720,kernel="lanczos",taps=4).set_output() >>"%~dpnx1_%resst%.vpy"
set jpname="%~n1_%resst%.mp4"
%vspipe% --y4m "%~dpnx1_%resst%.vpy" - | %x264% %x264info% --output "%~n1_%resst%.264" -
%mp4box% -add "%~n1_%resst%.264" -add "%~dpn1.aac" -new "%~n1_%resst%.mp4"
if exist "%~n1_%resst%.mp4" del "%~dpnx1_%resst%.vpy"
if exist "%~n1_%resst%.mp4" del "%~n1_%resst%.264"
if %jpsc%==1 ren "%~n1_%resst%.mp4" %jpname:_CHS=_JPSC%
if %jptc%==1 ren "%~n1_%resst%.mp4" %jpname:_CHT=_JPTC%

goto :callback_post%resst%
::------------------------------------------------------------------------------------------

:1080p
:1080sc
if %sc%==0 goto :1080tc
if %f1080scover%==0 goto :1080scfinish

set resst=1080p_CHS
set res720=0
goto :writecode_pre
:callback_pre1080p_CHS
echo ass = r%sc% >>"%~dpnx1_%resst%.vpy"
goto :writecode_post
:callback_post1080p_CHS

:1080scfinish
if %tc%==0 (
	if %resolution%==2 goto :720sc
	if %resolution%==0 shift /1
	if %resolution%==0 goto :start
)

:1080tc
if %f1080tcover%==0 goto :1080tcfinish

set resst=1080p_CHT
set res720=0
goto :writecode_pre
:callback_pre1080p_CHT
echo ass = r%tc% >>"%~dpnx1_%resst%.vpy"
goto :writecode_post
:callback_post1080p_CHT

:1080tcfinish
if %resolution%==2 goto :720p
shift /1
goto :start

:720p
:720sc
if %sc%==0 goto :720tc
if %f720scover%==0 goto :720scfinish

set resst=720p_CHS
set res720=1
goto :writecode_pre
:callback_pre720p_CHS
echo ass = r%tc% >>"%~dpnx1_%resst%.vpy"
goto :writecode_post
:callback_post720p_CHS

:720scfinish
if %tc%==0 shift /1
if %tc%==0 goto :start

:720tc
if %f720tcover%==0 goto :720tcfinish

set resst=720p_CHT
set res720=1
goto :writecode_pre
:callback_pre720p_CHT
echo ass = r%tc% >>"%~dpnx1_%resst%.vpy"
goto :writecode_post
:callback_post720p_CHT

:720tcfinish
shift /1
goto :start


:end
echo coding finish
pause
exit