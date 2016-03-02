require 'cgi'

# Takes an array of hashes to build a sitemap and setup pages
def build_sitemap_with(data)
  pdata = data.map do |row|
    if row['_embedded'] && row['_embedded']['editorial_app_association']
      assoc = row['_embedded']['editorial_app_association']
      page = {
        'title' => row['title'],
        'slug'  => assoc['slug'],
        'class' => assoc['class'],
        'chorus_entry' => row
      }
    else
      page = row.dup
    end

    unless page['chorus_entry'].blank?
      entry = page['chorus_entry']
      page.merge!(
        'seo_description' => page['social_share_description'],
        'twitter_text' => page['twitter_share_text'],
        'sharing_image_url' => page['social_share_image']
      )
    end

    if page['slug'].blank?
      page.merge!(
        'slug' => CGI.unescapeHTML(
          page['title'].sub('&nbsp;', ' ')).parameterize)
    end

    page
  end

  @pages_order = []
  pdata[1..-1].each do |page|
    next if page['class'] =~ /^section_title/ || page['class'] == 'link'

    path = "/#{page['slug']}/index.html"
    proxy(path, index_file, page)

    # We have to maintain our own list of pages becuase sitemap doesn't
    # reliably maintain order
    # Added this so that we don't map all of the proxy pages (generated for share images)
    # to the sitemap
    unless path.match('&=')
      @pages_order << path
    end
  end

  ready do
    metadata = { :options => pdata.first.merge('slug' => 'home') }
    sitemap.find_resource_by_path(index_file)
      .add_metadata(metadata)

    # When file changes are detected, the homepage metadata gets reset. So
    # we have to add our metadata back
    files.changed do
      sitemap.find_resource_by_path(index_file)
        .add_metadata(metadata)
    end
    files.deleted do
      sitemap.find_resource_by_path(index_file)
        .add_metadata(metadata)
    end
  end
end
