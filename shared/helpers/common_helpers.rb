require 'uri'

# A bunch of insanely useful helpers that tend to be used in every project
module CommonHelpers
  # Formats the page <title>
  def page_title(this_title = nil)
    if this_title.nil?
      if homepage == current_page
        title
      else
        "#{current_page_data['title']} | #{title}"
      end
    else
      if homepage == current_page
        this_title
      else
        "#{this_title} | #{title}"
      end
    end
  end

  # Gets the correct relative url for a given slug
  def page_url(slug = nil)
    # we want a slug, not a url
    fail 'NO! BAD! page_url takes a slug, not a url' if slug =~ %r{https?://}

    # so we're going to build and array of url path parts and
    # recombine them at the end. This way we avoid double slashes
    # in strange places
    uri = URI(http_prefix)

    # split up our url prefix into parts
    url = uri.path.strip.split('/')

    hash = nil
    unless slug.nil? || slug.strip.empty?
      # split off any anchor hash parts from our slug
      slug, hash = slug.strip.split('#')

      # if we got a real slug that is not 'home' or 'index', add it
      # to our array
      url += slug.strip.split('/') unless slug == 'home' || slug == 'index'
    end

    # remove any blank or empty parts from our array of url bits
    url.reject! { |i| i.strip.empty? }

    # If we have things in our url array, join them all together with
    # slashes, and make sure there are leading and trailing slashes
    if url.length > 0
      ret = '/' + url.join('/')
      ret += '/' if trailing_slashes
    else
      # if our url array is empty, we're at the root of the site!
      ret = '/'
    end

    # check if we have a hash laying around and slap it on to the final url
    ret += '#' + hash unless hash.nil? || hash.empty?

    ret
  end
  alias_method :page_path, :page_url

  # Same as above, but absolute
  def absolute_page_url(slug = nil)
    uri = URI(http_prefix)
    # absolute_prefix = uri.scheme.nil? ? "//#{uri.host}" : "#{uri.scheme}://#{uri.host}"
    absolute_prefix = "http://#{uri.host}"
    absolute_prefix.strip.chomp('/') + page_url(slug)
  end

  # Same as above, but with utm params
  def share_url(page_slug = nil, source: nil, location: nil)
    params = {
      'utm_medium' => 'social'
    }
    params['utm_source'] = source if source

    if page_slug.present?
      slug, anchor = page_slug.split('#')
      url = override_share_url || absolute_page_url(slug)

      if anchor.blank?
        "#{url}?#{params.to_query}"
      else
        "#{url}?#{params.to_query}##{anchor}"
      end
    else
      url = override_share_url || absolute_page_url(page_slug)
      "#{url}?#{params.to_query}"
    end
  end

  # Link to share a link on twitter
  def tweet(slug = nil, text = nil, location = nil)
    url = share_url(slug, :source => 'twitter', :location => location)
    via = twitter
    text ||= tweet_text || title
    tweet_url(url, text, via)
  end

  # share specific url twitter
  def tweet_url(url, text, via = nil)
    ret = "https://twitter.com/share?#{{url:url,text:text}.to_param}"
    return ret if via.nil?
    ret + "&#{{via:via}.to_param}"
  end

  # Link to share a link on facebook
  def facebook(slug = nil, location = nil)
    url = share_url(slug, :source => 'facebook', :location => location)
    facebook_url(url)
  end

  def facebook_url(url)
    "https://www.facebook.com/sharer/sharer.php?#{{u:url}.to_param}"
  end

  def pinterest(slug = nil, text = nil, image_url = nil, location = nil)
    url = share_url(slug, :source => 'pinterest', :location => location)
    text ||= tweet_text || title || ''
    image_url ||= sharing_image || ''
    text += ' ' + url
    pinterest_url(url, image_url, text)
  end

  def pinterest_url(url, media, description)
    "http://www.pinterest.com/pin/create/button/?#{{url:url,media:media,description:description}.to_param}"
  end

  # Shamelessly ripped off from ActiveSupport
  #
  # @param [String] String to process
  # @param [String] The separator to use
  def parameterize(string, sep = '-')
    string.parameterize(sep)
  end
  alias_method :slugify, :parameterize

  # Parse markdown with rdiscount
  #
  # @param [String] Text to process for markdown
  # @param [Symbol] Options for the markdown processing:
  #   :smart - Enable SmartyPants processing.
  #   :filter_styles - Do not output <style> tags.
  #   :filter_html - Do not output any raw HTML tags included in the source text.
  #   :fold_lines - RedCloth compatible line folding (not used).
  #   :footnotes - PHP markdown extra-style footnotes.
  #   :generate_toc - Enable Table Of Contents generation
  #   :no_image - Do not output any <img> tags.
  #   :no_links - Do not output any <a> tags.
  #   :no_tables - Do not output any tables.
  #   :strict - Disable superscript and relaxed emphasis processing.
  #   :autolink - Greedily urlify links.
  #   :safelink - Do not make links for unknown URL types.
  #   :no_pseudo_protocols - Do not process pseudo-protocols.
  def markdown(str, *extensions)
    return if str.nil?
    require 'rdiscount'
    no_p = extensions.delete(:no_p)
    ret = RDiscount.new(str, *extensions).to_html
    ret.gsub!(/<\/?p>/, '') if no_p
    ret
  end
  alias_method :md, :markdown

  # Process a block of html to make the included images and iframes lazy-load
  #
  # @param [String] Blob of HTML to process
  # @param [Hash] Options for adjusting tags
  #   :use_attr => [String] Change 'src' attributes to this name.
  #                         DEFAULT 'data-src'
  #   :add_class => [String] Add this class to affected tags
  def lazy_load(html, options = {})
    opts = {
      :use_attr => 'data-original',
      :add_class => 'lazy',
      :thumbnail => { :width => 900 }
    }.merge(options)

    use_attr = opts[:use_attr]
    add_class = opts[:add_class]
    placeholder = opts[:placeholder]

    require 'nokogiri'
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    # I realize that we may want to move this smart_quotes function
    # smart_quotes(doc)
    doc.css('img[src],iframe[src]').each do |tag|
      unless tag.include? use_attr
        url = tag['src']
        if url =~ /gif$/ || tag.name == 'iframe'
          tag[use_attr] = url
        else
          # test to see if image should be smaller if we're using foundation
          begin
            klass = tag.parent.attr('class') || ''
            if klass =~ /(large-\d|medium-\d)/
              # replace dashes with spaces, split string on spaces
              bits = klass.tr('-', ' ').split
              bits.select! { |i| i.to_i.to_s == i } # select the numbers
              biggest_num = bits.max # return the maximum

              # 90px is 1/12 of 1078, which is the largest width an image can be
              opts[:thumbnail][:width] = 90 * biggest_num
            end
          rescue
            'ignore'
          end
          tag[use_attr] = thumb_url(tag['src'], opts[:thumbnail])
        end
        tag.delete('src')
      end

      tag['src'] = placeholder unless placeholder.blank? || tag.name == 'iframe'

      next if add_class.blank?

      if tag['class'].blank?
        tag['class'] = add_class
      else
        tag['class'] += ' ' + add_class
      end
    end

    doc.serialize
  end

  # Process a block of html to thumbnail images
  #
  # @param [String] Blob of HTML to process
  # @param [Hash] Options for thumb_url
  def thumb_in_html(html, thumb_options)
    require 'nokogiri'
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    doc.css('img[src]').each do |tag|
      url = tag['src']
      unless url =~ /gif$/ || url =~ /thumbor/
        tag['src'] = thumb_url(url, thumb_options)
      end
    end

    doc.serialize
  end

  # Process a block of html to add smart quotes to elements with the
  # pullquote class.
  #
  # @param [String] Blob of HTML to process
  def smart_quotes(html)
    require 'nokogiri'
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    quotes = doc.css('q')
    quotes.each do |q|
      if q['class'].nil? || q['class'].empty?
        q['class'] = 'pullquote'
      end
      if q.content[0] == '"' && q.content[-1] == '"'
        q.content = '“'+q.content[1..-2]+'”'
      end
    end
    doc.serialize
  end

  # Turn copy with linebreaks into p-tag wrapped paragraphs
  #
  # @param [String] Blob of text
  # @param [String] Blob of HTML
  def linebreaks(text)
    return text if text.nil? || text.empty?
    text.split(/\n\s*\n/).map do |para|
      "<p>#{para.strip}</p>"
    end.join "\n\n"
  end

  # Process a chorus image url
  #
  # @param [String] Full URL to an image file
  # @param [Hash] Options for cutting the thumb:
  #  :meta => bool - flag that indicates that thumbor should return only
  #                  meta-data on the operations it would otherwise perform;
  #  :crop => [left, top, right, bottom] - Coordinates for manual cropping.
  #  :width => <int> - the width for the thumbnail;
  #  :height => <int> - the height for the thumbnail;
  #  :flip => <bool> - flag that indicates that thumbor should flip
  #                    horizontally (on the vertical axis) the image;
  #  :flop => <bool> - flag that indicates that thumbor should flip vertically
  #                    (on the horizontal axis) the image;
  #  :halign => :left, :center or :right - horizontal alignment that thumbor
  #                                        should use for cropping;
  #  :valign => :top, :middle or :bottom - horizontal alignment that thumbor
  #                                        should use for cropping;
  #  :smart => <bool> - flag indicates that thumbor should use smart cropping;
  # @return [String] Full URL to the thumbnail
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

  # Generate embed code for a ooalya video ID or and oembed compatible URL
  #
  # @param [String] Either an ooalya video ID or an oembed compatible URL
  # @return [String] HTML string of the embed code
  def embed(code_or_url)
    if code_or_url =~ %r{^http(s|)://}
      require 'oembed'
      OEmbed::Providers.register_all
      OEmbed::Providers.get(code_or_url).html
    elsif code_or_url =~ /^[^\s]{32}$/
      require 'securerandom'
      partial('partials/modules/ooalya_video',
              :locals => { :code => code_or_url, :id => SecureRandom.hex(4) })
    else
      code_or_url
    end
  end

  # make sure to gem install sanitize
  def sanitize(html)
    require 'sanitize'
    Sanitize.fragment(html, Sanitize::Config::BASIC)
  end

  # make sure to gem install sanitize
  def strip_html(html)
    require 'sanitize'
    Sanitize.fragment(html)
  end

  # make sure to gem install archieml
  def archieml(text_aml)
    require 'archieml'
    Archieml.load(text_aml)
  end

  # Find one hash in an array of hashes
  #
  # @param [Array] An array of hashes to search in
  # @param [Hash] A query to use
  # @return [Hash] Return the matching hash or an empty hash
  def find_by(array, query)
    array.find do |item|
      matching = []
      query.each do |k, v|
        matching << (item[k.to_s].to_s == v.to_s)
      end
      matching.reduce { |a, e| a && e }
    end || {}
  end

  # Find many hashes in an array of hashes
  #
  # @param [Array] An array of hashes to search in
  # @param [Hash] A query to use
  # @return [Array] Return an array of matching hashes or an empty array
  def filter_by(array, query)
    array.select do |item|
      matching = []
      query.each do |k, v|
        matching << (item[k.to_s].to_s == v.to_s)
      end
      matching.reduce { |a, e| a && e }
    end || []
  end
end
