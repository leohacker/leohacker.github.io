---
title: "Bash Scripting"
excerpt: 如何使用Bash编程
date: 2016-07-11 11:25
categories: [Linux]
published: false
---
{% include toc %}

### Login Shell and Interactive Shell
Login Shell载入时先读入`/etc/profile`，Bash会按顺序读第一个
  - `~/.bash_profile`
  - `~/.bash_login`
  - `~/.profile`

在退出时执行`~/.bash_logout`。Zsh在我的Ubuntu系统中有.zlogin，不过zsh依旧读的是.profile

## ABS (Advanced Bash Scripting Guide)
Shell编程不适合任务商业项目，Bash缺乏作为高级语言的基本特性。我们可以认为Shell编程就是利用Bash内置的控制语句和变量操作，
粘合外部程序的顺序执行。Shell也不擅长网络，处理文件是以行为单位。所以如果遇到比较复杂的任务，还是考虑用Python。Bash还是
适合制作小型的工具。


### Variable
Bash的变量，我们常常写作`$variable`，实际上它是`${variable}`的简化形式。变量赋值等号两侧是不能用空格的，设想如果有空格，Shell是解释每行作为命令，那么就会将变量作为命令，等号以及赋值作为参数。

下面这个例子解释了为什么要在输出变量值的时候给变量加上双引号。术语叫partial quoting，或者weak quoting。
```
hello="A B  C   D"
echo $hello   # A B C D
echo "$hello" # A B  C   D
# As we see, echo $hello   and   echo "$hello"   give different results.
# =======================================
# Quoting a variable preserves whitespace.
# =======================================
```

http://www.tldp.org/LDP/abs/html/internalvariables.html

declare
可以声明常量，整数，数组，函数。在函数内部声明的变量具有函数内部的作用域。
```

foo (){
declare FOO="bar"
}

bar ()
{
foo
echo $FOO
}

bar  # Prints nothing.
```
http://www.tldp.org/LDP/abs/html/parameter-substitution.html
Default value
 - `${parameter:-default}` if parameter not set, use default.  不要使用`${parameter-default}`，它在parameter声明但没赋值的情况下无效。
 - `${parameter:=default}` if parameter not set, set it to default.
 - `${parameter:?err_msg}` If parameter set, use it, else print err_msg and abort the script with an exit status of 1.
$RANDOM 是个伪随机变量。

### Position Parameter
如果没有在命令行给出需要的位置参数，相应的参数会得到null值。在脚本中可以检查参数是否给出，同时可以考虑使用参数替换给予参数缺省值。使用shift移动参数，可以指定移动的参数个数。

```
if [ -z $1 ]
then
  exit $E_MISSING_POS_PARAM
fi
#         ${1:-$DefaultVal}

$0 $1 $2 $3
$#  参数个数
$*  所有的参数看作一个字符串
$@  所有的参数看作多个分隔的字符串
```

结论就是用`"$@"`。

#### IFS
```
# IFS == whitespace
for a in $List     # Splits the variable in parts at whitespace.
do
  echo "$a"
done
```
http://www.tldp.org/LDP/abs/html/internalvariables.html

```
bash$ echo "$IFS" | cat -vte
 ^I$
 $

bash$ bash -c 'set w x y z; IFS=":-;"; echo "$*"'
w:x:y:z
(Read commands from string and assign any arguments to pos params.)

从标准的IFS分隔符中(空格，换行，tab)去掉空格。这里的巧妙之处是用$(printf) command substitute
IFS="$(printf '\n\t')"
```
### Test Condition
 - file test operator http://www.tldp.org/LDP/abs/html/fto.html
 - integer comparison http://www.tldp.org/LDP/abs/html/comparison-ops.html
 - string comparison  http://www.tldp.org/LDP/abs/html/comparison-ops.html

需要注意的是，字符串比较在双括号和单括号的时候是不同的。
```
The == comparison operator behaves differently within a double-brackets test than within single brackets.
[[ $a == z* ]]   # True if $a starts with an "z" (pattern matching).
[[ $a == "z*" ]] # True if $a is equal to z* (literal matching).

[ $a == z* ]     # File globbing and word splitting take place.
[ "$a" == "z*" ] # True if $a is equal to z* (literal matching).
```

### String Manipulation
http://www.tldp.org/LDP/abs/html/string-manipulation.html

 - String Length `${#stringvariable}`  For an array, ${#array} is the length of the first element in the array.
  For an array, `${#array[*]} and ${#array[@]}` give the number of elements in the array.
 - Length of Matching Substring
 - Index
 - Substring Extraction `${string:position:length}`  position and length can be parameterized.
   - `${@:2}` 取第二和第三个位置参数
 - Substring Removal
   - `${string#substring}` delete shortest match of substring from front of string
   - `${string##substring}` delete longest match of substrinf from front of string
   - `${string%substring}` delete shortest match of substring from back of string
   - `${string%%substring}` delete longest match of substring from back of string
   - `${string/substring/replacement}` replace first match of substring with replacement
   - `${string//substring/replacement}` replace all match of substring with replacement
   - `${string/#substring/replacement}` replace front match of substring with replacement
   - `${string/%substring/replacement}` replace end match of substring with replacement

### Tips

#### export
export -f function_name # export a function
export -p               # display all the exported variable

#### eval
eval将解释参数为命令，这提供了我们可以在脚本中动态构建命令的能力。

### Command Substitute
Command substitution invokes a subshell.

Even when there is no word splitting, command substitution can remove trailing newlines.
cd "`pwd`"  # Error message:
# bash: cd: /tmp/file with trailing newline: No such file or directory

cd "$PWD"   # Works fine.

$(...)的形式比backtick优越的地方是还允许嵌套。

```
Anagrams=( $(echo $(anagram $1 | grep $FILTER) ) )
#          $(     $(  nested command sub.    ) )
#        (              array assignment         )
```
For purposes of command substitution, a command may be an external system command, an internal scripting builtin, or even a script function.
In a more technically correct sense, command substitution extracts the stdout of a command, then assigns it to a variable using the = operator.

$(()) 是数学扩展arithmetic expansion.
```

z=$(($z+3))
z=$((z+3))                                  #  Also correct.
                                            #  Within double parentheses,
                                            #+ parameter dereferencing
                                            #+ is optional.

# $((EXPRESSION)) is arithmetic expansion.  #  Not to be confused with
                                            #+ command substitution.

let z=z+3
let "z += 3"  #  Quotes permit the use of spaces in variable assignment.
              #  The 'let' operator actually performs arithmetic evaluation,
              #+ rather than expansion.
```

### Quoting
```
dir_listing=`ls -l`
echo $dir_listing     # unquoted

# Expecting a nicely ordered directory listing.

# However, what you get is:
# total 3 -rw-rw-r-- 1 bozo bozo 30 May 13 17:15 1.txt -rw-rw-r-- 1 bozo
# bozo 51 May 15 20:57 t2.sh -rwxr-xr-x 1 bozo bozo 217 Mar 5 21:13 wi.sh

# The newlines disappeared.


echo "$dir_listing"   # quoted
# -rw-rw-r--    1 bozo       30 May 13 17:15 1.txt
# -rw-rw-r--    1 bozo       51 May 15 20:57 t2.sh
# -rwxr-xr-x    1 bozo      217 Mar  5 21:13 wi.sh
```
