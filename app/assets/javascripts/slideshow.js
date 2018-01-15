function Slideshow(options){
  this.$imageElement = options.$imageElement;
  this.sliderWidth = this.$imageElement.data("width");
}

Slideshow.prototype.init = function(){
  this.imageSlider();
};

Slideshow.prototype.imageSlider = function(){
  this.$imageElement.bxSlider({
    auto: true,
    sliderWidth: this.sliderWidth
  });
}

$(function(){

  var slideshowArguments = { $imageElement : $("ul[data-slider='images-slider']") },
      slideshow = new Slideshow(slideshowArguments);

  slideshow.init();

});
