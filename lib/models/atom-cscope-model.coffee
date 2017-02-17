path = require 'path'

module.exports =
class AtomCscopeModel
  constructor: ->
    @paths = []
    for project in atom.project.getPaths()
      @paths.push path.basename project
    @results = [
      {
        projectDir: "test_dir",
        fileName: "test_name",
        isJustFile: false,
        lineNumber: 99,
        functionName: "test_function",
        codeLine: "Sample Line"
      },
      {
        projectDir: "test_dir",
        fileName: "test_name",
        isJustFile: true
      }
    ]
