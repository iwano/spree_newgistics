Spree::Order.class_eval do

  after_update :update_newgistics_shipment_address, if: lambda { complete? && ship_address_id_changed?}

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
    document = Spree::Newgistics::DocumentBuilder.build_shipment(shipments)
    Spree::Newgistics::HTTPManager.post('/post_shipments.aspx', document)
  end

end
