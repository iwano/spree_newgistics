Spree::Order.class_eval do

  after_update :update_newgistics_shipment_address, if: lambda { complete? && ship_address_id_changed?}

  scope :not_in_newgistics, -> { where(posted_to_newgistics: false) }

  def update_newgistics_shipment_address
    document = Spree::Newgistics::DocumentBuilder.build_shipment_updated_address(self)
    Spree::Newgistics::HTTPManager.post('/update_shipment_address.aspx', document)
  end

  def add_newgistics_shipment_content(sku, qty)
    document = Spree::Newgistics::DocumentBuilder.build_shipment_contents(number, sku, qty, add = true)
    Spree::Newgistics::HTTPManager.post('/update_shipment_contents.aspx', document)
  end

  def remove_newgistics_shipment_content(sku, qty)
    document = Spree::Newgistics::DocumentBuilder.build_shipment_contents(number, sku, qty, add = false)
    Spree::Newgistics::HTTPManager.post('/update_shipment_contents.aspx', document)
  end

  def post_to_newgistics
    if complete? && payment_state == 'paid'
      document = Spree::Newgistics::DocumentBuilder.build_shipment(shipments)
      response = Spree::Newgistics::HTTPManager.post('/post_shipments.aspx', document)

      if response.status == 200
        errors = Nokogiri::XML(response.body).css('errors').children.any?
        update_attribute(:posted_to_newgistics, true) unless errors
      end

    end
  end

end
