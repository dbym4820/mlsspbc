// 日本語・「オントロジーとは」のスライド
/*
$(window).load(function () {	
     document.querySelector('button.finish-declare-btn').onclick = function(){
         swal({title:"オントロジーとは？",
 	      text:"あなたはこのスライドに明示的に書かれていることを説明できていますが，このスライドにおける「規約」の存在にどれほどの意味があるのか，といったことを理解しているでしょうか？",
 	      imageUrl:"/static/slide/keynote/test/assets/44C6346C-FC55-4C9F-8BCF-5F70BC027A15/thumbnail.jpeg"
 	     });
     };
 });
*/

// 日本語・「オントロジーにおける概念関係の扱い」のスライド
/*
$(window).load(function () {	
     document.querySelector('button.finish-declare-btn').onclick = function(){
         swal({title:"オントロジーにおける概念関係の扱い",
 	      text:"あなたは理解表明では，「理解している」と宣言していましたが，「３つの図が表す関係性の本質的な違い」について説明しようとしているでしょうか？もう一度考えてみては？",
 	      imageUrl:"/static/slide/keynote/test/assets/AB72A5AF-E40E-4992-B2CC-DDE3F08B0904/thumbnail.jpeg"
 	     });
     };
});
*/

// 英語・「関係概念の扱い」のスライド
/*
$(window).load(function () {	
    document.querySelector('button.finish-declare-btn').onclick = function(){
        swal({title:"Handling conceptual relations in Ontology",
	      text:"You declared that you already understand the knowledge written in the slide. But you doen't looks understand clearly such as Essence of the relationship amoung these three figures. Could you explain how relationship are there?",
	      imageUrl:"/static/slide/keynote/test/assets/F59CCAE5-0370-4AA0-AC69-2E87522F233C/thumbnail.jpeg"
	     });
    };
});
*/

// 英語・「関係概念の扱い」のスライド（ちょっと違う？）
/*
$(window).load(function () {	
     document.querySelector('button.add-term-btn').onclick = function(){
         swal({title:"Handling conceptual relations in Ontology",
	      text:"You declared that you already understand the knowledge written in the slide. But you doen't looks understand clearly such as Essence of the relationship amoung these three figures. Could you explain how relationship are there?",
	      imageUrl:"/static/slide/keynote/test/assets/AB72A5AF-E40E-4992-B2CC-DDE3F08B0904/thumbnail.jpeg"
	     });
     };
});
*/

// 英語・「関係概念の扱い」のスライド（これと上のやついらないかも）
/*
$(window).load(function () {	
     document.querySelector('button.finish-delare-btn').onclick = a();
});
*/

// $(window).load(function () {	
//      $('.slide-image').each(function(){
// 	var ab = $(this).attr("class");
// 	var path = "";
// 	if(ab === "slide-image intension-items"){
// 		path = $(this).attr("id");
// 	} else {
// 		path = $(this).parent().attr("id");
// 	}

// 	$(this).on('click', function(){
// 		swal({title:"", text:"", imageUrl:path});
//          });
//      });
//  });

// function loadAdvice (slideId, callback){
// 	$.ajax({
// 	type: 'GET',
// 	url: '/generate-advice?slide-id='+slideId,
// 	dataType: 'text',
// 	async: false,
// 	success: function(data){
// 		//	console.log(data);
// 		//	return data;
// 			callback(data);
// 		}
// 	});
// }

// function a (){
// 	var func;
// 	loadAdvice(function(result){
// 		func = swal(d);
// 	});
// 	return func;
// }
