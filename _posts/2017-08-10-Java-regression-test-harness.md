---
title: "Java regression test harness"
excerpt:
date: 2017-08-10 14:47:16
modified: 2017-08-10
categories: [Java]
published: false
---
{% include toc %}

-help all

#### vm mode
othervm
Any action run in this mode is run in its own JVM. This provides the maximum isolation between the actions, but also the maximum overhead, so it is the slowest of these three modes.
samevm
All actions are run in the same JVM. This is the fastest mode, but also has the maximum risk of interference between actions (tests). In the worst case, one bad test can cause all the following tests in the test run to fail.
agentvm
"Like samevm, but better". This mode is more robust than samevm: actions are run in a shared JVM, called an Agent. After each action completes, the agent will attempt to reset the JVM to a clean state; if it cannot, the agent will be shutdown and a new one created when next required. In the best case, the performance is similar to samevm mode; in the worst case it degrades to being similar to othervm mode.

In othervm and agentvm modes, jtreg can run tests concurrently, using multiple JVMs. Care must still be taken to ensure that tests do not interfere with each other using external resources such as absolute filenames (like /tmp) or fixed network ports. Since tests can and often will manipulate global data within a JVM (such as the system properties, streams, or even the security manager), it is never appropriate to run tests concurrently within the same JVM.

#### command line options

 - specify the test jdk on command line, e.g. jtreg -jdk:test-jdk test-or-folder
 - specify the JT_JAVA to jdk8
 - specify the JT_HOME to jtreg home
 - specify -w working dir, -r report dir
 - specify -agentvm in command line to set as default vm mode.
 - specify -a or -automatic to skip the manual test (which need interaction to determine whether pass or fail)
 - -conc:value set the number of concurrent vm
 - -l , -listtests list the tests instead of executing them.



#### Run your compiled component with released JDK binary
If you have built a component of JDK such as the compiler (javac), you may be able to test it in conjunction with a complete JDK by putting the classes or jar file for new component on the system bootstrap classpath:

% jtreg -jdk:jdk -Xbootclasspath/p:component.jar test-or-folder...


#### Test selection
-bug:bugid
-exclude:file
-k:keyword
-status:pass/fail/notRun/error

You can rerun any selection of tests. Use the -status:arg option to filter the set of tests to be run, based on their prior result status. For example, to rerun tests which previously failed or could not be run:

% jtreg -jdk:jdk -status:fail,error test-or-folder...

#### Misc
Run the test first then generate report
 -nr, -noreport, then -ro -reportOnly

Verify correctness of test description
 -c
#### verbose
 default, summary, all, pass, fail, error, nopass, time, multirun
