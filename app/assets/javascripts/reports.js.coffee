#= require FileSaver
#= require BlobBuilder
#= require jspdf

$ ->
  $('#print-tasks').click ->
    doc = new jsPDF()
    doc.text(20, 20, 'Hello world!')
    doc.text(20, 30, 'This is client-side Javascript, pumping out a PDF.')
    doc.addPage()
    doc.text(20, 20, 'Do you like that?')

    doc.save('Test.pdf')

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
    @batches = ko.observableArray()
    @stages = ko.observableArray()
    @stages(_.map(stages, (data) => new Stage(data, this)))
    @batches(_.map(batches, (data) => new Batch(data, @stages())))

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

  cancelEdit: =>
    _.each @batches(), (b) -> b.stage(b.initialStage())

window.loadReports = (batches, stages, weekNumber) ->
  vm = new ViewModel(batches, stages, weekNumber)
  ko.applyBindings vm
