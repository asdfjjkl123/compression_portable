@echo off
:path
call "%~dp0[0]set_path.bat"

:branch
set x265info=--y4m -D 10 --deblock -1:-1 --preset slower --tune lp++ --ctu 32 --qg-size 8 --crf 18.0 --pbratio 1.2 --cbqpoffs -2 --crqpoffs -2 --no-sao --me 3 --subme 5 --merange 38 --b-intra --limit-tu 4 --no-rect --no-amp --ref 4 --weightb --keyint 240 --min-keyint 1 --bframes 6 --aq-mode 1 --aq-strength 0.8 --rd 5 --psy-rd 2.0 --psy-rdoq 1.0 --rdoq-level 2 --no-open-gop --rc-lookahead 80 --scenecut 40 --qcomp 0.65 --no-strong-intra-smoothing --range limited --colorprim bt709 --transfer bt709 --colormatrix bt709 --chromaloc 0
set files=0
set shutdown=0
set /p shutdown=Shutdown computer when coding finished (0:no, 1:yes):
set allfilesame=0
set /p allfilesame=all file use same setting? (0:no, 1:yes):
set trim=0
if %allfilesame%==1 set /p trim=header trim in frames(0: no trim):
set customizeres=0
if %allfilesame%==1 set /p customizeres=use customize resoulusion? (0:default_1920x1080, 1:customize):
if %customizeres%==1 set /p cuswidth=please set width:
if %customizeres%==1 set /p cusheight=please set height:
set dsres=0
if %allfilesame%==1 if customizeres==0 set /p dsres=please set descale resoulusion(0:no descale):
set dsfilter=0
if not %dsres%==0 set /p dsfilter=please set ds filter(1:Debilinear,2:Debicubic,3:Delanczos,4:Despline16,5:Despline36,6:Despline64):
set dsaa=0
if %allfilesame%==1 set /p dsaa=anti-aliasing(0:no, 1:yes):

:start_audio
if %allfilesame%==0 set /p trim=header trim:
if %allfilesame%==0 set customizeres=0
if %allfilesame%==0 set /p customizeres=use customize resoulusion? (0:default_1920x1080, 1:customize):
if %allfilesame%==0 if %customizeres%==1 set /p cuswidth=please set width:
if %allfilesame%==0 if %customizeres%==1 set /p cusheight=please set height:
if %allfilesame%==0 set dsres=0
if %allfilesame%==0 if customizeres==0 set /p dsres=please set descale resoulusion(0:no descale):
if %allfilesame%==0 set dsfilter=0
if not %dsres%==0 set /p dsfilter=please set ds filter(1:Debilinear,2:Debicubic,3:Delanczos,4:Despline16,5:Despline36,6:Despline64):
if %allfilesame%==0 set dsaa=0
if %allfilesame%==0 set /p dsaa=anti-aliasing(0:no, 1:yes):

if "%~1"=="" goto :end
set /a files+=1

if exist "%~dp1%~nx1.vpy" del "%~dp1%~nx1.vpy"
if exist "%~dp1%~nx1.lwi" del "%~dp1%~nx1.lwi"
if exist "%~dpn1.hevc" del "%~dpn1.hevc"

if not exist "%~dpn1".aac %eac3to% "%~1" "%~dpn1".aac -log=nul

if %trim% GTR 0 set /a trimaudio=%trim%*1001*10/24
if %trim% GTR 0 set /a trimaudio=%trimaudio%+5
if %trim% GTR 0 set trimaudio=%trimaudio:~,-4%.%trimaudio:~-4,3%
if not %trim% GTR 0 set trimaudio=0
if %trim% GTR 0 %ffmpeg% -ss %trimaudio% -i "%~dpn1.aac" -acodec copy "%~dp1%~nx1_trimed.aac"

:start_video
set video="%~1"

@echo.
echo start coding file no%files%. %~n1
@echo.

if %allfilesame%==0 if not %dsres%==0 set /p dsfilter=please set ds filter(1:Debilinear,2:Debicubic,3:Delanczos,4:Despline16,5:Despline36,6:Despline64):
if %dsfilter%==1 set dsfilter=Debilinear
if %dsfilter%==2 set dsfilter=Debicubic
if %dsfilter%==3 set dsfilter=Delanczos
if %dsfilter%==4 set dsfilter=Despline16
if %dsfilter%==5 set dsfilter=Despline36
if %dsfilter%==6 set dsfilter=Despline64

