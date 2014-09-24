module Spree
  module Newgistics
    class Configuration < Spree::Preferences::Configuration
      preference :api_key, :string, default: ENV['NEWGISTICS_API_KEY']
      preference :url, :string, default: ENV['NEWGISTICS_URL']
    end
  end
end
