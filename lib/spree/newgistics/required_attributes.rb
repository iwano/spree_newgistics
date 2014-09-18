module Spree
  module Newgistics
    module RequiredAttributes
      ATTRIBUTES = [
        :product_attributes,
        :order_attributes,
        :manifest_attributes,
        :inventory_attributes,
        :return_attributes,
        :item_attributes
      ]

      mattr_reader *ATTRIBUTES

      @@product_attributes = {
          sku: :sku,
          description: :description,
          width: :width,
          height: :height,
          weight: :weight,
          retail_value: [:price, :to_s],
          ship_from: 'Newgistics',
          country_of_origin: 'US',
          is_active: [:product, :available?]
      }

      @@order_attributes = {
          customer_info: {
            company: [:address, :company],
            first_name: [:address, :first_name],
            last_name: [:address, :last_name],
            address1: [:address, :address1],
            address2: [:address, :address2],
            city: [:address, :city],
            state: [:address, :state, :name],
            zip: [:address, :zipcode],
            country: [:address, :country, :iso],
            email: [:order, :email],
            phone: [:address, :phone]
          },
          order_date: [:order, :completed_at, { strftime: '%m/%d/%Y' }],
          ship_method: 'UPSG',
          items: :line_items
      }

      @@item_attributes = {
          SKU: [:variant, :sku],
          qty: :quantity
      }
    end
  end
end
