$ ->
  on_star = (e)->
    star_index = $(e.target).data('index')
    stars = $(e.target).parent().find('.star')
    for star in stars
      star = $(star)
      if star.data('index') > star_index
        star.addClass('empty')
        star.removeClass('vote')
      else
        star.addClass('vote')
        star.removeClass('empty')

  out_star = (e)->
    parent = $(e.target).parent()
    return if parent.hasClass('disabled')
    stars = parent.find('.star')
    stars.removeClass('vote')
    stars.removeClass('empty')

  vote = (parent, star_index, success_callback, err_callback)->
    vote_path = parent.data('vote-path')

    $.ajax vote_path,
      type: 'POST'
      data: { score: star_index }
      error: (xhr, status, err)->
        vote_error(parent)

      success: (data, status, xhr)->
        success_callback(data, parent, star_index)

  # set selected to voted stars
  vote_success = (data, parent, star_index)->
    stars = parent.find('.star')
    for star in stars
      star = $(star)
      star.removeClass('vote')
      star.removeClass('empty')
      star.removeClass('selected')

      if star.data('index') > data.int_score
        star.addClass('empty')
      else
        star.addClass('selected')

    parent.find('.avg_score').html(data.avg_score)
    parent.find('.votes_number').html("(#{data.votes_number})")

  # set active to parent
  vote_error = (parent)->
    parent.removeClass('disabled')


  $(document).on 'mouseenter', '.star', on_star
  $(document).on 'mouseleave', '.star', out_star

  $(document).on 'click', '.star', (e)->
    parent = $(e.target).parent()
    parent.addClass('disabled')
    star_index = $(e.target).data('index')
    vote(parent, star_index, vote_success, vote_error)


