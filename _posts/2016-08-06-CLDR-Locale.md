---
title: "CLDR - Locale"
excerpt: 解读CLDR - Locale
date: 2016-08-06 00:50
categories: [TextProcessing]
published: published
---
{% include toc %}

## 引言
Unicode Common Locale Data Repository ([CLDR](http://cldr.unicode.org/))是软件国际化的基石，它作为一个国际标准提供了构建国际化软件所需要的定义和数据。本文假设读者对于软件国际化有基本的了解，知道国际化是关于语言，地域，时间，数字，时区等用户配置相关的软件技术的统称。英语使用Locale这个概念和词汇，而这个词实际用中文很难准确翻译，所以在本文中直接使用英文，请参照下面的讲解仔细理解Locale这个词汇的含义。本文基于[LDML 技术报告](http://www.unicode.org/reports/tr35/)来解读CLDR。

## Locale

### Locale的概念
Locale对于初学者是一个模糊的概念，对于略有一些国际化知识的人又是一个容易误解的概念。在LDML报告开头的一个小节很好的解释了什么是**locale**。其中的关键是，我们要认识到Locale其实不等于语言和地域，或者它们的组合，它代表一个和用户loclae设置相关的数据集合。这是我迄今为止看到的最明白的讲解。我不能用一句话来概括人家几个段落，请认真阅读以下文字。

> The first issue is basic: what is a locale? In this model, a locale is an identifier (id) that refers to a set of user preferences that tend to be shared across significant swaths of the world. Traditionally, the data associated with this id provides support for formatting and parsing of dates, times, numbers, and currencies; for measurement units, for sort-order (collation), plus translated names for time zones, languages, countries, and scripts. The data can also include support for text boundaries (character, word, line, and sentence), text transformations (including transliterations), and other services.

> Locale data is not cast in stone: the data used on someone's machine generally may reflect the US format, for example, but preferences can typically set to override particular items, such as setting the date format for 2002.03.15, or using metric or Imperial measurement units. In the abstract, locales are simply one of many sets of preferences that, say, a website may want to remember for a particular user. Depending on the application, it may want to also remember the user's time zone, preferred currency, preferred character set, smoker/non-smoker preference, meal preference (vegetarian, kosher, and so on), music preference, religion, party affiliation, favorite charity, and so on.

> Locale data in a system may also change over time: country boundaries change; governments (and currencies) come and go: committees impose new standards; bugs are found and fixed in the source data; and so on. Thus the data needs to be versioned for stability over time.

> In general terms, the locale id is a parameter that is supplied to a particular service (date formatting, sorting, spell-checking, and so on). The format in this document does not attempt to represent all the data that could conceivably be used by all possible services. Instead, it collects together data that is in common use in systems and internationalization libraries for basic services. The main difference among locales is in terms of language; there may also be some differences according to different countries or regions. However, the line between locales and languages, as commonly used in the industry, are rather fuzzy. Note also that the vast majority of the locale data in CLDR is in fact language data; all non-linguistic data is separated out into a separate tree. For more information, see Section 3.10 Language and Locale IDs.

> We will speak of data as being "in locale X". That does not imply that a locale is a collection of data; it is simply shorthand for "the set of data associated with the locale id X". Each individual piece of data is called a resource or field, and a tag indicating the key of the resource is called a resource tag.

### Locale Identifier
用户locale是数据集，在使用中需要使用一个id来指定某个集合。常见的POSIX的locale表示有`en_US`, `zh_CN`，BCP47则提供了更丰富的subtag来表示locale中的概念。CLDR基于BCP47，是BCP47的超集。在使用Locale ID的时候，原则是尽可能用短的表示。

> Unicode LDML uses stable identifiers based on [BCP47](http://www.rfc-editor.org/rfc/bcp/bcp47.txt) for distinguishing among languages, locales, regions, currencies, time zones, transforms, and so on.

#### BCP47
BCP47由两个RFC文档组成。BCP stands for 'Best Current Practice'.

 - **Tags for Identifying Languages** [RFC5646](http://w3c.github.io/ltli/#bib-RFC5646)，定义了各种language tag的语法、形式和术语。
 - **Matching of Language Tags** [RFC4647](http://w3c.github.io/ltli/#bib-RFC4647)，描述几种用于匹配、比较和选择language tag的方案。

W3C和Java都使用BCP47，也就是都可以使用BCP风格的language tag表示方式，也采用BCP47的Language Tag匹配方案。

首先我们来看看CLDR中language id的EBNF范式。

```
unicode_language_id
="root"
| (unicode_language_subtag
    (sep unicode_script_subtag)?
  | unicode_script_subtag)
(sep unicode_region_subtag)?
(sep unicode_variant_subtag)* ;
```

unicode_language_id是在CLDR中BCP47的language tags的对应定义。常见的POSIX风格的locale id可以认为是language subtag + region subtag。所有的subtags都在IANA有[注册](http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry)。CLDR将这些subtag放在`common/validity/`目录下的文件里: language, script, region, variant, 也包括currency和unit这样和语言无关的subtag。

作为速查，在这里也抄录作为无定义(undefined/unknown)时使用的subtag值。

|-----------|-----|---------------------------------------|
|Code Type	|Value|	Description in Referenced Standards   |
|:----------|:----|:--------------------------------------|
|Language	  | und	|Undetermined language                  |
|Script	    | Zzzz|	Code for uncoded script, Unknown [UAX24]|
|Region  	  | ZZ  |	Unknown or Invalid Territory          |
|Currency	  | XXX	|The codes assigned for transactions where no currency is involved|
|Time Zone	| unk |	Unknown or Invalid Time Zone          |
|Subdivision|	ZZZZ|	Unknown or Invalid Subdivision        |
|-----------|-----|---------------------------------------|

[Language tags in HTML and XML](https://www.w3.org/International/articles/language-tags/)对于这些subtags有非常好的讲解。从CLDR的角度，上面的BNF范式定义的是Language ID，完整的Locale ID的
格式是`language-extlang-script-region-variant-extension-privateuse`，当然不用每个域都指定。这篇文档非常出色，请仔细阅读。

关于Language ID的连接符和大小写规范：

> The identifiers can vary in case and in the separator characters. The `-` and `_` separators are treated as equivalent. All identifier field values are case-insensitive. Although case distinctions do not carry any special meaning, an implementation of LDML should use the casing recommendations in [BCP47], especially when a Unicode locale identifier is used for locale data exchange in software protocols. The recommendation is that: the region subtag is in uppercase, the script subtag is in title case, and all other subtags are in lowercase.

scripts subtags仅应该在需要明确指定语言的变种的时候使用。典型的script subtags是中文的Hans和Hant，还有Bopomofo。以前我们用`zh_CN`隐含表示使用简体，用`zh_TW`隐含表示使用繁体，实际上使用Hans和Hant是正确的方法。

如果想指定没有script呢？例如语音材料。

> If you specifically want to indicate that content is not written, there is a subtag for that. For example, you could use **en-Zxxx** to make it clear that an audio recording in English is not written content.

BCP47有扩展(extension)机制，可以使用单字符来表示某一个扩展，例如'x'表示私用扩展。CLDR维护'u'和't'扩展。

  - BCP47 U Extension, locale扩展，可以在正常的locale id后面指定如农历，电话号码簿等locale信息。
  - BCP47 T Extension, transformations扩展，可以指定文字的转换，例如transliteration(某些文字的拉丁转写)。

Unicode Locale扩展包含日历，货币，排序，数字，段行，计量，时区等的定义。所以还是要仔细研究的，相应的CLDR文件在bcp47目录下，可以查阅LDML的3.6.1节Key And Type Definitions。时区的数据采用[tz database](http://www.iana.org/time-zones)，由于tz database的id不符合BCP47语法要求，所以CLDR在bcp47/timzezone.xml中定义了缩短的ID。这种短ID尽可能使用5个字符的，国家(2)+地区(3)，的表示方式。如果不是5个字符，就表明没有对应的locale，例如utcw01对应Etc/GMT+1。文档中提到，时区不属于国家，不能假设前两个字符就是这个时区所属于的国家，并举了一个有趣的例子。如果夏威夷离开美国而加入加拿大，它的CLDR时区符号还是ushnl，而不会改变。

> The 'u' extension data is stored in multiple XML files located under common/bcp47 directory in CLDR. Each file contains the locale extension key/type values and their backward compatibility mappings appropriate for a particular domain. common/bcp47/collation.xml contains key/type values for collation, including optional collation parameters and valid type values for each key.

> The 't' extension data is stored in common/bcp47/transform.xml.

extlang和variant是比较少用到的，所以不在这里解读。同理不解读U Extension中的Subdivision和T Extension。

References:

- [BCP47](https://tools.ietf.org/html/bcp47)
- [IANA Language Subtag Registry](http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry)

#### BCP47 Language Tag Conversion
BCP47 Language Tag也不是完全等价于CLDR的Language ID。

A valid [BCP 47] language tag can be converted to a valid Unicode language/locale identifier by performing the following transformation.

1. Canonicalize the language tag (afterwards, there will be no extlang subtag)
1. Replace the BCP 47 primary language subtag "und" with "root" if no script, region, or variant subtags are present
1. If the BCP 47 primary language subtag matches the type attribute of a languageAlias element in [Supplemental Data](http://www.unicode.org/reports/tr35/tr35-info.html#Supplemental_Data), replace the language subtag with the replacement value.
    1. If there are additional subtags in the replacement value, add them to the result, but only if there is no corresponding subtag already in the tag.
1. If the BCP 47 region subtag matches the type attribute of a territoryAlias element in Supplemental Data, replace the language subtag with the replacement value, as follows:
    1. If there is a single territory in the replacement, use it.
    1. If there are multiple territories:
        1. Look up the most likely territory for the base language code (and script, if there is one).
        1. If that likely territory is in the list, use it.
        1. Otherwise, use the first territory in the list.

Examples:

|-------------|---------------|---------|
| Original    | Result        | Comment |
|:-           |:-             |:-       |
|en-US        |en-US          |         |
|und          |root           |         |
|und-US       |und-US         |no changes, because region subtag is present |
|und-u-cu-USD |root-u-cu-usd  |changed, because region subtag is present |
|cmn-TW       |zh_TW          |language alias  |
|sr-CS        |sr-RS          |territory alias |
|sh           |sr-Latin       |multiple replacement subtags, 3.1 above |
|sh-Cyrl      |sr-Cyrl        |no replacement with multiple subtags, 3.1 above |
|hy-SU        |hy-AM          |multiple territory values, 4.2 above. <territoryAlias type="SU" replacement="RU AM AZ BY EE GE KZ KG LV LT MD TJ TM UA UZ" …/> |

sh -> sr-Latin， sh是sr的别名，所以替换，同时因为没有script subtags，所以附加Latin。而下一条，由于已经有Cyrl，所以仅替换为sr。在CLDR的languageAlias元素中，实际上定义了别名到标准名称的转换。

#### Locale Identifier on Unix
> On POSIX platforms such as Unix, Linux and others, locale identifiers are defined by [ISO 15897](https://en.wikipedia.org/wiki/ISO_15897), which is similar to the BCP 47 definition of language tags, but the locale variant modifier is defined differently, and the character set is included as a part of the identifier. It is defined in this format: `[language[_territory][.codeset][@modifier]]`.                          --- from wikipedia

和CLDR的一个较大不同点在于将编码也作为id的一部分。术语POSIX Locale等价于C Locale，也就是在没有指定任何实际的Locale的情况下，glibc函数遵循的缺省行为。在CLDR中，C Locale的对应术语叫root locale，BCP47对应的primary langauge tag `und`。

```
# Output of the command 'locale' on Ubuntu 16.04
# enumerate all posix locale environment variables.
LANG=en_US.UTF-8
LANGUAGE=en_US:en
LC_CTYPE=en_US.UTF-8
LC_NUMERIC=en_US.UTF-8
LC_TIME=en_US.UTF-8
LC_COLLATE="en_US.UTF-8"
LC_MONETARY=en_US.UTF-8
LC_MESSAGES="en_US.UTF-8"
LC_PAPER=en_US.UTF-8
LC_NAME=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
LC_ALL=
```

The Open Group组织的标准The Single Unix Specification的[Locale](http://pubs.opengroup.org/onlinepubs/007908799/xbd/locale.html#tag_005_002)部分详细的描述了Unix平台上的locale环境变量和locale定义文件。我们可以看到标准定义的环境变量比Ubuntu中实现的要少。在C代码中，我们通过函数`setlocale()`来设置程序的locale。[环境变量](http://pubs.opengroup.org/onlinepubs/007908799/xbd/envvar.html)这篇文章中，描述了环境变量对于哪个函数有影响，可以作为参考。

Locale定义文件是源文件，我们需要使用命令`localedef`将其编译为二进制文件。这些源文件通常位于`/usr/share/i18n/locales`目录，相应的二进制文件位于`/usr/lib/locale`，可以查看localedef的manpage了解这些信息。两篇参考文献都详细的描述了locale定义文件，大部分雷同，不过在Base Specification中提供了POSIX Locale的定义。在`/usr/share/i18n/charmaps`存放了各种字符集(charset)的定义文件，也就是编码的定义。

References:

 - [Locale in The Open Group Base Specification](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap07.html)
 - [Locale in THe Single Unix Specification](http://pubs.opengroup.org/onlinepubs/007908799/xbd/locale.html#tag_005_002)

#### Locale Identifier on Windows Platforms
> Windows uses specific language and territory strings. The locale identifier (LCID) for unmanaged code on Microsoft Windows is a number such as 1033 for English (United States) or 1041 for Japanese (Japan). These numbers consist of a language code (lower 10 bits) and culture code (upper bits) and are therefore often written in hexadecimal notation, such as 0x0409 or 0x0411.

> Starting with Windows Vista, new functions[2] that use BCP 47 locale names have been introduced to replace nearly all LCID-based APIs.

References:

- [Microsoft Locale ID Chart with decimal equivalents](https://msdn.microsoft.com/en-us/library/ms912047(WinEmbedded.10).aspx)
- [LCID Structure](https://msdn.microsoft.com/en-us/library/cc233968.aspx)


#### Locale Identifier on Web
W3C采用BCP47标准。

> Identification of language and locale has a broad range of applications within the World Wide Web. Existing standards which make use of language identification include the xml:lang attribute in [XML10](http://w3c.github.io/ltli/#bib-XML10), the lang and hreflang atttributes in [HTML](http://w3c.github.io/ltli/#bib-HTML), the language property in [XSL10](http://w3c.github.io/ltli/#bib-XSL10), and the :lang pseudo-class in CSS [CSS3-SELECTORS](http://w3c.github.io/ltli/#bib-CSS3-SELECTORS). Language tags are also used to identify locales, such as in the Unicode Common Locale Data Repository or "CLDR" project [CLDR](http://w3c.github.io/ltli/#bib-CLDR).

> Many other W3C and Web-related specifications use language tags:
> - XHTML 1.0 uses language tags in the HTML lang attribute and the XML xml:lang attribute, as well as the hreflang attribute.
> - HTTP uses language tags in the Accept-Language and Content-Language headers.
> - SMIL and SVG can use language tags in the switch statement.
> - CSS and XSL use language tags for detailed style control.
>
> Note also that language information can be attached to objects such as images and included audio files.

References:

- [Language Tags and Locale Identifiers for the World Wide Web](https://www.w3.org/TR/ltli/)

### Locale Inheritance and Matching

#### Locale Inheritance
Locale主要以语言为核心来组织数据，那么在相同的语言下不同文字和地域的locale数据其实共同的。所以在组织locale数据的时候，是采用递增的方式，在通用语言部分存放大部分的数据，对于特定的locale仅仅存放特有的数据。这就是Locale的继承关系。在某些特殊情况下，孩子locale可以指定没有某个父辈locale中数据，这是可能的哦。Locale的继承关系，也不是移除地域符号那么简单。例如zh_Hant的parent就是root，而不是zh。(zh_Hant的collation还是要遵循zh)所以在CLDR中定义了parentLocale来覆盖正常的继承关系。我们可以在LDML Part6: Supplemental找到相应的定义。

缺省值

> For identifiers, such as language codes, script codes, region codes, variant codes, types, keywords, currency symbols or currency display names, the default value is the identifier itself whenever if no value is found in the root. Thus if there is no display name for the region code 'QA' in root, then the display name is simply 'QA'.

有些locale数据是仅仅与地域相关的，例如货币，计量，星期的约定。在LDML中举了一个例子，fr_US是一个不存在的locale，那么当用于货币时，货币的符号遵循语言fr的部分，货币数量格式遵循US的部分。如果一个locale没有指定地域，那么地域相关的设定用[Likely Subtags](http://www.unicode.org/reports/tr35/#Likely_Subtags)来推断。

References:

- [Likely Subtags](http://www.unicode.org/cldr/charts/latest/supplemental/likely_subtags.html)


#### Locale Lookup Fallback
在LDML4.1.1小节，描述了Bundle Lookup和Item Lookup。Bundle Lookup会按照zh_CN, zh, default locale, root的顺序查找合适的locale。而Item Lookup不使用default locale，在没有找到当前指定语言包zh的情况下，会去找root_alias*(语言使用root，其他尽可能的找别名)。使用缺省locale的方式对于message的显示是有效的，地域或许也可以从language中去推导，但是对于排序，断句等就不适合，所以对于它们使用root。

#### Locale Matching
在RFC4647中定义了几个用于选择Locale的概念：

A **language range** is a string similar in structure to a language tag that is used for "identifying sets of language tags that share specific attributes".

A **language priority** list is a collection of one or more language ranges identifying the user's language preferences for use in matching. As the name suggests, such lists are normally ordered or weighted according to the user's preferences. The HTTP [RFC2616](http://w3c.github.io/ltli/#bib-RFC2616) Accept-Language[RFC3282](http://w3c.github.io/ltli/#bib-RFC3282) header is an example of one kind of language priority list.

A **basic language range** is simply a language tag used to express a language preference. An **extended language** range allows a more expressive set of language preference through the use of a wildcard subtag `*`.

CLDR的4.4 Language Matching描述了相应的算法，[Java Tutorial](https://docs.oracle.com/javase/tutorial/i18n/locale/matching.html)提供了如何使用这些概念的例子，还是比较清楚的。


### CLDR Data

数字 bcp47/number.xml or supplemental/numberingSystems.xml


References:

- [ICU Locale Demo](http://demo.icu-project.org/icu-bin/locexp) 应该没有包含所有的信息，不过在这里可以找到在某个locale下的数据，尤其是当你想找语言，文字，地域的翻译时。
