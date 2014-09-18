Spree::Order.class_eval do

  after_touch :post_to_newgistics, if: :completed_at?


  def add_newgistics_shipment_content(sku, qty)
    document = Spree::Newgistics::DocumentBuilder.build_order_contents(number, sku, qty, add = true)
    Spree::Newgistics::HTTPManager.post('/update_shipment_contents.aspx', document)
  end

  def remove_newgistics_shipment_content(sku, qty)
    document = Spree::Newgistics::DocumentBuilder.build_order_contents(number, sku, qty, add = false)
    Spree::Newgistics::HTTPManager.post('/update_shipment_contents.aspx', document)
  end

  def remove_newgistics_shipment_content(sku, qty)
    document = Spree::Newgistics::DocumentBuilder.build_order_contents(number, sku, qty, add = false)
    Spree::Newgistics::HTTPManager.post('/update_shipment_contents.aspx', document)
  end

  def post_to_newgistics
    document = Spree::Newgistics::DocumentBuilder.build_order(shipments)
    Spree::Newgistics::HTTPManager.post('/post_shipments.aspx', document)
  end

end
