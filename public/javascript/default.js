// default.js

console.log(document.URL);

function initRemoveButtons() {
  var list_nodes = document.getElementsByTagName("li");
  for (var i = 0; i < list_nodes.length; i++) {
    if (!list_nodes[i].querySelector('.remove')) {
      var span = document.createElement("span");
      var text = document.createTextNode("\u00D7");
      span.className = "remove"
      span.appendChild(text)
      list_nodes[i].appendChild(span);
      
      span.onclick = function() {
        var parent = this.parentElement;
        parent.style.display = "none";
        // TODO: silo-sxv will handle actual DB deletion
      }
    }
  }
}

initRemoveButtons();

// --- Search Suggestion Logic (silo-ik7) ---

var searchInput = document.getElementById('show-search');
var suggestionsDiv = document.getElementById('suggestions');

if (searchInput) {
  var debounceTimer;

  // Add some basic styles for the suggestion dropdown
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
  // Focus back to input or trigger add? 
  // For now just fill the input.
};

// Close suggestions when clicking outside
document.onclick = function(e) {
  if (e.target !== searchInput && !suggestionsDiv.contains(e.target)) {
    suggestionsDiv.innerHTML = '';
  }
};
