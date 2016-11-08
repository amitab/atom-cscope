ResultItemView = require '../views/result-item-view'
path = require 'path'

module.exports = 
  class ResultModel
    constructor: (response, keyword, cwd) ->
      @keyword = if keyword? and keyword.trim() isnt "" then keyword else false
      @cwd = cwd
      @processResultString(response)

    getFilePath: ->
      filePath = if path.isAbsolute(@fileName) then @fileName else path.join(@cwd, @fileName)
      return filePath
    
    processResultString: (response) ->
      @resultString = response
      data = response.split(" ", 3)
      data.push(response.replace(data.join(" ") + " ", ""))

      @fileName = data[0]
      @functionName = data[1]
      @lineNumber = parseInt(data[2])
      @lineText = data[3]
      
      @isJustFile = data[3].trim() is '<unknown>' 
      regex = new RegExp(@keyword, 'g')
      @htmlFileName = @fileName.replace(regex, '<span class="text-highlight bold">\$&</span>')
      @projectPath = path.basename(@cwd)
      
      if @keyword
        @htmlLineText = data[3].replace(/</g, '&lt;')
        @htmlLineText = @htmlLineText.replace(/>/g, '&gt;')
        @htmlLineText = @htmlLineText.replace(regex, '<span class="text-highlight bold">\$&</span>')

    generateView: ->
      return ResultItemView.setup(@)

    encodeHtmlEntity: (str) ->
      buf = []
      buf.unshift(['&#', str[i].charCodeAt(), ';'].join('')) for i in [str.length-1...-1] by -1
      return buf.join('')

    generateHTML: (index) ->
      html  = '<li class="result-item" data-index="' + index + '">'
      html += '<div class="inline-block", style="margin-right=0px;">'
      html += '<span class="project-directory">[' + @projectPath + ']</span>'
      html += '<span class="gap"></span>'
      html += '<span class="file-name">' + @htmlFileName + '<span>'
      html += '</div>'
      if not @isJustFile
        html += '<div class="inline-block">'
        html += '<span>:</span>'
        html += '<span class="line-number bold">' + @lineNumber + '</span>'
        html += '<span class="gap"></span>'
        html += '<span class="highlight function-name">' + @encodeHtmlEntity(@functionName) + '</span>'
        html += '<span class="gap"></span>'
        html += '<div class="inline-block code-line">' + @htmlLineText + '</div>'
        html += '</div>'
      return html
