//auto-hide tags
$(function(){

  // auto-hide elements
  $('.auto-hide').delay(10000).slideUp();

  //image-slider
  function ImageSlider(selector, width){
    $(selector).bxSlider({
      auto: true,
      sliderWidth: width
    });
  }

  ImageSlider("ul[data-slider='deal-preview-image']", 240);
  ImageSlider("ul[data-slider='deal-show-images']", 600);
  ImageSlider("ul[data-slider='deal-admin-show-images']", 340)

});
