module Spree
  module Api
    class NewgisticsImportsController < Spree::Api::BaseController

      include ActionController::Live

      def products
        if current_spree_user.admin?
          job_id = Workers::ProductsPuller.perform_async
          session[:job_id] = job_id

          log = Spree::Newgistics::Log.find_or_create_by job_id: job_id
          log << "<p class='job-id'> Job: #{job_id} started <p/>"
          render nothing: true
        end
      end

      def log
        response.headers['Content-Type'] = 'text/event-stream'
        response.headers['Cache-Control'] = 'no-cache'
        job_id = session[:job_id]
        log = Spree::Newgistics::Log.find_or_create_by job_id: job_id

        begin
          while Sidekiq::Status.working?(job_id) do
            response.stream.write "data: #{log.reload.details}\n\n"
            sleep 1
          end
          log <<  "<p class='success'> Import finished </p>"
          response.stream.write "event: finished\n"
          response.stream.write "data: #{log.reload.details}\n\n"

        rescue IOError
        ensure
          response.stream.close
        end
      end
    end
  end
end