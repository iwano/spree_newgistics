module Workers
  class OrdersPuller < AsyncBase
    include Sidekiq::Worker
    include ActiveSupport::Callbacks

    def perform
      params = {
          startReceivedTimeStamp: 1.day.ago.strftime('%Y-%m-%d'),
          EndReceivedTimeStamp: Date.tomorrow.strftime('%Y-%m-%d')
      }

      response = Spree::Newgistics::HTTPManager.get('shipments.aspx', params)
      if response.status == 200
        xml = Nokogiri::XML(response.body).to_xml
        shipments = Hash.from_xml(xml)["Shipments"]
        if shipments
          update_shipments(shipments.values.flatten)
        end
      end
    end

    def update_shipments shipments
      shipments.each do |shipment|
        order = Spree::Order.find_by(number: shipment['OrderID'])
        if order
          Spree::Order.skip_callback(:update, :after, :update_newgistics_shipment_address)
          state_id = Spree::State.find_by(abbr: shipment['State']).try(:id)
          country_id = Spree::Country.find_by(iso_name: shipment['Country']).try(:id)
          attributes = {
              newgistics_status: shipment['ShipmentStatus'],
              ship_address_attributes: {
                firstname: shipment['FirstName'],
                lastname: shipment['LastName'],
                company: shipment['Company'],
                address1: shipment['Address1'],
                address2: shipment['Address2'],
                city: shipment['City'],
                zipcode: shipment['PostalCode'],
                phone: shipment['Phone']
              }
          }

          attributes[:ship_address_attributes].merge!({state_id: state_id}) if state_id
          attributes[:ship_address_attributes].merge!({country_id: country_id}) if country_id
          order.assign_attributes(attributes)
          order.cancel! if order.newgistics_status == 'CANCELED' && !order.canceled?
          order.shipments.each{ |shipment| shipment.ship! } if order.newgistics_status == 'SHIPPED' && !order.shipped?
          if order.changed?
            order.save!
            Spree::Order.set_callback(:update, :after, :update_newgistics_shipment_address)
          end

        end
      end
    end

  end
end
