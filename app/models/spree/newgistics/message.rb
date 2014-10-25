module Spree
  module Newgistics
    class Message < ActiveRecord::Base

      self.table_name = 'spree_newgistics_messages'

      belongs_to :log
    end
  end
end