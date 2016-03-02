require File.join(File.dirname(__FILE__), 'config_helpers.rb')
require 'foundation-sass'
require 'active_support/time'

# Force timezone to ET
Time.zone = 'Eastern Time (US & Canada)'

# Build time date object
set :now, Time.zone.now

# use this url instead of the url of this app
set :override_share_url, false

# default text to use in tweets
set :tweet_text, false

# default text to use in pinterest shares
set :pinterest_text, false

# Display stb in the navbar
set :show_stb, false

# Include comments on pages, if possible
set :show_comments, false

# include trailing slashes, if necessary (for s3)
set :trailing_slashes, false

# disable responsive meta header
set :not_responsive, false

# tell web crawlers to ignore this page
set :no_index, false

set :autotune_facebook_app_id, ''

# configuration for thumb_url helper
set :thumbor_force_no_protocol_in_source_url, true
set :thumbor_security_key, ''
set :thumbor_server_url, ''

# Analytics data layer settings (defaults set below)
set :data_layer, {}

after_configuration do
    set :vertical, 'custom'
    set :site_name, 'today.com'
    set :site_display_name, 'today'
    set :twitter, ''
    set :twitter_user_id, ''
    set :facebook_app_id, ''
    set :chartbeat_domain, ''
    set :gtm_container_id, ''
    set :utm_campaign, ''

  end

  #
  # Check for important settings and raise messages
  #

  unless respond_to? :title
    raise "Please add \"set :title, 'your app title'\" in your config.rb"
  end

  unless respond_to? :meta_description
    raise "Please add \"set :meta_description, 'Teaser for your app'\" in your config.rb"
  end

  unless respond_to? :sharing_image
    raise "Please add \"set :sharing_image, 'http://url/to/image.jpg'\" in your config.rb"
  end

  unless respond_to? :authors
    raise "Please add \"set :authors, 'Bobby Tables'\" in your config.rb"
  end

  #
  # Autopopulate some things
  #

  set :slug, title.parameterize unless respond_to? :slug

  date_format = '%F %H:%M' # 2015-09-21 14:30
  if publish_date.is_a? String
    pubd = Time.zone.parse(publish_date)
  elsif publish_date.is_a? ActiveSupport::TimeWithZone
    pubd = publish_date
  elsif publish_date.is_a?(Date) || publish_date.is_a?(Time)
    pubd = publish_date.in_time_zone
  else
    raise "Please add \"set :publish_date, '2014-04-21 16:00'\" in your config.rb"
  end

  # Updated date should be same as publish date unless the project is built
  # after the publish date.
  updated = now <= pubd ? pubd : now

  # Here we create the defaults which we then override with anything that
  # the developer added to data_layer in their config.rb
  set :data_layer,
      {
        'Network' => vertical,
        'Community' => vertical,
        'Content Type' => 'feature',
        'Day of Week' => pubd.strftime('%A').downcase,
        'Content ID' => slug,
        'Author' => authors,
        'Publish Date' => pubd.strftime(date_format),
        'Hour of Publish' => pubd.hour.to_s,
        'Last Time Updated' => updated.strftime(date_format),
        'Hour of Update' => updated.hour.to_s,
        'Demand Post' => 'no',
        'chartbeat_domain' => chartbeat_domain,
        'chartbeat_authors' => authors
      }.merge(data_layer)
end
