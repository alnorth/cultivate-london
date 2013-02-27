$ ->
  class Batch
    constructor: (data) ->
      @id = data.id
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

    format_week: (week) ->
      'W' + week

  class ViewModel
    constructor: (rawData) ->
      @data = ko.observable(new Batch(b) for b in rawData);

  if databaseData?
    vm = new ViewModel(databaseData);
    ko.applyBindings(vm);

