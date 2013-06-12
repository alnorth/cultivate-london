#= require FileSaver
#= require BlobBuilder
#= require jspdf

getValues = (section) ->
  values = {}
  section
    .find('select[data-batch-id]')
    .each(() -> values[$(this).data('batch-id')] = $(this).val())
  values

$ ->
  $('button.update-report').click ->
    btn = $ this
    if not btn.hasClass 'depressed'
      section = btn.closest('.report-section')
      stage = section.data('stage')
      data =
        values: getValues section
      url = '/reports/update/' + stage

      btn.addClass 'depressed'

      $.ajax
        url: url,
        type: 'POST',
        success: () -> btn.removeClass 'depressed',
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify(data),
        processData: false

  $('#print-tasks').click ->
    doc = new jsPDF()
    doc.text(20, 20, 'Hello world!')
    doc.text(20, 30, 'This is client-side Javascript, pumping out a PDF.')
    doc.addPage()
    doc.text(20, 20, 'Do you like that?')

    doc.save('Test.pdf')
