# Provides the ability to add ads to pages
#
# Place <%= ad_placement 'athena' %> where you would like the ad to be displayed
#
# To get debug information about these ads append ?googfc to the end of
# your URL and the google DFP console will be displayed
#
# 411 documentation here
# https://github.com/voxmedia/411/wiki/DFP-Ads-and-Editorial-Apps

module AdHelpers
  # Will return a unique id for the ad, which can then be shown via JS.
  # <%= ad_placement('leaderboard') %>
  def ad_placement(ad_name)
    "<div class=\"advert\" data-ad-slot=\"#{ad_name}\"></div>"
  end

  def dfp_site_name
    @dfp_site_name ||=
      case vertical.downcase
      when /sbnation/
        'sbn'
      when /verge/
        'verge'
      else
        vertical.downcase
      end
  end
end
