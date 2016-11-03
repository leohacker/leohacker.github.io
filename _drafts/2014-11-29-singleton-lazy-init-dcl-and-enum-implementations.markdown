---
layout: post
title: "Singleton, Lazy initialization, DCL and Enum implementations"
date: 2014-11-29 20:38
comments: true
categories: [Java, DesignPattern]
toc: true
published: true
---

## Singleton Pattern
单例模式是一个很有趣的模式，不过有趣的地方不是模式本身，而是我们可以从单例模式的实现讨论到双重检查锁定(Double Checked Locking)，然后就是从历史上DCL的实现瑕疵问题引出的Java内存模型和多线程编程中`synchronized`和`volatile`的语义和用法。

这篇博客集中在解释如何正确地实现单例模式，而我专门会用另外一篇博客解释DCL引出的Java内存模型问题。DCL的问题很多人都写过博客，但是大多数国人都是浅尝即止，即使Goetz已经给出了详细的解释，我也没有看到有人将其没有遗漏的翻译讲解，而是一知半解的。

当然实现单例这部分也很有趣。随着问题的展开，我们会了解到目前推荐的是用枚举来实现单例，以及枚举实现比其他的方式有哪些优点。Java1.5引入的枚举特性的确是让人眼前一亮。

## Static Factory Method
单例模式的初衷就是让整个系统中，只能创建一个类的对象。关于这一点，有不少程序员觉得单例模式其实是反模式的，因为单例模式就要求有类似`Singleton.getInstance()`的调用语句，也就形成调用类和单例类的强耦合。这种强耦合对于测试是很不利的。而解决的方法，可以是通过依赖注入的方式，或者参数传递的方式，由上层对象创建这个单例对象。在应用程序层面上，这种反单例的理由是成立的。不过考虑我们可能需要在库的实现中用到单例，这时候调用者是我们不能控制的，所以我们还是需要在类的定义层面上限制外部调用者不会产生类的多个实例。

不想让调用代码随意创建对象，首先要将构造函数私有化。然后我们可以想到static不就是让类的属性唯一吗？所以我们可以声明实例为static。进而我们可以有静态工厂的实现方式。静态工厂方法相比使用公有变量方式的好处，就在于可以在以后修改实现，不使用Singleton模式。不过，如果你将Singleton写入类的名字中，我觉得你还是用公有变量好了，反正你类的名字已经不好改变了 :) 虽然这么说，使用静态工厂方法还有一个好处，就是你可以实现`Lazy Initialization`。

``` java
// 公有属性
public class Singleton {
    public static final Singleton INSTANCE = new Singleton();
    private Singleton() {}
}

// 静态工厂方法
public class Singleton {
    private static final Singleton INSTANCE = new Singleton();
    private Singleton() {}
    public static Singleton getInstance() {
        return INSTANCE;
    }
}
```
<!-- more -->

## Lazy Initialization
静态工厂方法是在初始化阶段就生成了实例，也就是在类载入时完成。而Lazy Initialization(懒汉式)的意义在于，可以将创建实例的动作，推迟到调用代码第一次使用实例的时候。于是我们可以很容易地从上面的例子得出：

``` java
public class Singleton {
    private static Singleton instance;
    private Singleton() {}
    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}
```

但是这个实现在多线程编程时存在问题。有可能出现两个线程都判断`instance == null`，然后分别创建实例的情况。解决方法可以是给getInstance方法加上`synchronized`修饰。synchronized可以保证整个判断和创建实例的过程是原子化的，不过代价就是性能上甚至百倍的损失。

### Double Checked Locking
synchronized修饰符是多线程编程的主要工具，使用synchronized的一个基本原则就是尽可能小范围的使用，仅包裹访问共享数据的代码。所以可以使用双重检查锁模式，不过可耻的失败了，因为Java的内存模型。在修改了Volatile语义和改进JMM(Java Memory Model)规范后，我们可以使用DCL正确的实现Lazy Initialization Singleton。

