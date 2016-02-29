//= require _vendor_extra/pym
//= require masonry
//= require bottom
//= require imagesloaded.pkgd

(function() {
  $(document).ready(function() {
    var $grid = $('#container');
    var pymChild = pym.Child();

    // Anytime you change the height of the graphic, do this:
    pymChild.sendHeight();

    // send height every other second for the first 20 seconds so we can catch
    // twitter and facebook cards
    var sendHeight = function() { pymChild.sendHeight(); };
    for (var i; i < 10; i++) {
      setTimeout(sendHeight, i*2000);
    }

    $(function() {
      //responsivize videos
      var $allVideos = $("iframe[src^='https://player.vimeo.com'], iframe[src^='https://www.youtube.com'], video");
      $allVideos.each(function() {
        $(this).removeAttr('height').removeAttr('width');
      });
      $allVideos.wrap( '<div class="m-video"><div class="m-video__inner"><div class="embed"></div></div></div>' );
      // masonry layout after images load and vidoes are wrapped
      $grid.imagesLoaded().progress( function() {
        $grid.masonry({
          itemSelector : '.item',
          percentPosition: true
        });
      });
    });

    //ensure embedded anchor tags open in new window
    $(function() {
      $('.item').each(function() {
        $(this).find('a').attr('target', '_parent');
      });
    });

    //layout masonry after load or resize
    $(window).on('load resize', function(){
      $grid.masonry({itemSelector : '.item'});
    });

    //move timeline dots after masonry layout complete
    $grid.on( 'layoutComplete',
      function( event, laidOutItems ) {
        $('.item').each(function() {
          if ($(this).css('left') == '0px') {
            $(this).addClass('left');
          } else {
            $(this).removeClass('left');
          };
        });
        //send height after everything is laid out and loaded
        pymChild.sendHeight();
      }
    );

    var media_queries = [
      {media: "(max-width: 975px)", data_name: "large"},
      {media: "(max-width: 720px)", data_name: "medium"},
      {media: "(max-width: 400px)", data_name: "small"}
    ];

    $('.lazy').lazyload({
      threshold : 0,
      failure_limit: 999,
      effect: 'fadeIn',
      data_attribute_queries: media_queries
    });

  });
})();
