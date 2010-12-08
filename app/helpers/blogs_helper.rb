module BlogsHelper

# Added by Akiko for Customize
  def calendar_for_blog(field_id, format)
    include_calendar_headers_tags
    image_tag("calendar.png", {:id => "#{field_id}_trigger",:class => "calendar-trigger"}) +
    #javascript_tag("Calendar.setup({inputField : '#{field_id}', ifFormat : '%Y%m%d', button : '#{field_id}_trigger' });")
    javascript_tag("Calendar.setup({inputField : '#{field_id}', ifFormat : '#{format}', button : '#{field_id}_trigger' });")
  end

  def include_calendar_headers_tags
    unless @calendar_headers_tags_included
      @calendar_headers_tags_included = true
      content_for :header_tags do
        javascript_include_tag('calendar/calendar') +
        javascript_include_tag("calendar/lang/calendar-#{current_language}.js") +
        javascript_include_tag('calendar/calendar-setup') +
        stylesheet_link_tag('calendar')
      end
    end
  end

end
