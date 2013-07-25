c = (tagName, cls) ->
  $("<#{tagName}></#{tagName}>").addClass(cls)

contains = (text, searchString) ->
  text.toLowerCase().indexOf searchString.toLowerCase()

getLi = (res, searchString) ->
  li = c('li')
  if searchString and searchString.length > 0
    if res.index > 0
      li.append c('span').text res.text.substr(0, res.index)
    li.append c('span', 'highlight').text res.text.substr(res.index, searchString.length)
    li.append c('span').text res.text.substr(res.index + searchString.length)
  else
    li.text res.text
  li

ko.bindingHandlers.autocomplete =
  init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
    values = valueAccessor()
    visible = ko.observable()
    search = ko.observable()
    resultsDisplay = c('div', 'autocomplete-results')
    results = ko.computed ->
      searchString = search()
      if not searchString
        _.map(values, (v) -> text: v)
      else
        _.chain(values)
          .map((val) ->
            index: contains(val, searchString)
            text: val
          )
          .filter((v) -> v.index >= 0)
          .sortBy('text')
          .sortBy('index')
          .value()


    results.subscribe (r) ->
      if r.length > 0
        searchString = search()
        ul = c('ul').append(
          _.map r, (res) ->
            getLi(res, searchString)
              .click ->
                allBindingsAccessor().value(res.text)
                visible false
        )
        resultsDisplay.html ul
      else
        resultsDisplay.html c('div', 'no-results').text('No results')

    visible.subscribe (newValue) ->
      resultsDisplay.toggle newValue

    resultsDisplay.insertAfter element
    visible false
    search(allBindingsAccessor().value())
    onchange = ->
      search($(element).val())
      visible true
    $(element).keyup(onchange).change(onchange)

    # Close the list when clicking elsewhere
    $(document).click -> visible false

    # Get rid of the results display when the main element is removed
    ko.utils.domNodeDisposal.addDisposeCallback element, ->
      $(element).remove()
