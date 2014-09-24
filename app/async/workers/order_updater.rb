module Workers
  class OrderUpdater < AsyncBase
    include Sidekiq::Worker

    def perform(order_id, method, params = nil)
      order = Spree::Order.find order_id
      order.send(method, params)
    end
  end
end
