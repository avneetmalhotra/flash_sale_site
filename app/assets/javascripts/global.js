$(function(){
  
  //bx slider
  $("ul[data-slider='deal-preview-image'").bxSlider({
    auto: true,
    slideWidth: 240
  });

  $("ul[data-slider='deal-show-images']").bxSlider({
    auto: true,
    sliderWidth: 600
  });

  //freeze deal details on show
  $(window).scroll(function(){
    var scroll = $(window).scrollTop();
    // var dealDetailsPosition = $('.deal-details').position();
    // dealDetailsPosition.top = 182px;
    if(182 <= scroll){
      $("[data-type='deal-details']").addClass('freeze');
    }
    else{
      $("[data-type='deal-details']").removeClass('freeze');
    }
  });

});
