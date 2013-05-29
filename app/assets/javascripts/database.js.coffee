#= require knockout
#= require ko.editables
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

class Batch
  constructor: (data, year) ->
    this.id = ko.observable(data.id)

    for key in ['generation', 'total_trays', 'units_per_tray']
      this[key] = ko.observable(data[key]).extend(required: true, digit: true, min: 1)
    for key in ['start_week', 'germinate_week', 'pot_week', 'sale_week', 'expiry_week']
      this[key] = ko.observable(data[key]).extend(required: true, min: 1, max: 53, digit: true)
    for key in ['site', 'category', 'crop', 'type', 'size']
      this[key + '_name'] = ko.observable(if data[key] then data[key].name else undefined).extend(required: true)

    @cell_size = ko.computed((->
        cell = @total_trays() * @units_per_tray()
        if isNaN cell then '' else cell
      ), this)

    if year?
      @year = year

    @saving = ko.observable(false);

    ko.editable(this)

  format_week: (week) ->
    'W' + week

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
  constructor: (rawData, year) ->
    @data = ko.observableArray(ko.validatedObservable(new Batch(b)) for b in rawData)
    @editing = ko.observable()
    @year = year

  edit: (batch) =>
    if(!@editing())
      batch.beginEdit()
      @editing(batch)

  cancel_edit: =>
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

  add_new: ->
    if(!@editing())
      b = ko.validatedObservable(new Batch({}, @year))
      @data.unshift(b)
      b().beginEdit()
      @editing(b())

  destroy: (batch) =>
    if @editing() is batch
      @editing(undefined)
    batch.destroy(=> @data.remove((item) -> item() is batch))

window.loadDatabaseData = (databaseData, year) ->
  vm = new ViewModel(databaseData, year)
  ko.applyBindings(vm)

$ ->
  $('#year-picker').change ->
    window.location = '/database/' + $(this).val()
