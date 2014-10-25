module Spree
  module Newgistics
    class Log < ActiveRecord::Base

      self.table_name = 'spree_newgistics_logs'

      has_many :messages, dependent: :destroy


      def write details
        messages << Spree::Newgistics::Message.create(details: details)
      end

      def details
        messages.pluck(:details).join('')
      end

      alias_method :<< , :write

    end
  end
end