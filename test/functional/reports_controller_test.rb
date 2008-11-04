require File.dirname(__FILE__) + '/../test_helper'

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
  
  def test_create_iphone_report
    post(:create, "reporter"=>{"profile_location"=>"Secaucus, NJ, United States", "name"=>"Oscarlpelaez@gmail.com", "latlon"=>"40.803,-74.057:1368", "uniqueid"=>"79103044a2ecc86761b01bd7f94686d6427d510c"},
                "format"=>"iphone", "polling_place"=>{"name"=>"Secaucus"},
                "report"=>{"rating"=>"100", "tag_string"=>"", "wait_time"=>"Less Than 5 Minutes", "text"=>""})
    assert_response :success
    assert_equal "OK", @response.body
  end
end
