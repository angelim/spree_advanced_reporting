class Spree::AdvancedReport::TopReport::TopProducts < Spree::AdvancedReport::TopReport
  
  def name
    I18n.t("adv_report.top_products.name")
  end

  def description
    I18n.t("adv_report.top_products.description")
  end

  def initialize(params, limit)
    super(params)

    orders.each do |order|
      order.line_items.each do |li|
        if !li.product.nil?
          data[li.product.id] ||= {
            :name => li.product.name.to_s,
            :revenue => 0,
            :units => 0
          }
          data[li.product.id][:revenue] += li.quantity*li.price 
          data[li.product.id][:units] += li.quantity
        end
      end
    end

    self.ruportdata = Table(%w[name Units Revenue])
    data.inject({}) { |h, (k, v) | h[k] = v[:revenue]; h }.sort { |a, b| a[1] <=> b [1] }.reverse[0..limit].each do |k, v|
      ruportdata << { "name" => data[k][:name], "Units" => data[k][:units], "Revenue" => data[k][:revenue] } 
    end
    ruportdata.replace_column("Revenue") { |r| "$%0.2f" % r.Revenue }
    ruportdata.rename_column("name", "Product Name")
  end
end
