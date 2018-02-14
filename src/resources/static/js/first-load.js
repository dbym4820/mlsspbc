function convertAbsUrl(relativePath){
  var anchor = document.createElement("a");
  anchor.href = relativePath;
  return anchor.href;
}
