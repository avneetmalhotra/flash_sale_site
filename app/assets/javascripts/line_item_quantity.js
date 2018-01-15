function LineItemQuantity(options) {
  this.$quantitySelectBox = options.$quantitySelectBox;
}

LineItemQuantity.prototype.init = function(){
  this.handleQuantityUpdate();
};

LineItemQuantity.prototype.handleQuantityUpdate = function(){
  _this = this;
  this.$quantitySelectBox.change(_this.updateQuantity);
};

LineItemQuantity.prototype.updateQuantity = function(event){
  _this = this;
  $.ajax({

    url: 'line_items/update',
    data: {
      new_quantity: _this.value,
      line_item_id: $(_this).data('line-item-id')
    },
    type: 'PATCH',
    dataType : 'json',
  })
    .done(function(json){
      if(json.success){
        location.reload();
      }
      else
      {
        location.reload();
      }  
    })

    .fail(function(xhr, status, error){
      console.log(error);
    });

};

$(function(){
  var lineItemQuantityArguments = { $quantitySelectBox : $("select[data-line-item-attr='quantity']") },
      lineItemQuantity = new LineItemQuantity(lineItemQuantityArguments);

  lineItemQuantity.init();
});
