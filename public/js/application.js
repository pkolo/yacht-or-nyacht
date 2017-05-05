$(document).ready(function() {

  var jayGradient = function(pct) {
    var percentColors = [
    { pct: 0.0, color: { r: 230, g: 124, b: 115 } },
    { pct: 0.5, color: { r: 255, g: 214, b: 102 } },
    { pct: 1.0, color: { r: 87, g: 187, b: 138 } } ];

    for (var i = 1; i < percentColors.length - 1; i++) {
    if (pct < percentColors[i].pct) {
        break;
      }
    }

    var lower = percentColors[i - 1];
    var upper = percentColors[i];
    var range = upper.pct - lower.pct;
    var rangePct = (pct - lower.pct) / range;
    var pctLower = 1 - rangePct;
    var pctUpper = rangePct;
    var color = {
        r: Math.floor(lower.color.r * pctLower + upper.color.r * pctUpper),
        g: Math.floor(lower.color.g * pctLower + upper.color.g * pctUpper),
        b: Math.floor(lower.color.b * pctLower + upper.color.b * pctUpper)
    };
    return 'rgb(' + [color.r, color.g, color.b].join(',') + ')';
    // or output as hex if preferred
  };

  $('.yachtski').each(function() {
    var $this = $(this);
    var yachtski = $this.text()
    var color = jayGradient(yachtski / 100)

    $this.css('background-color', color)
    $this.parent().css('border', `1px solid ${color}`)
  });

  jQuery.expr[':'].Contains = function(a,i,m){
    return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase())>=0;
  };

  $('#songSearch').keyup(function() {
    var query = $(this).val();

    $('.song-list').find('.title:Contains(' + query + ')').parent().show()
    $('.song-list').find('.title:not(:Contains(' + query + '))').parent().hide()
  });

  $('.add-song-form').on('keyup', '.score-input', function() {
    var sum = 0;
    var avg = 0;
    $('.score-input').each(function() {
      sum += Number($(this).val());
    });

    var $allInput = $('.score-input');
    var $emptyInput = $('.score-input').filter(function(){return this.value==''});
    var full = $allInput.length - $emptyInput.length;

    if (full > 0) {avg = (sum/full)}

    $('.yachtski-score').text(avg)

  });

  $('.add-song-form').on('submit', '.song-form', function(e) {
    e.preventDefault();
    $.ajax({
      url: 'songs',
      method: 'POST',
      data: $('.song-form').serialize()
    }).done(function(res) {
      $('.song-list').append(res)
      $('.song-form').parent().remove()
    });
  });

  $('.add-song-btn').click(function() {
    $.ajax({
      url: 'songs/new'
    }).done(function(res) {
      $('.add-song-form').append(res)
    });
  });

  $('.discog-search-form').submit(function(e) {
    e.preventDefault();
    $.ajax({
      url: 'discog_search',
      method: 'POST',
      data: $(this).serialize()
    }).done(function(res) {
      $('.search-results-list').append(res)
    });
  });

  $('.search-results-list').on('click', '.add-personnel-btn', function() {
    var id = $(this).attr('id')
    var baseURL = "https://api.discogs.com/releases/"
    $.ajax({
      url: 'add_personnel',
      method: 'POST',
      data: {url: baseURL+id}
    }).done(function(res) {
      $('.edit-section').hide()
      $('.credits-list').append(res)
    });
  })

});
