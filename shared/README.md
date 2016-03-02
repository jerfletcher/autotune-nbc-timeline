## Installation

[Start here](https://github.com/voxmedia/411/wiki/Editorial-Apps-Rig) for installation and usage instructions.

## Making changes

[Start here](https://github.com/voxmedia/voxmedia-middleman-shared/blob/master/CONTRIBUTING.md) for guidelines on how and when to make changes to this repo.

# Reference

- [Settings](#configrb-settings)
- [Partials](#partials)
- [Javascript](#javascripts)
- [Style](#style)
- [Helpers](#helpers)
    - [Config](#config-helpers)
    - [Common](#common-helpers)
    - [Ads](#ads-helpers)
    - [Pages](#pages-helpers)
    - [Chorus](#chorus-helpers)

## Config.rb settings

### Important stuff

These are the settings for your `config.rb` that you will pretty much always need
to have:

```ruby
# Title is the default used in the meta tags
set :title, ''

# Meta description is used in the meta description tag and open graph tags
set :meta_description, ''

# Used in many of the partials and helpers, also used by `shared/config.rb`
# automatically configure a bunch of other settings
set :vertical, ''

# Default text that goes into tweet buttons
set :tweet_text, ''

# Default text that goes into pinterest shares
set :pinterest_text, ''

# Default image used in open graph tags (facebook, twitter cards, etc)
set :sharing_image, ''

# When this project publishes. Can be a DateTime object or parsable date time.
set :publish_date, ''

# Comma-delimited list of the authors of this project
set :authors, ''
```

### Optional settings

These are features that you can turn on if you'd like. You don't have
to put them in your `config.rb` unless you need to enable them.

```ruby
# This setting is automatic and does not need to be changed. So `now` will
# always be the build time of the project.
set :now, Time.zone.now

# Triggers the `nav` partial to display a `stb` ad unit
set :show_stb, false

# Triggers some partials to include javascript and markup to embed commenting
set :show_comments, false

# Disable viewport meta tags, causes the page to show as a regular desktop
# webpage on mobile
set :not_responsive, false

# Make all links to pages include a trailing slash. This must be `true` when
# publishing to S3
set :trailing_slashes, false

# Setting this URL will override the sharing helpers; which will use this new
# override url instead of the project url.
set :override_share_url

# Add a no index header flag. Tell web crawlers to ignore this project.
set :no_index

# Add classes to the <body>
set :body_classes, 'antialiased'
```

# Automatic stuff

Middleman will also load `shared/config.rb`. Settings in this file are common
and rarely change.

## Partials

## Javascript

## Style

## Helpers

### Config helpers

Config helpers can only be used in the `config.rb` file.

#### build_sitemap_with

This helper builds a flat sitemap in middleman using an array of hashes. This means
that for each item in the array, a new url and page is setup (using the middleman [proxy](https://middlemanapp.com/advanced/dynamic_pages/) command).

You must use this helper if you plan on using the [page helpers](#pages).

There are three required fields for each page: `slug`, `class`, `title`.
- `slug` is used in the url and as an identifier
- `title` is used in the template layout to set the page title and other meta
- `class` is used by the `pages` partial to pick a template for the page

You can add more fields to each page, and those data will be available in your
templates. You can access data for a page with the
[current_page_data](#current_page_data) helper.

The first page in the array will always be used as the home page. That means the `slug` will not be used for the url. The url of this page will always be `/`.

```ruby
pages = [
    { 'slug' => 'home', 'class' => 'cover', 'title' => 'Home page' },
    { 'slug' => 'lorem-ipsum', 'class' => 'article', 'title' => 'Lorem ipsum' },
    { 'slug' => 'dolor-sit-amet', 'class' => 'article', 'title' => 'Dolor sit amet' },
    { 'slug' => 'cras-in-magna', 'class' => 'gallery', 'title' => 'Cras in magna' }
]
build_sitemap_with pages
```

The most common use of this helper is to load page data from a google spreadsheet:

```ruby
# Load a google spreadsheet that contains a `pages` worksheet
activate :google_drive, load_sheets: 'mygoogledockey'
build_sitemap_with data.pages
```

### Common helpers

#### page_title

Generate the page title. Optionally takes a string to prepend to the title.
This helper uses the `app_name` setting from `config.rb`.

```ruby
set :app_name, 'My fancy app'

page_title 'Introduction'
#=> 'Introduction | My fancy app'

# without a parameter, it just returns the app_name
page_title
#=> 'My fancy app'
```

#### page_url

Generate the full path for a page. Optionally takes the slug for a page. This
helper uses the `http_prefix` setting from `config.rb`.

```ruby
set :http_prefix, 'http://www.vox.com/a/my-fancy-app'

page_url 'intro'
#=> '/a/my-fancy-app/intro'

# without a parameter, it just returns the path of the http_prefix
page_url
#=> '/a/my-fancy-app'
```

If `http_prefix` is missing or empty, this helper returns `'/'`

```ruby
set :http_prefix, ''

page_url 'intro'
#=> '/intro'
page_url
#=> '/'
```

#### absolute_page_url

Generate the full URL for a page. Optionally takes the slug for a page. This
helper uses the `http_prefix` setting from `config.rb`.

```ruby
set :http_prefix, 'http://www.sbnation.com/a/my-fancy-app'

absolute_page_url 'intro'
#=> 'http://www.sbnation.com/a/my-fancy-app/intro'

# without a parameter
absolute_page_url
#=> 'http://www.sbnation.com/a/my-fancy-app'
```

#### tweet

Generates a URL for sending a tweet. Tries to guess what URL, text and "via" to use in
the tweet.

```erb
<a href="<%=tweet %>" target="_blank">Tweet</a>
```

By default, this helper will generate a tweet that includes a link to the homepage
of the project, will use the text specified by the `tweet_text` setting from
`config.rb`, and will use the `twitter` setting from `config.rb`.

```ruby
set :tweet_text, 'Default tweet text for the tweet helper'
set :twitter, 'theverge'
```

**NOTE:** You shouldn't have to set `via` in your `config.rb`. I should be set
automatically based on your `vertical` setting.

You can provide two optional parameters: `slug` and `text`. Providing a slug will
cause the tweet to include a link to a specific page in the project. Providing text
will override the text for this tweet.

```erb
<a href="<%=tweet 'lorem-ipsum', 'hey, this is a cool page i found' %>"
   target="_blank">Tweet</a>
```

#### tweet_url

Generates a URL for sending a tweet. Requires `url` and `text` parameters.

```erb
<a href="<%=tweet_url 'http://example.com', 'Checkout this cool example website!' %>"
   target="_blank">Tweet</a>
```

You can provide a third parameter `via` which adds the "via @handle" to the end of
the tweet text. If you do not provide this parameter, the "via @handle" text is not
added.

#### facebook

Generates a URL for sharing on facebook. Tries to guess what URL to share.

```erb
<a href="<%=facebook %>" target="_blank">Tweet</a>
```

You can provide one optional parameter: `slug`. Providing a slug will share a link
to a specific page in the project.

```erb
<a href="<%=facebook 'lorem-ipsum' %>" target="_blank">Share on facebook</a>
```

**NOTE:** Most of the facebook sharing data is controlled by the `meta_tags` partial.
Also you can't share hidden stuff on facebook, so don't expect these links to work
before you publish.

#### facebook_url

Generates a URL for sharing on facebook. Requires a single URL parameter.

```erb
<a href="<%=facebook_url 'http://example.com' %>" target="_blank">Share on facebook</a>
```

#### google_plus

This helper has been removed.

#### pinterest

Generates a URL for posting on pinterest. Tries to guess what to share.

```erb
<a href="<%=pinterest %>" target="_blank">Pin</a>
```

By default, this helper will generate a pin link that includes a link to the homepage
of the project, will use the text specified by the `tweet_text` setting from
`config.rb`, and will use the `sharing_image` setting from `config.rb`.

```ruby
set :tweet_text, 'also used in the pinterest post'
set :sharing_image, 'default sharing image'
```

You can provide three optional parameters: `slug`, `text` and `image_url`. Providing
a slug will cause the pin to include a link to a specific page in the project.
Providing text will override the text for the pin. Providing an image URL will
pin that image instead of the default project sharing image.

```erb
<a href="<%=pinterest 'lorem-ipsum', 'this is a special photo', 'http://example.com/special_photo.jpg' %>"
   target="_blank">Pin</a>
```

#### parameterize or slugify

DEPRECIATED!!

This will be removed. Please use the built in string method.

```ruby
'My Fancy App'.parameterize
#=> 'my-fancy-app'

"St. Elmo's Fire".parameterize
#=> 'st-elmos-fire'
```

#### markdown

Takes a markdown-formatted blob of text and convert it into HTML. This is
very useful for processing text coming from a google spreadsheet or other
data sources.

```ruby
blob = <<TEXT
# Header

some description, with [link](url)
 * todo 1
 * todo 2
TEXT

markdown blob
#=> '<h1>Header</h1> <p>some description, with <a href="url">link</a></p><ul><li>todo 1</li><li>todo 2</li></ul>'
```

The `markdown` helper takes a bunch of parameters to control the output.

```
:smart - Enable SmartyPants processing.
:filter_styles - Do not output <style> tags.
:filter_html - Do not output any raw HTML tags included in the source text.
:fold_lines - RedCloth compatible line folding (not used).
:footnotes - PHP markdown extra-style footnotes.
:generate_toc - Enable Table Of Contents generation
:no_image - Do not output any <img> tags.
:no_links - Do not output any <a> tags.
:no_tables - Do not output any tables.
:strict - Disable superscript and relaxed emphasis processing.
:autolink - Greedily urlify links.
:safelink - Do not make links for unknown URL types.
:no_pseudo_protocols - Do not process pseudo-protocols.
```

You can use these parameters by adding them to the helper call.

```ruby
markdown blob, :autolink, :safelink
```

#### lazy_load

Takes a blob of HTML and adjust any `img` or `iframe` tags to enable lazy-
loading. Super useful for processing HTML coming from a spreadsheet or Chorus.

```ruby
html = '<img src="foo.jpg"/>'

lazy_load html
#=> '<img data-original="foo.jpg" class="lazy"/>'
```

You may want to adjust how this helper works, depending on which lazy-load
library you're planning to use.

```ruby
lazy_load html, use_attr: 'data-src', add_class: 'super-lazy'
#=> '<img data-src="foo.jpg" class="super-lazy"/>'
```

You could also chain this with the markdown helper to make markdown-formatted
image lazy-load.

```ruby
lazy_load markdown my_markdown_text
```

#### linebreaks

Takes a blob of plain text and wrap paragraphs in p tags. Super useful for
processing text coming from a spreadsheet. The `markdown` helper will also
wrap plain text paragraphs with p tags.

```ruby
text = <<TEXT
paragraph1

paragraph2
TEXT

linebreaks text
#=> '<p>paragraph1</p><p>paragraph2</p>'
```

#### thumb_url

Take a absolute URL to an image and generate a new URL for a resized version
of that image. This helper uses a Thumbor service, and does not actually
download or resize the image.

```ruby
image_url = 'http://cdn1.vox-cdn.com/uploads/chorus_asset/file/675980/454137706.0.jpg'

thumb_url image_url, width: 420
#=>//cdn2.vox-cdn.com/thumbor/AJFUbB7CYdKbIvpz_E-RaZ1RUgw=/420x0/cdn1.vox-cdn.com/uploads/chorus_asset/file/675980/454137706.0.jpg
```

This helper provides a lot of options for how the image will be resized:

```
:meta => bool - flag that indicates that thumbor should return only
                meta-data on the operations it would otherwise perform;
:crop => [left, top, right, bottom] - Coordinates for manual cropping.
:width => <int> - the width for the thumbnail;
:height => <int> - the height for the thumbnail;
:flip => <bool> - flag that indicates that thumbor should flip
                  horizontally (on the vertical axis) the image;
:flop => <bool> - flag that indicates that thumbor should flip vertically
                  (on the horizontal axis) the image;
:halign => :left, :center or :right - horizontal alignment that thumbor
                                      should use for cropping;
:valign => :top, :middle or :bottom - horizontal alignment that thumbor
                                      should use for cropping;
:smart => <bool> - flag indicates that thumbor should use smart cropping;
```

I don't understand what most of it does, so you should mess around with it ;).

#### embed

Takes an Ooalya ID or the URL for a YouTube, Vimeo, Soundcloud or other oembed
enabled media item and generates the embed code for you.

```ruby
url = 'https://www.youtube.com/watch?v=JYc05gZFly0'

embed url
#=>'<iframe width="420" height="315" src="//www.youtube.com/embed/JYc05gZFly0" frameborder="0" allowfullscreen></iframe>'
```

#### sanitize

Uses the sanitize gem to clean up some HTML. If you pass html through this helper,
most HTML elements and attributes will be removed to leave you with basic formatting
tags.

Make sure you add `gem 'sanitize'` to your `Gemfile`.

```ruby
bad_html = '<h1><FONT color="salmon" size="100">Hey header</FONT></h1>
<div style="crap"><p><b>YO:</b> some text here <blink>PAY ATTENTION</blink></p></div>'

sanitize bad_html
#=> '<h1>Hey header</h1>
<div><p><b>YO:</b> some text here PAY ATTENTION</p></div>'
```

#### strip_html

Also uses the sanitize gem, this time to remove all HTML from text.

Make sure you add `gem 'sanitize'` to your `Gemfile`.

```ruby
bad_html = '<h1><FONT color="salmon" size="100">Hey header</FONT></h1>
<div style="crap"><p><b>YO:</b> some text here <blink>PAY ATTENTION</blink></p></div>'

strip_html bad_html
#=> 'Hey header
YO: some text here PAY ATTENTION'
```

#### archieml

Uses the archieml gem to parse [archieml-formatted text](http://archieml.org/).

Make sure you add `gem 'archieml'` to your `Gemfile`.

```ruby
text_aml = "key: value"

archieml text_aml
=> {"key"=>"value"}
```

#### find_by

Find one hash in an array of hashes. This helper tries to make it easy to retrieve
a single item from a list based on the item's content.

Say we have page data from the example above:

```ruby
pages = [
    { 'slug' => 'home', 'class' => 'cover', 'title' => 'Home page' },
    { 'slug' => 'lorem-ipsum', 'class' => 'article', 'title' => 'Lorem ipsum' },
    { 'slug' => 'dolor-sit-amet', 'class' => 'article', 'title' => 'Dolor sit amet' },
    { 'slug' => 'cras-in-magna', 'class' => 'gallery', 'title' => 'Cras in magna' }
]
```

We could use `find_by` to get an item from the list using its slug:

```ruby
find_by pages, 'slug' => 'dolor-sit-amet'
#=> { 'slug' => 'dolor-sit-amet', 'class' => 'article', 'title' => 'Dolor sit amet' }
```

Which is much better than trying to keep track of the index number or something.

#### filter_by

Retrieve any number of hashes from an array of hashes. Similar to [find_by](#find_by),
only this helper will give you an list of matching things instead of just one.

Say we have page data from the example above:

```ruby
pages = [
    { 'slug' => 'home', 'class' => 'cover', 'title' => 'Home page' },
    { 'slug' => 'lorem-ipsum', 'class' => 'article', 'title' => 'Lorem ipsum' },
    { 'slug' => 'dolor-sit-amet', 'class' => 'article', 'title' => 'Dolor sit amet' },
    { 'slug' => 'cras-in-magna', 'class' => 'gallery', 'title' => 'Cras in magna' }
]
```

We could use `filter_by` to get all the items with a class of article:

```ruby
filter_by pages, 'class' => 'article'
#=> [{ 'slug' => 'lorem-ipsum', 'class' => 'article', 'title' => 'Lorem ipsum' },
{ 'slug' => 'dolor-sit-amet', 'class' => 'article', 'title' => 'Dolor sit amet' }]
```

### Ads helpers

Ad helpers are now unnecessary due to async loading:

```html
<div class="advert" data-ad-slot="leaderboard"></div>
```

Available ad slots:
- leaderboard (acts as a mobile_banner also)
- super_leaderboard
- athena
- stb
- medium_rectangle
- mobile_banner
- half_page
- sponsored_product_placement
- second_sponsored_product_placement

The ruby helper is still available for backward compatibility.


### Pages helpers

These helpers are meant to be used with the
[build_sitemap_with](#build_sitemap_with) helper in `config.rb`. Without it,
these helpers won't be very (ahem) helpful.

#### current_page_data

All the stuff that Middleman knows about the loaded page. Usually a slug,
title and class. If you have more fields in your pages, those fields
are available through this helper.

```erb
<div id="<%=current_page_data['slug'] %>"
     class="<%=current_page_data['class'] %>">
    <h1><%=current_page_data['title'] %></h1>
    <p>TKTKTK</p>
</div>
```

#### homepage_data

All the stuff that Middleman knows about the homepage or first page.

#### pages_data

An array of hashes with all the data that Middleman knows about all the pages.
This should be almost identical to the `pages` data you gave to `build_sitemap_with`.

#### next_page_data

The data for the page that comes after this one. This will be `nil` if the
current page is the last page.

#### prev_page_data

Ummmm, the previous page data... This will be `nil` if the current page is
the home or first page.

#### homepage

Returns the Middleman Resource object for the homepage. You probably want [homepage_data](#homepage_data).

#### pages

Returns an array of Middleman Resource objects. You probably want [pages_data](#pages_data).

#### next_page

Returns the Middleman Resource object for the next page. You probably want [next_page_data](#next_page_data).

#### prev_page

Returns the Middleman Resource object for the previous page. You probably want [prev_page_data](#prev_page_data).

#### data_for

This will get the data from a Middleman resource object. Don't use it.

```ruby
current_page_data == data_for current_page
#=> true
```

### Chorus helpers

In order to use the chorus helpers, you need to
[use the Chorus extension](https://github.com/voxmedia/middleman-chorus).

#### chorus_entry

Retrieves the content and meta data for an entry in Chorus. It takes a single
parameter which can be the ID number, slug or preview URL of a Chorus entry.

```erb
<% article = chorus_entry(12345) %>
<article>
<h1><%=article['title'] %></h1>
<%=article['body_extended'] %>
</article>
```

**NOTE:** Entry data is cached. So during development, you need to restart
Middleman in order to see changes to the Entry.

#### chorus_video_placeholders

Parses the body of a Chorus entry and adds embedded videos based on Chorus
snippets.

You can use the Chorus editor to embed a video into the body, which adds
something to the body that looks like this:

```html
<!-- CHORUS_VIDEO_EMBED ChorusVideo:123456 -->
```

The `chorus_video_placeholders` helper converts these tags to actual video
embed tags.

```erb
<%=chorus_video_placeholders article['body_extended'] %>
```

This helper gets the embed codes directly from Chorus, so the embeds are managed
by the Video Product team. Which means they should work exactly like they do in
Chorus.
