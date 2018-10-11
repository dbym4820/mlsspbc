
/*****************************************************************************
* 起動時処理
*****************************************************************************/
var chart; // グローバルから見えるプレゼン設計オブジェクト

$(function(){
    loadDatas();
});

$('#add-intent-form').submit(function(){
    // セーブボタン押下時の挙動
    //    saveDatas();
    s();
});

$(window).load(function(){
    // 語彙パーツリストの描画

    
    // スライドパーツの描画
    
});

$(window).resize(function(){
    chart.draw();
});



function s(){
    //インテンションマップの保存
    var node = chart.getData();
    var nodeLen = chart.nodesLength();

    // インテンションマップのJSONデータ構築
    var nodeDatas = "[";
    for(var i=0; i<=nodeLen-1; i++){
    	if(i < nodeLen-1){
    	    nodeDatas += JSON.stringify(node[i]) + ',';
    	} else {
    	    nodeDatas += JSON.stringify(node[i]);
    	}
    }
    nodeDatas += "]";
    //return nodeDatas;

    // APIに投げてセーブ処理
    var lessonId = getUrlVars()["lesson-id"];
    let conceptJsonUrl = baseURL+"save-concept-map?lessonid="+lessonId;
    $.ajax({
    	type: 'POST',
    	url: conceptJsonUrl,
    	dataType: 'text',
    	data:{
	    dat: nodeDatas
	},
    }).done(function(data){
    	console.log("success-save-concept");
    }).fail(function(data){
    	console.log("error-save-concept");
    });
}

/*****************************************************************************
* SAVEボタンの挙動制御
*****************************************************************************/
function saveDatas(){

    //兄弟リンクのセーブ
    saveSideLine();

    //インテンションマップのセーブ
    var node = chart.getData();
    var nodeLen = chart.nodesLength();

    // インテンションマップのJSONデータ構築
    var nodeDatas = "[";
    for(var i=0; i<=nodeLen-1; i++){
    	if(i < nodeLen-1){
    	    nodeDatas += JSON.stringify(node[i]) + ',';
    	} else {
    	    nodeDatas += JSON.stringify(node[i]);
    	}
    }
    nodeDatas += "]";

    // APIに投げてセーブ処理
    var lessonId = getUrlVars()["lesson-id"];    
    let saveConceptJsonUrl = baseURL+'save-concept-map?lessonid='+lessonId;
    $.ajax({
    	type: 'POST',
    	url: saveConceptJsonUrl,
    	dataType: 'text',
    	data:{
	    dat: nodeDatas
	},
    }).done(function(data){
    	console.log("success-save-concept");
    }).fail(function(data){
    	console.log("error-save-concept");
    });

    //インテンション選択肢の保存
    var elm = document.getElementById('intensions').innerText;
    
    var elmDash = "";
    elmDash = elm.split(/\r\n|\r|\n/);
    var intentDatas = "[";

    var cancel_frag = false; // スライドパーツの選択時に謎のインテンション選択肢バグが起こるのでその予防
    for(var i=1; i<=elmDash.length-1;i++){
	if( (elmDash[i].indexOf("let html =")) != -1 ) {
	    cancel_frag = true;
	    break; // スライドパーツ選択時にはインテンション選択肢の保存はしない
	}
	if( (elmDash[i] != "") && (elmDash[i] != undefined) ){
	    if(i < elmDash.length-1){
		intentDatas += "{\"id\":\""+ elmDash[i] + "\"},";
	    } else {
		intentDatas += "{\"id\":\""+ elmDash[i] + "\"}";
	    }
	}
    }
}




/***** インテンションマップの表示 *****/
function loadDatas() {
    // インテンションマップの取得とchart(マップオブジェクト)への設置
    var lessonId = getUrlVars()["lesson-id"];
    let loadConceptJsonUrl = baseURL+"api/presentations?purpose=construct-presentation&lesson-id="+lessonId;
    $.ajaxSetup({ async: false });
    $.getJSON(loadConceptJsonUrl, function(data) {
 	let jsonObject =  JSON.parse(JSON.stringify(data));
 	chart = $('#orgChart').orgChart({
            data: jsonObject,
 	});
    });
    $.ajaxSetup({ async: true });
}


/*****************************************************************
* パーツリストの生成
******************************************************************/
/***** 学習目標語彙の一覧取得 *****/
function loadIntent(){
    var lessonId = getUrlVars()["lesson-id"];
    let loadIntentJsonUrl = baseURL+"api/presentations?purpose=construct-term-parts&lesson-id="+lessonId;
    var returnData;
    $.ajaxSetup({ async: false });
    $.getJSON(loadIntentJsonUrl, function(data){
	returnData = JSON.stringify(data);
    });
    $.ajaxSetup({ async: true });
    return returnData;
}

