module.exports =
  MaxCscopeResults:
    title: 'Maximum Cscope Results'
    description: 'Don\'t allow cscope results beyond this. 0 for infinite (not recommended).'
    type: 'integer'
    default: 1000
  LiveSearch:
    title: 'Live Search toggle'
    description: 'Allow Live Search?'
    type: 'boolean'
    default: true
  LiveSearchDelay:
    title: 'Live Search delay'
    description: 'Time after typing in the search box to trigger Live Search'
    type: 'integer'
    default: 800
  WidgetLocation:
    title: 'Set Widget location'
    description: 'Where do you want the widget?'
    type: 'string'
    default: 'top'
    enum: ['top', 'bottom']
  cscopeSourceFiles:
    title: 'Source file extensions'
    description: 'Enter the extensions of the source files with which you want cscope generated (with spaces)'
    type: 'string'
    default: '.c .cc .cpp .h .hpp'
  cscopeBinaryLocation:
    title: 'Path for cscope binary'
    description: 'Enter the full path to cscope program'
    type: 'string'
    default: 'cscope'