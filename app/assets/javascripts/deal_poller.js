function DealPoller(options){
  this.$liveDealsTimerElement = options.$liveDealsTimerElement;
  this.$modalElement = options.$modalElement;
  this.pollingInterval = options.pollingInterval;
}

DealPoller.prototype.init = function(){
  this.setPolling();
};

DealPoller.prototype.setPolling = function(){
  var _this = this;
  if(this.$liveDealsTimerElement.length > 0)
    setInterval(_this.pollingForExpiration, this.pollingInterval, _this);
};

DealPoller.prototype.pollingForExpiration = function(_this){

  $.getJSON(window.location.href)
    
    .done(function(data){
      var currentTime = new Date();
      var dealEndTime = new Date(data.endTime);    


      if(dealEndTime <= currentTime ){
        _this.showModal('The Deal has expired. Please reload the page to continue shopping.');
        clearInterval(_this.pollingForExpiration);  
      }
    })
    
    .fail(function(data){
      _this.showModal('Something went wrong. Please reload the page.');
    });
};

DealPoller.prototype.showModal = function(modalText){
  this.$modalElement.on('show.bs.modal', function(){
    $(this).find('.modal-body').text(modalText);
  });

  this.$modalElement.modal({ backdrop: 'static' }, 'show');
}

$(function(){

  var dealPollerArguments = { $liveDealsTimerElement : $("[data-timer='yes']"),
                              $modalElement :          $("[data-modal='deal-show']"),
                              pollingInterval:         60000  },
      dealPoller = new DealPoller(dealPollerArguments);

  dealPoller.init();

});
