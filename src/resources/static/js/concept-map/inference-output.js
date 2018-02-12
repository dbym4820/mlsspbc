// 助言出力
// 出力の実行・非実行はココで操作
function inferenceOutput(){
    $.ajax({
	type: 'GET',
        url: '/inference-output',
        dataType: 'text',
        success: function(data) {
            alert(data);
        }
    });
}

