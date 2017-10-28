## 1.0.1
* Fix issue#30
* Fix issue#31, issue#28, issue#17

## 1.0.0
* UI revamped with ractive.js
* Added Cscope result history (Can be disabled in settings)
* Added Cscope result limiter (Can be bypassed in settings)
* Modified cscope.coffee to correctly bubble out the errors
* Removed unnecessary npm modules for faster loading time (Only 2 dependencies)
* Fix Issue #23 by @fadeevab
* Fix Issue #26

## 0.15.0
* PR - Check for absolute paths #16
* Fix Issue #18 - Open files which are not in project directory
* Fix Issue #20 - Changes required for CoffeeScript update
* Performance fixes

## 0.14.0
* Loads of code cleaning
* Fix Issue #11 - with the updates to Atom, a few changes were needed
* Fix Issue #12 - Added support for multiple projects
* Fix Issue #14 - Run find commands with no buffer open

## 0.13.0
* Fix Issue #9 by @vishalpatel

## 0.12.0
* Fix issue #5 can't run refresh-db
* Fix issue #6 refresh command as activation command
* Fix issue #7 Error on closing widget
* Fix issue #8 can't execute same query after rebuild cscope db
## 0.11.0
* Can build cscope db within atom
* Adds `atom-cscope:refresh-db` as command to build db
## 0.10.0
* Fix search under cursor/selection (Issue #2)
* Change event handling methods in Input View
* Fix filenames on file search
## 0.9.0
* Press `enter` to execute a new search
* Navigate Results list with arrow keys and select with `enter` (Issue #1)
* Switch between editor and widget with `atom-cscope:focus-next`
* Open widget with pre-selected option with new commands
* Fix Bug: Focus issue on closing widget with `esc` (Issue #1)
## 0.8.0
* Press `esc` to close widget
* Configurable position of widget
* Option to disable Live Search
* Option to change Live Search delay
## 0.7.0
* Append all the result items at once, decreasing lag
* Fix correct keyword highlighting
## 0.6.0
* Fix working egrep
* Search on Enter key or 800ms later
## 0.5.0
* Display total number of results on top
* Highlight search substring
* AutoFocus on input on toggle
* Run search with words under cursor or selection 
## 0.4.0
* Code Cleanup
## 0.3.0
* Code Cleanup
## 0.2.0
* Updated Styling
## 0.1.0
* Initial Release
