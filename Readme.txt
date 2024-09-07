#English
The decompressed path cannot contain spaces or Chinese characters.

Drag the files to bat as you need.
[1]For external subtitle video, if your video card is not Nvidia or didn't install CUDA, please choose no CUDA version.
[2]Hardsub: hardcoded subtitle (mp4), subset: build-in subtitle (mkv), check ass fonts: for checking is font has missing character.
[3]making torrent.

The nosub.bat requires a graphics card regardless of CUDA version. If you don't have a graphics card, please right-click > Edit noCUDA version, ctrl+h to replace GPU with CPU
The nosub.bat will stretch sources with width other than 1920 to 1920*1080(1080p). Users can also set a customize resolution.

video and subtitle matching rules:
video:a.mkv
subtitle can be a.[sc/tc/chs/cht/jpsc/jptc].ass
where "a" is any non-Chinese character

hardsub parallel & series:
In order to further squeeze the CPU performance, users whose CPU uasge is not 100% when running series can choose parallel mode, which will run multiple x264 at once. When using parallel, please note that the file name cannot contain "&" and other batches special symbols, otherwise x264 may not be started automatically and needs to be started manually

subset lite version:
Removed the function of checking for missing characters. If there are metaphysical bugs such as missing characters after subset, and the inability to load fonts after subset (random alphanumeric characters, for example: 9GXY3IRF), please use the lite version.
If you think there is no need to check for missing words (because hardsub.bat has check), you can also use the lite version directly because it is faster.

Before using subset, if an error is reported at last time, it is recommended to manually delete ass_warn.log, temp.bat, temp.txt, outfonts.txt in the subtitles folder. Although those old temporary files will be automatically deleted before running,

#中文
解壓後的路徑不能有空格，也不能有中文

按需求把文件拖到bat上，
[1]壓外掛用,非N卡及沒裝CUDA的,請選擇no CUDA
[2]hardsub:內嵌, subset:內封, check ass fonts:查缺字
[3]製種

壓外掛的nosub無論有沒有CUDA, 均需要顯卡, 無顯卡使用者請右鍵>編輯no CUDA版本, ctrl+h 替換GPU為CPU
壓外掛的nosub會將寬度不等於1920的源拉伸成1920*1080(1080p), 使用者亦可自設其他分辨率

視頻和字幕匹配規則:
視頻a.mkv
字幕可為a.[sc/tc/chs/cht/jpsc/jptc].ass
當中a為任意非中文字元

hardsub parallel & series:
為進一步壓榨cpu性能, 對跑串聯(series)時跑不滿cpu100%的用戶, 可選用並聯(parallel)方式, 它會一次性跑好多個x264, 使用並聯時請注意文件名不能包含&等batch中的特殊符號, 否則可能無法自動啟動x264, 需手動啟動

subset lite版:
去除查缺字功能,若出現內封後炸字,無法加載內封後的字體(隨機英數,例:9GXY3IRF)等玄學bug,請使用lite版,
如果認為不需要查缺字(反正壓內嵌時都查過一次), 亦可直接用lite版,因為速度比較快

使用subset前,若先前出報錯關閉後,盡管運行前會自動刪除舊有的臨時文件,但建議手動刪除字幕文件夾下的ass_warn.log, temp.bat, temp.txt, outfonts.txt

便攜包打包日期:2024/08/31

最新bat文件請到:https://github.com/asdfjjkl123/compression_protable