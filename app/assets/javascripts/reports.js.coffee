getValues = (section) ->
  values = {}
  section
    .find('select[data-batch-id]')
    .each(() -> values[$(this).data('batch-id')] = $(this).val())
  values

$ ->
  $('button.update-report').click(() ->
    btn = $ this
    if not btn.hasClass 'depressed'
      section = btn.closest('.report-section')
      stage = section.data('stage')
      data =
        values: getValues section
      url = '/reports/update/' + stage

      btn.addClass 'depressed'

      $.ajax(
        url: url,
        type: 'POST',
        success: () -> btn.removeClass 'depressed',
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify(data),
        processData: false
      )
  )
