window.onload = ->
  new TableView x for x in document.querySelectorAll ".table"

isString = (x) -> x.constructor == String
isArray = (x) -> x.constructor == Array

Array.prototype.last = -> @[@.length-1]

parseHTML = (x) ->
  if isString x
    div = document.createElement 'div'
    div.innerHTML = x
    div
  else
    x

div = (xs...) ->
  d = document.createElement 'div'
  d.appendChild parseHTML x for x in xs
  d

class TablePanel
  constructor: (@table, @data, @range) ->
    @createView @range
    @refresh @range

  createView: ({top, bottom, left, right}) ->
    @cellViews = (div() for cell in [top..bottom] for row in [left..right])
    @view = div (div cells... for cells in @cellViews)...
    @view.classList.add 'table-panel'
    for rowv in @view.children
      rowv.classList.add 'row'
      for cellv in rowv.children
        cellv.classList.add 'cell'

  refresh: (range) ->
    if range? then @range = range
    for row in [0...@cellViews.length]
      for col in [0...@cellViews[0].length]
        @cellViews[row][col].innerText =
          @data.getCell range.top+row, range.left + col
    @

  position: x: 0, y: 0

  setPosition: ({x, y}) ->
    @position = {x, y}
    @refreshPosition()

  refreshPosition: ->
    @view.style.transform = "translate3d(#{@position.x-@table.offset.x}px,
                                         #{@position.y-@table.offset.y}px,0)"

  getSize: ->
    @size ?= {y: @view.clientHeight, x: @view.clientWidth}

class TableView
  chunkWidth: 8
  chunkHeight: 8

  constructor: (@view) ->
    @container = document.createElement 'div'
    @container.classList.add 'table-container'
    @view.appendChild @container
    @view.addEventListener "mousewheel", (e) => @scroll e
    @size = x: @view.clientWidth, y: @view.clientHeight
    @initPanels()

  # 2D array of visible panels
  panels: [[]]

  # Pooling
  oldPanels: []
  rmPanel: (p) ->
    p.view.style.visibility = 'hidden'
    @oldPanels.push(p)
  getPanel: (range) ->
    if @oldPanels.length == 0
      p = new TablePanel @, basicTable, range
      @view.appendChild p.view
      p
    else
      p = @oldPanels.shift()
      p.view.style.visibility = null
      p.refresh range

  initPanels: ->
    p = @getPanel
      top: 1
      left: 1
      bottom: @chunkHeight
      right: @chunkWidth
    @panels[0].push p
    @container.appendChild p.view
    @refreshPanels()

  refreshPanels: ->
    @extendRight()
    @extendLower()
    @trim()
    @reposition()

  reposition: ->
    for row in @panels
      for p in row
        p.refreshPosition()

  extendRight: ->
    while @rightBound() < @size.x + 50
      for row in @panels
        last = row[row.length-1]
        p = @getPanel
          top: last.range.top
          bottom: last.range.bottom
          left: last.range.right + 1
          right: last.range.right + @chunkWidth
        p.setPosition
          y: last.position.y
          x: last.position.x + last.getSize().x
        row.push p

  extendLower: ->
    while @lowerBound() < @size.y + 50
      row = []
      for last in @panels[@panels.length-1]
        p = @getPanel
          top:    last.range.bottom + 1
          bottom: last.range.bottom + @chunkHeight
          left:   last.range.left
          right:  last.range.right
        p.setPosition
          y: last.position.y + last.getSize().y
          x: last.position.x
        row.push p
      @panels.push row

  trim: ->
    # Top Row
    while @offset.y > @panels[0][0].position.y + @panels[0][0].getSize().y
      ps = @panels.shift()
      @rmPanel p for p in ps
    # Left Column
    while @offset.x > @panels[0][0].position.x + @panels[0][0].getSize().x
      for row in @panels
        p = row.shift()
        @rmPanel p
    # Bottom Row
    while @offset.y + @size.y < @panels.last().last().position.y
      ps = @panels.pop()
      @rmPanel p for p in ps
    # Right Column
    while @offset.x + @size.x < @panels.last().last().position.x
      for row in @panels
        p = row.pop()
        @rmPanel p

  offset: x: 0, y: 0
  scroll: (e) ->
    e.preventDefault()
    @offset.x += e.deltaX
    @offset.y += e.deltaY
    # @size = x: @view.clientWidth, y: @view.clientHeight
    requestAnimationFrame => @refreshPanels()

  # Size calculations

  rightBound: ->
    r = @panels[0][0].position.x - @offset.x
    for p in @panels[0]
      r += p.getSize().x
    r

  lowerBound: ->
    r = @panels[0][0].position.y - @offset.y
    for row in @panels
      r += row[0].getSize().y
    r

basicTable =
  getCell: (row, col) ->
    "#{row}:#{col}"
