require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  def test_paginated_index_loads
    get(:index, :format => 'html')
    assert_response :success
    assert !@response.body.include?("hdn_reports_container")
  end
  
  def test_live_autoupdate_index_loads
    get(:index, :live => "1", :format => 'html')
    assert_response :success
    assert @response.body.include?("hdn_reports_container")
  end
  
  def test_reload_loads
    get(:reload)
    assert_response :success
    exp_size = [50, Report.count].min
    assert_equal exp_size, assigns(:reports).size
  end
  
  def test_reload_reads_count_param
    get(:reload, :per_page => 2)
    assert_response :success
    assert_equal 2, assigns(:reports).size
  end
end
