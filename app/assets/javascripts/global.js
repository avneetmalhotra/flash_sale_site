$(function(){

  //countdown-timer
  var countdownElements = $("[data-timer='yes']");
  var endTime = $(countdownElements).data('end-at');

  countdownElements.countdown(endTime, function(event){
    $(this).html(
      event.strftime('%H:%M:%S')
    ).addClass('label-warning');
  });

});
