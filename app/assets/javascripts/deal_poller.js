function DealPoller(options){
  this.$liveDealsTimerElement = $(options.liveDealsTimerElement);
  this.$modalElement = options.$modalElement;
  this.pollingInterval = this.$liveDealsTimerElement.data('poll-interval');
  this.pollingLink = this.$liveDealsTimerElement.data("poll-link");
}

DealPoller.prototype.init = function(){
  this.setPolling();
};

DealPoller.prototype.setPolling = function(){
  if(this.$liveDealsTimerElement.length)
    this.poller = setInterval(this.pollingForExpiration, this.pollingInterval, this);
};

DealPoller.prototype.pollingForExpiration = function(_this){

  $.getJSON(_this.pollingLink)
    
    .done(function(data){
    })
    
    .fail(function(data){
      if(data !== undefined && data.hasOwnProperty('error')){
        clearInterval(_this.poller);
        _this.showModal(data.responseJSON.error);
      }
    });
};

DealPoller.prototype.showModal = function(modalText){
  this.$modalElement.find('.modal-body').text(modalText);
  this.$modalElement.modal({ backdrop: 'static' }, 'show');
}

$(function(){

  var dealPollerArguments = { liveDealsTimerElement :  ("[data-timer='yes']"),
                              $modalElement :          $("[data-modal='deal-show']")
                            },
      dealPoller = new DealPoller(dealPollerArguments);

  dealPoller.init();
});
