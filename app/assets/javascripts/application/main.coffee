document.addEventListener 'turbolinks:before-cache',  ->
  $('.selectpicker').selectpicker('destroy').addClass('selectpicker')

document.addEventListener 'turbolinks:load',  ->
  $('.selectpicker').selectpicker()