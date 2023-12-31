解壓後的路徑不能有空格，也不能有中文

按需求把文件拖到bat上，
[1]壓外掛用,非N卡及沒裝CUDA的,請選擇no CUDA
[2]hardsub:內嵌, subset:內封, check ass fonts:查缺字
[3]製種

視頻和字幕匹配規則:
視頻a.mkv
字幕可為a.[sc/tc/chs/cht/jpsc/jptc].ass
當中a為任意非中文字元

hardsub parallel & series:
為進一步壓榨cpu性能, 對跑串聯(series)時跑不滿cpu100%的用戶, 可選用並聯(parallel)方式, 它會一次性跑好多個x264

subset lite版:
去除查缺字功能,若出現內封後炸字,無法加載內封後的字體(隨機英數,例:9GXY3IRF)等玄學bug,請使用lite版,
如果認為不需要查缺字(反正壓內嵌時都查過一次), 亦可直接用lite版,因為速度比較快

使用subset前,若先前出報錯關閉後,盡管運行前會自動刪除舊有的臨時文件,但建議手動刪除字幕文件夾下的ass_warn.log, temp.bat

便攜包打包日期:2023/12/03