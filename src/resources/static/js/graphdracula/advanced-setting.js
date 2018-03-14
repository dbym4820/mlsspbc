var knowledgeNodeData;
var knowledgeEdgeData;
var lastSelectedEvent;
var insertedKnowledge = new Array();
var insertExp = new Array();
var insertImp = new Array();
var dataKnowledge;

function knowledgeRender(){
   
    var nodeContent = $("#modalSelectedNode").html();

    var lessonId = getUrlVars()['lesson-id'];
    
    // create an array with nodes
    $.ajax({
	url: location.pathname+'/../../knowledge-struct?node-content='+nodeContent+'&lesson-id='+lessonId,
	dataType: 'text',
	async: false,
	success: function(data){
	    knowledgeNodeData = new vis.DataSet(eval(data));
	}
    });

    // create an array with edges
    $.ajax({
	url: location.pathname+'/../../knowledge-edge?node-content='+nodeContent+'&lesson-id='+lessonId,
	dataType: 'text',
	async: false,
	success: function(data){
	    knowledgeEdgeData = new vis.DataSet(eval(data));
	}
    });


    // create a network
    var container = document.getElementById('knowledge-structure');
    dataKnowledge = {
	nodes: knowledgeNodeData,
	edges: knowledgeEdgeData
    };

    var options = {
	interaction:{
	    hover:true,
	    multiselect: true,
	    navigationButtons: true
	},
	manipulation: {
	    enabled: true
	},
	configure: {
	    enabled: false,
	    filter: 'nodes,edges',
	    showButton: true
	}
    };

    var network = new vis.Network(container, dataKnowledge, options);

    network.on("click", function (params) {
	params.event = "[original event]";
	// document.getElementById('eventSpan').innerHTML = '<h2>Click event:</h2>' + JSON.stringify(params, null, 4);
	//console.log('click event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
    });
    network.on("doubleClick", function (params) {
	params.event = "[original event]";
	//console.log(data.nodes._data);
    });
    network.on("oncontext", function (params) {
	params.event = "[original event]";
    });
    network.on("dragStart", function (params) {
	// There's no point in displaying this event on screen, it gets immediately overwritten
	params.event = "[original event]";
	//console.log('dragStart Event:', params);
	//console.log('dragStart event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
    });
    network.on("dragging", function (params) {
	params.event = "[original event]";
    });
    network.on("dragEnd", function (params) {
	params.event = "[original event]";
	//console.log('dragEnd Event:', params);
	//console.log('dragEnd event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
    });
    network.on("zoom", function (params) {
    });
    network.on("showPopup", function (params) {
    });
    network.on("hidePopup", function () {
	//console.log('hidePopup Event');
    });
    network.on("select", function (params) {
	//console.log('select Event:', params);
    });
    network.on("selectNode", function (params) {
	lastSelectedEvent = params;
	//console.log('selectNode Event:', params);
    });
    network.on("selectEdge", function (params) {
	//console.log('selectEdge Event:', params);
    });
    network.on("deselectNode", function (params) {
	//console.log('deselectNode Event:', params);
    });
    network.on("deselectEdge", function (params) {
	//console.log('deselectEdge Event:', params);
    });
    network.on("hoverNode", function (params) {
	//console.log('hoverNode Event:', params);
    });
    network.on("hoverEdge", function (params) {
	//console.log('hoverEdge Event:', params);
    });
    network.on("blurNode", function (params) {
	//console.log('blurNode Event:', params);
    });
    network.on("blurEdge", function (params) {
	//console.log('blurEdge Event:', params);
    });
}


// concept-map/advanced-setting.js ないのModal設定のところでRender後に呼びだし
function knowledgeInitialize (){
    // 右側のExpKとImpKのリストに，既選択知識を挿入し，insertExpとinsertImp，insertedKnowledgeにも挿入
}

