var knowledgeNodeData;
var knowledgeEdgeData;


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
	// url: location.pathname+'/../../knowledge',
	url: location.pathname+'/../../knowledge-edge?node-content='+nodeContent+'&lesson-id='+lessonId,
	dataType: 'text',
	async: false,
	success: function(data){
	    knowledgeEdgeData = new vis.DataSet(eval(data));
	}
    });


    // create a network
    var container = document.getElementById('knowledge-structure');
    var data = {
	nodes: knowledgeNodeData,
	edges: knowledgeEdgeData
    };

    var options = {
	interaction:{hover:true},
	manipulation: {
	    enabled: true
	},
	configure: {
	    enabled: false,
	    filter: 'nodes,edges',
	    showButton: true
	}
    };

    var network = new vis.Network(container, data, options);

    network.on("click", function (params) {
	params.event = "[original event]";
	// document.getElementById('eventSpan').innerHTML = '<h2>Click event:</h2>' + JSON.stringify(params, null, 4);
	//console.log('click event, getNodeAt returns: ' + this.getNodeAt(params.pointer.DOM));
    });
    network.on("doubleClick", function (params) {
	params.event = "[original event]";
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
	console.log('hidePopup Event');
    });
    network.on("select", function (params) {
	console.log('select Event:', params);
    });
    network.on("selectNode", function (params) {
	console.log('selectNode Event:', params);
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
