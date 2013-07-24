#= require knockout.validation

send = (url, type, data, success) ->
  $.ajax(
    url: url,
    type: type,
    success: success,
    dataType: "json",
    contentType: "application/json",
    data: JSON.stringify(data),
    processData: false
  )

ko.bindingHandlers.autocomplete =
  init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    values = valueAccessor()
    visible = ko.observable false
    search = ko.observable()
    resultsDisplay = $('<div class="autocomplete-results"></div>')
    results = ko.computed ->
      searchString = search()
      if not searchString
        []
      else if searchString.length is 0
        values
      else
        _.filter values, (val) ->
          val.indexOf(searchString) >= 0

    results.subscribe ->
      r = results()
      if r.length > 0
        ul = $('<ul></ul>').append(
          _.map r, (res) ->
            $('<li></li>')
              .text(res)
              .click -> $(element).val(res)
        )
        resultsDisplay.html ul
      else
        resultsDisplay.html $('<div class="no-results"></div>').text('No results')

    resultsDisplay.insertAfter(element)
    search(allBindingsAccessor().value())
    onchange = -> search($(element).val())
    $(element).keyup(onchange).change(onchange)

class Batch
  constructor: (data, stages, year) ->
    this.id = ko.observable(data.id)

    for key in ['generation', 'total_trays', 'units_per_tray']
      this[key] = ko.observable(data[key]).extend(required: true, digit: true, min: 1)
    for key in ['start_week', 'germinate_week', 'pot_week', 'sale_week', 'expiry_week']
      this[key] = ko.observable(data[key]).extend(required: true, min: 1, max: 53, digit: true)
    for key in ['site', 'category', 'crop', 'type', 'size']
      this[key + '_name'] = ko.observable(if data[key] then data[key].name else undefined).extend(required: true)

    loadedStage = _.findWhere(stages, { id: data.stage })
    this.stage = ko.observable(loadedStage ? stages[0])

    @cell_size = ko.computed((->
        cell = @total_trays() * @units_per_tray()
        if isNaN cell then '' else cell
      ), this)

    if year?
      @year = year

    @saving = ko.observable(false);

    ko.editable(this)

  formatWeek: (week) ->
    'W' + week

  toJSON: ->
    copy = ko.toJS(this)
    if copy.stage?
      copy.stage = copy.stage.id
    copy

  save: ->
    self = this
    @saving(true)
    success = (json) ->
      self.saving(false)
      self.id(json.id)
    data = batch: ko.toJS(this)
    if(self.id())
      send '/batches/' + self.id(), 'PUT', data, success
    else
      send '/batches', 'POST', data, success

  destroy: (success) ->
    @saving(true)
    if this.id()
      send '/batches/' + this.id(), 'DELETE', {}, success
    else
      success()

class ViewModel
  constructor: (rawData, staticData, year) ->
    @stages = staticData.stages
    @sites = staticData.sites
    @categories = staticData.categories
    @crops = staticData.crops
    @types = staticData.types
    @sizes = staticData.sizes
    @data = ko.observableArray(ko.validatedObservable(new Batch(b, @stages)) for b in rawData)
    @editing = ko.observable()
    @year = year

  edit: (batch) =>
    if(!@editing())
      batch.beginEdit()
      @editing(batch)

  cancelEdit: =>
    e = @editing()
    if(!e.id())
      @data.remove(e)
    else
      e.rollback()
    @editing(undefined)

  save: =>
    e = @editing()
    if e.isValid()
      e.commit()
      e.save()
      @editing(undefined)

  addNew: ->
    if(!@editing())
      b = ko.validatedObservable(new Batch({}, @stages, @year))
      @data.unshift(b)
      b().beginEdit()
      @editing(b())

  destroy: (batch) =>
    if @editing() is batch
      @editing(undefined)
    batch.destroy(=> @data.remove((item) -> item() is batch))

window.loadDatabaseData = (databaseData, staticData, year) ->
  vm = new ViewModel(databaseData, staticData, year)
  console.log(staticData)
  ko.applyBindings(vm)

$ ->
  $('#year-picker').change ->
    window.location = '/database/' + $(this).val()
