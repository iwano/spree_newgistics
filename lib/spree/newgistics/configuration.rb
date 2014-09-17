module Spree
  module Newgistics
    class Configuration < Spree::Preferences::Configuration
      preference :api_key, :string, default: ENV['NEWGISTICS_STAGING_API_KEY']
      preference :url, :string, default: ENV['NEWGISTICS_STAGING_URL']
      preference :staging_api_key, :string, default: ENV['NEWGISTICS_STAGING_API_KEY']
      preference :staging_url, :string, default: ENV['NEWGISTICS_STAGING_URL']
      preference :production_api_key, :string, default: ENV['NEWGISTICS_PRODUCTION_API_KEY']
      preference :production_url, :string, default: ENV['NEWGISTICS_PRODUCTION_URL']
    end
  end
end
