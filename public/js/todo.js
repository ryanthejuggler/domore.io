var addPanel, deleteTodo, submitEntry;

addPanel = function(panel) {
  var $panel, $timeago;
  $panel = $(panel);
  $("#results").prepend($panel);
  $panel.show("slow");
  $timeago = $panel.find(".timeago");
  $timeago.text(new Date($timeago.attr("title")).toLocaleString());
  return $panel.find(".timeago").timeago();
};

submitEntry = function() {
  var handleSubmit;
  handleSubmit = function(geo) {
    var $entry;
    $entry = $("#entry");
    if ($entry.val().length === 0) {
      return;
    }
    $.ajax({
      type: "POST",
      url: "/ajax/todo/new",
      data: {
        entry: $entry.val(),
        location: geo
      },
      success: function(data) {
        if (!data.ok) {
          return;
        }
        return addPanel(data.panel);
      },
      error: console.log.bind(console),
      dataType: "json"
    });
    return $("#entry").val("");
  };
  return navigator.geolocation.getCurrentPosition((function(geo) {
    return handleSubmit({
      pos: {
        lat: geo.coords.latitude,
        lon: geo.coords.longitude,
        sigma: geo.coords.accuracy
      },
      alt: {
        value: geo.coords.altitude,
        sigma: geo.coords.altitudeAccuracy
      }
    });
  }), (function(err) {
    return handleSubmit(null);
  }), {
    enableHighAccuracy: true,
    maximumAge: 30000
  });
};

deleteTodo = function(id) {
  alert("deleting #" + id);
  return $.ajax({
    type: "POST",
    url: "/ajax/todo/delete",
    data: {
      id: id
    },
    success: function(data) {
      return $("#todo-" + id).remove();
    }
  });
};

$.ajax({
  type: "GET",
  url: "/ajax/todo/get",
  success: function(data) {
    var i, _results;
    if (!data.ok) {
      return;
    }
    i = 0;
    _results = [];
    while (i < data.panels.length) {
      addPanel(data.panels[i]);
      _results.push(i++);
    }
    return _results;
  }
});

$("#entry").on("keypress", function(e) {
  if (e.keyCode === 13) {
    submitEntry();
    return false;
  }
  return true;
});

$("#crunch").click(submitEntry);
