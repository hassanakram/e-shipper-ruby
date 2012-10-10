require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class PackageTest  < Test::Unit::TestCase

  def test_valid_package
    package = EShipper::Package.new({:length=>"15", :width=>"10", :height=>"12", :weight=>"10",
      :insuranceAmount=>"120", :codAmount=>"120"})

    assert package.validate!
    assert_equal "15", package.length
    assert_equal "120", package.insuranceAmount
  end

  def test_invalid_address
    package1 = EShipper::Package.new
    assert_raise(ArgumentError) { package1.validate! }

    package2 = EShipper::Package.new({:invalid => "invalid"})
    assert_raise(ArgumentError) { package2.validate! }
  end
  
  def test_description_render_html_of_the_package_content
    package = EShipper::Package.new({:length => "15", :width => "10", :height => "10", :weight => "5",
      :insuranceAmount => "120", :codAmount => "120"})
    
    html = package.description
    assert html.include?('15')
    assert html.include?('10')
    assert html.include?('120')
  end
end
