module Workers
  class ProductsPuller < AsyncBase
    include Sidekiq::Worker

    def perform

      response = Spree::Newgistics::HTTPManager.get('products.aspx')
      if response.status == 200
        xml = Nokogiri::XML(response.body).to_xml
        products = Hash.from_xml(xml)["products"]
        if products
          save_products(products.values.flatten)
        end
      end
    end

    def save_products(products)
      log = File.open("#{Rails.root}/log/missing_newgistics_products.log", 'w')
      disable_callbacks
      products.each do |product|

        next if product['isActive'] == 'false'

        begin
          spree_variant = Spree::Variant.find_by(sku: product['sku'])

          if spree_variant

            spree_variant.update_attributes!({ upc: product['upc'],
                                               cost_price: product['value'].to_f,
                                               price: product['retailValue'].to_f,
                                               height: product['height'].to_f,
                                               width: product['width'].to_f,
                                               weight: product['weight'].to_f,
                                               depth: product['depth'].to_f,
                                               vendor_sku: product['supplierCode'],
                                               vendor: product['supplier'],
                                               newgistics_active: product['isActive'] == 'true' ? true : false })
          else

            color_code = product['sku'].match(/-([^-]*)$/).try(:[],1).to_s

            ## if sku has color code it means we need to build and group variants together
            if color_code.present?

              ## build a master variant sku which would be the same color code with 0000
              product_code = product['sku'].match(/^(.*)-/)[1].to_s
              master_variant_sku = "#{product_code}-00"
              master_variant = Spree::Variant.find_by(sku: master_variant_sku)

              ## if we already have a master variant it means a product has been created
              ## let's just add a new variant to the product.
              ## else create a new product, let spree callbacks create the master variant
              ## and change the sku to the one we want.
              if master_variant
                variant = master_variant.product.variants.new(get_attributes_from(product))
                variant.assign_attributes(variant_attributes_from(product))
                variant.save!
              else
                spree_product = Spree::Product.new(get_attributes_from(product))
                spree_product.taxons << supplier_from(product) if product['supplier'].present?
                spree_product.master.assign_attributes(variant_attributes_from(product).merge({ sku: master_variant_sku }))

                spree_variant = Spree::Variant.new(get_attributes_from(product))
                spree_variant.assign_attributes(variant_attributes_from(product))
                spree_variant.save!

                spree_product.variants << spree_variant
                spree_product.save!
              end

            else
              spree_product = Spree::Product.new(get_attributes_from(product))
              spree_product.taxons << supplier_from(product) if product['supplier'].present?
              spree_product.save!
              master = spree_product.master
              master.update_attributes!(variant_attributes_from(product))
            end
          end
        rescue StandardError => e
          log.write("#{product['sku']} = #{e.message}\n")
        end

      end
      enable_callbacks
      log.close
    end

    def supplier_from(product)
      find_supplier(product['supplier']) || create_supplier(product["supplier"])
    end

    def find_supplier(name)
      @taxonomy ||= Spree::Taxonomy.find_by(name: 'Brands')
      @brands ||= @taxonomy.root.children
      @brands.reload.where("LOWER(spree_taxons.name) = LOWER('#{name.downcase}')").first
    end

    def create_supplier(name)
      @taxonomy ||= Spree::Taxonomy.find_by(name: 'Brands')
      @brands ||= @taxonomy.root.children
      @brands.reload.create!(name: name.downcase.camelcase, permalink: "brands/#{name.downcase.split(' ').join('-')}", taxonomy_id: @taxonomy.id)
    end

    def disable_callbacks
      Spree::Variant.skip_callback(:create, :after, :post_to_newgistics)
      Spree::Variant.skip_callback(:update, :after, :post_to_newgistics)
      Spree::Variant.skip_callback(:save, :after, :enqueue_product_for_reindex)
      Spree::Product.skip_callback(:save, :after, :enqueue_for_reindex)
    end

    def enable_callbacks
      Spree::Variant.set_callback(:create, :after, :post_to_newgistics)
      Spree::Variant.set_callback(:update, :after, :post_to_newgistics)
      Spree::Variant.set_callback(:save, :after, :enqueue_product_for_reindex)
      Spree::Product.set_callback(:save, :after, :enqueue_for_reindex)
    end

    def variant_attributes_from(product)
      item_category_id = product["category"].present? ? Spree::ItemCategory.find_or_create_by!(name: product["category"].downcase.camelcase).id : nil

      {
          posted_to_newgistics: true,
          item_category_id: item_category_id,
          upc: product['upc'],
          vendor_sku: product['supplierCode'],
          vendor: product['supplier'],
          newgistics_active: product['isActive'] == 'true' ? true : false
      }
    end

    def get_attributes_from(product)
      {
          sku: product['sku'],
          name: product['description'],
          description: product['description'],
          slug: product['description'].present? ? product['description'].downcase.split(' ').join('-') : '',
          upc: product['upc'],
          cost_price: product['value'].to_f,
          price: product['retailValue'].to_f,
          height: product['height'].to_f,
          width: product['width'].to_f,
          weight: product['weight'].to_f,
          depth: product['depth'].to_f,
          available_on: product['isActive'] == 'true' ? Time.now : nil,
          shipping_category_id: 1
      }
    end
  end
end