双重检查锁不是在Java中特有的，其他语言也会使用这个模式。是否应用这个模式，更多的取决于编程语言在多线程环境下的内存模型。Refer: [Double checked lokcing](http://en.wikipedia.org/wiki/Double-checked_locking)。

这个历史上被很多文章推荐的，但是却是有瑕疵的，实现是这样的：
``` java
public class Singleton {
    private static Singleton instance;
    private Singleton() {}
    public static Singleton getInstance() {
        if (instance == null) {
            synchronized (Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```
这个实现表面上看很完美。先在没有锁的情况下检查instance，如果不是null，就说明已经创建了。如果null，则锁定关键区域，以解决竞争条件(race condition)问题。通过第二次的检查，解决第一次检查的失效。

[有的博客文章](http://wuchong.me/blog/2014/08/28/how-to-correctly-write-singleton-pattern/)会指出语句`instance = new Singleton`不是原子化的。构造函数实际上是分步骤的，要分配内存，初始化，最后将内存地址赋给instance变量。不过这是通常意义上的顺序，program order。由于编译优化的原因，有可能先赋值，在初始化内存块里面的变量。编译优化是不可能考虑多线程的，太复杂了。文章继续解释于是可能出现第二个线程在第一次检查的时候，看到instance变量不是null，于是返回一个没有完成初始化步骤的实例对象。

其实稍稍有一些Java内存模型概念的人，反而会有疑问。`synchronized`不是保护了instance变量吗？不是应该在退出关键区域的时候，将local memory里面的数据写回main memory吗？这里的关键是，synchronized可以保证同步在相同对象（监视器）上的代码块，可以是不同线程的相同代码块，也可以是不同的代码块，它们在访问代码块中的共享数据变量是同步的，保证次序的。而在没有synchronized的地方，可以出现不一致。在例子里面，第一次检查就不在控制中。这才是问题所在，即没有保证共享变量的访问次序一定是[Happened before](http://en.wikipedia.org/wiki/Happened-before)。所以在JSR133中改进了Volatile的语义，在JDK1.5以后，然后我们可以通过声明`private static volatile Singleton instance;`来同步对共享变量的读写，这样就实现了一个正确的DCL单例。

> The model also allows inconsistent visibility in the absence of synchronization. For example, it is possible to obtain a fresh value for one field of an object, but a stale value for another. Similarly, it is possible to read a fresh, updated value of a reference variable, but a stale value of one of the fields of the object now being referenced.

引用一个来之[Double checked lokcing](http://en.wikipedia.org/wiki/Double-checked_locking)的实现。这段代码引入了一个临时变量，来改进Volatile语义导致的性能下降问题。改进后的Volatile语义会保证每次读写所修饰对象的次序，这会带来更多的同步操作和相应地性能下降。

```
// Works with acquire/release semantics for volatile
// Broken under Java 1.4 and earlier semantics for volatile
class Foo {
    private volatile Helper helper;
    public Helper getHelper() {
        Helper result = helper;
        if (result == null) {
            synchronized(this) {
                result = helper;
                if (result == null) {
                    helper = result = new Helper();
                }
            }
        }
        return result;
    }

    // other functions and members...
}
```

> Note the local variable result, which seems unnecessary. This ensures that in cases where helper is already initialized (i.e., most of the time), the volatile field is only accessed once (due to "return result;" instead of "return helper;"), which can improve the method's overall performance by as much as 25 percent.

关于由这个问题引出的JMM和Java并发编程，可以参考另外一篇博客[Behide the DCL: Java Memory Model and Concurrent Programming](http://leohacker.github.io/blog/2014/11/29/behide-the-dcl-java-memory-model-and-concurrent-programming/)

### Static Inner Class
实现懒汉式单例，还可以利用内部类的方式。利用Classloader的特性，在调用getInstance时候才载入SingletonHolder类，从而创建Singleton实例。这也被称为[Initialization-on-demand holder idiom](http://en.wikipedia.org/wiki/Initialization-on-demand_holder_idiom)。前面描述的静态工厂方法，会在类载入的时候创建instance对象；而静态内部类的方法，将instance对象的创建延迟到实际第一次使用的时候才创建。同样是利用类载入的机制，不过由于内部类是不会立即载入的，所以可以用来做延迟。
``` java
public class Singleton {
    private static class SingletonHolder {
        private static final Singleton INSTANCE = new Singleton();
    }

    private Singleton() {}

    public static Singleton getInstance() {
        return SingletonHolder.INSTANCE;
    }

}
```

## Enum Implementat
用Enumeration来实现单例是现在公认的最好的实现单例方法。
``` java
public enum Singleton {
    INSTANCE;
    public void method() {
      ...
    }
}
```

这不仅仅是因为其简单，而且还是因为Enumeration已经实现了Serializable接口，即使在通过反序列化构建对象的时候，也可以由JVM保证对象的唯一性。而其他方法在类实现了Serializable接口后，就必须实现如下函数。而且传统方式的单例实现，都具有一个私有的构造函数，即使不能用常规的手段创建实例，但是有可能会遭到恶意的反射攻击，通过反射的方式直接创建实例。为了防止反射攻击，我们可以在私有构造函数中抛出异常来阻止。而如果用枚举的方式，则是由JVM来保证，这是又一个优点。
``` java
//readResolve to prevent another instance of Singleton
    private Object readResolve(){
        return INSTANCE;
    }
```

Refer: [Why num singleton are better in java](http://javarevisited.blogspot.com/2012/07/why-enum-singleton-are-better-in-java.html) and "Effective Java"

