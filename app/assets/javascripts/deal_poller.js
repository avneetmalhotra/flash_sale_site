function DealPoller(options){
  this.$liveDealsTimerElement = $(options.liveDealsTimerElement);
  this.$modalElement = options.$modalElement;
  this.pollingInterval = options.pollingInterval;
  this.pollingLink = this.$liveDealsTimerElement.data("poll-link")
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

    $.getJSON(_this.pollingLink)
    
    .done(function(data){
    })
    
    .fail(function(data){
      var response_status_code = self.jqxhr.status

      if(response_status_code == (422 || 404) ){
        _this.showModal(data.responseJSON.error);
        clearInterval((_this.pollingForExpiration));
      }
    });
};

DealPoller.prototype.showModal = function(modalText){
  this.$modalElement.on('show.bs.modal', function(){
    $(this).find('.modal-body').text(modalText);
  });

  this.$modalElement.modal({ backdrop: 'static' }, 'show');
}

$(function(){

  var dealPollerArguments = { liveDealsTimerElement :  ("[data-timer='yes']"),
                              $modalElement :          $("[data-modal='deal-show']"),
                              pollingInterval:         60000  },
      dealPoller = new DealPoller(dealPollerArguments);

  dealPoller.init();

});
