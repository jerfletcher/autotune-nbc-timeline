// http://stackoverflow.com/a/3855394
(function($) {
  $.decodeParam = function(s) {
    if (s === "") { return {}; }
    var a = s.substr(1).split('&'), b = {};
    for (var i = 0; i < a.length; ++i) {
      var p=a[i].split('=');
      if (p.length !== 2) { continue; }
      b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
    }
    return b;
  };

  $.QueryString = $.decodeParam(window.location.search);
})(jQuery);
