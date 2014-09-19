class AsyncBase
  include Sidekiq::Worker

  def perform args = {}
    Rails.logger.info("starting job #{self.class.name}, args [#{args}]")
    args = HashWithIndifferentAccess.new args
    self.perform args
    Rails.logger.info("finished job #{self.class.name}, args [#{args}]")
  rescue Exception => e
    Rails.logger.error("error executing job #{self.class.name} args [#{args}]: #{e}")
    raise e
  end
end
