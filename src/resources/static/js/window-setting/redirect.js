$(function(){
    function timer_func(){
	location.href='/software/aburatani/sign-out-process'; // ここのURLをログアウト処理のURLに書き換える
	// 必要であればAjaxなどでPOST情報などを飛ばす
    }
    var time_limit=20*(60*1000); //制限時間・分数*(1分間の秒数)
    var timer_id=setTimeout(timer_func, time_limit);
    
    $('body').on('keydown mousedown',function(){
	clearTimeout(timer_id);
	timer_id=setTimeout(timer_func, time_limit);
    });
});
