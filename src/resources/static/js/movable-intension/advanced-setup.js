$(document).ready(function(){ 
    var obj = '[{"id":"オントロジーを理解させる"},{"id":"オントロジーの構成を理解させる"},{"id":"オントロジーのイメージを理解させる"},{"id":"簡単な図を理解させる"},{"id":"オントロジーの利用法を理解させる"},{"id":"基本的構成要素を理解させる"},{"id":"法造における構成要素を理解させる"},{"id":"Protegeにおける構成要素を理解させる"},{"id":"構成要素間の繋がりを理解させる"},{"id":"新規ノードの作成法を理解させる"},{"id":"part-ofとattribute-ofの区別を理解させる"}]';
    var output = '';
    function buildItem(item) {

        var html = "<li draggable class='dd-item' data-id='" + item.id + "'>";
        html += "<div class='dd-handle'>" + item.id + "</div>";

        if (item.children) {
            html += "<ol class='dd-list'>";
            $.each(item.children, function (index, sub) {
                html += buildItem(sub);
            });
            html += "</ol>";
        }
        html += "</li>";

        return html;
    }

    $.each(JSON.parse(obj), function (index, item) {

        output += buildItem(item);

    });

    $('#dd-empty-placeholder').html(output);
    $('#nestable').nestable();
});
