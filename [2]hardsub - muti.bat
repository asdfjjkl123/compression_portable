::@echo off
:path
call "%~dp0[0]set_path.bat"

:branch
set /p resolution=Please select output videos' resolution (0: 1080p, 1: 720p, 2:1080p+720p):
set /p subfilter=Please select subfilter (0: xyvsf, 1: assrender, 2:vsfm):

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
if exist "%~n1.SC.ass" set sc="%~n1.SC.ass"
if exist "%~n1.TC.ass" set tc="%~n1.TC.ass"
if exist "%~n1.CHS.ass" set sc="%~n1.CHS.ass"
if exist "%~n1.CHT.ass" set tc="%~n1.CHT.ass"
if exist "%~n1.JPSC.ass" set sc="%~n1.JPSC.ass"
if exist "%~n1.JPTC.ass" set tc="%~n1.JPTC.ass"
if exist "%~n1.JPSC.ass" set jpsc=1
if exist "%~n1.JPTC.ass" set jptc=1

set Audio_Quality=192

::check mp4 exist
set f720sexist=0
set f720texist=0
set f1080sexist=0
set f1080texist=0
if exist "%~n1[720p][CHT].mp4" set f720texist=1
if exist "%~n1[720p][JPTC].mp4" set f720texist=1
if exist "%~n1[720p][CHS].mp4" set f720sexist=1
if exist "%~n1[720p][JPSC].mp4" set f720sexist=1
if exist "%~n1[1080p][CHT].mp4" set f1080texist=1
if exist "%~n1[1080p][JPTC].mp4" set f1080texist=1
if exist "%~n1[1080p][CHS].mp4" set f1080sexist=1
if exist "%~n1[1080p][JPSC].mp4" set f1080sexist=1

set f720tcover=1
set f720scover=1
set f1080tcover=1
set f1080scover=1
if %f720texist%==1 set /p f720tcover=720tc already exist cover it?(0:no, 1:yes):
if %f720sexist%==1 set /p f720scover=720sc already exist cover it?(0:no, 1:yes):
if %f1080texist%==1 set /p f1080tcover=1080tc already exist cover it?(0:no, 1:yes):
if %f1080sexist%==1 set /p f1080scover=1080sc already exist cover it?(0:no, 1:yes):

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
:writecode
::echo title file no%files%. "%~n1" 1080p sc

::------------------------------------------------------------------------------------------
:1080p
:1080sc
if %sc%==0 goto :1080tc
if %f1080scover%==0 goto :1080scfinish

if exist "%~dpnx1_720_tc.vpy" del "%~dpnx1_1080_sc.vpy"
if exist "%~dpnx1_720_tc.bat" del "%~dpnx1_1080_sc.bat"
echo import vapoursynth as vs >>"%~dpnx1_1080_sc.vpy"
echo import sys >>"%~dpnx1_1080_sc.vpy"
echo import mvsfunc as mvf >>"%~dpnx1_1080_sc.vpy"
echo from vapoursynth import core >>"%~dpnx1_1080_sc.vpy"
echo source = r%mkv% >>"%~dpnx1_1080_sc.vpy"
echo ass = r%sc% >>"%~dpnx1_1080_sc.vpy"
echo src = core.lsmas.LWLibavSource(source,format="yuv420p10") >>"%~dpnx1_1080_sc.vpy"
echo src = mvf.Depth(src,depth=8) >>"%~dpnx1_1080_sc.vpy"
if %subfilter%==0 echo res = core.xyvsf.TextSub(src,ass).set_output() >>"%~dpnx1_1080_sc.vpy"
if %subfilter%==1 echo res = core.assrender.TextSub(src,ass).set_output() >>"%~dpnx1_1080_sc.vpy"
if %subfilter%==2 echo res = core.vsfm.TextSubMod(src,ass).set_output() >>"%~dpnx1_1080_sc.vpy"

echo %vspipe% --y4m "%~dpnx1_1080_sc.vpy" - ^| %x264% %x264info% --output "%~n1_1080p_sc.264" ->>"%~dpnx1_1080_sc.bat"
if %jpsc%==0 echo %mp4box% -add "%~n1_1080p_sc.264" -add "%~dpn1.aac" -new "%~n1[1080p][CHS].mp4">>"%~dpnx1_1080_sc.bat"
if %jpsc%==1 echo %mp4box% -add "%~n1_1080p_sc.264" -add "%~dpn1.aac" -new "%~n1[1080p][JPSC].mp4">>"%~dpnx1_1080_sc.bat"

