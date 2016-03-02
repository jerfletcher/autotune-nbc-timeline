(function ($) {
  var logged_in = false;
  var rendered_once = false;
  var iframe_rendered = false;
  var iframe_interval = false;
  var iframe_height = 0;

  var checkLoginStatus = function(callback) {
    var url = "/account/auth_status";
    $.getJSON(url, function(data) {
      logged_in = !!data.logged_in;
      if (!!callback) {
        callback(data);
      }
    });
  };

  var hideComments = function() {
    stopIframeInterval();
    $('#comments-overlay').hide();
  };

  var renderComments = function(content) {
    if (logged_in && rendered_once) {
      if (iframe_rendered) {
        startIframeInterval();
      }
      return;
    }
    if (logged_in) {
      rendered_once = true;
      renderIframe(content);
    } else if (!logged_in) {
      content.html('<p>Please <a target="_blank" id="plz-login" href="/account/login">login to Polygon first</a>.</p>');
    }
  };

  var renderIframe = function(content) {
    //var theme_name = "review_" + Review.context.review_console;
    var url = "/polygon_entries/iframed_comments" + SBN.Context.comments_slug //+ "?theme=" + theme_name;
    var iframe = $('<iframe id="comments-iframe" scrolling="no" src="' + url + '"></iframe>');
    content.empty().append(iframe);
    $('#comments-iframe').load(function() {
      iframe_rendered = true;
      iframeHeightResize();
      startIframeInterval();
    });
  };

  var startIframeInterval = function() {
    iframe_interval = setInterval(iframeHeightResize, 500);
    iframeHeightResize();
  };

  var stopIframeInterval = function() {
    if (!!iframe_interval) {
      clearInterval(iframe_interval);
    }
  };

  var iframeHeightResize = function() {
    var iframe = $('#comments-iframe');
    var iframe_dom = iframe[0];
    var iframewindow= iframe_dom.contentWindow? iframe_dom.contentWindow : iframe_dom.contentDocument.defaultView;
    var new_height = iframewindow.$('body').height();
    if (new_height != iframe_height) {
      iframe_height = new_height;
      iframe.css({
        height: iframe_height
      });
    }
  };

  var setLoading = function(content) {
    content.html("<p class='m-loader'></p>");
  };

  $(function() {

    var content = $('.comments-content');

    $(document).on('click', '#plz-login', function(e) {
      hideComments();
    });

    $('.review-comments').click(function(e) {
      e.preventDefault();
      if (!logged_in) {
        setLoading(content);
      }
      checkLoginStatus(function(data) {
        renderComments(content);
      });
      $('#comments-overlay').show();
    });

    $('#comments-overlay').click(function(e) {
      if ($(e.target).is($('#comments-overlay'))) {
        e.preventDefault();
        hideComments();
      }
    });

  });

})(jQuery);
