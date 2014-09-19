module Workers
  class OrdersPoster < AsyncBase
    include Sidekiq::Worker

    def perform
      Spree::Order.not_in_newgistics.each do |order|
        order.post_to_newgistics
      end

    end
  end
end
