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
  constructor: (data) ->
    for key in ['id', 'generation', 'start_week', 'germinate_week', 'pot_week', 'sale_week', 'expiry_week', 'total_trays', 'units_per_tray']
      this[key] = ko.observable(data[key])
    for key in ['site', 'category', 'crop', 'type', 'size']
      this[key + '_name'] = ko.observable(if data[key] then data[key].name else undefined)

    @cell_size = ko.computed((->
        cell = @total_trays() * @units_per_tray()
        if isNaN cell then '' else cell
      ), this)

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

class ViewModel
  constructor: (rawData) ->
    @data = ko.observableArray(new Batch(b) for b in rawData)
    @editing = ko.observable()

  edit: (batch) ->
    if(!@editing())
      batch.beginEdit()
      @editing(batch)

  cancel_edit: ->
    e = @editing()
    if(!e.id())
      @data.remove(e)
    else
      e.rollback()
    @editing(undefined)

  save: ->
    @editing().commit()
    @editing().save()
    @editing(undefined)

  add_new: ->
    if(!@editing())
      b = new Batch({})
      @data.unshift(b)
      @editing(b)

$ ->
  if databaseData?
    vm = new ViewModel(databaseData)
    ko.applyBindings(vm)
