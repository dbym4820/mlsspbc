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

function testCan() {
  //描画コンテキストの取得
  var canvas = document.getElementById('test-canvas');
  if (canvas.getContext) {
    var context = canvas.getContext('2d');
    //ここに具体的な描画内容を指定する
    //図形やイメージの透明度を指定する
    context.globalAlpha = 0.5;
    //青い四角形を描く
    context.fillStyle = "rgb(0, 0, 255)";
    context.fillRect(20,20,50,50);
    //赤い四角形を描く
    context.fillStyle = "rgb(255, 0, 0)";
    context.fillRect(40,40,50,50);
  }
}

$(window).load(function () {	
    mouseListen();
    //makeSigma();

});


$(window).load(function(){
    $('#ick25').click(function() {
        $("body").css("zoom","25%");
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
