module Spree
  module Newgistics
    module DocumentBuilder

      attr_accessor :case_sensivity

      def self.build_product(products)
        @case_sensivity = :lower
        build_objects_xml('product', products.flatten)
      end

      def self.build_shipment(shipments)
        @case_sensivity = :upper
        build_objects_xml('order', shipments.flatten, { orderID: shipments[0].order.number })
      end


      def self.build_shipment_contents(order_number, sku, qty, add)
        node_name = add ? 'AddItems' : 'RemoveItems'
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send('Shipment', { apiKey: api_key, orderID: order_number}) {
            xml.send(node_name){
              xml.Item{
                xml.SKU sku
                xml.Qty qty
              }
            }
          }
        end.to_xml
      end

      def self.build_shipment_updated_address(order)
        @case_sensivity = :upper
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send('updateShipment', { apiKey: api_key, orderID: order.number}) {
            required_attributes.address_update_attributes.each do |key, value|
              get_node_value(key, value, order, xml)
            end
          }
        end.to_xml
      end

      private

      def self.build_objects_xml(type, objects, node_id = {})
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.send(type.pluralize.camelize(@case_sensivity), { apiKey: api_key}) {
            objects.each do |object|
              xml.send(type.camelize(@case_sensivity), node_id) {
                required_attributes.send("#{type}_attributes").each do |key, value|
                  get_node_value(key, value, object, xml)
                end
              }
            end
          }
        end.to_xml
      end

      def self.get_node_value(key, value, object, xml)
        key = key.to_s.camelize(@case_sensivity)
        ## if it's a symbol is because is a method call.
        if value.kind_of?(Symbol)
          data = object.send(value)
          ## if data it's a collection proxy it means we have children nodes (1 to N)
          if data.respond_to? :each
            self.get_children_nodes(key, data, xml)
          else
            #else just send what the method returns.
            xml.send(key, data)
          end
        #if an array it means we need to chain method calls
        elsif value.kind_of?(Array)
          xml.send(key, chain_methods(object, value))
        #if a string it means it's hardcoded data
        elsif value.kind_of?(String)
          xml.send(key, value)
        #if hash it means its a child node 1 to 1
        elsif value.kind_of?(Hash)
          xml.send(key){
            value.each do |key, value|
              get_node_value(key, value, object, xml)
            end
          }
        end
      end

      # method to go through a set of children and get their data
      def self.get_children_nodes(key, children, xml)
        xml.send(key){
          type = key.singularize
          children.compact.each do |object|
            xml.send(type) {
              required_attributes.send("#{type.downcase}_attributes").each do |key, value|
                get_node_value(key, value, object, xml)
              end
            }
          end
        }
      end

      # this method only chains the array of symbols to return expected data
      def self.chain_methods(object, methods)
        methods.each do |method|
          if method.kind_of?(Hash)
            object = object.send(method.keys[0], method.values[0])
          else
            object = object.send(method)
          end
        end
        object
      end


      def self.required_attributes
        Spree::Newgistics::RequiredAttributes
      end

      def self.api_key
        Spree::Newgistics::Config[:api_key]
      end

    end
  end
end
