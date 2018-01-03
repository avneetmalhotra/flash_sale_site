module Presentable

  extend ActiveSupport::Concern

  def presenter
    @presenter ||= "#{self.class}Presenter".constantize.new(self)
  end

end
