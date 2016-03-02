# A bunch of insanely useful helpers that tend to be used in every project
module ChorusHelpers
  # Iterates over text and finds video placeholders and yields it to a
  # url generating block. The result is used as the src url for the iframe
  def chorus_video_placeholders(text)
    return text if text.blank?
    text.gsub(/(<!-- CHORUS_VIDEO_EMBED ChorusVideo:([A-Za-z0-9]+) -->)/m) do |match|
      id = match[/ChorusVideo:([A-Za-z0-9]+)/, 1]
      data = chorus.get_video id
      if data && data['provider']
        if data['provider']['embed_code']
          embed data['provider']['embed_code']
        elsif data['provider']['data'] && data['provider']['data']['player_url']
          embed data['provider']['data']['player_url']
        else
          raise 'Unsupported chorus video type'
        end
      end
    end
  end

  # handles `chorus-ad` html elements
  #   <chorus-ad data-ad-slot="athena" />
  # or something
  def chorus_ad(html)
    require 'nokogiri'

    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    doc.css('[data-ad-slot]').each do |tag|
      ad_slot = tag['data-ad-slot']
      ad_html = Nokogiri::HTML::DocumentFragment.parse(ad_placement(ad_slot))
      tag.after(ad_html)
      tag.remove
    end
    doc.serialize
  end

  def chorus_entry_for(resource)
    data = data_for resource
    if data['chorus_entry']
      return data['chorus_entry']
    elsif data['chorus_entry_url']
      load_chorus_entry(data['chorus_entry_url'])
    elsif data['chorus_entry_id']
      load_chorus_entry(data['chorus_entry_id'])
    else
      puts "\nI can't find Chorus entry for page #{resource.url} \n"
      return {}
    end
  end

  def chorus_entry(id_slug_or_url = nil)
    if id_slug_or_url.nil?
      current_chorus_entry
    else
      load_chorus_entry(id_slug_or_url)
    end
  end

  def current_chorus_entry
    chorus_entry_for current_page
  end

  def homepage_chorus_entry
    chorus_entry_for homepage
  end

  def chorus_body_raw
    chorus_entry['body_extended']
  end

  def chorus_body_data
    @chorus_body_data ||= archieml(
      strip_html(chorus_body_raw))
  end

  def homepage_chorus_body_data
    @homepage_chorus_body_data ||= archieml(
      strip_html(homepage_chorus_entry['body_extended']))
  end

  def chorus_body
    @chorus_body ||= chorus_ad(
      chorus_video_placeholders(chorus_body_raw))
  end

  def chorus_image
    chorus_entry['_embedded']['image']
  end

  def chorus_author
    chorus_entry['_embedded']['author']
  end

  private

  def load_chorus_entry(id_slug_or_url)
    @_entry_cache ||= {}

    if id_slug_or_url.to_s.strip.empty?
      return {}
    elsif id_slug_or_url =~ /^http/
      match = /preview\/(?<id>\d+)(\?.*)?$/.match(id_slug_or_url)
      if match.nil?
        puts "\nI don't understand this url: #{id_slug_or_url}\n"
        return {}
      end
      id = match[:id]
    else
      id = id_slug_or_url
    end

    @_entry_cache[id] ||= chorus.get_entry(id)
  end
end
