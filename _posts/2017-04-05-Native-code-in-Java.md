---
title: "Native code in Java"
excerpt:
date: 2017-04-05 01:41:24
modified: 2017-04-05
categories: [Java]
published: true
---

在Java的源码里面，有些实现部分是使用native代码来实现的，其实也就是用C/CPP来实现。在Java的代码里面，
使用关键字native来标记一个方法是native code。我们最容易发现是由native代码来实现的函数，很可能就是
位于`Object.java`中的hashcode, clone这些会出现在经典书籍中的函数。

```java
@HotSpotIntrinsicCandidate
protected native Object clone() throws CloneNotSupportedException;  
```

clone()函数是一个很有趣的函数。实现Cloneable接口的类，仅仅需要调用super.clone()就可以生成一个自身的
对象的克隆实例。这里有趣的地方在于，真正实现的代码在Object这类里面，而创建的对象却是调用类的真实对象，克隆
对象会正确的包含调用类的instance fields。而当我们好奇的想看看是怎么实现的，你就会发现在Java的代码中，仅仅
声明了一个返回Object的protected native方法。而且这个native方法还可以抛出一个Java异常，有趣吧。

对于如何正确实现一个Cloneable类，可以参考Effective Java。

那么，实现clone()的native代码在哪里呢？

 - 首先，我们找到OpenJDK是如何组织native代码的。Java的native代码是基于JNI技术，在实现上native代码的对应
 文件名是Java Class的`.c`版本。
 - 于是，我们可以在java.base模块发现好几个native目录，有各个平台依赖的native代码，也有`share/native`。

clone()的实现就在`Object.c`中。不过这里并没有真正的代码实现，不过还是有点线索的。

```c
static JNINativeMethod methods[] = {
    {"hashCode",    "()I",                    (void *)&JVM_IHashCode},
    {"wait",        "(J)V",                   (void *)&JVM_MonitorWait},
    {"notify",      "()V",                    (void *)&JVM_MonitorNotify},
    {"notifyAll",   "()V",                    (void *)&JVM_MonitorNotifyAll},
    {"clone",       "()Ljava/lang/Object;",   (void *)&JVM_Clone},
};

JNIEXPORT void JNICALL
Java_java_lang_Object_registerNatives(JNIEnv *env, jclass cls)
{
    (*env)->RegisterNatives(env, cls,
                            methods, sizeof(methods)/sizeof(methods[0]));
}
```

从上面的代码可以看出，这部分C代码定义了JVM_Clone方法，并将其注册为clone方法的native方法。那么怎么找到JVM_Clone函数呢？
我们可以使用OpenGrok这样的代码搜索引擎来查找JVM_Clone这个函数。

我们会发现，真正的实现在`hotspot/src/share/vm/prims/jvm.cpp`， hotspot仓库的jvm.cpp实现里面。


```c
// java.lang.Object ///////////////////////////////////////////////

JVM_ENTRY(jobject, JVM_Clone(JNIEnv* env, jobject handle))
  JVMWrapper("JVM_Clone");
  Handle obj(THREAD, JNIHandles::resolve_non_null(handle));
  const KlassHandle klass (THREAD, obj->klass());
  JvmtiVMObjectAllocEventCollector oam;

#ifdef ASSERT
  // Just checking that the cloneable flag is set correct
  if (obj->is_array()) {
    guarantee(klass->is_cloneable(), "all arrays are cloneable");
  } else {
    guarantee(obj->is_instance(), "should be instanceOop");
    bool cloneable = klass->is_subtype_of(SystemDictionary::Cloneable_klass());
    guarantee(cloneable == klass->is_cloneable(), "incorrect cloneable flag");
  }
#endif

  // Check if class of obj supports the Cloneable interface.
  // All arrays are considered to be cloneable (See JLS 20.1.5)
  if (!klass->is_cloneable()) {
    ResourceMark rm(THREAD);
    THROW_MSG_0(vmSymbols::java_lang_CloneNotSupportedException(), klass->external_name());
  }

  // Make shallow object copy
  const int size = obj->size();
  oop new_obj_oop = NULL;
  if (obj->is_array()) {
    const int length = ((arrayOop)obj())->length();
    new_obj_oop = CollectedHeap::array_allocate(klass, size, length, CHECK_NULL);
  } else {
    new_obj_oop = CollectedHeap::obj_allocate(klass, size, CHECK_NULL);
  }

  // 4839641 (4840070): We must do an oop-atomic copy, because if another thread
  // is modifying a reference field in the clonee, a non-oop-atomic copy might
  // be suspended in the middle of copying the pointer and end up with parts
  // of two different pointers in the field.  Subsequent dereferences will crash.
  // 4846409: an oop-copy of objects with long or double fields or arrays of same
  // won't copy the longs/doubles atomically in 32-bit vm's, so we copy jlongs instead
  // of oops.  We know objects are aligned on a minimum of an jlong boundary.
  // The same is true of StubRoutines::object_copy and the various oop_copy
  // variants, and of the code generated by the inline_native_clone intrinsic.
  assert(MinObjAlignmentInBytes >= BytesPerLong, "objects misaligned");
  Copy::conjoint_jlongs_atomic((jlong*)obj(), (jlong*)new_obj_oop,
                               (size_t)align_object_size(size) / HeapWordsPerLong);
  // Clear the header
  new_obj_oop->init_mark();

  // Store check (mark entire object and let gc sort it out)
  BarrierSet* bs = Universe::heap()->barrier_set();
  assert(bs->has_write_region_opt(), "Barrier set does not have write_region");
  bs->write_region(MemRegion((HeapWord*)new_obj_oop, size));

  Handle new_obj(THREAD, new_obj_oop);
  // Special handling for MemberNames.  Since they contain Method* metadata, they
  // must be registered so that RedefineClasses can fix metadata contained in them.
  if (java_lang_invoke_MemberName::is_instance(new_obj()) &&
      java_lang_invoke_MemberName::is_method(new_obj())) {
    Method* method = (Method*)java_lang_invoke_MemberName::vmtarget(new_obj());
    // MemberName may be unresolved, so doesn't need registration until resolved.
    if (method != NULL) {
      methodHandle m(THREAD, method);
      // This can safepoint and redefine method, so need both new_obj and method
      // in a handle, for two different reasons.  new_obj can move, method can be
      // deleted if nothing is using it on the stack.
      m->method_holder()->add_member_name(new_obj(), false);
    }
  }

  // Caution: this involves a java upcall, so the clone should be
  // "gc-robust" by this stage.
  if (klass->has_finalizer()) {
    assert(obj->is_instance(), "should be instanceOop");
    new_obj_oop = InstanceKlass::register_finalizer(instanceOop(new_obj()), CHECK_NULL);
    new_obj = Handle(THREAD, new_obj_oop);
  }

  return JNIHandles::make_local(env, new_obj());
JVM_END
```

整个的代码实现相对于其他Object的native方法要长很多，大概是因为有很多后续的操作吧。这里使用JVM_ENTRY宏组织
native方法，可以看出内存的拷贝使用很直接的方法。也可以找到抛出异常的代码。

以clone()这个函数为例子，我们大概就可以找到以后如何查询和分析native代码的思路了。
