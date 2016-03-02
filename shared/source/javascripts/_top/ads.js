/* load dfp javascript in async mode */
(function() {
  var useSSL = 'https:' == document.location.protocol;
  var src = (useSSL ? 'https:' : 'http:') +
    '//www.googletagservices.com/tag/js/gpt.js';
  document.write('<scr' + 'ipt async=true src="' + src + '"></scr' + 'ipt>');
})();

// Placeholders to use until DFP library is loaded
var googletag = googletag || {};
googletag.cmd = googletag.cmd || [];

/* global module */
(function(factory) {
  if (typeof define === 'function' && define.amd) {
    define('VoxAds', ['jquery'], factory);
  } else if (typeof module !== 'undefined' && module.exports) {
    module.exports = factory( require('jquery') );
  } else {
    window.VoxAds = factory.call( this, jQuery );
  }
})(function($) {
  /*
   * Configure the library
   */
  var AD_CONFIG = {
    'catchall': '1x1',
    'reskin': '2x2',
    'stb': '26x1',
    'second_stb': '26x2',
    'leaderboard': {
      '(max-width: 640px)': '320x50',
      '(min-width: 641px)': '728x90'
    },
    'super_leaderboard': '1020x90',
    'medium_rectangle': '300x250',
    'billboard': '970x250',
    'pushdown': '970x90',
    'half_page': '300x600',
    'pre_roll': '640x360',
    'sponsored_logo': '250x40',
    'mobile_banner': '320x50',
    'queen': '1022x341',
    'athena': '1030x590',
    'athena_features': '1030x590',
    'custom_sbn_hub_top_athena': '1030x591',
    'helios': '1080x600',
    'prelude': '1400x600',
    'bookmark': '1400x900',
    'sponsored_product_placement': '1100x500',
    'second_sponsored_product_placement': '1100x501'
  };

  function debug(msg) {
    if ( window.location.search === '?googfc' && console && console.debug ) {
      return console.debug.apply(console, arguments);
    }
  }

  function error(msg) {
    if ( console && console.error ) {
      return console.error.apply(console, arguments);
    }
  }

  /* Setup ads on the page
   *
   *   ads = new VoxAds({
   *     selector: '.advert',
   *     slug: '/172968584/vox/thing-1/thing-2',
   *     keywords: ['foo', 'bar'] })
   */
  function VoxAds(opts) {
    this.$ads = $(opts.selector);

    this.$ads.each( function(i) {
      if ( $(this).data('ad-initialized') ) { return; }

      var slot = $(this).data('ad-slot'),
          id = "div-gpt-ad-" + i,
          dimensions = AD_CONFIG[slot];

      if ( !slot ) {
        if ( console ) { console.error('Element is missing data-ad-slot'); }
        return;
      }

      if ( !dimensions ) {
        if ( console ) { console.error('The ad-slot "'+slot+'" is not recognized'); }
        return;
      }

      debug('initializing slot: '+id);
      $(this).attr('id', id);

      if ( typeof dimensions === 'object' ) {
        for ( var query in dimensions ) {
          if ( window.matchMedia(query).matches ) {
            dimensions = dimensions[query];
            break;
          }
        }
      }

      if ( typeof dimensions === 'string' ) {
        var xy = dimensions.split('x').map( Number );
        googletag.cmd.push( function() {
          debug('defining slot '+[opts.slug, xy, id].join(' '));
          googletag.defineSlot(
              opts.slug, xy, id )
            .addService( googletag.pubads() )
            .setTargeting( 'position', slot )
            .setCollapseEmptyDiv( true );
          debug('slot is defined: '+id);
        } );

        debug('initialized slot: '+id);
        $(this).data('ad-initialized', true);
      } else {
        error('Could not init ad '+id+': no appropriate sizes', dimensions);
      }
    });

    googletag.cmd.push(function() {
      if (opts.keywords) {
        googletag.pubads().setTargeting('keywords', opts.keywords);
      }

      googletag.pubads().enableSingleRequest();
      googletag.pubads().addEventListener('slotRenderEnded', function(event) {
        $(document).triggerHandler('dfp:adRendered', {
          lineItem: event.lineItemId,
          size:     event.size
        });
      });

      debug('Enabling GPT');
      googletag.enableServices();
    });
  }

  /* Display an ad
   *
   *   ads.display(id);
   */
  VoxAds.prototype.display = function(id) {
    if ( ! $('#'+id).data('ad-initialized') ) {
      throw 'Ad slot not initialized';
    }
    if ( $('#'+id).data('ad-displayed') ) {
      if ( console ) { console.log('Ad slot already displayed'); }
      return;
    }

    debug('display: '+id);
    googletag.cmd.push(function() {
      googletag.display(id);
      $('#'+id).data('ad-displayed', true);
      debug('displayed: '+id);
    });
  };

  /* jQuery API interface
   *
   * To setup:
   *   $('.advert').ads({
   *     slug: 'blah/blah/blah',
   *     keywords: ['blah', 'blah']});
   *
   * To display:
   *   $('.advert:visible').ads('display');
   */
  $.fn.ads = function(opts) {
    if ( opts === 'display' ) {
      this.each(function () {
        if ( !$(this).attr('id') ) {
          if ( console ) { console.error('Ad slot not initialized for',opts); }
          return;
        }

        $(this).data('ads').display($(this).attr('id'));
      });
    } else {
      var ads = new VoxAds(
        $.extend({ selector: this }, opts) );
      this.data('ads', ads);
    }
    return this;
  };

  return VoxAds;
});
