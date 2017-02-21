class History
  constructor: (size) ->
    @size = size
    @clear()

  addHistory: (item) ->
    if @cur == @stack.length - 1
      @stack.push(item)
      ++@cur
    else if @cur < @stack.length
      @stack.splice ++@cur, 0, item

    if @cur > @size
      --@cur
      @stack.shift()

  moveBack: () ->
    return null if @cur <= 0
    return @stack[--@cur]

  getCurrent: () ->
    return @stack[@cur]

  moveFront: () ->
    return null if @cur >= @stack.length - 1
    return @stack[++@cur]

  clear: () ->
    @stack = []
    @cur = -1
    
module.exports =
class Navigation
  constructor: (size) ->
    @history = new History size

  saveNew: (item) ->
    @history.addHistory item

  saveCurrent: () ->
    editor = atom.workspace.getActiveTextEditor()
    pos = editor?.getCursorBufferPosition()
    file = editor?.buffer.file
    filePath = file?.path
    if pos? and filePath?
      item = @history.getCurrent()
      return if item?.path == filePath && item?.keyword == null && item?.pos.row = pos.row && item?.pos.column = pos.column
      @history.addHistory
        path: filePath
        pos: pos
        keyword: null

  isEmpty: () ->
    return @history.stack.length == 0

  clearHistory: () ->
    @history.clear()

  openPrev: () ->
    item = @history.moveBack()
    return unless item?
    atom.workspace.open(item.path, {initialLine: item.pos.row, initialColumn: item.pos.column})
    
  openNext: () ->
    item = @history.moveFront()
    return unless item?
    atom.workspace.open(item.path, {initialLine: item.pos.row, initialColumn: item.pos.column})