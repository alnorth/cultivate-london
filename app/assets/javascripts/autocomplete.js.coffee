c = (tagName, cls) ->
  $("<#{tagName}></#{tagName}>").addClass(cls)

contains = (text, searchString) ->
  text.toLowerCase().indexOf searchString.toLowerCase()

getLi = (res, searchString, isSelected) ->
  li = c('li')
  if isSelected
    li.addClass 'selected'
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
    selectedIndex = ko.observable(0)
    resultsDisplay = c('div', 'autocomplete-results')

    select = (text) ->
      allBindingsAccessor().value(text)
      visible false

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

    displayedHtml = ko.computed ->
      if visible()
        r = results()
        if r.length > 0
          searchString = search()
          lis = _.map r, (res, index) ->
            getLi(res, searchString, selectedIndex() is index)
              .click -> select(res.text)

          c('ul').append lis
        else
          c('div', 'no-results').text('No results')

    displayedHtml.subscribe (newValue) ->
      resultsDisplay.html newValue

    visible.subscribe (newValue) ->
      resultsDisplay.toggle newValue

    resultsDisplay.insertAfter element
    visible false
    search(allBindingsAccessor().value())

    onchange = ->
      search($(element).val())
      visible true
      selectedIndex 0
    onkeyup = (event) ->
      if event.keyCode is 38
        selectedIndex Math.max(0, selectedIndex() - 1)
      else if event.keyCode is 40
        selectedIndex Math.min(results().length - 1, selectedIndex() + 1)
      else if event.keyCode is 13 # Enter
        select results()[selectedIndex()].text
      else if event.keyCode is 27 # Esc
        visible false
      else
        onchange()

    $(element)
      .keyup(onkeyup)

    allBindingsAccessor().value.subscribe onchange

    # Close the list when clicking elsewhere
    $(document).click -> visible false

    # Get rid of the results display when the main element is removed
    ko.utils.domNodeDisposal.addDisposeCallback element, ->
      $(element).remove()
