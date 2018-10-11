/*****************************************************************************
関係関数
*****************************************************************************/
// Getパラメータ取得
var getUrlVars = function(){
    var vars = {}; 
    var param = location.search.substring(1).split('&');
    for(var i = 0; i < param.length; i++) {
        var keySearch = param[i].search(/=/);
        var key = '';
        if(keySearch != -1) key = param[i].slice(0, keySearch);
        var val = param[i].slice(param[i].indexOf('=', 0) + 1);
        if(key != '') vars[key] = decodeURI(val);
    } 
    return vars; 
}

function convertAbsUrl(relativePath){
  var anchor = document.createElement("a");
  anchor.href = relativePath;
  return anchor.href;
}

var baseURL = location.pathname+"/../../";