echo if exist "%~n1[1080p][CHS].mp4" del "%~dpnx1_1080_sc.vpy">>"%~dpnx1_1080_sc.bat"
echo if exist "%~n1[1080p][CHS].mp4" del "%~n1_1080p_sc.264">>"%~dpnx1_1080_sc.bat"
echo if exist "%~n1[1080p][JPSC].mp4" del "%~dpnx1_1080_sc.vpy">>"%~dpnx1_1080_sc.bat"
echo if exist "%~n1[1080p][JPSC].mp4" del "%~n1_1080p_sc.264">>"%~dpnx1_1080_sc.bat"
echo exit>>"%~dpnx1_1080_sc.bat"
timeout 1
start "coding %~n1 1080p sc" "%~dpnx1_1080_sc.bat"
:1080scfinish
if %tc%==0 (
	if %resolution%==2 goto :720sc
	if %resolution%==0 shift /1
	if %resolution%==0 goto :start
)

:1080tc
if %f1080tcover%==0 goto :1080tcfinish

if exist "%~dpnx1_720_tc.vpy" del "%~dpnx1_1080_tc.vpy"
if exist "%~dpnx1_720_tc.bat" del "%~dpnx1_1080_tc.bat"
echo import vapoursynth as vs >>"%~dpnx1_1080_tc.vpy"
echo import sys >>"%~dpnx1_1080_tc.vpy"
echo import mvsfunc as mvf >>"%~dpnx1_1080_tc.vpy"
echo from vapoursynth import core >>"%~dpnx1_1080_tc.vpy"
echo source = r%mkv% >>"%~dpnx1_1080_tc.vpy"
echo ass = r%tc% >>"%~dpnx1_1080_tc.vpy"
echo src = core.lsmas.LWLibavSource(source,format="yuv420p10") >>"%~dpnx1_1080_tc.vpy"
echo src = mvf.Depth(src,depth=8) >>"%~dpnx1_1080_tc.vpy"
if %subfilter%==0 echo res = core.xyvsf.TextSub(src,ass).set_output() >>"%~dpnx1_1080_tc.vpy"
if %subfilter%==1 echo res = core.assrender.TextSub(src,ass).set_output() >>"%~dpnx1_1080_tc.vpy"
if %subfilter%==2 echo res = core.vsfm.TextSubMod(src,ass).set_output() >>"%~dpnx1_1080_tc.vpy"

echo %vspipe% --y4m "%~dpnx1_1080_tc.vpy" - ^| %x264% %x264info% --output "%~n1_1080p_tc.264" ->>"%~dpnx1_1080_tc.bat"
if %jptc%==0 echo %mp4box% -add "%~n1_1080p_tc.264" -add "%~dpn1.aac" -new "%~n1[1080p][CHT].mp4">>"%~dpnx1_1080_tc.bat"
if %jptc%==1 echo %mp4box% -add "%~n1_1080p_tc.264" -add "%~dpn1.aac" -new "%~n1[1080p][JPTC].mp4">>"%~dpnx1_1080_tc.bat"

echo if exist "%~n1[1080p][CHT].mp4" del "%~dpnx1_1080_tc.vpy">>"%~dpnx1_1080_tc.bat"
echo if exist "%~n1[1080p][CHT].mp4" del "%~n1_1080p_tc.264">>"%~dpnx1_1080_tc.bat"
echo if exist "%~n1[1080p][JPTC].mp4" del "%~dpnx1_1080_tc.vpy">>"%~dpnx1_1080_tc.bat"
echo if exist "%~n1[1080p][JPTC].mp4" del "%~n1_1080p_tc.264">>"%~dpnx1_1080_tc.bat"
echo exit>>"%~dpnx1_1080_tc.bat"
timeout 1
start "coding %~n1 1080p tc" "%~dpnx1_1080_tc.bat"
:1080tcfinish
if %resolution%==2 goto :720p
shift /1
goto :start

:720p
:720sc
if %sc%==0 goto :720tc
if %f720scover%==0 goto :720scfinish

if exist "%~dpnx1_720_tc.vpy" del "%~dpnx1_720_sc.vpy"
if exist "%~dpnx1_720_tc.bat" del "%~dpnx1_720_sc.bat"
echo import vapoursynth as vs >>"%~dpnx1_720_sc.vpy"
echo import sys >>"%~dpnx1_720_sc.vpy"
echo import mvsfunc as mvf >>"%~dpnx1_720_sc.vpy"
echo from vapoursynth import core >>"%~dpnx1_720_sc.vpy"
echo source = r%mkv% >>"%~dpnx1_720_sc.vpy"
echo ass = r%sc% >>"%~dpnx1_720_sc.vpy"
echo src = core.lsmas.LWLibavSource(source,format="yuv420p10") >>"%~dpnx1_720_sc.vpy"
echo src = core.fmtc.resample(src,1280,720,kernel="lanczos",taps=4) >>"%~dpnx1_720_sc.vpy"
echo src = mvf.Depth(src,depth=8) >>"%~dpnx1_720_sc.vpy"
if %subfilter%==0 echo res = core.xyvsf.TextSub(src,ass).set_output() >>"%~dpnx1_720_sc.vpy"
if %subfilter%==1 echo res = core.assrender.TextSub(src,ass).set_output() >>"%~dpnx1_720_sc.vpy"
if %subfilter%==2 echo res = core.vsfm.TextSubMod(src,ass).set_output() >>"%~dpnx1_720_sc.vpy"

