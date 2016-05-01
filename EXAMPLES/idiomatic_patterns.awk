##  Here are some examples of typical awk idioms, using only conditions:

awk 'NR % 6'            # prints all lines except those divisible by 6
awk 'NR > 5'            # prints from line 6 onwards (like tail -n +6, or sed '1,5d')
awk '$2 == "foo"'       # prints lines where the second field is "foo"
awk 'NF >= 6'           # prints lines with 6 or more fields
awk '/foo/ && /bar/'    # prints lines that match /foo/ and /bar/, in any order
awk '/foo/ && !/bar/'   # prints lines that match /foo/ but not /bar/
awk '/foo/ || /bar/'    # prints lines that match /foo/ or /bar/ (like grep -e 'foo' -e 'bar')
awk '/foo/,/bar/'       # prints from line matching /foo/ to line matching /bar/, inclusive
awk 'NF'                # prints only nonempty lines (or: removes empty lines, where NF==0)
awk 'NF--'              # removes last field and prints the line
awk '$0 = NR" "$0'      # prepends line numbers (assignments are valid in conditions)

##  Another construct that is often used in awk is as follows:

awk 'NR==FNR { # some actions; next} # other condition {# other actions}' file1 file2

##  This is used when processing two files. When processing more than one file,
##  awk reads each file sequentially, one after another, in the order they are
##  specified on the command line. The special variable NR stores the total
##  number of input records read so far, regardless of how many files have been
##  read. The value of NR starts at 1 and always increases until the program
##  terminates. Another variable, FNR, stores the number of records read from
##  the current file being processed. The value of FNR starts from 1, increases
##  until the end of the current file, starts again from 1 as soon as the first
##  line of the next file is read, and so on. So, the condition "NR==FNR" is
##  only true while awk is reading the first file. Thus, in the program above,
##  the actions indicated by "# some actions" are executed when awk is reading
##  the first file; the actions indicated by "# other actions" are executed
##  when awk is reading the second file, if the condition in "# other
##  condition" is met. The "next" at the end of the first action block is
##  needed to prevent the condition in "# other condition" from being
##  evaluated, and the actions in "# other actions" from being executed while
##  awk is reading the first file.

##  There are really many problems that involve two files that can be solved
##  using this technique. Here are some examples:

# prints lines that are both in file1 and file2 (intersection)
awk 'NR==FNR{a[$0];next} $0 in a' file1 file2

##  Here we see another typical idiom: a[$0] has the only purpose of creating
##  the array element indexed by $0. During the pass over the first file, all
##  the lines seen are remembered as indexes of the array a. The pass over the
##  second file just has to check whether each line being read exists as an
##  index in the array a (that's what the condition $0 in a does). If the
##  condition is true, the line is printed (as we already know).

##  Another example. Suppose we have a data file like this

20081010 1123 xxx
20081011 1234 def
20081012 0933 xyz
20081013 0512 abc
20081013 0717 def
...thousand of lines...

##  where "xxx", "def", etc. are operation codes. We want to replace each
##  operation code with its description. We have another file that maps
##  operation codes to human readable descriptions, like this:

abc withdrawal
def payment
xyz deposit
xxx balance
...other codes...

##  We can easily replace the opcodes in the data file with this simple awk
##  program, that again uses the two-files idiom:

# use information from a map file to modify a data file
awk 'NR==FNR{a[$1]=$2;next} {$3=a[$3]}1' mapfile datafile

##  First, the array a, indexed by opcode, is populated with the human readable
##  descriptions. Then, it is used during the reading of the second file to do
##  the replacements. Each line of the datafile is then printed after the
##  substitution has been made.

##  Another case where the two-files idiom is useful is when you have to read
##  the same file twice, the first time to get some information that can be
##  correctly defined only by reading the whole file, and the second time to
##  process the file using that information. For example, you want to replace
##  each number in a list of numbers with its difference from the largest
##  number in the list:

# replace each number with its difference from the maximum
awk 'NR==FNR{if($0>max) max=$0;next} {$0=max-$0}1' file file

##  Note that we specify "file file" on the command line, so the file will be
##  read twice.

##  Caveat: all the programs that use the two-files idiom will not work
##  correctly if the first file is empty (in that case, awk will execute the
##  actions associated to NR==FNR while reading the second file). To correct
##  that, you can reinforce the NR==FNR condition by adding a test that checks
##  that also FILENAME equals ARGV[1].
