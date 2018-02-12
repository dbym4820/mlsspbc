function mouseListen (){   
    
    // マウスイベントを設定
    var mouseEvent = function( e ) {

	// 動作を停止
	e.preventDefault() ;

	// マウス位置を取得する
	var mouseX = e.pageX; // X座標
	var mouseY = e.pageY; // Y座標

	// 結果の書き出し
	xElement.textContent = mouseX ;
	yElement.textContent = Math.floor( mouseY ) ;
    } ;

    // イベントの設定
    $("#orgChartContainer")[0].addEventListener( "mousemove", mouseEvent ) ;

    // 結果書き出し用の要素
    var xElement = document.getElementById( "pointer-position-x" ) ;
    var yElement = document.getElementById( "pointer-position-y" ) ;
}

$(window).load(function () {	
    mouseListen();
    //makeSigma();
});


$(window).load(function(){
    $('#ick25').click(function() {
        $o("body").css("zoom","25%");
	console.log("25");
    });
    $('#ick50').click(function() {
        $("body").css("zoom","50%");
	console.log("50");
    });
    $('#ick100').click(function() {
        $("body").css("zoom","100%");
	console.log("100");
    });
    $('#ick150').click(function() {
        $("body").css("zoom","150%");
	console.log("150");
    });
    $('#ick200').click(function() {
        $("body").css("zoom","200%");
	console.log("200");
    });
});
