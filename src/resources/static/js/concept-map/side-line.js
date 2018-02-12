function draw_line (parent_node_id, child_node_id) {

    // ノードIDの取得
    let parent_node = $(parent_node_id.replace(/[ !"$%&'()*+,.\/:;<=>?@\[\\\]^`{|}~]/g, "\\$&"));
    let child_node = $(child_node_id.replace(/[ !"$%&'()*+,.\/:;<=>?@\[\\\]^`{|}~]/g, "\\$&"));

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
    let date = new Date();
    let id = ""+date.getYear()+""+date.getMonth()+""+date.getDate()+""+date.getHours()+""+date.getMinutes()+""+date.getSeconds();

    // パラメータ
    // let param = {
    // 	line_style: "solid"
    // 	, line_color: "red"
    // 	, line_width: "2px"
    // 	, parent: $("#orgChart")
    // 	, callback: function(){}};
    let param = {
	line_style: "dashed"
	, line_color: "black"
	, line_width: "1px"
	, parent: $("#orgChart")
	, callback: function(){}};


    
    // 文字表示用ボックス
    let lineAttrParent = $("<p class='line-attr-parent'></p>");
    let lineAttrChild = $("<p class='line-attr-child'></p>");

    // 順序関係用文字表示
    // 関係がOrderなら，，，に変更する

    // 本命ラインの設定
    let line;

    if(parent_node_position_x < child_node_position_x){
	// 時計回りに回転か，逆回りか
        degree = parent_node_position_y > child_node_position_y ? 0 - degree: degree;
	
	// lineAttrParent.append("先");
	// lineAttrChild.append("後");
	lineAttrParent.append("");
	lineAttrChild.append("");

	line = $("<div></div>")
	    .addClass("side-line")
	    .attr({
		"draggable": "true",
		"id": id
	    })
	    .css({	    
		"left": parent_node_position_x-50,
		"top": parent_node_position_y-150,
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
	
	lineAttrParent.append("");
	lineAttrChild.append("");
	line = $("<div></div>")
	    .addClass("side-line")
	    .attr({
		"draggable": "true",
		"id": id
	    })
	    .css({	    
		"left": parent_node_position_x-distance_between_nodes,
		"top": parent_node_position_y-130,
		"z-index": 1,
		"width": distance_between_nodes,

		//"-webkit-transform": "rotate(" + 86 + "deg)",
		
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
    $(param.parent).prepend(line);
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
	draw_line(clickedNodeId, new_Node_Id);
	saveLineList(clickedNodeId, new_Node_Id, "order");
	clickFrag = false;
	clickedNodeId = '';
	console.log("２回目");
    }
}

// JSONのセーブ
function saveLineList(parent, child, functor){
    let newLineStr = "{\"parent\":\""+parent+"\",\"child\":\""+child+"\",\"function\":\""+functor+"\"}";
    let jsonObject = "[";
    $.getJSON("/load-slide-line-list", function(data) {
	let dataLen = data.length;
	if(dataLen != 0){
	    for(let i=0; i<=dataLen-1; i++){
		jsonObject += "{\"parent\":"+JSON.stringify(data[i].parent) + "," +
		    "\"child\":"+ JSON.stringify(data[i].child) + "," +
		    "\"function\":"+ JSON.stringify(data[i].function) + "},";
	    }
	}
	jsonObject += newLineStr + "]";
	$.ajax({
    	    type: 'POST',
    	    url: '/save-side-line-list',
    	    dataType: 'text',
    	    data:{ dat: jsonObject},
	}).done(function(data){
    	    console.log("success");
	}).fail(function(data){
    	    alert("error");
	});
    });
}
