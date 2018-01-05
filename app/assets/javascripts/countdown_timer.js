function CountdownTimer(options){
  counterElementSelector = options.counterElementSelector;
  $counterElements = $(counterElementSelector);
}

CountdownTimer.prototype.init = function(){
  this.generateTimersForAllElements();
};

CountdownTimer.prototype.generateTimersForAllElements = function(){
  var _this = this;
  $counterElements.each(_this.generateTimer());
};

CountdownTimer.prototype.generateTimer = function(){
  var _this = this;

  return function(){

    var counterElement = this;
    var endDate = $(counterElement).data('end-at');

    var x = setInterval(function(){

      var countdownInterval = _this.getCountdownInterval(endDate);

      // Time calculations for hours, minutes and seconds
      var hours = Math.floor((countdownInterval % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      var minutes = Math.floor((countdownInterval % (1000 * 60 * 60)) / (1000 * 60));
      var seconds = Math.floor((countdownInterval % (1000 * 60)) / 1000);

      // Output the result in the counterElement
      $(counterElement).html("Ends in: " +  hours + "hours "+ minutes + "min " + seconds + "sec ").addClass('label-warning');
    
      if (countdownInterval <= 0) {
        clearInterval(x);
        $(counterElement).html("End in: 0hours 0minutes 0seconds");
      }

    }, 1000);
  };
};


CountdownTimer.prototype.getCountdownInterval = function(date){
  var endDate = new Date(date)
  var now = new Date();
  return (endDate - now);
};


$(function(){
  var dealCountdownTimerArguments = { counterElementSelector : "[data-timer='yes']" },
      dealCountdownTimer = new CountdownTimer(dealCountdownTimerArguments);

  dealCountdownTimer.init();
});
