---
title: "Command Query Separation"
excerpt: Design Pattern Command Query Separation
date: 2014-04-02 22:28
categories: [DesignPattern]
published: true
---
{% include toc %}

## CQS的起源
CQS，Command Query Separation，这个词是Bertrand Meyer在他的书 Object Oriented Software Construction中首次提出的。据Martin Fowler说，这本书的第一版在面向对象流行的初期有很大的影响力，而第二版对于你的肱二头肌很大的影响。想知道为什么？请follow参考的连接 :)

CQS的基本理念是，当我们设计对象时，对象的每个方法

 - 或者是一个command，执行一个动作修改对象的状态，无返回值。
 - 或者是一个query，返回数据给调用者。

根据维基上的说法，按照CQS的设计规范，方法只能在它们是[referential transparency](http://en.wikipedia.org/wiki/Referential_transparency_%28computer_science%29)，也就是没有副作用的情况下，返回一个值。讽刺的是，紧接着维基在这个论述的下一句就是，

> 值得注意的是如果严格按这个规范实现，那么要计算你运行了多少次Query是不可能的。所以CQS更应该作为一个编程的指导原则，类似避免使用goto语句一样，而不是一条铁律。

## CQS辨析

### CQS精髓
CQS的精髓可以用一句话来描述：**读取器是无副作用的**。

### CQS的理想国：Design by contract
在维基中提到，CQS非常适用于 design by contract 方法学。在Design by Contract中，程序的设计是由一系列内嵌在源代码中的断言(assertion)来描述的，即描述和限定在某些检查点上系统的状态。很显然，这些断言是不应该对程序的执行有影响的，CQS的设计理念非常符合这一需求。如果所有读操作都是符合CQS，无副作用的，则断言一定是无副作用的。

关于Design by Contract的描述，很容易让你联想到图灵机。作为计算模型的最简化形式，计算就是系统状态转变的过程，以及将当前状态返回给外界。对于系统最基本的就是读和写，也就是对应到Query和Command。之所以不用Read和Write，我想部分的原因是一个读取系统状态的工作不是像从内存单元或者寄存器中读一个数据这么简单，Query可能包含复杂的计算步骤。同理，Command也可能触发一系列的动作。Martin Fowler说command这个词已经被用于很常见的概念，他提到另外两个词：modifiers 和 mutators。说实话，我觉得modifiers还不如commands，倒是mutators比较贴切。

### CQS的现实世界：状态机和返回值
CQS的核心是基于状态机原理的，任何返回值的动作是没有 side-effect 副作用的。这样你可以很信任任何Query动作，在任何地方安全的使用它们，不必顾虑它们的执行次序。这个概念是个很理想化的概念，和我们已有的某些概念和计算模型是不吻合的。例如，Martin Fowler在文章中提出堆栈操作中的pop函数。Pop函数在返回给外部顶层元素的同时，还改变了栈本身的状态。类似的例子还有iterator，调用next()意味着获得当前元素的同时，移动指针到下一个位置。显然这和CQS原则是违背的。

其深层的原因是，我们设计和理解计算模型，是划分了不同的Scope，即系统的范围的。任何Query操作对于操作的对象集而言，是不会影响到对象集的状态的。但是如果你将Query操作本身的历史，计数等概念纳入考虑，即扩大系统的范围，系统状态是改变了的。所以CQS原则是作用于一定范围的。

实际上，对于堆栈操作的例子，我们可以这么考虑。将需要外部返回的元素和栈都作为一个系统，这样系统的状态就包含两部分。对于栈的pop操作，我们可以在一个系统中改变状态。然后用另外一个操作来读取需返回的元素。这样的两步操作就可以符合CQS原则。但显然这样的设计是和我们的直觉相冲突的。一个好的设计不应该是过于数学化的，尤其是体系结构层面，或者像CQS这样企图作为通用原则的。

同理，对于command，很多时候我们都是期望有返回值的，例如告诉调用者是否成功，结果如何等等。严格执行CQS原则，要求有返回值的方法只能是纯读取工作的，这一个规范过于严厉了。从设计和实现的便利来看，对于非getter的方法，允许其返回结果可能带来设计上的优美。在面向过程的设计中，procedure返回数据或者结果是很自然的事。而面向对象的设计偏爱区分Query和Command的。

我们可以将方法的划分方式扩展一下，分为三类：

 - 修改器。修改目标系统的状态，无返回信息。
 - 读取器。读取目标系统的当前状态。
 - 返回结果的修改器。

前两种方法是符合CQS原则的，同时我们也注意到某些具有返回值的方法不是只读方法，返回值只是此修改器的副产品。对于读取器而言，返回值才是主要的。在工程实践中，我们可以尽量符合CQS原则设计我们的读取器，同时兼容第三种方式，允许修改提供返回值。如果我们认识到，有返回值的不一定是读取器，在实践中并没有什么问题。力求完美，但不过于苛求。

### CQS的缺点：原子操作
有时应用CQS原则，我们必须要割裂包含读写的原子操作。考虑到原子操作的特性，采用其他方式让设计满足CQS原则只会让设计和代码更丑陋。

``` java
private int x;
public int increment_and_return_x()
{
  lock x;   // by some mechanism
  x = x + 1;
  int x_copy = x;
  unlock x; // by some mechanism
  return x_copy;
}
```

### CQS原则 vs CQRS设计模式
其实这个CQS术语没有CQRS(Command and Query Responsibility Segregation)来的流行。
在Greg Young从设计(DDD, Domain Driven Design)和构架的角度提出CQRS概念的时候，由于和CQS的相似，他专门写了篇博客说明CQRS和CQS的区别，并正式命名为CQRS设计模式。

在Greg看来，CQS和CQRS具有相同的原理，不过CQRS是作用于Event之上，其目的是区分Command和Query的责任，以满足设计上对于CQ的不同的非功能性需求。
他认为相对CQS原则而言，CQRS可以作为对象粒度上的设计模式存在。

### References
 - [CommandQuerySeparation - martin fowler's bliki](http://martinfowler.com/bliki/CommandQuerySeparation.html)
 - [Command-query separation - wikipedia](http://en.wikipedia.org/wiki/Command%E2%80%93query_separation)
 - [Command query separation - Greg Young](http://codebetter.com/gregyoung/2009/08/13/command-query-separation/)


## 相关概念

### Referential Transparency
如果一个表达式可以被用它的输入求值后替换，而对于程序没有影响，就可以称为Referential Transparency，否则Referential Opacity。这个概念对于程序推导，程序的正确性验证都有很重要的意义。一个数学公式计算都是referential transparency的。我还不了解函数式编程，但是其是不是借鉴了这种思想呢？

### Design by contract
Design By Contract的理念适合做程序证明，但是由于它只是检查某些关键点的状态，而不能跟踪关键点之间的程序运行，也就无法很好地验证程序是否符合和满足对性能等非功能性的设计要求。很显然，我们不能对每条语句都插入检查点，否则就是将代码直接膨胀了一倍。而且，给程序的语句添加恰当的约束是很困难，不妨你想想如何给一个求和函数添加断言。在程序验证理论中，大多是用形式化的方式描述一个函数的输入输出的约束，即不变式，然后使用计算机自动推导验证。

另外在给定约束的情况下，用程序正确的实现约束也可能是很困难。受限于语言的描述能力，我们很难真正的实现一个完全匹配约束的方法或函数。在推导的过程中，约束和方法实现之间的差异会放大。所以从程序验证的角度来看，我们通常是实现了一个可接受的计算子集，来满足业务的需要。而在中间层的模块，我们甚至可以超过约束的范围来实现。

相比而言，用单位测试定义一个程序的概念，更有说服力。单元测试可以深入到每个函数和模块，在约束输入和输出的情况下，可以近似的用形式化的数学公式来描述。使用外部的数据驱动，可以很好地表现和描述代码的意图。在此基础上实现集成测试，进而很好地定义和检查系统级别的程序。用单元测试，使用外部数据和用例驱动设计和定义模块，是一种实用的理念和技术。
