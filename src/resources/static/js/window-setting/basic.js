$(document).ready(function () {

    hsize = $(window).height();

    $("#slide-bar").css("height", hsize + "px");

});

// $(window).resize(function () {

//     hsize = $(window).height();

//     $("#slide-bar").css("height", hsize + "px");

// });


//センタリングをする関数
function centeringModalSyncer(){

    //画面(ウィンドウ)の幅を取得し、変数[w]に格納
    var w = window.innerWidth;

    //画面(ウィンドウ)の高さを取得し、変数[h]に格納
    var h = window.innerHeight;

    //コンテンツ(#modal-content-div)の幅を取得し、変数[cw]に格納
    var cw = $("#modal-content-div").outerWidth();

    //コンテンツ(#modal-content-div)の高さを取得し、変数[ch]に格納
    var ch = $("#modal-content-div").outerHeight();

    
    //コンテンツ(#modal-content-div)を真ん中に配置するのに、左端から何ピクセル離せばいいか？を計算して、変数[pxleft]に格納
    var pxleft = ((w - cw)/2);

    //コンテンツ(#modal-content-div)を真ん中に配置するのに、上部から何ピクセル離せばいいか？を計算して、変数[pxtop]に格納
    var pxtop = ((h - ch)/2);

    //[#modal-content-div]のCSSに[left]の値(pxleft)を設定
    $("#modal-content-div").css({"left": pxleft + "px"});

    //[#modal-content-div]のCSSに[top]の値(pxtop)を設定
    $("#modal-content-div").css({"top": 10/* pxtop */ + "px"});

    $("#modal-content-div").css({"height": 90 + "vh"});
    
}
