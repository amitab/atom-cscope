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

Finds the selected text or word under cursor to perform a cscope lookup and displays
the results in a panel which shows up above (Check screenshot).
Or you could just toggle the display of the atom-cscope panel and look it up yourself.
The following commands are registered:

```
atom-cscope:toggle
atom-cscope:find-this-symbol
atom-cscope:find-this-global-definition
atom-cscope:find-functions-called-by
atom-cscope:find-functions-calling
atom-cscope:find-text-string
atom-cscope:find-egrep-pattern
atom-cscope:find-this-file
atom-cscope:find-files-including
atom-cscope:find-assignments-to
```

Only `atom-cscope:toggle` has a keymap set. You can setup your own keymaps for the other
commands.

## Set it up?
You need to generate the cscope.out file before using this package.

In your project directory, run:
```bash
find . -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > cscope.files
cscope -q -R -b -i cscope.files
```
And then the package will be able to use the cscope.out file to generate results.

## Screenshots
![ScreenShot](http://i.imgur.com/MzPfKdb.png)

## Further Improvements?
1. Add 'Change this text string' functionality
