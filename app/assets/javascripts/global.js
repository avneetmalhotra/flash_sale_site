$(function(){

  //countdown-timer
  (function(){
    this.elements = $("[data-timer='yes']");
    
    this.elements.each(function(){
      var _this = this;

      $(this).countdown($(_this).data('end-at'), function(event){
        $(this).html(
          event.strftime('%H:%M:%S')
        ).addClass('label-warning');
      });
    
    });
  })();

});
