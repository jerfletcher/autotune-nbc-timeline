//=require_tree './_templates'
//= require _vendor_extra/pym
//= require masonry
//= require bottom
//= require imagesloaded.pkgd

(function() {
  var pymChild = pym.Child(),
      $grid = $('#container'),
      initialized = false,
      init_cards = false,
      num_cards = 0,
      card_data = AUTOTUNE.moments;

  function createCards(card_data){
    $.each(card_data, function(i, d){
      var item = window.JST['_templates/card']({
        card: d, index: i
      });
      $('#container ul').append(item);
    })
    loadCards();
  }

  function loadCards(){
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
        initialized = true;
      });
    });

    //ensure embedded anchor tags open in new window
    $(function() {
      if(!(initialized)){
        $grid.masonry({
          itemSelector : '.item',
          percentPosition: true
        });
        initialized = true;
      }
      $('.item').each(function() {
        $(this).find('a').attr('target', '_parent');
      });
    });

    //layout masonry after load or resize
    $(window).on('load resize', function(){
      $grid.masonry({itemSelector : '.item'});
      initialized = true;
    });

    //move timeline dots after masonry layout complete
    $grid.on( 'layoutComplete',
      function( event, laidOutItems ) {
        $('.item').each(function(i) {
          if ($(this).css('left') == '0px') {
            $(this).addClass('left');
          } else {
            $(this).removeClass('left');
          };
        });
        pymChild.sendHeight();
      }
    );
  }

  function checkCustomColor(data) {
    if(data.primaryColor && data.theme === 'custom'){
      $('h5').css('color', data.primaryColor);
      document.styleSheets[0].addRule('.timeline ul li:before','background-color: '+data.primaryColor+';');
      document.styleSheets[0].addRule('.timeline ul li:after','background-color: '+data.primaryColor+';');
    }
  }

  // Anytime you change the height of the graphic, do this:

  pymChild.onMessage('updateData', function(data) {
    console.log('----------- received message', data);
    data = JSON.parse(data),
    num_cards = data.moments.length;

    if (!init_cards && num_cards > 0){
      init_cards = true;
    }

    if (init_cards) {
      card_data = data.moments;
      $('.item').remove();
      $grid.masonry( 'destroy' );
      initialized = false;
      createCards(card_data);
    }
    checkCustomColor(data);
  })

  $(document).ready(function() {
    if(window.location.hash === '#new'){
      createCards(card_data);
      checkCustomColor(AUTOTUNE);
    }

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
