###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :authors, 'Josh Laincz'
set :publish_date, '2014-04-21 16:00'

set :app_name, data.autotune.title

set :title, data.autotune.title
set :slug, data.autotune.slug
set :meta_description, 'Autotune Timeline Example'

set :vertical, data.autotune.theme

set :trailing_slashes, 'false'

set :sharing_image, ''

set :dfp_site_name, data.autotune.theme

set :layout, 'layout'
set :theme, 'dark'

activate :directory_indexes

if vertical === 'custom'
  set :site_name, 'VoxMedia.com'
  set :twitter, 'voxmediainc'
  set :twitter_user_id, ''
  set :facebook_app_id, ''
  set :chartbeat_domain, 'voxmedia.com'
  set :quantcast_id, ''
  set :comscore_id, ''
  set :umbel_id, ''
  set :gtm_container_id, ''
  set :utm_campaign, 'voxmedia'
end

def thumb_url(image_url, options = {})
  return image_url if image_url.nil? || image_url.empty?

  require 'ruby-thumbor'
  url = image_url.strip
  if thumbor_force_no_protocol_in_source_url == true
    url.sub!(%r{^http(s|)://}, '')
  end

  if @thumbor_service.nil?
    if options[:unsafe]
      @thumbor_service = Thumbor::CryptoURL.new(nil)
    else
      @thumbor_service = Thumbor::CryptoURL.new(thumbor_security_key)
    end
  end

  options[:image] = URI.escape(url)
  host = thumbor_server_url
  path = @thumbor_service.generate(options)
  host = (host % (Zlib.crc32(path) % 4)) if host =~ /%d/
  host + path
end

data.autotune.moments.each_with_index do |i, index|
  if i.image
    data.autotune.moments[index]['image'] = thumb_url(i.image, width: 400)
  end
end

# Load a single spreadsheet
#activate :google_drive, load_sheets: data.autotune.google_doc_id #'0Ap7i7YcIeVqjdFlIWDMtOS11Zi1ocmNyZFczMTRYbVE'

#set :share_url, data.autotune['share_url']
#set :meta_description, data.autotune['share_url']

#set :tweet_text, data.autotune.tweet_text

#set :data_source, data.autotune.data_source

#set :sorted_data, data.timeline_data.sort_by { |k| k["date"] }

# h = Hash.new{|h,k| h[k] = []}
# data.table_data.each do |entry|
#   entry.each do |key, value|
#     h[key] << value
#   end
# end
# set :get_str, h

# Load multiple google spreadsheets
# activate :google_drive, load_sheets: {
#     spreadsheet: 'my_key'
# }

# Activate the chorus exension to use the `chorus` object
# activate :chorus, domain: 'www.vox.com'
# Load content from chorus with an entry slug or id
# activate :chorus, load_entries: {
#     story: 'my-story-slug'
# }

# Build-specific configuration
configure :build do
  require 'uri'
  uri = URI(data.autotune.base_url)
  set :absolute_prefix, uri.scheme.nil? ? "//#{uri.host}" : "#{uri.scheme}://#{uri.host}"

  set :url_prefix, uri.path
  set :http_prefix, data.autotune.base_url

  activate :asset_hash
  activate :minify_javascript
  activate :minify_css
end
