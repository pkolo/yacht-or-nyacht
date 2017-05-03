$(document).ready(function() {

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

  $('.add-discog-btn').click(function() {
    $.ajax({
      url: 'discog_search'
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
      console.log(res)
    });
  })

});
