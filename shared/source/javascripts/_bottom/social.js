var EdProd = EdProd || {};

EdProd.Social = (function ($) {
  var shareUrl = document.URL,
      iframed = (window !== window.top);

  var openShareWindow = function(e) {
    var $link = $(this),
        width = 500,
        height = 300,
        left = (window.innerWidth / 2) - (width / 2),
        top = (window.innerHeight / 2) - (height / 2);

    if (e.which === 1 && !e.metaKey && !e.ctrlKey) {
      e.preventDefault();
      window.open(
        $link.attr('href'), "",
        "menubar=no,toolbar=no,resizable=yes,scrollbars=yes,width=" + width + ",height=" + height + ",top=" + top + ",left=" + left
      );
    }
  };

  var updateShareLinks = function() {
    var params = {
      url: shareUrl,
      twitter_text: $("meta[name='twitter:tweet_text']").attr("content"),
      text: $("meta[property='og:description']").attr("content"),
      shareImg: $("meta[property='og:image']").attr("content"),
      title: $("meta[property='og:title']").attr("content"),
      via: $("meta[name='twitter:site']").attr("content").substring(1),
      meta_url: $("meta[property='og:url']").attr("content")
    };

    console.debug( 'updateShareLinks', shareUrl );

    $('a[data-analytics-social]').each(function(i, d) {
      var button_url = params['url'],
          tweet_text = params['twitter_text'],
          pinterest_img = params['shareImg'],
          pinterest_text = params['text'],
          url;

      if ( $(d).hasClass('top-nav') ) {
        tweet_text = $(d).attr('tweet-text');
        button_url = document.URL.replace($(d).attr('page-slug'), '');
        pinterest_img = $(d).attr('app-img');
        pinterest_text = $(d).attr('app-text');
      }

      switch ( $(this).data('analytics-social') ) {
        case 'twitter':
          url = "https://twitter.com/share?url=" +  encodeURIComponent(button_url.concat("?utm_medium=social&utm_source=twitter")) + "&text=" + encodeURIComponent(tweet_text) + "&via=" +  encodeURIComponent(params['via']);
          break;
        case 'facebook':
          url = "https://www.facebook.com/sharer/sharer.php?u=" +  encodeURIComponent(button_url);
          break;
        case 'pinterest':
          url = "http://www.pinterest.com/pin/create/button/?" + "url=" +  encodeURIComponent(button_url) + "&media=" +  encodeURIComponent(pinterest_img) + "&description=" +  encodeURIComponent(pinterest_text);
          break;
      }

      if ( url ) { $(this).attr('href', url); }
    });
  };

  var loaded = function () {
    if ( document.readyState === 'complete' ) {
      if ( window.pymChild ) {
        shareUrl = $.QueryString['parentUrl'];

        pymChild.onMessage('setShareUrl', function(data) {
          data = JSON.parse(data);
          shareUrl = data.url.replace('#' + data.slug, '');
          updateShareLinks();
        });

        pymChild.sendMessage('childLoaded', 'ready');
        pymChild.sendHeight();
      }

      updateShareLinks();
    }
  };

  $(document).ready(function() {
    $('body').on('click', 'a[data-analytics-social]', openShareWindow);

    if ( iframed ) {
      document.onreadystatechange = loaded;
      loaded();
    }
  });

})(jQuery);
