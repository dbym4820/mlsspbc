/* スライドに知識をマッピングする  */


function saveKnow (slideId){//, callback){
    // var slidePath = "www";
    // $.ajax({
    // 	type: 'GET',
    // 	url: location.pathname+'/../../knowledge-save?slide-id='+slideId+'&slide-path='+slidePath,
    // 	dataType: 'text',
    // 	async: false,
    // 	success: function(data){
    // 	    	//console.log(data);
    // 	    	return data;
    // 	    // callback(data);
    // 	}
    // });
}


$(window).ready(function (){
    $("#k-save-btn").on("click", function(e){
	var nodeContent = $("#modalSelectedNode").html();
	swal({
	    // 表示するタイトル(default:null)
	    title: "本当に知識を保存しますか?",
	    // 表示するテキスト文(default:null)
	    text: "明示的知識，潜在的知識が正しく設定されていることを確認してください",
	    // タイプ（warning,error,success,info）(default:null)
	    type: "success",
	    // cancelボタンの表示(default:false)
	    showCancelButton: true,
	    // confirmボタンの色設定(16進数値)(default:"#AEDEF4")
	    confirmButtonColor: "#DD6B55",
	    // confirmボタンのテキスト設定(default:"OK")
	    confirmButtonText: "Yes",
	    // cancelボタンのテキスト設定(default:"Cancel")
	    cancelButtonText : "Not yet",
	    // confirmボタン押下でウインドウを閉じるかどうかの設定(default:true)
	    closeOnConfirm: true,
	    // cancelボタン押下でウインドウを閉じるかどうかの設定(default:true)
	    closeOnCancel : true
	}, function (){
	    		
	    $("#modal-overlay").fadeOut("fast");
	    $("#modal-content-div").fadeOut("fast");
	    $("#modal-overlay").remove();

	    /* 定義は，graphdracula/advanced-setting.js内にある．ノードの知識をセーブ */
	    knowledgeSelectionSave(nodeContent);
	    
	    saveKnow(nodeContent);
	});
    });
});
			    
