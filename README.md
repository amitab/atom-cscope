# atom-cscope package

Using cscope within Atom Code Editor CUZ I wanted one.
This is my first Atom package(PLS be gentle) which I created out of need since 
I was not able to find any package which could let me use cscope in Atom. (It 
may be there but is probably buried under a million packages so I could not 
find it.)

## What it does?
1.  Find this C symbol:                         ✓
2.  Find this global definition:                ✓
3.  Find functions called by this function:     ✓
4.  Find functions calling this function:       ✓
5.  Find this text string:                      ✓
6.  Change this text string:                    ✗
7.  Find this egrep pattern:                    ✓
8.  Find this file:                             ✓
9.  Find files #including this file:            ✓
10. Find assignments to this symbol:            ✓

Finds the selected text or word under cursor to perform a cscope lookup and 
displays the results in a panel which shows up above (Check screenshot).
Or you could just toggle the display of the atom-cscope panel and look it up 
yourself. 

The following commands are registered to execute search with the word in 
selection or under cursor:
```
atom-cscope:find-symbol
atom-cscope:find-global-definition
atom-cscope:find-functions-called-by
atom-cscope:find-functions-calling
atom-cscope:find-text-string
atom-cscope:find-egrep-pattern
atom-cscope:find-file
atom-cscope:find-files-including
atom-cscope:find-assignments-to
```

The following commands are registered to toggle the Widget open with 
pre-selected options to save time.
```
atom-cscope:toggle
atom-cscope:toggle-symbol
atom-cscope:toggle-global-definition
atom-cscope:toggle-functions-called-by
atom-cscope:toggle-functions-calling
atom-cscope:toggle-text-string
atom-cscope:toggle-egrep-pattern
atom-cscope:toggle-file
atom-cscope:toggle-files-including
atom-cscope:toggle-assignments-to
```

Only `atom-cscope:toggle` has a keymap set. You can setup your own keymaps for 
the other commands.

The command `atom-cscope:focus-next` allows you to switch between the main 
editor and the widget, while the widget is open.

Command `atom-cscope:refresh-db` allows you to create/re-create the cscope
database for all the projects in the Atom workspace.

Command `atom-cscope:project-select` allows you to open the dropdown to select
the project in which you want to run the cscope query in (For all those who do
not want to touch your mouse :P)

There are 3 ways of executing a search:
* Live search: Executes a search with configurable delay after you input your 
   search term.
* Enter Key: Just press enter after typing your input.
* "SCOPE IT!" button: Click the button.

If new search is same as previous search, no action is taken. However, you can
force search by clicking on the "SCOPE IT!" button

You can navigate the Result Items using arrow keys and press `enter` to open 
the target file in a new buffer and the cursor automatically moves to the 
location of the query or you can click on the Result Item for the same effect.

## Set it up?
You can use the existing cscope.out file, generate on your own, or generate
through the widget with the lightning button.

To generate cscope.out manually, in your project directory run:
```bash
find . -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > cscope.files
cscope -q -R -b -i cscope.files
```
And then the package will be able to use the cscope.out file to generate results.

## Screenshots
![ScreenShot](http://i.imgur.com/t7p7lvn.png)

## Further Improvements?
1. Add 'Change this text string' functionality
