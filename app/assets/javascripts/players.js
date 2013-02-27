// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

function SearchBoxHandler() {
  var search_request, search_running = false;
  var info_request, info_running = false;
  var lastActive = null;
  var spinneropts = {
    lines: 9, // The number of lines to draw
    length: 4, // The length of each line
    width: 5, // The line thickness
    radius: 9, // The radius of the inner circle
    corners: 1, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    color: '#000', // #rgb or #rrggbb
    speed: 1, // Rounds per second
    trail: 60, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: false, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    top: 'auto', // Top position relative to parent in px
    left: 'auto' // Left position relative to parent in px
  };
  
  // Update html content from json data
  var updatePlayerList = function(data) {
    var i, first, last, num, city, team, name_string;
    for (i = 0; i < data.length; i+=1) {
      first = data[i].first_name;
      last = data[i].last_name;
      num = data[i].number;
      city = data[i].team_city;
      team = data[i].team_name;
      name_string = first+' '+last+', No.'+num+', '+city+' '+team;
      $('<li id="'+data[i].id+'"><a href="#">'+name_string+'</a></li>').click(listClick).appendTo('#results');
    }
  };

  // Send query to server and get results
  var getResults = function(query) {
    $('#results').html('');
    search_request = $.getJSON("/players/search", {query: query}, function(data) {
      updatePlayerList(data);
      search_running = false;
    });
  };

  // Prepare query from user input
  var prepareQuery = function() {
    var query = $("#search_box #query").val();
    if (query.length === 0) {
      return null;
    }
    if (search_running) {
      search_request.abort();
    }
    search_running = true;
    return query;
  };

  // Callback for typing or submit events
  var updateSearchResults = function() {
    var query = prepareQuery();
    if (query) {
      getResults(query);
    }
  };

  $("#search_box").submit(function(e) {
    e.preventDefault();
    updateSearchResults();
  });

  $("#search_box input").keyup(function(e) {
    updateSearchResults();
  });

  var listClick = function(e) {
    e.preventDefault();

    // Change active style
    if (lastActive) {
      lastActive.toggleClass('active');
    }
    $(this).toggleClass('active');
    lastActive = $(this);
    getInfo($(this).attr('id'));
  };

  var getInfo = function(id) {
    if (info_running) {
      info_request.abort();
    }
    info_running = true;
    $('#information_container').spin(spinneropts);
    $('#information').fadeOut();
    info_request = $.getJSON("/players/get_info", {id: id}, function(data) {
      $('#information').html('');
      updateInfo(data);
      $('#information_container').spin(false);
      $('#information').fadeIn();
      info_running = false;
    });
  };

  var updateInfo = function(data) {
    var infoblock = $('#information');
    var ppg = data.ppg, rpg = data.rpg, apg = data.apg, img = data.img, news = data.news;
    infoblock.append('<div><h3>PPG:'+ppg+' | RPG:'+rpg+' | APG:'+apg
      +'</h3><img src="'+img+'"/></div>');
    infoblock.append('<ul>');
    for (var i = 0; i < news.length; i++) {
      infoblock.append('<li><a href="'+news[i].url+'">'+news[i].title+'</a></li>')
    }
    infoblock.append('</ul>');
  }
}

function initSearchPage() {
  var s = new SearchBoxHandler();
}

// jQuery plugin for spin.js
$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};