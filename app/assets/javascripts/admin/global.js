$(function(){
  
  //bx slider
  $('.bxslider').bxSlider({
    mode: 'fade',
    // speed: 2000,
    slideWidth: 300,
    auto: true
  });

  //jquery ui datepicker
  $("#datepicker").datepicker({ dateFormat: "yy-mm-dd" });
});
