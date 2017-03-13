$ ->
  $(document).on 'submit', 'form#movies-menu', (e)->
    e.preventDefault()
    e.stopPropagation()
    form_params = $(this).serialize()

    # simple way to use a filter
    # Turbolinks.visit("/movies?#{form_params}")

    # alternative way to load movies with filter params
    $.ajax
      type: 'GET',
      data: form_params,
      url: $('.movies-container').data('js-url'),
      dataType : 'script'
    history.replaceState('', '', "/movies?#{form_params}");

