---
title: "Java Generic"
excerpt: Java Generic FAQ
date: 2017-01-23 13:21:31
modified: 2017-01-23
categories: [Java]
published: false
---
{% include toc %}


###
The getClass method returns an instantiation of class Class , namely Class<? extends X> , where X is the erasure of the static type of the expression on which getClass is called. In the example, the parameterization of the return type is ignored and the raw type Class is used instead.  As a result, certain method calls, such as the invocation of getAnnotation , are flagged with an "unchecked" warning.

``` java
void f(Object obj) {
  // Class  type = obj.getClass();      # unchecked warning
  Class <?> type = obj.getClass();
  Annotation a = type.getAnnotation(Documented.class);  
  ...
}
```
