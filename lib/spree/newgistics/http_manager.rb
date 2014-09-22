module Spree
  module Newgistics
    module HTTPManager

      @conn ||= Faraday.new(:url => Spree::Newgistics::Config[:url]) do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      def self.post(url, body)
        @conn.post do |req|
          req.url url
          req.body = body
        end
      end

      def self.get(url, params = {})
        @conn.get do |req|
          req.url url
          req.params['key'] = Spree::Newgistics::Config[:api_key]
          params.each do |k,v|
            req.params[k.to_s] = v
          end
        end
      end
    end
  end
end