echo import vapoursynth as vs >>"%~dp1%~nx1.vpy"
echo from vapoursynth import core >>"%~dp1%~nx1.vpy"
echo import sys  >>"%~dp1%~nx1.vpy"
echo import havsfunc as haf >>"%~dp1%~nx1.vpy"
echo import mvsfunc as mvf >>"%~dp1%~nx1.vpy"
echo import nnedi3_resample as nnrs >>"%~dp1%~nx1.vpy"
echo import descale as ds >>"%~dp1%~nx1.vpy"
echo import math as math >>"%~dp1%~nx1.vpy"

echo source = r%video% >>"%~dp1%~nx1.vpy"

echo src8 = core.lsmas.LWLibavSource(source,threads=0,repeat=True) >>"%~dp1%~nx1.vpy"
if %trim% gtr 0 echo src8 = core.std.Trim(src8,%trim%) >>"%~dp1%~nx1.vpy"
if %customizeres%==0 echo if src8.width !=1920: >>"%~dp1%~nx1.vpy"
if %customizeres%==0 echo 	src8 = core.fmtc.resample(src8,1920,1080,kernel="lanczos",taps=4) >>"%~dp1%~nx1.vpy"
if %customizeres%==1 echo src8 = core.fmtc.resample(src8,%cuswidth%,%cusheight%,kernel="lanczos",taps=4) >>"%~dp1%~nx1.vpy"

echo src16 = mvf.Depth(src8, depth=16, useZ=True) >>"%~dp1%~nx1.vpy"

if %dsaa%==1 echo w = src16.width >>"%~dp1%~nx1.vpy"
if %dsaa%==1 echo h = src16.height >>"%~dp1%~nx1.vpy"
if %dsaa%==1 echo aa = core.eedi2cuda.EEDI2(src16,1, mthresh=10, lthresh=20, vthresh=20, maxd=24, nt=50) >>"%~dp1%~nx1.vpy"
if %dsaa%==1 echo aa = core.fmtc.resample(aa, w, h, 0, [-0.5,-1]).std.Transpose() >>"%~dp1%~nx1.vpy"
if %dsaa%==1 echo aa = core.eedi2cuda.EEDI2(aa,1, mthresh=10, lthresh=20, vthresh=20, maxd=24, nt=50) >>"%~dp1%~nx1.vpy"
if %dsaa%==1 echo resaa = core.fmtc.resample(aa, h, w, 0, [-0.5,-1]).std.Transpose() >>"%~dp1%~nx1.vpy"

if %dsaa%==1 echo pre_nr32y = mvf.Depth(resaa, 32) >>"%~dp1%~nx1.vpy"

if %dsaa%==0 echo pre_nr32y = mvf.Depth(src16, 32) >>"%~dp1%~nx1.vpy"

echo src16 = mvf.ToRGB(src16,depth=16) >>"%~dp1%~nx1.vpy"
echo nr16y = core.knlm.KNLMeansCL(src16, d=2, a=2, s=3,  h=0.8, wmode=2, device_type="GPU") >>"%~dp1%~nx1.vpy"
echo nr16y = mvf.ToYUV(nr16y,depth=16) >>"%~dp1%~nx1.vpy"
echo nr16uv = core.knlm.KNLMeansCL(src16, d=2, a=1, s=3,  h=0.4, wmode=2, device_type="GPU") >>"%~dp1%~nx1.vpy"
echo nr16uv = mvf.ToYUV(nr16uv,depth=16) >>"%~dp1%~nx1.vpy"
echo nr16uv = core.fmtc.resample(nr16uv,960,540,sx=-0.5) >>"%~dp1%~nx1.vpy"

echo nr16 = core.std.ShufflePlanes([nr16y, nr16uv], [0,1,2], vs.YUV) >>"%~dp1%~nx1.vpy"

