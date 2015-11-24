window.onload = ->
  new GridView x for x in document.querySelectorAll ".table"

isString = (x) -> x.constructor == String
isArray = (x) -> x.constructor == Array

Array.prototype.last = -> @[@.length-1]

callback = (t, f) -> setTimeout f, t

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
  col: (j) -> @data[i][j] for i in [0...@height()]

  firstRow: -> @row 0
  firstCol: -> @col 0
  lastRow: -> @row @height()-1
  lastCol: -> @col @width()-1

  topLeft: -> @data[0][0]
  bottomRight: -> @data.last().last()

  pushRow: (row) -> @data.push(row)
  pushCol: (col) -> @row(i).push col[i] for i in [0...@height()]
  unshiftRow: (row) -> @data.unshift row
  unshiftCol: (col) -> @row(i).unshift col[i] for i in [0...@height()]

  popRow: -> @data.pop()
  popCol: -> row.pop() for row in @data
  shiftRow: -> @data.shift()
  shiftCol: -> row.shift() for row in @data

  forEach: (f) -> f(val) for val in row for row in @data

class GridPanel
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

class GridView
  chunkSize: x: 8, y: 8

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
      p = new GridPanel @, basicTable, range
      @container.appendChild p.view
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
      bottom: @chunkSize.y
      right: @chunkSize.x
    @panels = new Matrix [[p]]
    @panelCycle()

  reposition: -> @panels.forEach (p) -> p.refreshPosition()

  panelCycle: ->
    if @extendLower()
      @trimUpper()
    else if @extendUpper()
      @trimLower()
    callback 0.1, =>
      if @extendLeft()
        @trimRight()
      else if @extendRight()
        @trimLeft()
      callback 0.1, =>
        @panelCycle()

  extendUpper: ->
    if @panels.topLeft().position.y > @offset.y
      row = for last in @panels.firstRow()
        p = @getPanel
          top:    last.range.top - @chunkSize.y
          bottom: last.range.top - 1
          left:   last.range.left
          right:  last.range.right
        p.setPosition
          x: last.position.x
          y: last.position.y - p.size.y
        p
      @panels.unshiftRow row
      return true
    else
      return false

  extendLeft: ->
    if @panels.topLeft().position.x > @offset.x
      col = for last in @panels.firstCol()
        p = @getPanel
          top: last.range.top
          bottom: last.range.bottom
          left: last.range.left - @chunkSize.x
          right: last.range.left - 1
        p.setPosition
          x: last.position.x - p.size.x
          y: last.position.y
        p
      @panels.unshiftCol col
      return true
    else
      return false

  extendLower: ->
    if @panels.bottomRight().position.y + @panels.bottomRight().size.y < @offset.y + @size.y/@zoom
      row = for last in @panels.lastRow()
        p = @getPanel
          top:    last.range.bottom + 1
          bottom: last.range.bottom + @chunkSize.y
          left:   last.range.left
          right:  last.range.right
        p.setPosition
          x: last.position.x
          y: last.position.y + last.size.y
        p
      @panels.pushRow row
      return true
    else
      return false

  extendRight: ->
    if @panels.bottomRight().position.x + @panels.bottomRight().size.x < @offset.x + @size.x/@zoom
      col = for last in @panels.lastCol()
        p = @getPanel
          top: last.range.top
          bottom: last.range.bottom
          left: last.range.right + 1
          right: last.range.right + @chunkSize.x
        p.setPosition
          x: last.position.x + last.size.x
          y: last.position.y
        p
      @panels.pushCol col
      return true
    else
      return false

  trimUpper: ->
    if @offset.y > @panels.topLeft().position.y + @panels.topLeft().size.y
      ps = @panels.shiftRow()
      @rmPanel p for p in ps
    return

  trimLeft: ->
    if @offset.x > @panels.topLeft().position.x + @panels.topLeft().size.x
      ps = @panels.shiftCol()
      @rmPanel p for p in ps
    return

  trimLower: ->
    if @offset.y + @size.y/@zoom < @panels.bottomRight().position.y
      ps = @panels.popRow()
      @rmPanel p for p in ps
    return

  trimRight: ->
    if @offset.x + @size.x/@zoom < @panels.bottomRight().position.x
      ps = @panels.popCol()
      @rmPanel p for p in ps
    return

  refreshZoom: ->
    zoom = Math.exp @zoomFactor/1000
    # TODO: keep cursor position
    @container.style.transform = "scale(#{zoom})"
    @zoom = zoom

  zoomFactor: 0
  zoom: 1
  offset: x: 0, y: 0

  scroll: (e) ->
    e.preventDefault()
    if e.ctrlKey
      @zoomFactor -= e.deltaY
      requestAnimationFrame => @refreshZoom()
    else
      @offset.x += e.deltaX/@zoom
      @offset.y += e.deltaY/@zoom
      requestAnimationFrame => @reposition()

basicTable =
  getCell: (row, col) ->
    "#{row}:#{col}"
