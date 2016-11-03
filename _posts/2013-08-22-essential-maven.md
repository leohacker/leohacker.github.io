---
title: "Essential Maven"
excerpt: 介绍Maven的基本概念
date: 2013-08-22 10:27
categories: [Java]
published: true
---
{% include toc %}

## Maven 是什么

[Maven](maven.apache.org) 是Apache组织下的构建工具(build tool)开源项目。Maven本身是插件系统的构架，内核很小，主要的功能都依靠插件实现。Maven是以Java Build Tool的角色出现在人们的视野中的，是目前Java构建工具的事实上的标准。也因为大量的插件都是围绕Java程序的构建生命周期和开发模式创造出来的，所以Maven基本也就是在Java开发中使用。其实每个语言都会有自己的倾向性的构建工具，特别为自己的开发模式所定制。

在Java开发中，面向对象和模块化是随处可见的，需要引入大量的库，也就会有依赖管理的问题。依赖管理也是最初的Java构建工具Ant相比Maven所缺失的地方。Maven项目的配置都定义在一个POM文件，其中很大的一部分就是定义依赖软件包以及版本。Maven项目从代码结构上就强调单元测试，将源代码和测试代码分别放在不同的两个目录下。也正是因为，POM文件的这种定义方式，注定了Maven基本只有Java项目才会使用。试想谁会在其他语言的项目中，用Maven定义jar包的方式定义软件的元数据呢？谁会在自己Home目录下创建一个.m2目录作为本地仓库用来存放库文件呢？RPM管理系统级别的软件包，包定义的元数据比Maven的复杂的多。Python的PIP管理python模块的下载安装，而且python是动态的脚本语言，不需要编译步骤，也不会需要一个本地仓库。

### Jave程序的构建过程
与用于C语言的make类比，我们常用的build tool都提供clean和compile的功能或者目标。make不知道怎么去定义具体的build动作，我们是在Makefile文件中定义源码之间的依赖关系，以及在依赖列表中的文件有更新时的动作。例如Clean通常是一个Makefile中定义的一个目标，具体的执行语句由程序员定义。

Maven是在总结前人的经验的基础上的结果。在Maven的理念中，代码的构建过程可以描述为一个生命周期(life cycle)，可以涉及编译、测试、打包、部署，还预留了其他阶段的钩子接口用于其他任务，例如测试覆盖率，生成报告等等。实际上Maven将构建过程理解为多个生命周期：clean,default,site。在default生命周期，还包括compile,package等几个主要阶段。在每个阶段，完成不同的构建任务。这样整个构建过程已经经过了抽象和统一，每个任务可以由插件来完成。可见Maven是一个非常灵活的框架。

<!-- more -->

相比Makefile而言，就是整个编译的目标简化为clean和compile源码两个目标。源码编译的依赖关系是Java代码中import语言描述定义的，我们就不需要写具体类层面的依赖编译命令，这主要得益于Java的编译方式，但也的确简化了Maven的模型。所以其实在不考虑软件包依赖管理的情况下，Maven的POM文件可以仅仅简单的定义产出的软件包的信息。

一般的Java程序在编译完成后，只是一堆.class文件和目录，我们需要有个package的步骤将它们打包，所以我们常用的maven命令是packge，而不是compile。
``` bash
$ maven clean package
```

一个典型的Java程序需要引入很多第三方库，而不是什么都是自己写。在用Ant管理的项目中，我们通常有一个lib目录用来存放所有项目需要的库文件。如果缺少某个库，我们就需要到网上去查找，找到官方网站下载软件包。有在早期的RedHat Linux发行版上使用经验的用户，很容易联想到当初为了让一个软件运行起来满世界找软件包的情景。YUM以集中式仓库提供软件包的方式大大的减轻的系统管理员的痛苦。Maven的依赖管理也是构建在这样的一个理念之上。在Maven源码树中，没有lib目录，只有源码和测试源码目录。在用户目录的下有个.m2的目录，它是在用户机器上的一个本地仓库，存放项目中需要的所有jar包。在编译时，maven首先访问这个仓库，获得需要依赖的jar包完成编译。如果在本地仓库没有找到相应版本的jar包，maven会从系统默认的中央仓库下载一份，放在本地仓库中。下载过的软件包都会放在这.m2目录下。

