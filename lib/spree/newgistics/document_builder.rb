module Spree
  module Newgistics
    module DocumentBuilder

      def self.products(products)
        build_objects_xml('product', products.flatten)
      end

      def self.orders(orders)
        build_objects_xml('order', orders.flatten)
      end

      private

      def self.build_objects_xml(type, objects)
        Nokogiri::XML::Builder.new do |xml|
          xml.send(type.pluralize.camelise, { apiKey: api_key}) {
            objects.each do |object|
              xml.send(type.camelcase) {
                required_attributes.send("#{type}_attributes").each do |key, value|
                  get_node_value(key, value, object, xml)
                end
              }
            end
          }
        end.to_xml
      end

      def self.get_node_value(key, value, object, xml)
        key = key.to_s.camelcase
        ## if it's a symbol is because is a method call.
        if value.kind_of?(Symbol)
          data = object.send(value)
          ## if data it's a collection proxy it means we have children nodes (1 to N)
          if data.kind_of?(ActiveRecord::Associations::CollectionProxy)
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
          children.each do |object|
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
        methods.each{ |method| object = object.send(method) }
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