echo %vspipe% --y4m "%~dpnx1_720_sc.vpy" - ^| %x264% %x264info% --output "%~n1_720p_sc.264" ->>"%~dpnx1_720_sc.bat"
if %jpsc%==0 echo %mp4box% -add "%~n1_720p_sc.264" -add "%~dpn1.aac" -new "%~n1[720p][CHS].mp4">>"%~dpnx1_720_sc.bat"
if %jpsc%==1 echo %mp4box% -add "%~n1_720p_sc.264" -add "%~dpn1.aac" -new "%~n1[720p][JPSC].mp4">>"%~dpnx1_720_sc.bat"

echo if exist "%~n1[720p][CHS].mp4" del "%~dpnx1_720_sc.vpy">>"%~dpnx1_720_sc.bat"
echo if exist "%~n1[720p][CHS].mp4" del "%~n1_720p_sc.264">>"%~dpnx1_720_sc.bat"
echo if exist "%~n1[720p][JPSC].mp4" del "%~dpnx1_720_sc.vpy">>"%~dpnx1_720_sc.bat"
echo if exist "%~n1[720p][JPSC].mp4" del "%~n1_720p_sc.264">>"%~dpnx1_720_sc.bat"
echo exit>>"%~dpnx1_720_sc.bat"
timeout 1
start "coding %~n1 720 sc" "%~nx1_720_sc.bat"
:720scfinish
if %tc%==0 shift /1
if %tc%==0 goto :start

:720tc
if %f720tcover%==0 goto :720tcfinish

if exist "%~dpnx1_720_tc.vpy" del "%~dpnx1_720_tc.vpy"
if exist "%~dpnx1_720_tc.bat" del "%~dpnx1_720_tc.bat"
echo import vapoursynth as vs >>"%~dpnx1_720_tc.vpy"
echo import sys >>"%~dpnx1_720_tc.vpy"
echo import mvsfunc as mvf >>"%~dpnx1_720_tc.vpy"
echo from vapoursynth import core >>"%~dpnx1_720_tc.vpy"
echo source = r%mkv% >>"%~dpnx1_720_tc.vpy"
echo ass = r%tc% >>"%~dpnx1_720_tc.vpy"
echo src = core.lsmas.LWLibavSource(source,format="yuv420p10") >>"%~dpnx1_720_tc.vpy"
echo src = core.fmtc.resample(src,1280,720,kernel="lanczos",taps=4) >>"%~dpnx1_720_tc.vpy"
echo src = mvf.Depth(src,depth=8) >>"%~dpnx1_720_tc.vpy"
if %subfilter%==0 echo res = core.xyvsf.TextSub(src,ass).set_output() >>"%~dpnx1_720_tc.vpy"
if %subfilter%==1 echo res = core.assrender.TextSub(src,ass).set_output() >>"%~dpnx1_720_tc.vpy"
if %subfilter%==2 echo res = core.vsfm.TextSubMod(src,ass).set_output() >>"%~dpnx1_720_tc.vpy"

echo %vspipe% --y4m "%~dpnx1_720_tc.vpy" - ^| %x264% %x264info% --output "%~n1_720p_tc.264" ->>"%~dpnx1_720_tc.bat"
if %jptc%==0 echo %mp4box% -add "%~n1_720p_tc.264" -add "%~dpn1.aac" -new "%~n1[720p][CHT].mp4">>"%~dpnx1_720_tc.bat"
if %jptc%==1 echo %mp4box% -add "%~n1_720p_tc.264" -add "%~dpn1.aac" -new "%~n1[720p][JPTC].mp4">>"%~dpnx1_720_tc.bat"

echo if exist "%~n1[720p][CHT].mp4" del "%~dpnx1_720_tc.vpy">>"%~dpnx1_720_tc.bat"
echo if exist "%~n1[720p][CHT].mp4" del "%~n1_720p_tc.264">>"%~dpnx1_720_tc.bat"
echo if exist "%~n1[720p][JPTC].mp4" del "%~dpnx1_720_tc.vpy">>"%~dpnx1_720_tc.bat"
echo if exist "%~n1[720p][JPTC].mp4" del "%~n1_720p_tc.264">>"%~dpnx1_720_tc.bat"
echo exit>>"%~dpnx1_720_tc.bat"
timeout 1
start "coding %~n1 720 tc" "%~nx1_720_tc.bat"
:720tcfinish
shift /1
goto :start


:end
pause
exit