所以我们已经清楚的了解，maven的关键特性是

- 标准的构建过程
- 插件式的构架
- 依赖管理
- 软件包仓库。

## Maven的依赖管理

### Maven如何定义软件包
Maven需要解决编译中的依赖问题，就需要区分任何一个软件包，包括同一个软件包的不同版本，给每一个包一个ID。所以Maven引入了软件包的元数据：坐标(Coordinate)。

``` xml
<groupId>org.apache.httpcomponents</groupId>
<artifactId>httpclient</artifactId>
<version>4.2</version>
```

- `groupId`     定义所属的项目。如果是比较大的框架项目，如SpringFramework，`groupId` 可以是spring-core这样子框架模块的形式。groupId也采用反向公司域名的方式，便于区分。
- `artifactId`  定义包的名称。用maven生成的包，会以`artifactId`作为文件的名称，而一般的项目也由多个包/模块组成，所以通常采用项目名称做前缀。
- `version`     定义包的版本。
- `packaging`   定义打包的方式。

软件包的名称是根据定义的坐标信息确定的，一般为`artifactId-version.jar` 。根据打包方式的指定，文件扩展名可以是jar或者war。和RPM打包类似，除了生成二进制形式的软件包，还可以生成包含javadoc和source的包。这样的包，会有`artifactId-version-classifier.packaging`这样的名称。classifier不是软件包的坐标，因为`groupId`,`artifactId`,`version`三项元数据已经可以定位软件包了。classifier的作用是从一份源码中产生的多个内容不同的jar包。

### 依赖范围
在POM文件中，`dependencies`定义这个包依赖的其他软件包列表，每个软件包以`dependency`的方式包括进来，软件包以坐标的形式描述。通常Java的项目都会用到JUnit作为单元测试工具，留意依赖的定义，会发现多一个描述tag `scope`。`scope`用来定义这个依赖的应用范围。

``` xml
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
```

运行Java程序，除了系统默认的jar包外，其他依赖的包需要放在`classpath`上才能找到。在Maven项目的开发中，我们通常有三种应用场景：compile, test, runtime。JUnit这样的软件包就是只在测试阶段才使用的软件包，有些包则是运行时依赖。

依赖的范围可以是：

- `compile` 编译、测试、运行都需要。默认scope。
- `test`    测试时依赖。
- `runtime` 运行时依赖。编译时不需要，但是测试和运行时必须明确指出。例如JDBC的驱动。
- `provided` 系统提供的依赖。例如容器提供的依赖包。编译和测试都需要，但是不必打包到项目的软件包中。
- `import`  导入性依赖，用于导入其他POM文件中定义的配置。

### 依赖的解析
类似其他的包管理机制，在声明依赖的时候，我们只需要声明直接使用的依赖包。项目导入的依赖包所依赖的其他软件包，Maven会自动的分析传递性依赖。在解析依赖包的时候，可能会遇到多处声明依赖的情况，即依赖冲突，尤其是你不清楚传递性的依赖包。Maven遵循两个原则：

- 路径最近原则。在依赖路径上近的优先。
- 优先声明原则。在同等路径长度的情况下，先声明的优先。

Maven在解析依赖的时候，对于冲突的依赖，可以采用排除的方式。例如某个库jar包有个依赖包，项目自己也用这个依赖包，不过项目指定了一个更新的版本。那么项目可以在声明库的依赖的时候，用`exclusions`来排除库的低版本依赖包。在声明`exclusion`的时候，不需要指定版本。

``` xml
<dependency>
    <groupId>foo</groupId>
    <artifactId>foo-bar</artifactId>
    <version>1.0.0</version>
    <exclusions>
        <exclusion>
            <groupId>library</groupId>
            <artifactId>library-low-version</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

### 可选依赖
Maven允许一种特殊的依赖关系: optional 。可选依赖的应用场景是，当你开发了一个软件包，例如某种框架，设计上是兼容多种数据库实现的，但是在具体的项目例子中只能使用一种数据库技术。数据库方案的采用是互斥的，但是框架设计时不确定用哪一种。在框架中可以声明两个依赖，都是optional依赖。

``` xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-driver</artifactId>
    <version>1.0.0</version>
    <optional>true</optional>
