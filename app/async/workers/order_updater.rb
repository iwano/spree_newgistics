module Workers
  class OrderUpdater < AsyncBase
    include Sidekiq::Worker
    sidekiq_options :retry => false

    def perform(order_id, method, args)
      order = Spree::Order.find order_id
      if args.present?
        order.send(method, *args)
      else
        order.send(method)
      end
    end
  end
end
