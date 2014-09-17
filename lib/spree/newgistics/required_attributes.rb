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
          is_active: :available?
      }

      @@order_attributes = {
          customer_info: {
            company: [:ship_address, :company],
            first_name: [:ship_address, :first_name],
            last_name: [:ship_address, :last_name],
            address1: [:ship_address, :address1],
            address2: [:ship_address, :address2],
            city: [:ship_address, :city],
            state: [:ship_address, :state, :name],
            zip: [:ship_address, :zipcode],
            country: [:ship_address, :country, :iso],
            email: :email,
            phone: [:ship_address, :phone]
          },
          items: :line_items
      }

      @@item_attributes = {
          sku: [:variant, :sku],
          quantity: :quantity
      }
    end
  end
end
