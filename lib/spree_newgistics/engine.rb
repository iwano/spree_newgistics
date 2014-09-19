module SpreeNewgistics
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_newgistics'

    config.autoload_paths += %W(#{config.root}/lib )

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), '../../app/async/*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.after_initialize do
      ## hacky way to set the transition, if by any reason the project in which this gem is being used removes a checkout step in a decorator or something, the callbacks would be deleted, so this is a 'safe' way to set the callbacks.
      Spree::Order.state_machine.after_transition to: :complete, do: :post_to_newgistics
    end

    config.to_prepare &method(:activate).to_proc
  end
end
