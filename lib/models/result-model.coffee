module.exports =
class ResultModel
  constructor: (results=[], keyword=null) ->
    @items = @processResults results
    @keyword = keyword

  processResults: (results) ->
    return [
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