</dependency>
<dependency>
    <groupId>postgresql</groupId>
    <artifactId>postgre-driver</artifactId>
    <version>1.0.0</version>
    <optional>true</optional>
</dependency>
```

### 依赖分析工具
Maven支持使用`dependency`插件分析项目的依赖关系。

``` bash
# 查看项目的已解析依赖
$ mvn dependency:list

# 查看项目的依赖树
$ mvn dependency:tree

# 分析依赖关系
$ mvn dependency:analyze
```

在依赖关系的分析结果中，Used undeclared dependencies 指项目中用到但是没有显示声明的依赖。应该分析这种依赖，如果这个包被项目直接import使用了，但是被传递性依赖隐形解决的，这个依赖关系就不可靠。对于Unused declared dependencies，一般应该删除。不过要注意分析，因为分析工具只会分析编译源码和测试代码用到的依赖，不会获得运行时需要的依赖。

- 要显式声明在项目中直接用到的依赖
- 删除未使用的依赖时要小心

### 多模块
项目通常有多个模块，所以我们希望一次可以构建多个模块。每个模块有自己的POM文件，另外创建一个聚合项目管理所有模块。聚合项目的packaging的值必须是pom，表示这不是一个真实的项目，不产生jar包或者war包。`module`的值是模块目录对于当前POM文件的相对路径。显然，为了代码结构，我们通常将模块作为整个项目的子目录，而在项目的根目录下放聚合POM。

``` xml
<groupId>aggregator project</groupId>
<artifactId>aggregator</artifactId>
<version>1.0.0</version>
<name>Aggregator project</name>
<packaging>pom<packaging>
<modules>
    <module>module A</module>
    <module>module B</module>
</modules>
```

当我们管理多个模块的时候，每个模块都会定义相同的`groupId`和`version`，因为他们属于同一个项目，采用相同的发布进度。而且在多个模块之间很可能采用相同的依赖关系和插件配置。所以我们可以创建一个parent pom文件，抽取所有相同的配置到parent pom文件，模块POM文件继承在parent中的设置。

在模块POM文件中，定义parent模块的坐标信息。
``` xml
<parent>
    <groupId>parent project</groupId>
    <artifactId>parent</artifactId>
    <version>1.0.0</version>
</parent>
```

我们可以将各个模块都使用的依赖关系都是抽取到parent pom文件中。但是不能简单地在parent pom文件中声明dependencies，那样所有的模块都会拥有这些依赖，不管需不需要。所以我们在parent模块中定义`dependencyManagement`，管理所有的依赖关系的定义，尤其是版本信息。而模块的POM文件定义使用哪些依赖，而不必定义版本。这样我们需要更新依赖的时候，只需要修改parent pom文件。同样地原理也适用于plugin管理，在parent pom中定义`pluginManagement`。为了方便书写，我们可以使用`properties`来定义变量。

``` xml
<properties>
    <spring.groupId>org.springframework</spring.groupId>
    <spring.version>2.5.6</spring.version>
</properties>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>${spring.groupId}</groupId>
            <artifactId>spring-core</artifactId>
            <version>${spring.version}</version>
        </dependency>
    </dependencies>
</dependencyManagement>

<build>
    <pluginManagement>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
                <version>2.1.1</version>
                <executions>
                    <execution>
                        <id>attach-sources</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>jar-no-fork</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </pluginManagement>
</build>
```
parent pom和aggregator pom作用不同，不过都可以理解为模块的parent。一个是配置的parent，一个是module编译关系的parent，很自然我们可以用一个pom文件来组织所有这些信息。

如果觉得spring框架的依赖管理列表很长，我们甚至可以采用将spring框架的依赖列表单独写成一个POM文件，然后在parent pom文件中import这个POM文件。依赖里面的`type`就对应软件包信息定义里的`packaging`。下面的例子，在parent pom中导入一个独立的spring框架的依赖定义文件。

``` xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>spring framework</groupId>
            <artifactId>framework dependency definition</artifactId>
            <version>1.0.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

