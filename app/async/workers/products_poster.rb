module Workers
  class ProductsPoster < AsyncBase
    include Sidekiq::Worker

    def perform
      Spree::Variant.not_in_newgistics.each{ |variant| variant.post_to_newgistics }
    end
  end
end
