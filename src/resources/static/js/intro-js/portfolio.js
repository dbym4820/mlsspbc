/************ 各スライドについての助言を出力する設定を書くファイル ***********/

function loadAdvice (slideId, lessonId, callback){
    $.ajax({
	type: 'GET',
	url: location.pathname+'/../../generate-advice?slide-id='+slideId+'&lesson-id='+lessonId,
	dataType: 'text',
	async: false,
	success: function(data){
	    //	console.log(data);
	    //	return data;
	    callback(data);
	}
    });
}

function plusIntroTug (){
    var lessonId = getUrlVars()['lesson-id'];
    var count = 1;
    $(".slide-node").each(function(index, element){
	var slidePathId = $(element).find(".slide-node-content").attr("id");
	loadAdvice(slidePathId, lessonId, function(res){
	    $(element).attr("data-intro", res);
	});
	$(element).attr("data-step", count);
	count++;
	$(element).attr("data-position", "left");
	$(element).attr("src", slidePathId);
    });
}


function kModal (slideId){
    sigma.parsers.json(location.pathname+"/../../slide-knowledge-struct?slide-id="+slideId, {
	//    sigma.parsers.json('/static/js/sigma/sample-data.json', {
	container: 'paper',
	x: 0, y: 0, angle: 0.5, ratio: 0.5,
	settings: {
	    defaultNodeColor: '#ec5148'
	}
    });
}


$(window).ready(function () {
    if(document.getElementById("finish-declare-btn")){

	document.querySelector('button#finish-declare-btn').onclick = function(){
	    
	    swal({
		// 表示するタイトル(default:null)
		title: "本当に課題を終了しますか?",
		// 表示するテキスト文(default:null)
		text: "十分に自分の考えが設計できたと思えるまで課題を続けてください",
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
		plusIntroTug();
		var introInstance = introJs();
		console.log("push intro btn");
		introInstance.onafterchange(function(targetElem){
		    setTimeout(function(){
		 	kModal("1");
		    }, 500);
		});
		introInstance.setOptions({
		    'nextLabel': '次のスライド',
		    'prevLabel': '前のスライド',
		    'showProgress': false,
		    'showStepNumbers': false,
		    'showBullets': false,
		    'tooltipClass': "intro-tool",	    
		}).start();
	    });
	};
    }
});