## Maven的插件
Maven是管理构建过程的工具，所以如何完成每个阶段的任务是Maven的核心。仅仅依靠默认的插件是不足以满足实际项目的需求的。理解Maven的插件系统是如何运作的，也就能够让Maven实现定制化的构建。

Maven有三个相互独立的生命周期，clean,default和site。default生命周期中常用的阶段有：compile,test,package,install,deploy。site生命周期中有site,site-deploy。

Maven定义了抽象的生命周期阶段，具体阶段的任务是由插件完成的。插件目标(plugin goal)定义了可以完成的任务目标。一个插件可以有多个目标，例如dependency插件可以有目标:analyze,tree,list。一个阶段可以绑定多个插件目标，插件声明的先后顺序决定了目标的执行顺序。同一个阶段甚至可以绑定来自同一个插件的多个目标，只要符合你的想法。

我们通常在命令行上指定的是生命周期的阶段，也可以直接指定插件目标。Maven核心为主要的阶段默认绑定了核心插件的目标，执行这个生命周期阶段，就会调用相应地插件目标。指定插件目标要指定插件的名称和具体的目标，插件名称很长，所以通常使用插件的前缀，`plugin-prefix:goal`。插件前缀的定义是在插件仓库中元数据中定义的。

``` bash
# 生命周期阶段
$ mvn clean package

# 插件目标
$ mvn dependency:analyze
```

Maven只给几个重要的生命周期阶段绑定了默认的插件，其他的阶段需要自定义绑定插件目标。生命周期阶段和插件目标的默认绑定关系是受项目的打包类型决定的。绑定插件，就是配置插件的任务绑定。在插件定义部分，定义`executions`，每个`execution`配置一个任务，`id`是执行任务的名称，`phase`是生命周期阶段，`goals`配置插件目标。还可以有`configuration`定义任务的配置。以下就是将maven-clean-plugin插件的clean目标绑定到clean阶段。

``` xml
<build>
  <plugins>
    <plugin>
      <artifactId>maven-clean-plugin</artifactId>
      <version>2.4.1</version>
      <executions>
        <execution>
          <id>default-clean</id>
          <phase>clean</phase>
          <goals>
            <goal>clean</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

在插件的定义中，也可以定义插件的全局配置。例如配置maven-compiler-plugin，告诉它使用Java的1.6版本。那么所有属于这个插件的目标都使用这个配置。
``` xml
<build>
  <plugins>
    <plugin>
      <artifactId>maven-compiler-plugin</artifactId>
      <version>2.1</version>
      <configuration>
        <source>1.6</source>
        <target>1.6</target>
      </configuration>
    </plugin>
  </plugins>
</build>
```

定义插件的时候，不一定要配置`phase`也能执行。这是因为在插件编写的时候，已经定义了默认的绑定阶段。而且在上面的例子，没有指定`groupId`，是因为maven自带的插件已经超级POM中声明过。

我们可以使用`maven-help-plugin`查看插件的详细信息。

``` bash
mvn help:describe -Dplugin=plugin-groupid:plugin-artifactid:version -Ddetail
```

## Maven的仓库
任何软件包管理都需要仓库技术的支持。Maven项目支持本地仓库和远程仓库。本地仓库是远程仓库的cache系统。中央仓库是由权威机构维护的远程软件包仓库，各个项目都会向中央仓库提交自己的软件包。远程仓库不一定是唯一的，例如JBoss就可能放在自己的远程仓库中。我们可以在配置中设置多个远程仓库来获得软件包。

Maven默认的中央仓库是apache maven项目维护的。Maven区分依赖和插件的仓库，依赖仓库用`repositories`定义，插件用自己的仓库`pluginRepositories`定义。不过在默认的配置中，它们指向同一个仓库。插件也是一个个jar包，所以也是以坐标的形式定位和组织。我们不必去手动查找和下载插件，和依赖一样，当定义使用这个插件后，maven会将插件也下载到本地仓库中。

本地仓库在用户的HOME目录下，默认是.m2目录。`mvn install`是将生成的软件包安装到本地仓库中，供其他项目使用。

常见的远程仓库有:

- jave.net http://download.jave.net/maven/2
- JBoss http://repository.jboss.com/maven2/

``` xml
  <repositories>
    <repository>
      <snapshots>
        <enabled>false</enabled>
      </snapshots>
      <id>central</id>
      <name>Central Repository</name>
      <url>http://repo.maven.apache.org/maven2</url>
    </repository>
  </repositories>
  <pluginRepositories>
    <pluginRepository>
      <releases>
        <updatePolicy>never</updatePolicy>
      </releases>
      <snapshots>
        <enabled>false</enabled>
      </snapshots>
      <id>central</id>
      <name>Central Repository</name>
      <url>http://repo.maven.apache.org/maven2</url>
    </pluginRepository>
  </pluginRepositories>
