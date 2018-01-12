function Slideshow(options){
  this.imageElementSelector = options.imageElementSelector;
  this.sliderWidth = $(this.imageElementSelector).data("width");
}

Slideshow.prototype.init = function(){
  this.imageSlider();
};

Slideshow.prototype.imageSlider = function(){
  $(this.imageElementSelector).bxSlider({
    auto: true,
    sliderWidth: this.sliderWidth
  });
}

$(function(){

  var slideshowArguments = { imageElementSelector : "ul[data-slider='images-slider']" },
      slideshow = new Slideshow(slideshowArguments);

  slideshow.init();

});
