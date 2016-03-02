# A bunch of helpers for working with the middleman sitemap
module PageHelpers
  # Get the root page resource for this site
  def homepage
    @homepage ||= sitemap.find_resource_by_path index_file
  end

  # Get a list of resources for all the pages in this site (only one level deep)
  def pages
    @pages ||=
      [homepage] + @pages_order.map do |path|
        sitemap.find_resource_by_path(path)
      end
  end

  # Get the resource for the next page
  def next_page
    return @next_page unless @next_page.nil?

    if current_page == pages.last
      nil
    elsif pages.include? current_page
      index = pages.index current_page
      @next_page = pages[index + 1]
    else
      raise "The current page isn't under the homepage"
    end
  end

  def next_page?
    !@next_page.nil?
  end

  # Get the resource for the previous page
  def prev_page
    return @prev_page unless @prev_page.nil?

    if current_page == pages.first
      nil
    elsif pages.include? current_page
      index = pages.index current_page
      @prev_page = pages[index - 1]
    else
      raise "The current page isn't under the homepage"
    end
  end

  def prev_page?
    !@prev_page.nil?
  end

  # Get the page number
  #  @param Resource
  def page_number_for(page)
    pages.index(page) + 1
  end

  # Extract our optional from the page resource provided
  #  @param Resource
  def data_for(resource)
    resource.metadata[:options] unless resource.nil?
  end

  # Get our optional data for the current page
  def current_page_data
    data_for current_page
  end

  # Get our optional data for the home page
  def homepage_data
    data_for homepage
  end

  # Get a list of our optional data for all the pages
  def pages_data
    pages.map do |page|
      data_for page
    end
  end

  # Get our optional data for the next page
  def next_page_data
    data_for next_page
  end

  # Get our optional data for the next page
  def prev_page_data
    data_for prev_page
  end
end
