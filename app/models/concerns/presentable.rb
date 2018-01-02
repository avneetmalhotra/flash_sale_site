module Presentable

  extend ActiveSupport::Concern

  def present
    presenter ||= "#{self.class}Presenter".constantize.new(self)
  end

end
