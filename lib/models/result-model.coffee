path = require 'path'

module.exports =
class ResultModel
  constructor: (keyword=null) ->
    @keyword = keyword
    @regex = new RegExp(@keyword, 'g')
    @items = []

  processResults: (results, cwd) ->
    for line in results.split '\n'
      line = line.trim()
      continue if line is ""
      @items.push @processLine line, cwd

  processLine: (line, cwd) ->
    data = line.split(" ", 3)
    data.push(line.replace(data.join(" ") + " ", ""))
    info =
      projectDir: if path.isAbsolute data[0] then data[0] else path.join cwd, data[0]
      fileName: path.basename data[0]
      functionName: data[1]
      lineNumber: parseInt data[2]
      codeLine: data[3]
      isJustFile: data[3].trim() is '<unknown>'
      relativePath: data[0]

    if info.isJustFile
      info.fileName = info.fileName.replace(/</g, '&lt;')
      info.fileName = info.fileName.replace(/>/g, '&gt;')
      info.fileName = info.fileName.replace(@regex, '<span class="text-highlight bold">\$&</span>')
    else
      info.codeLine = info.codeLine.replace(/</g, '&lt;')
      info.codeLine = info.codeLine.replace(/>/g, '&gt;')
      info.codeLine = info.codeLine.replace(@regex, '<span class="text-highlight bold">\$&</span>')

    return info