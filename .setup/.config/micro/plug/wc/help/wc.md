# WordCount (wc) Plugin #

The wc plugin provides the user with the ability to count either
characters or strings in any text being edited with micro. 

A word is defined as a string of characters delimited by white 
space characters.  White space characters are the set of characters
for which the iswspace(3) function returns true. 

A line is defined as a string of characters delimited by \n
characters, or by the beginning or end of the file. \r\n line
endings will be counted correctly as well, since there is only
one \n per \r\n.

Character count includes white space and newline characters.

To initiate the function, you can either:

Press "F5"

Or run:

```
> wc
```
