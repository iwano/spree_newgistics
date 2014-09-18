Spree::Order.class_eval do

  def update_newgistics_shipment_address
    document = Spree::Newgistics::DocumentBuilder.build_shipment_address(number, sku, qty, add = true)
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
