---
layout: post
title: "Behide the DCL: Java Memory Model and Concurrent Programming"
date: 2014-11-29 19:11
comments: true
categories:
categories: [Java]
toc: true
published: true
---

在这篇博客中，我试图从经典的DCL(Double Checked Locking)失效的例子出发，引述Goetz的经典文章，来说清楚原来的JMM的问题所在，以启发大家对并发编程中如何访问共享内存的思考，以及相关的synchronized, volatile, final的语义的正确理解。

## DCL Idiom
DCL(Double Checked Locking)伴随多线程编程中竞争条件(race condition)概念才会出现的一段经典代码，在一般的语义上，这段代码解决了竞争条件的问题。不过，基于JMM(Java Memory Model)，尤其是Java1.4及以前版本的，这段代码是有问题的。

``` java
class SomeClass {
  private Resource resource = null;
  public Resource getResource() {
    if (resource == null) {
      synchronized {
        if (resource == null)
          resource = new Resource();
      }
    }
    return resource;
  }
}
```

Reference:

 - [Double-checked locking: Clever, but broken](http://www.javaworld.com/article/2074979/java-concurrency/double-checked-locking--clever--but-broken.html)
 - [Can double-checked locking be fixed?](http://www.javaworld.com/article/2075306/java-concurrency/can-double-checked-locking-be-fixed-.html)

在文章"Double-checked locking: Clever, but broken"中，作者指出由于`resource = new Resource()`实际包含多个步骤，由于编译优化的原因，一个没有初始化的内存地址可以被先赋值给resource变量，而由于第一次检查不受synchronized约束，可以获取resource变量的值，于是出现返回一个没有初始化的对象的错误情况。这个解释很多地方都有，我不再引述，请参考原文。

在文章中，作者甚至更进一步的指出，即使resouce变量在退出同步语句块后正确的赋值了，也可能还是会存在问题。这个read barrier是多数人没有概念的吧？

> Other concurrency hazards are embedded in DCL -- and in any unsynchronized reference to memory written by another thread, even harmless-looking reads. Suppose thread A has completed initializing the Resource and exits the synchronized block as thread B enters getResource(). Now the Resource is fully initialized, and thread A flushes its local memory out to main memory. The resource's fields may reference other objects stored in memory through its member fields, which will also be flushed out. While thread B may see a valid reference to the newly created Resource, because it didn't perform a read barrier, it could still see stale values of resource's member fields.

## Concurrent programming in Java
要理解Java Memory Model，先让我们回顾关于线程的基本概念。

什么是线程？线程是在进程内部更低一级的执行单元，线程可以共享进程内部的资源。以JMM的术语，就是存放在堆上的数据都是共享的，例如实例成员，静态成员，数组。局部变量是不用共享的。Java线程间通过共享的数据通信。Java的语言规范是要跨平台的，所以在设计线程支持时，必须要考虑设计一个抽象的概念来兼容所有硬件平台。所以在抽象中，每个线程有自己的local memory，进程有个main memory，线程在同步原语发生时同步local memory和main memory里面的数据。

在并发编程中，我们主要考虑多线程竞争条件带来的访问共享变量的问题。这带来同步，锁，死锁等经典问题。多核、多CPU、CPU缓存、编译的寄存器优化等，也带来很多存储位置的同步问题。编译优化中的指令并行和指令顺序调整也会在多线程中造成困恼。

所以Java语言设计了JMM和基本的工具来帮助我们同步和保护我们的数据访问。C语言以前是没有MemoryModel的，据说现在好像开始搞了。

> By contrast, languages like C and C++ do not have explicit memory models -- C programs instead inherit the memory model of the processor executing the program (although the compiler for a given architecture probably does know something about the memory model of the underlying processor, and some of the responsibility for compliance falls to the compiler). This means that concurrent C programs may run correctly on one processor architecture, but not another. While the JMM may be confusing at first, there is a significant benefit to it -- a program that is correctly synchronized according to the JMM should run correctly on any Java-enabled platform.

## Semantics of synchronized
`synchronized`的语义，最基本的是起到锁的作用。但不可忽视的是，它起到了触发memory barrier，也就是进入同步块时read barrier，退出同步块时write barrier的作用。这对于同步local memory和main memory的共享变量起到了重要的作用。同时我们也要主要到，如果没有synchronized的参与的话，一致性不能得到保障。
> Most programmers know that the synchronized keyword enforces a mutex (mutual exclusion) that prevents more than one thread at a time from entering a synchronized block protected by a given monitor. But synchronization also has another aspect: It enforces certain memory visibility rules as specified by the JMM. It ensures that caches are flushed when exiting a synchronized block and invalidated when entering one, so that a value written by one thread during a synchronized block protected by a given monitor is visible to any other thread executing a synchronized block protected by that same monitor. It also ensures that the compiler does not move instructions from inside a synchronized block to outside (although it can in some cases move instructions from outside a synchronized block inside). The JMM does not make this guarantee in the absence of synchronization -- which is why synchronization (or its younger sibling, volatile) must be used whenever multiple threads are accessing the same variables.  -- Java theory and practice: Fixing the Java Memory Model

Refer: [Java theory and practice: Fixing the Java Memory Model, Part 1](http://www.ibm.com/developerworks/java/library/j-jtp02244/index.html)

> The model also allows inconsistent visibility in the absence of synchronization. For example, it is possible to obtain a fresh value for one field of an object, but a stale value for another. Similarly, it is possible to read a fresh, updated value of a reference variable, but a stale value of one of the fields of the object now being referenced. -- Concurrent programming in Java

## Usage of synchronized
同步要针对同一个监视器目标。如果是对一般的对象或者函数使用synchronized的话，监视器通常是this。如果是静态函数，监视器就是Resource.class。
> A synchronized method or block obeys the acquire-release protocol only with respect to other
synchronized methods and blocks on the same target object. Methods that are not
synchronized may still execute at any time, even if a synchronized method is in progress.
In other words, synchronized is not equivalent to atomic, but synchronization can be used to
achieve atomicity.

synchronized不是方法的signature，也就不可以继承。接口中的方法和构造函数也不能声明为synchronized的。
> The synchronized keyword is not considered to be part of a method's signature. So the
synchronized modifier is not automatically inherited when subclasses override superclass
methods, and methods in interfaces cannot be declared as synchronized. Also,
constructors cannot be qualified as synchronized (although block synchronization can be used
within constructors).

同步是可以重入的。
> Locks operate on a per-thread, not per-invocation basis. A thread hitting synchronized passes if
the lock is free or the thread already possess the lock, and otherwise blocks. (This reentrant or
recursive locking differs from the default policy used for example in POSIX threads.) Among other
effects, this allows one synchronized method to make a self-call to another synchronized
method on the same object without freezing up.

Refer: [Synchronization and the Java Memory Model](http://gee.cs.oswego.edu/dl/cpj/jmm.html)

## Semantics of Volatile
在原来的语义下，volatile仅仅管自己这个变量的读写同步。
> The original semantics for volatile guaranteed only that reads and writes of volatile fields would be made directly to main memory, instead of to registers or the local processor cache, and that actions on volatile variables on behalf of a thread are performed in the order that the thread requested. In other words, this means that the old memory model made promises only about the visibility of the variable being read or written, and no promises about the visibility of writes to other variables. While this was easier to implement efficiently, it turned out to be less useful than initially thought.

但是实际上我们常常用volatile作为guard变量。例如这个例子，我们是希望这个变量表示其他变量已经初始化号了。但在原来的语义下，volatile语句和非volatile修饰的变量的语句是可以被重排，于是无法起到Guard的作用。
``` java
Map configOptions;
char[] configText;
volatile boolean initialized = false;

// In Thread A
configOptions = new HashMap();
configText = readConfigFile(fileName);
processConfigOptions(configText, configOptions);
initialized = true;

// In Thread B
while (!initialized)
  sleep();
// use configOptions
```

在新的语义下，volatile修饰的变量成为整个线程的守护神。每次对它的读写，都导致整个线程的变量同步。所以也造成相当高的性能影响。
> Under the new memory model, when thread A writes to a volatile variable V, and thread B reads from V, any variable values that were visible to A at the time that V was written are guaranteed now to be visible to B. The result is a more useful semantics of volatile, at the cost of a somewhat higher performance penalty for accessing volatile fields.

Refer: [Java theory and practice: Fixing the Java Memory Model, Part 2](http://www.ibm.com/developerworks/library/j-jtp03304/)

## Final
在Fixing the Java Memory Model一文第一部分中，作者给了Immutable Objects其实不一定是不可变的例子，当然是在JDK1.4版本。举得的例子是String的实现，值得一看。

在新的JMM定义下，不会出现在一个final对象构造过程中来自其他线程读对象的指令执行。"a reference to the object is not published before the constructor has completed"，变量的引用不会先于构造函数完成前公开，确保对象的构造完整。
> The mechanism by which final fields could appear to change their value under the old memory model was outlined in Part 1 -- in the absence of synchronization, another thread could first see the default value for a final field and then later see the correct value.
Under the new memory model, there is something similar to a happens-before relationship between the write of a final field in a constructor and the initial load of a shared reference to that object in another thread. When the constructor completes, all of the writes to final fields (and to variables reachable indirectly through those final fields) become "frozen," and any thread that obtains a reference to that object after the freeze is guaranteed to see the frozen values for all frozen fields. Writes that initialize final fields will not be reordered with operations following the freeze associated with the constructor.

而且强化了final变量以及变量引用的子对象，对其他线程的可见性。也就是不会出现虽然final对象及时更新，但是子对象引用的还是过时的数据的情况。
> The new JMM also seeks to provide a new guarantee of initialization safety -- that as long as an object is properly constructed (meaning that a reference to the object is not published before the constructor has completed), then all threads will see the values for its final fields that were set in its constructor, regardless of whether or not synchronization is used to pass the reference from one thread to another. Further, any variables that can be reached through a final field of a properly constructed object, such as fields of an object referenced by a final field, are also guaranteed to be visible to other threads as well. This means that if a final field contains a reference to, say, a LinkedList, in addition to the correct value of the reference being visible to other threads, also the contents of that LinkedList at construction time would be visible to other threads without synchronization. The result is a significant strengthening of the meaning of final -- that final fields can be safely accessed without synchronization, and that compilers can assume that final fields will not change and can therefore optimize away multiple fetches.

## Other topics
在文章[Java theory and practice: Fixing the Java Memory Model, Part 2](http://www.ibm.com/developerworks/library/j-jtp03304/)中，还讨论了Visibility, Happens before等关键的术语，它们对于深入理解Java并发编程很有帮助。文中也讨论了改进版的DCL，指出由于新的volatile的语义，现在版本的DCL实际起不到改进性能的作用。
