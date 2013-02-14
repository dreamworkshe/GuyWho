// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

function initSearchPage() {
  var request;
  var running = false;

  function getResults(query) {
    $('#results').html('');
    request = $.getJSON("/players/search", {query: query}, function(data) {
      for (var i = 0; i < data.length; i++) {
        $('#results').append("<p>"+data[i].first_name+" "+data[i].last_name);
      }
      running = false;
    });
  }

  $("#search_box").submit(function(e) {
    e.preventDefault();
    var query = $("#search_box #query").val();
    if (!query) return;
    running = true;
    getResults(query);
  });

  $("#search_box input").keyup(function(e) {
    e.preventDefault();
    var query = $(this).val();
    if (!query) return;
    if (running) {
      request.abort();
    }
    getResults(query);
  });
}