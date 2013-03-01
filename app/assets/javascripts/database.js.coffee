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
    $.postJSON('/batch/save', {batch: ko.toJS(this)}, (json) ->
      self.saving(false)
      self.id(json.id)
    )

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
