#= require knockout.validation
#= require autocomplete

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

class Batch
  constructor: (data, stages, year) ->
    this.id = ko.observable(data.id)

    for key in ['generation', 'total_trays', 'units_per_tray']
      this[key] = ko.observable(data[key]).extend(required: true, digit: true, min: 1)
    for key in ['site', 'category', 'crop', 'type', 'size']
      value = undefined
      if _.isObject(data[key])
        value = data[key].name
      else if _.isString(data[key + '_name'])
        value = data[key + '_name']
      this[key + '_name'] = ko.observable(value).extend(required: true)

    @start_week = ko.observable(data.start_week ? 1).extend(required: true, min: 1, max: 53, digit: true)
    @weeks_to_germinate = @getGapObservable data, 'start_week', 'germinate_week'
    @weeks_to_pot = @getGapObservable data, 'germinate_week', 'pot_week'
    @weeks_to_sale = @getGapObservable data, 'pot_week', 'sale_week'
    @weeks_to_expiry = @getGapObservable data, 'sale_week', 'expiry_week'

    @germinate_week = @getWeekComputed @start_week, @weeks_to_germinate
    @pot_week = @getWeekComputed @germinate_week, @weeks_to_pot
    @sale_week = @getWeekComputed @pot_week, @weeks_to_sale
    @expiry_week = @getWeekComputed(@sale_week, @weeks_to_expiry).extend(required: true, min: 1, max: 53, digit: true)
    
    loadedStage = _.findWhere(stages, { id: data.stage })
    this.stage = ko.observable(loadedStage ? stages[0])

    @cell_size = ko.computed((->
        cell = @total_trays() * @units_per_tray()
        if isNaN cell then 0 else cell
      ), this)

    if data.year?
      @year = data.year
    else if year?
      @year = year

    @saving = ko.observable(false)
    
    ko.editable(this)

  getWeekComputed: (start, gap) ->
    ko.computed () => parseInt(start(), 10) + parseInt(gap(), 10)

  getGapObservable: (data, start, end) ->
    gap = if data[start]? then parseInt(data[end], 10) - parseInt(data[start], 10) else 1
    ko.observable(gap).extend(required: true, min: 1, max: 53, digit: true)

  formatWeek: (week) ->
    'W' + week

  toJSON: ->
    copy = ko.toJS(this)
    if copy.stage?
      copy.stage = copy.stage.id
    copy

  getNextGeneration: ->
    stage = @stage()
    json = @toJSON()
    copy = new Batch(json, [stage], @year) # Only need the one stage in the array, as this is the one that would be picked anyway
    copy.id(undefined)
    copy.generation(parseInt(@generation(), 10) + 1)
    copy.start_week(parseInt(@start_week(), 10) + 1)
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
    @displayedData = ko.computed => b for b in @data() when !!b().id()
    @editing = ko.observable()
    @year = year

  edit: (batch) =>
    if(!@editing())
      batch.beginEdit()
      @editing(batch)

  cancelEdit: =>
    e = @editing()
    if(!e.id())
      @destroy e
    else
      e.rollback()
    @editing(undefined)

  save: =>
    e = @editing()
    if e.isValid()
      e.commit()
      e.save()
      @editing(undefined)
    else
      e.errors.showAllMessages()

  saveAndAdd: =>
    e = @editing()
    @save()
    @addNew(ko.validatedObservable(e.getNextGeneration()))

  addNew: (b) =>
    if(!@editing())
      b = if ko.isObservable(b) then b else ko.validatedObservable(new Batch({}, @stages, @year))
      @data.unshift(b)
      b().beginEdit()
      @editing(b())

  destroy: (batch) =>
    if @editing() is batch
      @editing(undefined)
    batch.destroy(=> @data.remove((item) -> item() is batch))

window.loadDatabaseData = (databaseData, staticData, year) ->
  vm = new ViewModel(databaseData, staticData, year)
  ko.applyBindings(vm)

  $(window).bind 'beforeunload', ->
    if vm.editing()
      'You haven\'t saved the batch you were editing.'

$ ->
  $('#year-picker').change ->
    window.location = '/database/' + $(this).val()