function knowledgeSelectionSave(nodeContent){
    let lessonId = getUrlVars()["lesson-id"];
    
    let selectedNodes = lastSelectedEvent.nodes;

    /* 当該ノードへ付与する知識リスト */
    let kLis = new Array();
    getExpList().forEach(function (d){
	kLis.push("{"+d+"}");
    });
    getImpList().forEach(function (d){
	kLis.push("{"+d+"}");
    });
    let resultListString = "["+kLis.toString()+"]";

    /* システム（当該ドメイン）が持っているすべての知識リスト */
    let resultSystemKListString = new Array();
    Object.keys(dataKnowledge.nodes._data).forEach(function(d){
    	resultSystemKListString.push("{id:'"+dataKnowledge.nodes._data[d]['id']+"', label:'"+dataKnowledge.nodes._data[d]['label']+"'}");
    });
    resultSystemKListString = "["+resultSystemKListString.toString()+"]";

    /* システム（当該ドメイン）知識が持っているエッジのリスト・ユーザはこれを選択するとかないから，システムのやつだけ持ってりゃOK */    
    let resultSystemEdgesString = new Array();
    Object.keys(dataKnowledge.edges._data).forEach(function(d){
	resultSystemEdgesString.push("{from:'"+dataKnowledge.edges._data[d]['from']+"', to:'"+dataKnowledge.edges._data[d]['to']+"'}");
    });
    resultSystemEdgesString = "["+resultSystemEdgesString.toString()+"]";    
    
    $.ajax({
    	method: "GET",
    	url: location.pathname+'/../../knowledge-save?node-content='+nodeContent+'&lesson-id='+lessonId+'&k-list='+resultListString+'&system-k-list='+resultSystemKListString+'&system-edge-list='+resultSystemEdgesString,
    	dataType: 'text',
    	async: false,
    	success: function(d){
	    console.log(d);
    	}
    });
}



function getExpList(){
    let result = new Array();
    let container = $("#k-exp-list");
    let tmp;
    let tmpArray;
    Object.keys(container.children('li')).forEach(function(d){
	tmpArray = new Array();
	tmp = container.children('li')[d]['id'];
	if(tmp !== undefined){
	    tmp = tmp.slice(14); // 余計な文字列の排除（IDだけ残す）
	    tmpArray.push(tmp, "exp");
	    result.push(tmpArray);
	}
    });
    return result;
}

function getImpList(){
    let result = new Array();
    let container = $("#k-imp-list");
    let tmp;
    let tmpArray;
    Object.keys(container.children('li')).forEach(function(d){
	tmpArray = new Array();
	tmp = container.children('li')[d]['id'];
	if(tmp !== undefined){
	    tmp = tmp.slice(14);
	    tmpArray.push(tmp, "imp");
	    result.push(tmpArray);
	}
    });
    return result;
}


function insertExplicitKnowledgeIntoDiv(){
    if (lastSelectedEvent !== undefined ){
	let container = $("#k-exp-list");
	container.empty();
	insertExp = new Array();
	lastSelectedEvent.nodes.forEach(function(d0){
	    insertedKnowledge.push(d0);
	    insertExp.push(d0);
	    container.append("<li id='exp-k-data-id-"+d0+"'>"+getKnowledgeLabelFromId(d0)+"</li>");
	    if (alreadyInsertedKnowledgeP(d0)) {
		$('#imp-k-data-id-'+d0).remove();
		insertImp = insertImp.filter(function(d1){
		    return d1 !== d0;
		});
	    }
	});
    }
}

function insertImplicitKnowledgeIntoDiv(){
    if (lastSelectedEvent !== undefined ){
	let container = $("#k-imp-list");
	container.empty();
	insertImp = new Array();
	lastSelectedEvent.nodes.forEach(function(d0){
	    insertedKnowledge.push(d0);
	    insertImp.push(d0);
	    container.append("<li id='imp-k-data-id-"+d0+"'>"+getKnowledgeLabelFromId(d0)+"</li>");
	    if (alreadyInsertedKnowledgeP(d0)) {
		$('#exp-k-data-id-'+d0).remove();
		insertExp = insertExp.filter(function(d1){
		    return d1 !== d0;
		});
	    }
	});
    }
}

function alreadyInsertedKnowledgeP(knowledgeId){
    let result = false;
    insertedKnowledge.forEach(function(d){
	if(d == knowledgeId){
	    result = true;
	}
    });
    return result;
}

function clearKnowledgeInsertion(){
    lastSelectedEvent = null;
    insertedKnowledge = new Array();
    insertExp = new Array();
    insertImp = new Array();
    $("#k-imp-list").empty();
    $("#k-exp-list").empty();
}

function getKnowledgeLabelFromId(knowledgeId){
    let result = null;
    Object.keys(dataKnowledge.nodes._data).forEach(function(d){
	if (dataKnowledge.nodes._data[d]['id'] == knowledgeId){
	    result = dataKnowledge.nodes._data[d]['label'];
	}
    });
    return result;
}

function expKnowledgeP(knowledgeId){
    let result = false;
    insertExp.forEach(function(d){
	if(d == knowledgeId){
	    result = true;
	}
    });
    return result;
}

function impKnowledgeP(knowledgeId){
    let result = false;
    insertImp.forEach(function(d){
	if(d == knowledgeId){
	    result = true;
	}
    });
    return result;
}
