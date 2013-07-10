#= require FileSaver
#= require BlobBuilder
#= require jspdf
#= require jspdf.plugin.standard_fonts_metrics
#= require jspdf.plugin.split_text_to_size

class Batch
  constructor: (data, stages) ->
    for own key, value of data
      this[key] = value
    @initialStage = ko.observable _.findWhere(stages, id: @stage)
    @stage = ko.observable @initialStage()

    @changed = ko.computed =>
      @stage() isnt @initialStage()

class Stage
  constructor: (data, vm) ->
    for own key, value of data
      this[key] = value
    @id = data.id
    @title = data.title
    @field = data.field

    @currentBatches = ko.computed =>
      _.filter vm.batches(), (b) =>
        b.stage() is this and b[@field] is vm.weekNumber

    @overdueBatches = ko.computed =>
      _.filter vm.batches(), (b) =>
        b.stage() is this and b[@field] < vm.weekNumber

    @completedBatches = ko.computed =>
      _.filter vm.batches(), (b) =>
        b.stage() is this.next() and (b.initialStage() is this or b[@field] is vm.weekNumber)

    @totalBatches = ko.computed =>
      @currentBatches().length + @overdueBatches().length + @completedBatches().length

    @next = ko.computed =>
      index = vm.stages().indexOf(this)
      vm.stages()[index + 1]

class ViewModel
  constructor: (batches, stages, weekNumber) ->
    @weekNumber = weekNumber
    @year = moment().year()
    @batches = ko.observableArray()
    @stages = ko.observableArray()
    @stages(_.map(stages, (data) => new Stage(data, this)))
    @batches(_.map(batches, (data) => new Batch(data, @stages())))

    @includeOverdue = ko.observable false
    @includeCompleted = ko.observable false

    @changes = ko.computed =>
      _.some @batches(), (b) -> b.changed()
    @saving = ko.observable false

  save: =>
    if not @saving()
      @saving true
      values = _.chain(@batches())
        .filter((b) -> b.changed())
        .map((b) -> [b.id, b.stage().id])
        .object()
        .value()

      success = =>
        _.each @batches(), (b) -> b.initialStage(b.stage())
        @saving(false)

      $.ajax
        url: '/reports/update',
        type: 'POST',
        success: success,
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify(values: values),
        processData: false

  printTasks: =>
    # A4 dimensions (in mm) 210 × 297
    ptsInMm = 72 / 25.4
    pageWidth = 210
    pageHeight = 297
    margin = 10

    doc = new jsPDF()

    textWidth = (text) ->
      size = doc.internal.getFontSize()
      doc.getStringUnitWidth(text, {fontName:'Times', fontStyle:'Roman'}) * size
    centreText = (text, y) ->
      width = (textWidth text) / ptsInMm
      doc.text((pageWidth - width) / 2, y, text)
    rightText = (text, y, rightX) ->
      width = (textWidth text) / ptsInMm
      doc.text(pageWidth - width - rightX, y, text)

    # Add left and right aligned headings
    doc.setFontSize 8
    doc.text margin, margin, 'Cultivate London'
    doc.text margin, margin + 5, 'Growing Database'

    rightText 'Task Report', margin, margin
    rightText _.template('For week <%= weekNumber %> (starting <%= weekStart %>)', {
      weekNumber: @weekNumber,
      weekStart: moment().year(@year).week(@weekNumber).startOf('week').format('Do MMMM')
    }), margin + 5, margin
    rightText 'Printed ' + moment().format('Do MMMM'), margin + 10, margin

    #Add larger centered heading
    doc.setFontSize 20
    centreText 'To Do on Week ' + @weekNumber, margin + 20
    doc.setLineWidth 0.3
    doc.line margin, margin + 23, pageWidth - margin, margin + 23

    doc.save(_.template('Task List <%= date %>.pdf', {date: moment().format('YYYY-MM-DD')}))

  cancelEdit: =>
    _.each @batches(), (b) -> b.stage(b.initialStage())

window.loadReports = (batches, stages, weekNumber) ->
  vm = new ViewModel(batches, stages, weekNumber)
  ko.applyBindings vm
