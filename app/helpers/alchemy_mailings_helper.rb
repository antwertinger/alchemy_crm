module AlchemyMailingsHelper
  
  def contact_count_from_tag(tag)
    content_tag('small', "(#{Contact.tagged_with(tag).count})")
  end
  
  # Renders the layout from @page.page_layout. File resists in /app/views/newsletter_layouts/_LAYOUT-NAME.html.erb
  def render_newsletter_layout(options={})
    default_options = {
      :render_format => "html"
    }
    options = default_options.merge(options)
    render :partial => "newsletter_layouts/#{@page.page_layout.downcase.gsub(/newsletter_/, '')}.#{options[:render_format]}.erb"
  end
  
end

# requiring AlchemyHelper and AlchemyMailingsHelper, because we need the methods for rendering the elements from @mailing.page
ActionView::Base.send(:include, AlchemyMailingsHelper)
ActionView::Base.send(:include, ElementsHelper)
