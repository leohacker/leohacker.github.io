---
title: "Build JDK from source"
excerpt: 编译JDK源码
date: 2016-08-31 23:50
categories: [Java]
published: false
---

#### Repository Source Guidelines

There are some very basic guidelines:

 - Use of whitespace in source files (.java, .c, .h, .cpp, and .hpp files) is restricted. No TABs, no trailing whitespace on lines, and files should not terminate in more than one blank line.
 - Files with execute permissions should not be added to the source repositories.
 - All generated files need to be kept isolated from the files maintained or managed by the source control system. The standard area for generated files is the top level build/ directory.
 - The default build process should be to build the product and nothing else, in one form, e.g. a product (optimized), debug (non-optimized, -g plus assert logic), or fastdebug (optimized, -g plus assert logic).
 - The .hgignore file in each repository must exist and should include ^build/, ^dist/ and optionally any nbproject/private directories. It should NEVER include anything in the src/ or test/ or any managed directory area of a repository.
 - Directory names and file names should never contain blanks or non-printing characters.
 - Generated source or binary files should NEVER be added to the repository (that includes javah output). There are some exceptions to this rule, in particular with some of the generated configure scripts.
 - Files not needed for typical building or testing of the repository should not be added to the repository.


#### Basic Concepts

Bootstrap JDK.

The general rule is that the bootstrap JDK must be an instance of the previous major release of the JDK. Building JDK 9 requires JDK 8. JDK 9 developers should not use JDK 9 as the boot JDK, to ensure that JDK 9 dependencies are not introduced into the parts of the system that are built with JDK 8.

Add bootstrap JDK bin directory to PATH env variable.

file:///home/lljiang/repo/jdk9dev/README-builds.html
