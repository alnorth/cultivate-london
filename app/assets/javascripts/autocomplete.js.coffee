#= require jquery.scrollTo

c = (tagName, cls) ->
  $("<#{tagName}></#{tagName}>").addClass(cls)

contains = (text, searchString) ->
  text.toLowerCase().indexOf searchString.toLowerCase()

# From http://stackoverflow.com/questions/9796764/how-do-i-sort-an-array-with-coffeescript
sortBy = (key, a, b, r) ->
  r = if r then 1 else -1
  return -1*r if a[key] > b[key]
  return +1*r if a[key] < b[key]
  return 0

getLi = (res, searchString, isSelected, selectFn) ->
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
  li.click -> selectFn(res.text)

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
        (text: v for v in values)
      else
        filtered = (index: contains(val, searchString), text: val for val in values when contains(val, searchString) >= 0)
        filtered.sort (a,b) -> (sortBy 'index', a, b) or (sortBy 'text', a, b)

    displayedHtml = ko.computed ->
      if visible()
        r = results()
        if r.length > 0
          searchString = search()
          lis = (getLi(res, searchString, selectedIndex() is index, select) for res, index in r)
          c('ul').append lis
        else
          c('div', 'no-results').text('No results')

    displayedHtml.subscribe (newValue) ->
      resultsDisplay.html newValue
      selected = resultsDisplay.find('li.selected')
      if selected.length > 0
        resultsDisplay.scrollTo(resultsDisplay.find('li.selected'))

    visible.subscribe (newValue) ->
      resultsDisplay.toggle newValue

    resultsDisplay.insertAfter element
    visible false
    search(allBindingsAccessor().value())

    onchange = ->
      search($(element).val())
      visible true
      selectedIndex 0
    onkeydown = (event) ->
      # Tab events on key up actually get sent to the *next* input
      # element - the one you're moving to. So we detect on key down.
      if event.keyCode is 9
        select results()[selectedIndex()].text
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
      .keydown(onkeydown)
      .keyup(onkeyup)

    allBindingsAccessor().value.subscribe onchange

    # Close the list when clicking elsewhere
    $(document).click -> visible false

    # Close the list when clicking in the modal container around the autocomplete
    $(element).closest('.modal-content').click -> visible false

    # Get rid of the results display when the main element is removed
    ko.utils.domNodeDisposal.addDisposeCallback element, ->
      $(element).remove()
