function draw_line (parent_node_id, child_node_id, new_line_id, functor) {

    // ノードIDの取得
    let parent_node = $(parent_node_id.replace(/[ !"$%&'()*+,.\/:;<=>?@\[\\\]^`{|}~]/g, "\\$&"));
    let child_node = $(child_node_id.replace(/[ !"$%&'()*+,.\/:;<=>?@\[\\\]^`{|}~]/g, "\\$&"));

    // 語彙が設計エリアにあるかどうかを判定し，パーツ置き場にあれば先は惹かずに，データベースから削除し，Return刷る
    function checkNodesUsedP(){

    }

    // Firefox対応用のoffset処理
    
    // 各ノードの座標取得
    let parent_node_position_x = parent_node.offset().left;
    let parent_node_position_y = parent_node.offset().top;
    let child_node_position_x = child_node.offset().left;
    let child_node_position_y = child_node.offset().top;
    
    
    // ノード間の距離
    let distance_between_nodes = Math.sqrt(Math.pow((parent_node_position_x - child_node_position_x) ,2) + Math.pow((parent_node_position_y - child_node_position_y) ,2));

    // 確度計算（逆三角関数法）
    let base = Math.max(parent_node_position_x, child_node_position_x) - Math.min(parent_node_position_x, child_node_position_x);
    let tall = Math.max(parent_node_position_y, child_node_position_y) - Math.min(parent_node_position_y, child_node_position_y); 
    let degree = Math.atan(tall / base) * 180 / Math.PI;

    // サイドラインのID設定
    let id = "";
    if (new_line_id === "") {
	let date = new Date();
	id = ""+date.getYear()+""+date.getMonth()+""+date.getDate()+""+date.getHours()+""+date.getMinutes()+""+date.getSeconds();
    } else {
	id = new_line_id;
    }

    let param = {
	line_style: "dashed"
	, line_color: "black"
	, line_width: "1px"
	, parent: $("#orgChart")
	, callback: function(){}};
    
    // 文字表示用ボックス
    let lineAttrParent = $("<p class='line-attr-parent' style='padding: 0px 4em;'></p>");
    let lineAttrChild = $("<p class='line-attr-child'></p>");

    // 順序関係用文字表示
    // 関係がOrderなら，，，に変更する

    // 本命ラインの設定
    let line;

    if(parent_node_position_x < child_node_position_x){
	// 時計回りに回転か，逆回りか
        degree = parent_node_position_y > child_node_position_y ? 0 - degree: degree;
	
	lineAttrParent.append("");
	lineAttrChild.append("");

	line = $("<div></div>")
	    .addClass("side-line")
	    .attr({
		"draggable": "true",
		"ondragstart": "f_dragstart(event)",
		"ondblclick": "removeSideLine("+id+");",
		"parentId": parent_node_id,
		"childId": child_node_id,
		"id": id
	    })
	    .css({	    
		"left": parent_node_position_x,
		"top": parent_node_position_y-50,
		"z-index": 1,
		"width": distance_between_nodes, 
		"transform": "rotate(" + degree + "deg)",
		"-webkit-transform": "rotate(" + degree + "deg)",
		"border-top-style": param.line_style,
		"border-top-color": param.line_color,
		"border-top-width": param.line_width,
		"-moz-transform-origin": "left bottom",
		"-webkit-transform-origin": "left bottom",
		"transform-origin": "left bottom",
	    });
    } else {
	// 時計回りに回転か，逆回りか
	degree = parent_node_position_y < child_node_position_y ? 0 - degree: degree;
	
	lineAttrParent.append();
	lineAttrChild.append("");
	line = $("<div></div>")
	    .addClass("side-line")
	    .attr({
		"draggable": "true",
		"ondragstart": "f_dragstart(event)",
		"ondblclick": "removeSideLine("+id+");",
		"parentId": parent_node_id,
		"childId": child_node_id,
		"id": id
	    })
	    .css({	    
		"left": parent_node_position_x-distance_between_nodes,
		"top": parent_node_position_y-50,
		"z-index": 1,
		"width": distance_between_nodes,
		"-webkit-transform": "rotate(" + 86 + "deg)",
		"transform": "rotate(" + degree + "deg)",
		"-webkit-transform": "rotate(" + degree + "deg)",
		"border-top-style": param.line_style,
		"border-top-color": param.line_color,
		"border-top-width": param.line_width,
		"-moz-transform-origin": "right bottom",
		"-webkit-transform-origin": "right bottom",
		"transform-origin": "right bottom"
	    });
    }

    line.append(lineAttrParent, lineAttrChild);// 文字ラベルの追加
 
    // DOMへの追加
    $(param.parent).append(line);
}

// サイドラインの追加描画＋JSONセーブの実行
let clickFrag = false; // 一階目のクリックが成されているかどうか
let clickedNodeId = ''; // 一階前のクリックでのノードのID
function makeLine1(node_Id) {

    let new_Node_Id = "#"+node_Id;
    
    if(!clickFrag){ // まだクリックされていない時
	if(clickedNodeId == '') {
	    clickFrag = true;
	    clickedNodeId = new_Node_Id;
	} else {
	    clickFrag = false;
	    clickedNodeId = '';
	}
	console.log("１回目");
    } else { // １クリックされている時
	let date = new Date();
	let new_side_id = ""+date.getYear()+""+date.getMonth()+""+date.getDate()+""+date.getHours()+""+date.getMinutes()+""+date.getSeconds();
	draw_line(clickedNodeId, new_Node_Id, new_side_id);
	
	clickFrag = false;
	clickedNodeId = '';
	console.log("２回目");
    }
}

function saveSideLine(){
    let lessonId = getUrlVars()['lesson-id'];
    let pId = "";
    let cId = "";
    $(".side-line").each(function(counter, dom) {
	pId = dom.attributes.parentid.nodeValue.slice(1);
	cId = dom.attributes.childid.nodeValue.slice(1);
	$.ajax({
    	    type: 'POST',
    	    url: baseURL+"api/post/presentations",
    	    dataType: 'text',
	    data:{
		purpose: "save-side-line",
		lessonId: lessonId,
		lineId: dom.id,
		parentId: pId,
		childId: cId,
		type: "super"
	    }
	}).done(function(data){
    	    console.log("success"+data);
	}).fail(function(data){
    	    console.log("error");
	});	
    });
}


$(window).load(function(){

    // 兄弟リンクの描画
    var lessonId = getUrlVars()['lesson-id'];
    //$.getJSON(baseURL+"load-slide-line-list?lesson-id="+lessonId, function(dataList) {
    $.getJSON(baseURL+"api/presentations?purpose=construct-side-line&lesson-id="+lessonId, function(dataList) {
	dataList.forEach(function(d){
	    draw_line(d.parent, d.child, d.edgeId, d.functor);
	});
    });
});

function removeSideLine (lineId) {
    $('#'+lineId).remove(); 
    alert(lineId+"のラインをけした");
    $.ajax({
    	type: 'POST',
    	url: baseURL+"api/post/presentations",
    	dataType: 'text',
	data:{
	    purpose: "delete-side-line",
	    lineId: ""+lineId
	}
	}).done(function(data){
    	    console.log(data);
	}).fail(function(data){
    	    console.log(data);
	});	
}
