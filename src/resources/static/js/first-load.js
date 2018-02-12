$(window).load(function(){
    $("#register-btn").on('click',function(){
	
	$("#modal-overlay").fadeOut("fast");
	$("#modal-content-div").fadeOut("fast");
	$("#modal-overlay").remove();
    });
});
