Spree::Order.class_eval do

  after_update :update_newgistics_shipment_address, if: lambda { complete? && ship_address_id_changed?}

  has_many :state_changes, as: :stateful, after_add: :update_newgistics_shipment_status

  scope :not_in_newgistics, -> { where(state: 'complete', posted_to_newgistics: false) }

  # This method is called everytime a state change in the order happens
  def update_newgistics_shipment_status(state_change)
    if should_update_newgistics_state? state_change
      document = Spree::Newgistics::DocumentBuilder.build_shipment_updated_state(state_change)
      Spree::Newgistics::HTTPManager.post('/update_shipment_address.aspx', document)
    end
  end


  # This method is used to update both shipment address and shipment status
  def update_newgistics_shipment_address
    document = Spree::Newgistics::DocumentBuilder.build_shipment_updated_address(self)
    Spree::Newgistics::HTTPManager.post('/update_shipment_address.aspx', document)
  end


  ## This method is called whenever order contents are updated, this is triggered on the after update callback for line items quantity
  def add_newgistics_shipment_content(sku, qty)
    document = Spree::Newgistics::DocumentBuilder.build_shipment_contents(number, sku, qty, add = true)
    Spree::Newgistics::HTTPManager.post('/update_shipment_contents.aspx', document)
  end

  ## This method is called whenever order contents are updated, this is triggered on the after update callback for line items quantity
  def remove_newgistics_shipment_content(sku, qty)
    document = Spree::Newgistics::DocumentBuilder.build_shipment_contents(number, sku, qty, add = false)
    Spree::Newgistics::HTTPManager.post('/update_shipment_contents.aspx', document)
  end


  ## This method posts the order to newgisitcs as soon as the checkout ends, if using auto capture
  ## the shipping status would be blank, if not using autocapture the order status would be ONHOLD,
  ## and will be updated as soon as the order changes to 'PAID', if it success, it updates the
  ## posted_to_newgistics flag in the order for further queue updates control.
  def post_to_newgistics
    if complete? && payment_state == 'paid'
      document = Spree::Newgistics::DocumentBuilder.build_shipment(shipments)
      response = Spree::Newgistics::HTTPManager.post('/post_shipments.aspx', document)

      if response.status == 200
        errors = Nokogiri::XML(response.body).css('errors').children.any?
        if !errors
          update_attributes({posted_to_newgistics: true, newgistics_status: 'RECEIVED'})
        end
      end

    end
  end

  private

  def should_update_newgistics_state? state_change
    (state_change.name == 'payment' || state_change.name == 'order') && posted_to_newgistics?
  end

end
