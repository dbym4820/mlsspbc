function saveKnow (slideId){//, callback){
    var slidePath = "www";
    $.ajax({
	type: 'GET',
	url: location.pathname+'/../../knowledge-save?slide-id='+slideId+'&slide-path='+slidePath,
	dataType: 'text',
	async: false,
	success: function(data){
	    	console.log(data);
	    	return data;
	    // callback(data);
	}
    });
}


$(window).ready(function (){
    $("#k-save-btn").on("click", function(e){
	var nodeContent = $("#modalSelectedNode").html();
	saveKnow(nodeContent);
    });
});
			    
