#= require FileSaver
#= require BlobBuilder
#= require jspdf
#= require jspdf.plugin.standard_fonts_metrics
#= require jspdf.plugin.split_text_to_size

# A4 dimensions (in mm) 210 × 297
util =
  ptsInMm: (72 / 25.4)
  pageWidth: 210
  pageHeight: 297
  margin: 10
  batchBoxHeight: 10
  textColour: { r: 0, g: 0, b: 0 }
  overdueColour: { r: 128, g: 0, b: 27 }
  completedColour: { r: 87, g: 128, b: 0 }
  setColour: (colour, doc) ->
    doc.setTextColor(colour.r, colour.g, colour.b);
  textWidth: (text, doc) ->
    size = doc.internal.getFontSize()
    doc.getStringUnitWidth(text, {fontName:'Times', fontStyle:'Roman'}) * size
  centreText: (text, y, doc) ->
    width = (util.textWidth text, doc) / util.ptsInMm
    doc.text((util.pageWidth - width) / 2, y, text)
  rightText: (text, y, rightX, doc) ->
    width = (util.textWidth text, doc) / util.ptsInMm
    doc.text(util.pageWidth - width - rightX, y, text)
  drawBox: (lineWidth, x1, y1, x2, y2, doc) ->
    doc.setLineWidth lineWidth
    # Extend the vertical lines a little so we don't see the joins at the corners.
    y1 -= lineWidth
    y2 += lineWidth
    doc.line x1, y1, x2, y1
    doc.line x2, y1, x2, y2
    doc.line x2, y2, x1, y2
    doc.line x1, y2, x1, y1
  possiblyAddPage: (testHeight, y, doc) ->
    if y + testHeight > util.pageHeight - util.margin
      doc.addPage()
      util.margin
    else
      y
  addStage: (stage, y, vm, doc) ->
    y = util.possiblyAddPage 43, y, doc

    doc.setFontSize 14
    doc.text util.margin, y, stage.title
    y += 7

    batchCount = stage.currentBatches() +
      (if vm.includeOverdue() then stage.overdueBatches().length else 0) +
      (if vm.includeCompleted() then stage.completedBatches().length else 0)

    if batchCount > 0
      y = util.addBatches 'Current tasks', y, stage.currentBatches(), util.textColour, doc
      if vm.includeOverdue()
        y = util.addBatches 'Overdue tasks', y, stage.overdueBatches(), util.overdueColour, doc
      if vm.includeCompleted()
        y = util.addBatches 'Completed tasks', y, stage.completedBatches(), util.completedColour, doc
    else
      doc.setFontSize 12
      doc.text util.margin + 5, y, 'No batches'
      y += 13
    y
  addBatches: (title, y, batches, titleColour, doc) ->
    if batches.length > 0
      y = util.possiblyAddPage 35, y, doc
      doc.setFontSize 12
      util.setColour titleColour, doc
      doc.text util.margin + 5, y, title
      util.setColour util.textColour, doc
      y += 3
      for b in batches
        y = util.addBatch b, y, doc
      y += 5
    y
  addBatch: (batch, y, doc) ->
    y = util.possiblyAddPage util.batchBoxHeight, y, doc
    tickBoxSize = 6
    tickBoxPadding = (util.batchBoxHeight - tickBoxSize) / 2
    leftEdge = util.margin + 10
    rightEdge = util.pageWidth - util.margin
    textFontSize = 10

    util.drawBox 0.3, leftEdge, y, rightEdge, y + util.batchBoxHeight, doc
    util.drawBox 0.3, rightEdge - tickBoxSize - tickBoxPadding, y + tickBoxPadding, rightEdge - tickBoxPadding, y + tickBoxSize + tickBoxPadding, doc

    doc.setFontSize textFontSize
    text = "Site #{batch.site.name}, #{batch.crop.name}, #{batch.type.name}, Generation #{batch.generation}, #{batch.size.name}, Cell size: #{batch.cell_size()}"
    fontHeight = textFontSize / util.ptsInMm
    doc.text leftEdge + 2, y + fontHeight + (util.batchBoxHeight - fontHeight) / 2, text
    y += util.batchBoxHeight + 3
    y

class Batch
  constructor: (data, stages) ->
    for own key, value of data
      this[key] = value
    @initialStage = ko.observable _.findWhere(stages, id: @stage)
    @stage = ko.observable @initialStage()

    @cell_size = ko.computed((->
        cell = @total_trays * @units_per_tray
        if isNaN cell then '' else cell
      ), this)

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

    @displayedBatchCount = ko.computed =>
      return _.reduce _.map(_.initial(@stages()), (s) -> s.totalBatches()),
        (memo, num) -> memo + num

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
    doc = new jsPDF()

    # Add left and right aligned headings
    doc.setFontSize 8
    doc.text util.margin, util.margin, 'Cultivate London'
    doc.text util.margin, util.margin + 5, 'Growing Database'

    util.rightText 'Task Report', util.margin, util.margin, doc
    util.rightText _.template('For week <%= weekNumber %> (starting <%= weekStart %>)', {
      weekNumber: @weekNumber,
      weekStart: moment().year(@year).week(@weekNumber).startOf('week').format('Do MMMM')
    }), util.margin + 5, util.margin, doc
    util.rightText 'Printed ' + moment().format('Do MMMM'), util.margin + 10, util.margin, doc

    #Add larger centered heading
    doc.setFontSize 20
    util.centreText 'To Do on Week ' + @weekNumber, util.margin + 20, doc
    doc.setLineWidth 0.3
    doc.line util.margin, util.margin + 23, util.pageWidth - util.margin, util.margin + 23

    currentY = util.margin + 33
    for s in @stages()
      currentY = util.addStage s, currentY, this, doc

    doc.save(_.template('Task List <%= date %>.pdf', {date: moment().format('YYYY-MM-DD')}))

  cancelEdit: =>
    _.each @batches(), (b) -> b.stage(b.initialStage())

window.loadReports = (batches, stages, weekNumber) ->
  vm = new ViewModel(batches, stages, weekNumber)
  ko.applyBindings vm
