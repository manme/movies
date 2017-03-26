$ ->
  $(document).on 'hidden.bs.dropdown', '.category-filter', (e)->
    $(this).parents('form').submit();

  $(document).on 'hidden.bs.dropdown', '.rating-filter', (e)->
    $(this).parents('form').submit();

  $(document).on 'submit', 'form#movies-menu', (e)->
    e.preventDefault()
    e.stopPropagation()
    form_params = $(this).serialize()

    # simple way to use a filter with history
    # Turbolinks.visit("/movies?#{form_params}")

    # alternative way to load movies with filter params
    $.ajax
      type: 'GET',
      data: form_params,
      url: $('.movies-container').data('js-url'),
      dataType : 'script',
      success: (data, status, xhr)->
        history.replaceState(null, null, "/movies?#{form_params}");

  $(window).bind "popstate", ->
    $.getScript(location.href)