```

远程仓库管理release和snapshots软件包。对于导入的第三方软件包，不推荐使用snapshot版本，尤其是插件。所以通常配置关闭snapshot的版本，snapshot应该只应用在自己正在开发的组件。

还可以配置远程仓库的自动更新检查和下载校验功能。`updatePolicy`设置从远程仓库检查更新的频率。默认是daily。可选的是：

- never     从不检查更新
- always    每次都检查
- daily     每天检查

`checksumPolicy`配置校验和失败的策略。默认是warn。

- warn      输出警告信息
- fail      构建失败，停止构建
- ignore    忽略校验和错误

如果远程仓库需要认证，在settings.xml中配置服务器的认证信息。远程仓库一般不需要认证，认证配置主要用于Nexus私服。`id`用来匹配仓库的定义的`id`。POM文件是应该提交到SCM代码仓库里的，settings.xml因为包含私密信息，不能提交。
``` xml
<servers>
  <server>
    <id>repository server</id>
    <username>repo-user</username>
    <password>repo-pwd</password>
  </server>
</servers>
```

Nexus服务器是用来建立team级别的私有中央服务器，主要的作用是代理其他远程服务器。我们可以采用定义远程仓库的方式，定义central仓库指向Nexus服务器，覆盖超级POM文件中的默认定义。也可以用定义镜像的方式，将指向中央服务器的请求重定向到镜像服务器。

``` xml
<mirrors>
  <mirror>
    <id>Nexus</id>
    <name>Nexus Repository</name>
    <url>http://local.address/maven2/</url>
    <mirrorOf>*</mirrorOf>
  </mirror>
</mirrors>
```
mirrorOf的值可以是：

- \* 镜像所有远程仓库
- repo1,repos2 镜像repos1和repos2仓库
- external:* 匹配所有远程仓库

需要注意的是，镜像仓库会完全屏蔽被镜像仓库，当镜像仓库不稳定或者停止服务的时候，Maven会无法访问原来的被镜像仓库。使用Nexus私服并且配置Nexus为镜像服务器，可以简化用户在settings.xml中的配置，不过需要在Nexus中加入所有项目需要的远程仓库。我觉得也可以在镜像设置中，明确镜像的是哪几个服务器，例如只镜像著名的中央仓库，然后用户可以根据项目需要，在POM文件或者settings.xml文件中加入特别的仓库。最好是只在settings.xml文件中定义仓库信息。可以将不包含登陆信息的settings.xml保存在代码仓库中，方便小组共享。

## References
本文参考了许晓斌的Maven实战一书。《Maven实战》内容很充实，涵盖Maven应用的原理和实践，被同事成为神书。不过略有遗憾的地方是，没有对于一些插件的应用做详细的讲解。有些章节也没有写得必要。我总觉得Maven应该是可以用一篇文章讲明白原理的工具，所以有这篇Essential Maven。而且在日常的使用中，好的模板文件对于理解Maven也很重要。

- Template files of pom.xml and settings.xml
