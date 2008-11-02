# created by wgray@zetetic.net
module AutoCompleteMacrosHelper
  # adds a quick n' dirty object_id param for using this multi-edit scenarios
  # like a list of reports being edited, unique dom id needed
  def text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {}, object_id = nil)
    if object_id.nil?
      field_id = "#{object}_#{method}"
    else
      field_id = "#{object}_#{object_id}_#{method}"
      tag_options[:id] = field_id
    end
      
    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
    text_field(object, method, tag_options) +
    content_tag("div", "", :id => "#{field_id}_auto_complete", :class => "auto_complete") +
    auto_complete_field(field_id, { :url => { :action => "auto_complete_for_#{object}_#{method}" } }.update(completion_options))
  end
end