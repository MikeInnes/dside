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

class Matrix
  data: []
  constructor: (@data) ->

  height: -> @data.length
  width: -> @data[0]?.length || 0
  length: -> @width() * @height()

  get: (i, j) -> @data[i][j]
  row: (i) -> @data[i]
  col: (i) -> @data[i][j] for j in [1..@height()]

  topLeft: -> @data[0][0]
  bottomRight: -> @data.last().last()

  pushRow: (row) -> @data.push(row)
  pushCol: (col) -> @row(i).push(col[i]) for i in [0...@height()]
  unshiftRow: (row) -> @data.unshift(row)
  unshiftCol: (col) -> @row(i).unshift(col[i]) for i in [0...@height()]

  popRow: -> @data.pop()
  popCol: -> row.pop() for row in @data
  shiftRow: -> @data.shift()
  shiftCol: -> row.shift() for row in @data

  forEach: (f) -> f(val) for val in row for row in @data

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

  # Pooling
  oldPanels: []
  rmPanel: (p) ->
    p.view.style.visibility = 'hidden'
    @oldPanels.push(p)
  getPanel: (range) ->
    if @oldPanels.length == 0
      p = new TablePanel @, basicTable, range
      @view.appendChild p.view
      # TODO: variable cell sizes
      p.size = x: p.view.clientWidth, y: p.view.clientHeight
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
    @panels = new Matrix [[p]]
    @container.appendChild p.view
    @refreshPanels()

  refreshPanels: ->
    @extendRight()
    @extendLower()
    @trim()
    @reposition()

  reposition: -> @panels.forEach (p) -> p.refreshPosition()

  extendRight: ->
    while @panels.bottomRight().position.x + @panels.bottomRight().size.x < @offset.x + @size.x + 50
      for row in @panels.data
        last = row[row.length-1]
        p = @getPanel
          top: last.range.top
          bottom: last.range.bottom
          left: last.range.right + 1
          right: last.range.right + @chunkWidth
        p.setPosition
          y: last.position.y
          x: last.position.x + last.size.x
        row.push p

  extendLower: ->
    while @panels.bottomRight().position.y + @panels.bottomRight().size.y < @offset.y + @size.y + 50
      row = []
      for last in @panels.data[@panels.data.length-1]
        p = @getPanel
          top:    last.range.bottom + 1
          bottom: last.range.bottom + @chunkHeight
          left:   last.range.left
          right:  last.range.right
        p.setPosition
          y: last.position.y + last.size.y
          x: last.position.x
        row.push p
      @panels.data.push row

  trim: ->
    # Top Row
    while @offset.y > @panels.topLeft().position.y + @panels.topLeft().size.y
      ps = @panels.data.shift()
      @rmPanel p for p in ps
    # Left Column
    while @offset.x > @panels.topLeft().position.x + @panels.topLeft().size.x
      for row in @panels.data
        p = row.shift()
        @rmPanel p
    # Bottom Row
    while @offset.y + @size.y < @panels.bottomRight().position.y
      ps = @panels.data.pop()
      @rmPanel p for p in ps
    # Right Column
    while @offset.x + @size.x < @panels.bottomRight().position.x
      for row in @panels.data
        p = row.pop()
        @rmPanel p

  offset: x: 0, y: 0
  scroll: (e) ->
    e.preventDefault()
    @offset.x += e.deltaX
    @offset.y += e.deltaY
    requestAnimationFrame => @refreshPanels()

  # Size calculations

basicTable =
  getCell: (row, col) ->
    "#{row}:#{col}"
