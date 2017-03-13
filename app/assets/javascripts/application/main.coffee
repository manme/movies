document.addEventListener 'turbolinks:before-cache',  ->
  $('.selectpicker').selectpicker('destroy').addClass('selectpicker')

document.addEventListener 'turbolinks:load',  ->
  $(".selectpicker").selectpicker()
  $('.selectpicker').on 'hidden.bs.select', (e)->
    console.log('select')
