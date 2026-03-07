// default.js

console.log(document.URL);

function initRemoveButtons() {
  var list_nodes = document.querySelectorAll("ul#show.list li");
  for (var i = 0; i < list_nodes.length; i++) {
    if (!list_nodes[i].querySelector('.remove')) {
      var span = document.createElement("span");
      var text = document.createTextNode("\u00D7");
      span.className = "remove"
      span.appendChild(text)
      list_nodes[i].appendChild(span);
      
      span.onclick = function() {
        var li = this.parentElement;
        var showName = li.childNodes[0].textContent.trim();
        removeShow(showName, li);
      }
    }
  }
}

function removeShow(name, li) {
  var username = window.location.pathname.split('/')[2];
  if (!username) return;

  fetch('/api/v0.1/user/' + username + '/show/' + encodeURIComponent(name), {
    method: 'DELETE'
  })
  .then(response => response.json())
  .then(data => {
    li.remove();
  });
}

// --- Drag and Drop Logic (silo-pqt) ---

function initDraggable() {
  var items = document.querySelectorAll("ul#show.list li");
  items.forEach(function(item) {
    item.draggable = true;
    item.addEventListener('dragstart', handleDragStart);
    item.addEventListener('dragover', handleDragOver);
    item.addEventListener('drop', handleDrop);
    item.addEventListener('dragend', handleDragEnd);
  });
}

var dragSourceItem = null;

function handleDragStart(e) {
  dragSourceItem = this;
  e.dataTransfer.effectAllowed = 'move';
  this.classList.add('dragging');
}

function handleDragOver(e) {
  if (e.preventDefault) e.preventDefault();
  return false;
}

function handleDrop(e) {
  if (e.stopPropagation) e.stopPropagation();
  
  if (dragSourceItem !== this) {
    var list = this.parentNode;
    var allItems = Array.from(list.children);
    var sourceIndex = allItems.indexOf(dragSourceItem);
    var targetIndex = allItems.indexOf(this);
    
    if (sourceIndex < targetIndex) {
      list.insertBefore(dragSourceItem, this.nextSibling);
    } else {
      list.insertBefore(dragSourceItem, this);
    }
    
    saveNewOrder();
  }
  return false;
}

function handleDragEnd() {
  this.classList.remove('dragging');
}

function saveNewOrder() {
  var username = window.location.pathname.split('/')[2];
  if (!username) return;

  var showNames = Array.from(document.querySelectorAll("ul#show.list li"))
    .map(li => li.childNodes[0].textContent.trim());

  fetch('/api/v0.1/user/' + username + '/shows/reorder', {
    method: 'POST',
    body: JSON.stringify(showNames),
    headers: { 'Content-Type': 'application/json' }
  });
}

// Run initializers
initRemoveButtons();
initDraggable();

// --- Search Suggestion Logic (silo-ik7) ---

var searchInput = document.getElementById('show-search');
var suggestionsDiv = document.getElementById('suggestions');

if (searchInput) {
  var debounceTimer;

  var style = document.createElement('style');
  style.innerHTML = `
    #suggestions-list {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      background: white;
      border: 1px solid #ccc;
      border-top: none;
      z-index: 1000;
      list-style: none;
      margin: 0;
      padding: 0;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    #suggestions-list li {
      padding: 10px;
      cursor: pointer;
      border-bottom: 1px solid #eee;
    }
    #suggestions-list li:hover {
      background-color: #f0f0f0;
    }
    #suggestions-list li .meta {
      font-size: 0.8em;
      color: #666;
    }
    ul#show.list li {
      cursor: move;
      background: #fdfdfd;
      margin-bottom: 5px;
      padding: 5px;
      border: 1px solid #eee;
    }
    ul#show.list li.dragging {
      opacity: 0.5;
      background: #eee;
    }
  `;
  document.head.appendChild(style);

  searchInput.oninput = function() {
    clearTimeout(debounceTimer);
    var query = this.value;

    if (query.length < 2) {
      suggestionsDiv.innerHTML = '';
      return;
    }

    debounceTimer = setTimeout(function() {
      fetch('/api/v0.1/search?q=' + encodeURIComponent(query))
        .then(response => response.json())
        .then(data => {
          renderSuggestions(data);
        });
    }, 300);
  };
}

function renderSuggestions(suggestions) {
  if (suggestions.length === 0) {
    suggestionsDiv.innerHTML = '';
    return;
  }

  var html = '<ul id="suggestions-list">';
  suggestions.forEach(function(s) {
    var genreText = s.genres && s.genres.length > 0 ? s.genres.join(', ') : 'No genres';
    var yearText = s.year ? s.year : 'N/A';
    
    html += '<li onclick="selectSuggestion(\'' + s.name.replace(/'/g, "\\'") + '\')">';
    html += '<strong>' + s.name + '</strong>';
    html += '<div class="meta">' + yearText + ' &bull; ' + genreText + '</div>';
    html += '</li>';
  });
  html += '</ul>';
  
  suggestionsDiv.innerHTML = html;
}

window.selectSuggestion = function(name) {
  searchInput.value = name;
  suggestionsDiv.innerHTML = '';
  addShow(name);
};

function addShow(name) {
  var username = window.location.pathname.split('/')[2];
  if (!username) return;

  var formData = new FormData();
  formData.append('show', name);

  fetch('/api/v0.1/user/' + username + '/show', {
    method: 'POST',
    body: formData
  })
  .then(response => response.json())
  .then(data => {
    renderShows(data);
    searchInput.value = '';
  });
}

function renderShows(showNames) {
  var showList = document.querySelector('ul#show.list');
  if (!showList) return;

  showList.innerHTML = '';
  showNames.forEach(function(name) {
    var li = document.createElement('li');
    li.textContent = name;
    showList.appendChild(li);
  });
  initRemoveButtons();
  initDraggable();
}

var addButton = document.querySelector('.addbutton');
if (addButton) {
  addButton.onclick = function() {
    var name = searchInput.value;
    if (name) addShow(name);
  };
}

document.onclick = function(e) {
  if (e.target !== searchInput && !suggestionsDiv.contains(e.target)) {
    suggestionsDiv.innerHTML = '';
  }
};
