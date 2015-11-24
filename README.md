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

## Set it up?
You need to generate the cscope.out file before using this package.

```bash
find . -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > cscope.files
cscope -q -R -b -i cscope.files
```
And then the package will be able to use the cscope.out file to generate results.

## Screenshots
![alt tag](blob:https%3A//drive.google.com/cd033353-b6b2-45cc-a78b-8f1c209655e9)

## Further Improvements?
1. Add 'Change this text string' functionality