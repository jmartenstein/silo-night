// default.js

function initRemoveButtons() {
  document.querySelectorAll("ul#show.list .remove").forEach(function(btn) {
    btn.onclick = function() {
      var li = this.parentElement;
      var showName = li.querySelector('.name').textContent.trim();
      removeShow(showName, li);
    }
  });
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

// --- Availability AJAX ---
var availForm = document.getElementById('availability-form');
if (availForm) {
  availForm.onsubmit = function(e) {
    e.preventDefault();
    var formData = new FormData(this);
    var username = window.location.pathname.split('/')[2];
    
    fetch('/user/' + username + '/availability', {
      method: 'POST',
      body: formData
    })
    .then(response => {
      if (response.ok) {
        // Show a brief success indicator if needed
        var btn = availForm.querySelector('input[type="submit"]');
        var originalValue = btn.value;
        btn.value = 'Saved';
        setTimeout(() => btn.value = originalValue, 2000);
      }
    });
  };
}

// --- Drag and Drop Logic ---

function initDraggable() {
  var items = document.querySelectorAll("ul#show.list li");
  items.forEach(function(item) {
    item.draggable = true;
    item.addEventListener('dragstart', handleDragStart);
    item.addEventListener('dragover', handleDragOver);
    item.addEventListener('dragenter', handleDragEnter);
    item.addEventListener('dragleave', handleDragLeave);
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
  
  if (dragSourceItem !== this) {
    var rect = this.getBoundingClientRect();
    var midpoint = rect.top + rect.height / 2;
    if (e.clientY < midpoint) {
      this.classList.add('over-top');
      this.classList.remove('over-bottom');
    } else {
      this.classList.add('over-bottom');
      this.classList.remove('over-top');
    }
  }
  
  return false;
}

function handleDragEnter(e) {
}

function handleDragLeave(e) {
  this.classList.remove('over-top');
  this.classList.remove('over-bottom');
}

function handleDrop(e) {
  if (e.stopPropagation) e.stopPropagation();
  
  this.classList.remove('over-top');
  this.classList.remove('over-bottom');

  if (dragSourceItem !== this) {
    var list = this.parentNode;
    var rect = this.getBoundingClientRect();
    var midpoint = rect.top + rect.height / 2;
    
    if (e.clientY < midpoint) {
      list.insertBefore(dragSourceItem, this);
    } else {
      list.insertBefore(dragSourceItem, this.nextSibling);
    }
    
    saveNewOrder();
  }
  return false;
}

function handleDragEnd() {
  this.classList.remove('dragging');
  var items = document.querySelectorAll("ul#show.list li");
  items.forEach(function(item) {
    item.classList.remove('over-top');
    item.classList.remove('over-bottom');
  });
}

function saveNewOrder() {
  var username = window.location.pathname.split('/')[2];
  if (!username) return;

  var showNames = Array.from(document.querySelectorAll("ul#show.list li"))
    .map(li => li.querySelector('.name').textContent.trim());

  fetch('/api/v0.1/user/' + username + '/shows/reorder', {
    method: 'POST',
    body: JSON.stringify(showNames),
    headers: { 'Content-Type': 'application/json' }
  });
}

// --- Search Suggestion Logic ---

var searchInput = document.getElementById('show-search');
var suggestionsDiv = document.getElementById('suggestions');

if (searchInput) {
  var debounceTimer;

  // Add styles for suggestions only if they don't exist
  if (!document.getElementById('suggestion-styles')) {
    var style = document.createElement('style');
    style.id = 'suggestion-styles';
    style.innerHTML = `
      #suggestions-list {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        background: var(--bg-color);
        border: 1px solid var(--border-color);
        border-top: none;
        z-index: 1000;
        list-style: none;
        margin: 0;
        padding: 0;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
      }
      #suggestions-list li {
        padding: var(--spacing-md);
        cursor: pointer;
        border-bottom: 1px solid var(--border-color);
      }
      #suggestions-list li:hover {
        background-color: var(--hover-bg);
      }
      #suggestions-list li .meta {
        font-size: 0.8em;
        color: var(--dim-color);
      }
      ul#show.list li.dragging {
        opacity: 0.5;
        background: var(--hover-bg);
      }
      ul#show.list li.over-top {
        border-top: 2px solid var(--accent-color);
      }
      ul#show.list li.over-bottom {
        border-bottom: 2px solid var(--accent-color);
      }
    `;
    document.head.appendChild(style);
  }

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

function renderShows(shows) {
  var showList = document.querySelector('ul#show.list');
  if (!showList) return;

  showList.innerHTML = '';
  shows.forEach(function(s) {
    var li = document.createElement('li');
    li.className = 'list-item';
    
    var nameSpan = document.createElement('span');
    nameSpan.className = 'name';
    nameSpan.textContent = s.name;
    li.appendChild(nameSpan);
    
    var runtimeSpan = document.createElement('span');
    runtimeSpan.className = 'runtime';
    runtimeSpan.textContent = s.runtime + 'm';
    li.appendChild(runtimeSpan);

    var removeSpan = document.createElement('span');
    removeSpan.className = 'remove';
    removeSpan.innerHTML = '&times;';
    li.appendChild(removeSpan);
    
    showList.appendChild(li);
  });
  initRemoveButtons();
  initDraggable();
}

// Run initializers
initRemoveButtons();
initDraggable();

document.onclick = function(e) {
  if (e.target !== searchInput && !suggestionsDiv.contains(e.target)) {
    suggestionsDiv.innerHTML = '';
  }
};
