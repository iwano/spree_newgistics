module Workers
  class InventoryPuller < AsyncBase
    include Sidekiq::Worker

    def perform
    end
  end
end
