// default.js

console.log(document.URL);

var list_nodes = document.getElementsByTagName("li");
var i;

console.log("li nodes: ", list_nodes.length)

// add a "remove" button to each list item
for (i = 0; i < list_nodes.length; i++) {

  // define the elements we want to add
  var span = document.createElement("span");
  var text = document.createTextNode("\u00D7");

  // decorate the span
  span.className = "remove"
  span.appendChild(text)

  list_nodes[i].appendChild(span);

}

// click on the "remove" button to hide the list item
var remove_nodes = document.getElementsByClassName("remove");
console.log("remove nodes: ", remove_nodes.length)

for (i = 0; i < remove_nodes.length; i++) {

  remove_nodes[i].onclick = function() {
    var parent = this.parentElement;
    parent.style.display = "none";
  }

}
