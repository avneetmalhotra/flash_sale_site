class AddDealReferenceToImage < ActiveRecord::Migration[5.1]
  def change
    add_reference :images, :deal, foreign_key: true
  end
end
