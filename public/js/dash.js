
function addPanel(panel){
  var $panel = $(panel);
  $('#results').prepend($panel);
  $panel.show('slow');
  var $timeago = $panel.find('.timeago');
  $timeago.text( new Date($timeago.attr('title')).toLocaleString());
  $panel.find('.timeago').timeago();
}
function submitEntry(){
  var handleSubmit = function(geo){
    var $entry = $('#entry');
    if($entry.val().length === 0) return;
    $.ajax({
      type: 'POST',
      url: '/ajax/snippets/new',
      data: {entry:$entry.val(),location:geo},
      success: function(data) {
        if(!data.ok) return;
        addPanel(data.panel);
      },
      error: console.log.bind(console),
      dataType: 'json'
    });
    $('#entry').val('');
  }
  navigator.geolocation.getCurrentPosition(function(geo){
        handleSubmit({
          pos: {
            lat: geo.coords.latitude,
            lon: geo.coords.longitude,
            sigma: geo.coords.accuracy
          },
          alt: {
            value:geo.coords.altitude,
            sigma:geo.coords.altitudeAccuracy
          }
        });
      }, function(err){ handleSubmit(null); },
      {enableHighAccuracy: true, maximumAge: 30000});
}
function deleteSnippet(id){
  $.ajax({
    type: 'POST',
    url: '/ajax/snippets/delete',
    data: {id:id},
    success: function(data) {
      $('#snippet-'+id).remove();
    }
  });
}
$.ajax({
  type: 'GET',
  url: '/ajax/snippets/get',
  success: function(data) {
    if(!data.ok) return;
    for(var i=0;i<data.panels.length;i++){
      addPanel(data.panels[i]);
    }
  }
});
$('#entry').on('keypress', function(e){
  if(e.keyCode === 13){
    submitEntry();
    return false;
  }
  return true;
});
$('#crunch').click(submitEntry);