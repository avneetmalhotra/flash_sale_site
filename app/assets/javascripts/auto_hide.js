function AutoHide(options){
  this.$element = options.$autoHideElement;
  this.duration = options.duration;
}

AutoHide.prototype.init = function(){
  this.hideElement()
};

AutoHide.prototype.hideElement = function(){
  _this = this
  setTimeout(function(){
    _this.$element.slideUp(1000);
  }, _this.duration);
};

$(function(){
  var options = { $autoHideElement: $('.auto-hide'),
                  duration: 10000 },
      autoHide = new AutoHide(options);

  autoHide.init();
});
