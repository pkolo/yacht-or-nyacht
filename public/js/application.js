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

  $('.add-song-btn').click(function() {
    var id = $(this).attr('id')
    $.ajax({
      url: '/episodes/'+id+'/songs/new'
    }).done(function(res) {
      $('.add-song-form').append(res)
    });
  });

});
