---
title: "Reading JDK Source Code"
excerpt:
date: 2017-08-14 15:02:48
modified: 2017-08-14
categories: []
published: false
---
{% include toc %}

1. Use Void (Uppercase)

prevent the object initialization if permission check failed.

```
    private static Void checkPermission() {
        SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
            sm.checkPermission(new RuntimePermission("localeServiceProvider"));
        }
        return null;
    }
    private LocaleServiceProvider(Void ignore) { }

    protected LocaleServiceProvider() {
        this(checkPermission());
    }
```

2. Get the data file in module

```
InputStream in = Currency.class.getModule().getResourceAsStream("java/util/currency.data");
```
