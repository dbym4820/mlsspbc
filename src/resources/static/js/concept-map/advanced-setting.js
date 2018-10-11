//org-chart記述部本体
(function($) {

    var chart;
    $.fn.orgChart = function(options) {
        var opts = $.extend({}, $.fn.orgChart.defaults, options);
	chart = new $.fn.OrgChart($(this), opts); 
        return chart;
    }

    $.fn.orgChart.defaults = {
        data: [{id:1, name:'Root', parent: 0}],
	nlis: {},
        showControls: false,
        allowEdit: true,
        onAddNode: null,
        onDeleteNode: null,
        onClickNode: function(){},
        newNodeText: 'Add Child'
    };

    $.fn.OrgChart = function($container, opts){
        var data = opts.data;
        var nodes = opts.nlis;
        var rootNodes = [];
        this.opts = opts;
        this.$container = $container;
        var self = this;
	
        this.draw = function(){
	    
            $container.empty().append(rootNodes[0].render(opts));

            $container.find('.node').on('click',function(){
		// ノードクリック時の挙動
                if(self.opts.onClickNode !== null){
                    self.opts.onClickNode(nodes[$(this).attr('node-id')]);

		    var clickedNode = $(this);
		    var selectedNode = nodes[$(this).attr('node-id')];
		    var selectedNodeName = selectedNode.data.name;
		    
		    //キーボード操作などにより、オーバーレイが多重起動するのを防止
		    $(this).blur();
		    if($("#modal-overlay")[0]) return false;
		    
		    //オーバーレイ用のHTMLコードを、[body]内の最後に生成する/この時点では隠し
		    $("body").append('<div id="modal-overlay"></div>');
		    $("#modal-overlay, #modal-close-btn1, #modal-close-btn2").on('click',function(){			
			$("#modal-overlay").fadeOut("fast");
			$("#modal-content-div").fadeOut("fast");
			$("#modal-overlay").remove();
		    });

		    
		    
		    //保存ボタンを押したときの挙動 => cytoscape/save-knowledge.jsにて，語彙に知識をマッピングする処理に変更 // 20180313
		    // $("#modal-save").on('click',function(){
			
		    // 	$("#modal-overlay").fadeOut("fast");
		    // 	$("#modal-content-div").fadeOut("fast");
		    // 	$("#modal-overlay").remove();
		    // 	clickedNode.css("background", "#2E64FE");
		    // });
		
		    //[$modal-overlay]をフェードインさせる
		    centeringModalSyncer();
		    $("#modalSelectedNode").text(selectedNodeName);    
		    $("#modal-overlay").fadeIn("fast");
		    $("#modal-content-div").fadeIn("fast");

		    // セマンティクスの描画
		    clearKnowledgeInsertion();
		    knowledgeRender();
		    knowledgeInitialize();
                }
            });

	    //↓ボタン
	    $container.find('.add-org-chart-node').click(function(e){
		var thisId = $(this).parents('.node').attr('node-id');
		if(self.opts.onAddNode !== null){
                    self.opts.onAddNode(nodes[thisId]);
                } else {
                    self.newNode("", thisId);
                }
                e.stopPropagation();
		self.redraw();
            });

	    // ↑ボタン
	    $container.find('.add-node-above').click(function(e){

		var thisId = $(this).parents('.node').attr('node-id');
		
		if(typeof thisId === "undefined") {
		    thisId = $(this).parents('.slide-node').attr('node-id');
		}
		var thisNode = self.getNode(thisId);
		var parentId = checkParentNodeId(thisNode.data.id);
		var nextId = self.newNodePlusReturn("", parentId);
		self.updateNodeInfo(thisId, thisId, nextId);

            });

	    //-ボタン
	    $container.find('.edit-btn').click(function(e){	
		e.stopPropagation();
            });

	    $container.find('.make-line-btn').click(function(e){	
		e.stopPropagation();
            });

	    $container.find('.remove-org-chart-node').click(function(e){
		var thisId = $(this).parent().parent().parent().attr('node-id');

		if(self.opts.onDeleteNode !== null) {
                    self.opts.onDeleteNode(nodes[thisId]);
                } else {
                    self.deleteNode(thisId);
                }
		self.redraw();
                e.stopPropagation();
            });
	    
	    $container.find('.node').click(function(e){
		var thisId = $(this).attr('node-id');
		e.stopPropagation();
	    });

	    // 兄弟リンク描画
	    var jsonObject;

        }

	this.redraw = function(){
	    this.draw();
	    // 兄弟リンクの再描画
	    var lessonId = getUrlVars()['lesson-id'];
	    $.getJSON(baseURL+"load-slide-line-list?lesson-id="+lessonId, function(dataList) {
		dataList.forEach(function(d){
		    draw_line(d.parent, d.child, d.function);
		});
	    });

	}
	
	this.updateNode = function(content, nodeId){
	    // ここはDeprecated
	    if(content.charAt(0) === "."){
		$("[node-id ^= '" + nodeId + "']").css('width', '250px');
		$("[node-id ^= '" + nodeId + "']").css('height', '250px');
		nodes[nodeId].data.name = "<p>aaa</p><img src='"+content+"' width='250px' height='250px' />";
		$("[node-id ^= '" + nodeId + "']").parent().css('height', '250px');
		$("[node-id ^= '" + nodeId + "']").find('#dropbox').css('height', '250px');	
	    } else {
		$("[node-id ^= '" + nodeId + "']").css('width', '150px');
		$("[node-id ^= '" + nodeId + "']").css('height', '100px');
		nodes[nodeId].data.name = content;
	    }	    
	}
	
        this.newNode = function(content, parentId){
            var nextId = Object.keys(nodes).length;
            while(nextId in nodes){
                nextId++;
            }
            self.addNode({id: nextId, name: content, parent: parentId});
        }

        this.genNewNode = function(content, parentId){
            var nextId = Object.keys(nodes).length;
            while(nextId in nodes){
                nextId++;
            }
            return {id: nextId, name: content, parent: parentId};
        }

	
	this.newNodePlusReturn = function(content, parentId){
            var nextId = Object.keys(nodes).length; // グラフ全体のノード数計上
            while(nextId in nodes){
                nextId++;
            }
            self.addNode({id: nextId, name: content, parent: parentId});
	    return nextId;
        }

	this.nodesLength = function(){
	    return Object.keys(nodes).length;
	}
	
        this.addNode = function(data){
            var newGenNode = new Node(data);
            nodes[data.id] = newGenNode;
            nodes[data.parent].addChild(newGenNode);
            self.draw();
	}

	this.updateNodeInfo = function(targetId, newNodeId, newParentId, nodeObject){

 	    for(i=0;i<=self.opts.data.length-1;i++){
		if(self.opts.data[i].id == targetId){
		    // 押下したノードIDに対応するノードを特定の親の子ノードにすげ替える(木ごと移動する)
	    
		    // システム内部での状態の更新
		    //self.opts.data[i].parent = newParentId;
		    //nodes[self.opts.data[i].id].parent = newParentId;
		    let oldParentId = self.opts.data[i].parent;
		    // 表示上での更新
		    this.moveNode(targetId, oldParentId, newParentId);
		}
	    }
	    self.redraw();
	}

	this.nextID = function () {
	    return Object.keys(nodes).length + 1;
	}
	
	this.moveNode = function(id, oldParentId, newParentId) {
	    let startId = self.nextID();
	    // 押下したノードを更新
	    self.addNode({id: startId, name: self.getNode(id).data.name, parent: newParentId});
	    // 押下したノード以下のノードを再帰的に更新
	    self.recursiveAddNode(id, startId); 
	    self.deleteNode(id); // 元のツリーを削除して転送完了
	}

	this.recursiveAddNode = function (oldId, newParentId){
	    if(Object.keys(self.findChilds(oldId)).length !== 0){
		self.findChilds(oldId).map(function(d){
		    let newId = self.nextID();
		    self.addNode({id: newId, name: self.getNode(d).data.name, parent: newParentId});
		    self.recursiveAddNode(d, newId);
		});
	    } else {
		return 0;
	    }
	}
	
	this.flatten = function (ary) {
	    return ary.reduce(function (p, c) {
		return Array.isArray(c) ? p.concat(self.flatten(c)) : p.concat(c);
	    }, []);
	}
		
	this.findChilds = function(id) {
	    // 直系の子ノードだけ取得
	    let childList = [];
	    self.getData().forEach(function(data){
		if(data.parent == id) {
		    childList.push(data.id);
		}
	    });
	    return childList;
	}

	this.deleteNode = function(id){

	    // 再帰的に子ノードを削除することで，下から順番に削除することを担保している・末尾再帰による最適化
	    if(Object.keys(self.findChilds(id)).length !== 0){
		self.findChilds(id).map(function (tmpId){
		    self.deleteNode(tmpId);
		});
	    }
	    var oldNode = nodes[id].data.name;
	    if( (oldNode !== "") && (oldNode !== "NEW") && (oldNode !== "NEW\n") && (!oldNode.match("/static/")) ){
	    	var inNode = '<div class="node-content intension-items" draggable="true" id="' + oldNode + '" ondragstart="f_dragstart(event)">' + oldNode + '</div>';
	    	document.getElementById('intensions').innerHTML += inNode;
	    }

            nodes[nodes[id].data.parent].removeChild(id);
            delete nodes[id];
            self.redraw();
        }

	this.getNode = function(id){
	    return nodes[id];
	}

        this.getData = function(){
            var outData = [];
            for(var i in nodes){
                outData.push(nodes[i].data);
            }
            return outData;
        }
	
        // constructor
        for(var i in data){
            var node = new Node(data[i]);
            nodes[data[i].id] = node;
        }

        // generate parent child tree
        for(var i in nodes){
            if(nodes[i].data.parent == 0){

		rootNodes.push(nodes[i]);
            }
            else{
                nodes[nodes[i].data.parent].addChild(nodes[i]);
            }
        }

        // draw org chart
        $container.addClass('orgChart');
        self.draw();
    }


    $.fn.OrgChart.instance = function(){
	return this;
    }
    
    function Node(data){
        this.data = data;
        this.children = [];
        var self = this;

        this.addChild = function(childNode){
            this.children.push(childNode);
        }

	///////////////////////////////////////////////////
	///////////////////////////////////////////////////
	///////////////////////////////////////////////////
	/* this.moveNode = function(oldParentNode, newParentNode){
	   self.data.parent = newParentNode;
	   let moveNode = chart.getNode(self.data.id);
	   //chart.deleteNode(self.data.id);
	   self.removeSelf();
	   chart.getNode(newParentNode).children.push(moveNode);
	   
	   chart.getNode(oldParentNode).children.forEach(function (d,count){
	   
	   if(self.data.id+"" === d.data.id+""){
	   }
	   });

	   // 内容の同じ異なるノード（新ノード）を再帰的に構築する
	   for(var i=0;i<chart.opts.nlis[this.data.id].children.length;i++){
	   if(self.findChilds(this.data.id)){
	   self.findChilds(this.data.id).map(function (tmpId){
	   console.log(chart.genNewNode(this.data.name, newParentNode));
	   //self.deleteNode(tmpId);
	   });
	   }
	 *         //self.deleteNode(nodes[id].data.id);
	 *     }

	   } */
	///////////////////////////////////////////////////
	///////////////////////////////////////////////////
	///////////////////////////////////////////////////
	///////////////////////////////////////////////////
	
	this.removeSelf = function(){

	}
	
        this.removeChild = function(id){
            for(var i=0;i<self.children.length;i++){
                if(self.children[i].data.id == id){
                    self.children.splice(i,1);
                    return;
                }
            }
        }

	//ここからは組織図レンダリング用
        this.render = function(opts){
            var childLength = self.children.length,
                mainTable;

            mainTable = "<div class='clear-float'></div>"+"<table class='conceptTable' cellpadding='0' cellspacing='0' border='0'>";
            var nodeColspan = childLength > 0 ? 2*childLength : 2;
            mainTable += "<tr><td colspan='"+nodeColspan+"'>"+self.formatNode(opts)+"</td></tr>";

            if(childLength > 0){
                var downLineTable = "<table cellpadding='0' cellspacing='0' border='0'><tr class='lines x'><td class='line left half'></td><td class='line right half'></td></table>";
                mainTable += "<tr class='lines'><td colspan='"+childLength*2+"'>"+downLineTable+'</td></tr>';

                var linesCols = '';
                for(var i=0;i<childLength;i++){
                    if(childLength==1){
                        linesCols += "<td class='line left half'></td>";    // keep vertical lines aligned if there's only 1 child
                    }
                    else if(i==0){
                        linesCols += "<td class='line left'></td>";     // the first cell doesn't have a line in the top
                    }
                    else{
                        linesCols += "<td class='line left top'></td>";
                    }

                    if(childLength==1){
                        linesCols += "<td class='line right half'></td>";
                    }
                    else if(i==childLength-1){
                        linesCols += "<td class='line right'></td>";
                    }
                    else{
                        linesCols += "<td class='line right top'></td>";
                    }
                }
                mainTable += "<tr class='lines v'>"+linesCols+"</tr>";

                mainTable += "<tr>";
                for(var i in self.children){
                    mainTable += "<td colspan='2'>"+self.children[i].render(opts)+"</td>";
                }
                mainTable += "</tr>";
            }
            mainTable += '</table>';
            return mainTable;
        }

	//ノードの形式の定義
        this.formatNode = function(opts){
	    var descString = '';
	    var dId = self.data.id; // ノードのID
	    var dName = self.data.name; // ノードの中身
	    var contentHTML;

	    var addButton = '<div class="add-node-bottom-div">' +
                                '<button class="add-org-chart-node btn-xs btn-success" type="button">' +
                                    //'<p class="btn-img-content-l">↓</p>'+// '<img src="/static/image/concept-map/add.gif" height="12" width="12" />' +
		                    '↓' +
                                '</button>' +
                             '</div>';

	    var addAboveButton = '<div class="add-node-above-div">' +
                                    '<button class="add-node-above btn-xs btn-success" type="button">' +
                                      //'<p class="btn-img-content-l">↑</p>'+// '<img src="/static/image/concept-map/add.gif" height="12" width="12" />' +
		                      '↑' +
                                    '</button>' +
                                 '</div>';

	    // スライド削除ボタン
	    var removeButton1 = '<div style="text-align:right;" class="remove-btn-div1">' +
                                    '<button class="remove-org-chart-node btn-xs btn-danger" type="button">' +
                                        //'<img src="../../static/image/concept-map/closs.png" class="btn-img-content-r" />' +
		                        '✕' +
                                    '</button>' +
                                '</div>';		    

	    // 語彙ノード削除ボタン
	    var removeButton2 = '<div style="text-align:right;" class="remove-btn-div">' +
                                    '<button class="remove-org-chart-node btn-xs btn-danger" type="button">' +
                                        //'<img src="/static/image/concept-map/closs.png" class="btn-img-content-r" />' +
		                        '✕' +
                                    '</button>' +
                                '</div>';		    

	    var editButton = '<div data-toggle="modal" data-target="#div-modal" class="edit-btn">' +
		                 '<a class="modal-opening">' +
		                     '<button class="edit-node btn-xs btn-default" type="button">' +
                                       '<img src="../../static/image/concept-map/edit.png" class="btn-img-content-l2" />' +
                                     '</button>' +
		                 '</a>' +
                              '</div>';

	    var lineMakeButton = '<div class="make-line-btn">' +
                                    '<button class="nodes-line btn-xs btn-warning" type="button" onclick="makeLine1(\'' + dName  + '\');" >' +
                                        '<img src="../static/image/concept-map/edit.png" class="btn-img-content-r2" />' +
                                    '</button>' +
                                '</div></div>';
	    
	    
            if(typeof data.description !== 'undefined'){
		descString = self.data.description;
            }

	    // ノードの組み立て
	    if( dName.match("/static/") ){ // スライドノードの設定
	    	return "<div class='slide-node' node-id='"+this.data.id+"'>" +
		          "<div class='above-buttom'>" +
		          addAboveButton + removeButton1 +
		          "</div>" +
		          // ここからノードのコンテンツ
		          "<div class='node-content-square' ondragover='f_dragover(event)' " +
		               "ondrop='f_drop(event,"+ dId  +")'>" +
		             '<div class="slide-node-content intension-items" draggable="true"' +
		                    'id="' +dName+ '" ' +
		                    'ondragstart="f_dragstart(event)">'+
		                  '<img src="' + dName  + '" class="slide-image" height="100" width="100" />' +
		                  //createContent(dName) +
		             '</div>' +
		              descString +
		          "</div><div class='bottom-buttom'>"
		          // ここまでノードのコンテンツ
		          // + editButton
		    + lineMakeButton +
		       "</div></div>";
	    } else { // 通常インテンションノードの設定
		return "<div class='node' node-id='"+this.data.id+"'>" +
		          "<div class='above-buttom'>" +
			  addAboveButton + addButton + removeButton2 + 
		          "</div>" +
		          // ここからノードのコンテンツ
		          "<div class='node-content-square' ondragover='f_dragover(event)' " +
		               "ondrop='f_drop(event,"+ dId  +")'>" +
		              '<div class="node-content intension-items" draggable="true"' +
		                    'id="' +dName+ '" ' +
		                    'ondragstart="f_dragstart(event)">'+
		                  createContent(dName) +
		              '</div>'
		              + descString +
		          "</div><div class='bottom-buttom'>" +
		          // ここまでノードのコンテンツ
		          // 開発をすすめるときは↓はアンコメントする
		           // editButton +
		    lineMakeButton +
	               "</div></div>";
	    }
        }
    }
    
})(jQuery);


window.addEventListener('resize', function (event) {
    chart.redraw();
});

//ノードの中身を編集しリターン
function createContent(content){
    var splitedContent = content.split(/(.{12})/).filter(x=>x);
    var arrayLength = splitedContent.length;
    var edittedContent = content;

    return edittedContent;
}
