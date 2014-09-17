Spree::Product.class_eval do

  after_create :post_to_newgistics

  def post_to_newgistics
    document = Spree::Newgistics::DocumentBuilder.build_product([self])
    Spree::Newgistics::HTTPManager.post('/post_products.aspx', document)
  end
end
