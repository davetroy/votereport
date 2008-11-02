require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  def test_paginated_index_loads
    get(:index, :format => 'html')
    assert_response :success
    assert !@response.body.include?("function reloadReportData(")
  end
  
  def test_zzz_autoupdate_index_loads
    get(:index, :live => "1", :format => 'html')
    assert_response :success
    assert @response.body.include?("function reloadReportData(")
  end
  
  def test_reload_loads
    xhr(:get, :reload)
    assert_response :success
  end
end
