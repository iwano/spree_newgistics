module Workers
  class OrdersPuller < AsyncBase
    include Sidekiq::Worker


    def perform

    end
  end
end
