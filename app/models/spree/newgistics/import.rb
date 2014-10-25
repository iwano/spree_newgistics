module Spree
  module Newgistics
    class Import < ActiveRecord::Base

      self.table_name = 'spree_newgistics_imports'

      has_attached_file :log,
                        url: '/spree/logs/:id/:basename.:extension',
                        path: ':rails_root/public/spree/logs/:id/:basename.:extension'

      def as_json(options={})
        {
            id: id,
            job_id: job_id,
            status: status,
            log_url: log.url,
            progress: progress
        }
      end

    end
  end
end