/***** 一覧データからタグ生成 *****/
function intentList(){
    var obj = loadIntent();
    console.log(obj);
    let html = '';
    $.each(JSON.parse(obj), function (index, item) {
    	html += '<div class="node-content intension-items" draggable="true"' +
	              'id="' + item['id'] + '" ondragstart="f_dragstart(event)">' +
	            item['id'] +
	        '</div>'; 
    });
    return html;
}

/***** スライド(パス)一覧取得 *****/
function loadSlide(){
    var lessonId = getUrlVars()["lesson-id"];
    let loadSlideJsonUrl = baseURL+"api/presentations?purpose=construct-slide-parts&lesson-id="+lessonId;
    var returnData;
    $.ajaxSetup({ async: false });
    $.getJSON(loadSlideJsonUrl, function(data){
	returnData = JSON.stringify(data);
    });
    $.ajaxSetup({ async: true });
    return returnData;
}

/***** 一覧データからタグ生成 *****/
function slidePartsList(){
    var obj = loadSlide();
    let html = '';
    $.each(JSON.parse(obj), function (index, item) {
    	html += '<img id="' + item['id'] + '" class="slide-image intension-items" '+
		   '"ondragstart="f_dragstart(event)" src="' + item['id'] + '" />';
    });
    return html;    
}

/*****************************************************************
* インテンションのドラッグ＆ドロップの処理
******************************************************************/
/***** ドラッグ開始時の処理 *****/
function f_dragstart(event){
    //ドラッグするデータのid名をDataTransferオブジェクトにセット
    event.dataTransfer.setData("img", event.currentTarget.id);
}

/***** ドラッグ要素がドロップ要素に重なっている間の処理 *****/
function f_dragover(event){
    //dragoverイベントをキャンセルして、ドロップ先の要素がドロップを受け付けるようにする
    event.preventDefault();
}

/***** ドロップ時の処理 *****/
function f_drop(event, dataId){
    //ドラッグされたデータのid名をDataTransferオブジェクトから取得
    var id_name = event.dataTransfer.getData("img");
    //id名からドラッグされた要素を取得
    var drag_elm = document.getElementById(id_name);
    //もともとノード内にあったデータの格納
    var oldNode = event.currentTarget.innerText;
    //ドロップ先にドラッグされた要素を追加  
    event.currentTarget.innerText = "";
    //ドロップ先のノードの更新
    chart.updateNode(drag_elm.getAttribute('id'), dataId);
    event.currentTarget.appendChild(drag_elm);
    //ノードリストの更新（入れ替え）
    if( (oldNode !== "") && (oldNode !== "NEW") && (oldNode !== "NEW\n") ){
	var inNode = '<div class="node-content intension-items" draggable="true" id="' + oldNode + '" ondragstart="f_dragstart(event)">' + oldNode + '</div>';
	$('#intensions').innerHTML += inNode;
    }
    //エラー回避のため、ドロップ処理の最後にdropイベントをキャンセルしておく
    event.preventDefault();
    chart.draw();
}


/*****************************************************************
* データ検索用API
******************************************************************/
/***** 親ノードのIDのを取得する *****/
function checkParentNodeId(nodeId){
    var parentId;
    chart.getData().forEach(function(node){
	if(node.id == nodeId){
	    parentId = node.parent;
	}
    });
    return parentId;
}

/*****************************************************************
* システム上のノードのみやすさ向上API
******************************************************************/
/***** スライドノードに画像表示ツールチップ付与 *****/
/* $(function() {
 *     
 *     xOffset = 20;
 *     yOffset = 20;
 *     
 *     $("#photo a").hover(function(e){
 *         this.t = this.title;
 *         this.title = "";   
 *         var c = (this.t != "") ? "<span class='caption'>" + this.t + "</span>" : "";
 *         $("body").append("<div id='tooltip'><div class='img'><img src='"+ this.href +"' /></div>"+ c +"</div>");                              
 *         $("#tooltip")
 *             .css("top",(e.pageY - xOffset) + "px")
 *             .css("left",(e.pageX + yOffset) + "px")
 *             .fadeIn("fast");                       
 *     },
 * 			function(){
 * 			    this.title = this.t;   
 * 			    $("#tooltip").remove();
 * 			});
 *     $("#photo a").mousemove(function(e){
 *         $("#tooltip")
 *             .css("top",(e.pageY - xOffset) + "px")
 *             .css("left",(e.pageX + yOffset) + "px");
 *     });        
 *     
 * }); */
