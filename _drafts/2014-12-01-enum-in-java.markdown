---
layout: post
title: "Enum in Java"
date: 2014-12-01 22:00
comments: true
categories: [Java]
published: true
---

Enum是常常会用到的一个类。不过我的Java书籍还是Java1.5的时候的，仅有一页来讲解Enumeration。最近在整理Java的知识，所以特意写一篇备忘吧。用一个例子来说明Enum的特性：

``` java
public enum Currency {
    PENNY(1) {
        @Override
        public String color() {
            return "copper";
        }
    }, NICKLE(5) {
        @Override
        public String color() {
            return "bronze";
        }
    }, DIME(10) {
        @Override
        public String color() {
            return "silver";
        }
    }, QUARTER(25) {
        @Override
        public String color() {
            return "silver";
        }
    };

    private int value;
    private Currency(int value) {
        this.value = value;
    }

    public abstract String color();
}
```

 - 在开始，我们先声明枚举变量。
 - 枚举变量是可以用值来初始化的，而且一定static final的。
 - 构造函数必须是私有的。
 - 枚举变量实例是可以有函数方法的，而且可以声明抽象函数，然后在实例中Override。
 - 枚举可以有构造函数，变量，一般的方法，还可以实现接口。
 - 枚举是很好地实现单例模式的手段。
 - 枚举已经实现了Serialiable和Comparable接口。
 - 枚举变量每个都是单例，所以我们可以用`==`做比较，而不用equals。
 - 枚举从JVM层面，保证了无法用构造函数，防止了反射攻击。
 - 枚举定义了values()方法，方便iterator。
 - 枚举已经定义了toString()和valueOf()方法。
 - 别忘了还有EnumMap和EnumSet类。

