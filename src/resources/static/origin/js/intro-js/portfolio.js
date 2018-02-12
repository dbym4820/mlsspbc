
function loadAdvice (slideId, callback){
	$.ajax({
	type: 'GET',
	url: '/generate-advice?slide-id='+slideId,
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
    var count = 1;
    $(".slide-node").each(function(index, element){
	var slidePathId = $(element).find(".slide-node-content").attr("id");
	loadAdvice(slidePathId, function(res){
	    $(element).attr("data-intro", res);
	});
	$(element).attr("data-step", count);
	count++;
	$(element).attr("data-position", "left");
	$(element).attr("src", slidePathId);
    });
}


function kModal (slideId){
        sigma.parsers.json("/slide-knowledge-struct?slide-id="+slideId, {
    //    sigma.parsers.json('/static/js/sigma/sample-data.json', {
	container: 'paper',
	x: 0, y: 0, angle: 0.5, ratio: 0.5,
	settings: {
	    defaultNodeColor: '#ec5148'
	}
    });
}

$(window).load(function () {
    
    document.querySelector('button.finish-declare-btn').onclick = function(){
	plusIntroTug();
	var introInstance = introJs();
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
    };
});

