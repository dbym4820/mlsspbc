var cy;
var callKnowledge = function(){};
var cytoLayout;
var addKnowldge;

$(window).load(function (){
    cy = cytoscape({

	container: $('#knowledge-structure'),

	elements: [{ data: { id: "root", label: 'root-1' }}],	
	style: [
	    {
		selector: 'node',
		style: {
		    'background-color': '#666',
		    'label': 'data(label)',
		    shape: 'hexagon',
		    'padding-right': '3',
		    'padding-left': '3',
		    'padding-top': '3',
		    'padding-bottom': '3',
		}
	    },
	    {
		selector: 'edge',
		style: {
		    'width': 3,
		    'line-color': '#000000',
		    'target-arrow-color': '#ccc',
		    'target-arrow-shape': 'triangle',
		    
		}
	    }
	],
	wheelSensitivity: 0.5,
	zoom: 1,
	pan: { x: 200, y: 200 },
    });

    cytoLayout = {
 name: 'grid',

  fit: true, // whether to fit the viewport to the graph
  padding: 30, // padding used on fit
  boundingBox: undefined, // constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }
  avoidOverlap: true, // prevents node overlap, may overflow boundingBox if not enough space
  avoidOverlapPadding: 10, // extra spacing around nodes when avoidOverlap: true
  nodeDimensionsIncludeLabels: false, // Excludes the label when calculating node bounding boxes for the layout algorithm
  spacingFactor: undefined, // Applies a multiplicative factor (>0) to expand or compress the overall area that the nodes take up
  condense: false, // uses all available space on false, uses minimal space on true
  rows: undefined, // force num of rows in the grid
  cols: undefined, // force num of columns in the grid
  position: function( node ){}, // returns { row, col } for element
  sort: undefined, // a sorting function to order the nodes; e.g. function(a, b){ return a.data('weight') - b.data('weight') }
  animate: false, // whether to transition the node positions
  animationDuration: 500, // duration of animation in ms if enabled
  animationEasing: undefined, // easing of animation if enabled
  animateFilter: function ( node, i ){ return true; }, // a function that determines whether the node should be animated.  All nodes animated by default on animate enabled.  Non-animated nodes are positioned immediately when the layout starts
  ready: undefined, // callback on layoutready
  stop: undefined, // callback on layoutstop
	transform: function (node, position ){ return position; } // transform a given node position. Useful for changing flow direction in discrete layouts
    };

    cy.add([
	{ group: "nodes", data: { id: "n0", label: "new1" }},
	{ group: "nodes", data: { id: "n1", label: "new2" }},
	{ group: "edges", data: { id: "e0", source: "n0", target: "n1" }},
	{ group: "edges", data: { id: "e1", source: "root", target: "n1" }}
    ]);

    addKnowledge = function(nodeId, nodeLabel){
	cy.add([
	    { group: "nodes", data: { id: nodeId, label: nodeLabel }}
	]);
    }

    cy.on('click', 'node', function(evt) {
    	console.log('clicked ' + this.id());
    });
    
    cy.layout(cytoLayout);

    callKnowledge = function(cytoObj) {
	console.log("start-before");
	//console.log(cytoObj);
	let result = $.getJSON("/software/aburatani/static/js/cytoscape/test.json", function(json){
	    alert("start-inner:");
	    // cytoObj.add([
	    // 	{ group: "nodes", data: { id: "n0" }, position: { x: 100, y: 100 } },
	    // 	{ group: "nodes", data: { id: "n1" }, position: { x: 200, y: 200 } },
	    // 	{ group: "edges", data: { id: "e0", source: "n0", target: "n1" } }
	    // ]);  
	    //console.log("ssssdddd:"+JSON.parse(JSON.stringify(json.elements))+":aaassss");
	    alert(":end-inner");
	    return "ssdd";
	});
	console.log(result.status);
	console.log(":finish-all");
    }
    callKnowledge(cy);
});
