class Batch
  constructor: (data) ->
    @id = ko.observable(data.id)
    @site_name = ko.observable(data.site.name)
    @category_name = ko.observable(data.category.name)
    @crop_name = ko.observable(data.crop.name)
    @type_name = ko.observable(data.type.name)
    @size_name = ko.observable(data.size.name)
    @generation = ko.observable(data.generation)

    @start_week = ko.observable(data.start_week)
    @germinate_week = ko.observable(data.germinate_week)
    @pot_week = ko.observable(data.pot_week)
    @sale_week = ko.observable(data.sale_week)
    @expiry_week = ko.observable(data.expiry_week)

    @total_trays = ko.observable(data.total_trays)
    @units_per_tray = ko.observable(data.units_per_tray)
    @cell_size = ko.computed((-> @total_trays() * @units_per_tray()), this)

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
    @data = ko.observable(new Batch(b) for b in rawData)
    @editing = ko.observable()

  edit: (batch) ->
    if(!@editing())
      batch.beginEdit()
      @editing(batch)

  cancel_edit: ->
    @editing().rollback()
    @editing(undefined)

  save: ->
    @editing().commit()
    @editing().save()
    @editing(undefined)

$ ->
  if databaseData?
    vm = new ViewModel(databaseData)
    ko.applyBindings(vm)
