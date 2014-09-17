Spree::Product.class_eval do

  after_create :post_to_newgistics

  def post_to_newgistics
    binding.pry
    document = Spree::Newgistics::DocumentBuilder.products([self])
    Spree::Newgistics::HTTPManager.post('/products.aspx', document)
  end
end
