$(document).ready (function() {
  player_hit();
  player_stay();
  dealer_hit();
});

function player_hit() {
  $(document).on("click", "form#hit input", function() {
    $.ajax({
      type: 'POST',
      url: '/player/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $(document).on("click", "form#stay input", function() {
    $.ajax({
      type: 'POST',
      url: '/player/stay'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function dealer_hit() {
  $(document).on("click", "form#dealer_hit input", function() {
    $.ajax({
      type: 'POST',
      url: '/dealer/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}