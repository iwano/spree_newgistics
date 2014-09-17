Spree::LineItem.class_eval do

  after_create :add_to_newgistics_shipment_contents, if: lambda {|line_item| line_item.order.complete? }
  after_destroy :remove_from_newgistics_shipment_contents, if: lambda {|line_item| line_item.order.complete? }
  after_update :update_newgistics_shipment_contents, if: lambda { |line_item| line_item.quantity_changed? && line_item.order.complete? }

  private

    def add_to_newgistics_shipment_contents(qty = self.quantity)
      order.add_newgistics_shipment_content(sku, qty)
    end

    def remove_from_newgistics_shipment_contents(qty = self.quantity)
      order.remove_newgistics_shipment_content(sku, qty)
    end

    def update_newgistics_shipment_contents
      old_value = changes[:quantity][0]
      new_value = changes[:quantity][1]
      if old_value > new_value
        remove_from_newgistics_shipment(old_value - new_value)
      else
        add_to_newgistics_shipment(new_value - old_value)
      end
    end
end