if not %dsres%==0 echo dh = %dsres% >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo dw = dh * 16 / 9 >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo if dw %% 2 !=0: >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo 	dw = math.ceil(dw) >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo if dw %% 2 !=0: >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo 	dw = dw+1 >>"%~dp1%~nx1.vpy"
if not %dsres%==0 if %dsfilter%==Debicubic echo descale = ds.%dsfilter%(nr16, dw, dh, 1/3 ,1/3) >>"%~dp1%~nx1.vpy"
if not %dsres%==0 if not %dsfilter%==Debicubic echo descale = ds.%dsfilter%(nr16, dw, dh) >>"%~dp1%~nx1.vpy"

if not %dsres%==0 echo w = 1920 >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo h = 1080 >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo rescale = nnrs.nnedi3_resample(descale, w, h, mode='znedi3') >>"%~dp1%~nx1.vpy"
if not %dsres%==0 echo nr16 = rescale >>"%~dp1%~nx1.vpy"

echo nr8    = mvf.Depth(nr16, depth=8, useZ=True) >>"%~dp1%~nx1.vpy"
echo luma   = core.std.ShufflePlanes(nr8, 0, vs.YUV).resize.Bilinear(format=vs.YUV420P8) >>"%~dp1%~nx1.vpy"
echo nrmasks = core.tcanny.TCanny(nr8,sigma=0.8,op=2,gmmax=255,mode=1,planes=[0,1,2]).std.Expr(["x 7 < 0 65535 ?",""],vs.YUV420P16) >>"%~dp1%~nx1.vpy"
echo nrmaskb = core.tcanny.TCanny(nr8,sigma=1.3,t_h=6.5,op=2,planes=0) >>"%~dp1%~nx1.vpy"
echo nrmaskg = core.tcanny.TCanny(nr8,sigma=1.1,t_h=5.0,op=2,planes=0) >>"%~dp1%~nx1.vpy"
echo nrmask  = core.std.Expr([nrmaskg,nrmaskb,nrmasks, nr8],["a 20 < 65535 a 48 < x 256 * a 96 < y 256 * z ? ? ?",""],vs.YUV420P16) >>"%~dp1%~nx1.vpy"
echo nrmask  = core.std.Maximum(nrmask,0).std.Maximum(0).std.Minimum(0) >>"%~dp1%~nx1.vpy"
echo nrmask  = core.rgvs.RemoveGrain(nrmask,[20,0]) >>"%~dp1%~nx1.vpy"
echo debd  = core.f3kdb.Deband(nr16,12,24,16,16,0,0,output_depth=16) >>"%~dp1%~nx1.vpy"
echo debd  = core.f3kdb.Deband(debd,20,56,32,32,0,0,output_depth=16) >>"%~dp1%~nx1.vpy"
echo debd  = mvf.LimitFilter(debd,nr16,thr=0.6,thrc=0.5,elast=2.0) >>"%~dp1%~nx1.vpy"
echo debd  = core.std.MaskedMerge(debd,nr16,nrmask,first_plane=True) >>"%~dp1%~nx1.vpy"

echo denoised_Y = core.std.ShufflePlanes(debd,0,vs.GRAY) >>"%~dp1%~nx1.vpy"
echo res = core.std.ShufflePlanes([denoised_Y, debd], planes=[0,1,2], colorfamily=vs.YUV) >>"%~dp1%~nx1.vpy"

echo res = mvf.Depth(res,10,useZ=True).set_output() >>"%~dp1%~nx1.vpy"

%vspipe% --y4m "%~dp1%~nx1.vpy" - | %x265% %x265info% --output "%~n1.hevc" -

del "%~dp1%~nx1.vpy"
del "%~dp1%~nx1.lwi"

:mux
if %trim%==0 %mmg% -o "%~dpn1_encode.mkv" --language 0:und "%~dpn1.hevc" --language 0:jpn "%~dpn1.aac"
if %trim% GTR 0 %mmg% -o "%~dpn1_encode.mkv" --language 0:und "%~dpn1.hevc" --language 0:jpn "%~dp1%~nx1_trimed.aac"

if exist "%~dpn1_encode.mkv" del "%~dpn1.hevc"

shift /1
goto :start_audio


:end
@echo.
echo coding finish

if %shutdown%==1 shutdown /s /t 5

pause