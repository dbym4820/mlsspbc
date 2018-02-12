/*****************************************************************************
関係関数
*****************************************************************************/
// Getパラメータ取得
var getUrlVars = function(){
    var vars = {}; 
    var param = location.search.substring(1).split('&');
    for(var i = 0; i < param.length; i++) {
        var keySearch = param[i].search(/=/);
        var key = '';
        if(keySearch != -1) key = param[i].slice(0, keySearch);
        var val = param[i].slice(param[i].indexOf('=', 0) + 1);
        if(key != '') vars[key] = decodeURI(val);
    } 
    return vars; 
}


/*****************************************************************************
起動時処理
*****************************************************************************/

var chart;
$(function(){
    loadDatas();
});


function s(){
    var node = chart.getData();
    var nodeLen = chart.nodesLength();

    //インテンションマップの保存
    var nodeDatas = "[";
    for(var i=0; i<=nodeLen-1; i++){
    	if(i < nodeLen-1){
    	    nodeDatas += JSON.stringify(node[i]) + ',';
    	} else {
    	    nodeDatas += JSON.stringify(node[i]);
    	}
    }
    nodeDatas += "]";
    return nodeDatas;


    var lessonId = getUrlVars()["lesson-id"];
    $.ajax({
    	type: 'POST',
    	url: '/software/aburatani/save-concept-map?lessonid='+lessonId,
    	dataType: 'text',
    	data:{ dat: nodeDatas},
    }).done(function(data){
    	console.log("success-save-concept");
    }).fail(function(data){
    	conseole.log("error-save-concept");
    });
}

/*****************************************************************************
SAVEボタンの挙動制御
*****************************************************************************/
function saveDatas(){

    var node = chart.getData();
    var nodeLen = chart.nodesLength();

    //インテンションマップの保存
    var nodeDatas = "[";
    for(var i=0; i<=nodeLen-1; i++){
    	if(i < nodeLen-1){
    	    nodeDatas += JSON.stringify(node[i]) + ',';
    	} else {
    	    nodeDatas += JSON.stringify(node[i]);
    	}
    }

    var lessonId = getUrlVars()["lesson-id"];
    
    nodeDatas += "]";
    $.ajax({
    	type: 'POST',
    	url: '/software/aburatani/save-concept-map?lessonid='+lessonId,
    	dataType: 'text',
    	data:{ dat: nodeDatas},
    }).done(function(data){
    	console.log("success-save-concept");
    }).fail(function(data){
    	conseole.log("error-save-concept");
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

    
    // intentDatas += "]";
    // if(!cancel_frag) {
    // 	$.ajax({
    // 	    type: 'POST',
    // 	    url: '/save-intent-list',
    // 	    dataType: 'text',
    // 	    data:{ dat: intentDatas},	
    // 	}).done(function(data){
    // 	    console.log("success-save-intent");
    // 	}).fail(function(data){
    // 	    console.log("error-save-intent");
    // 	});
    // }
}



$('#add-intent-form').submit(function(){
    //    saveDatas();
    s();
});


function loadDatas(){
    var lessonId = getUrlVars()["lesson-id"];
    $.ajaxSetup({ async: false });
    $.getJSON("/software/aburatani/load-concept-map?lessonid="+lessonId, function(data) {
	let jsonObject =  JSON.parse(JSON.stringify(data));
	chart = $('#orgChart').orgChart({
            data: jsonObject,
	});	
    });
    $.ajaxSetup({ async: true });
}

function checkParentNodeId(nodeContent){

    var returnData;
    var node = chart.getData();
    var nodeLen = chart.nodesLength()

    //インテンションマップの保存
    var nodeDatas = "[";
    for(var i=0; i<=nodeLen-1; i++){
    	if(i < nodeLen-1){
    	    nodeDatas += JSON.stringify(node[i]) + ',';
    	} else {
    	    nodeDatas += JSON.stringify(node[i]);
    	}
    }
    nodeDatas += "]";

    $.ajaxSetup({ async: false });
    $.ajax({
    	type: 'POST',
    	url: '/software/aburatani/find-parent-node-id',
    	dataType: 'text',
    	data:{ jsonObject: nodeDatas,
	       conceptName: nodeContent},
    }).done(function(data){
    	returnData = data;
    }).fail(function(data){
    	console.log("error-save-concept");
    });

    return returnData;
}

function loadIntent(){
    var lessonId = getUrlVars()["lesson-id"];
    var returnData;
    $.ajaxSetup({ async: false });
    console.log(lessonId);
    $.getJSON("/software/aburatani/load-intent-list?lessonid="+lessonId, function(data){
	returnData = JSON.stringify(data);
    });
    $.ajaxSetup({ async: true });
    return returnData;
}

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

function intentList(){
    var obj = loadIntent();
    let html = '';
    $.each(JSON.parse(obj), function (index, item) {
    	html += '<div class="node-content intension-items" draggable="true"' +
	              'id="' + item['id'] + '" ondragstart="f_dragstart(event)">' +
	            item['id'] +
	        '</div>'; 
    });
    return html;
}

/*****************************************************************
大きさ変更時処理
******************************************************************/
$(window).resize(function(){
    chart.draw();
});
