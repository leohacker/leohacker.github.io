---
title: "CLDR - Number"
excerpt:
date: 2017-03-14 00:06:35
modified: 2017-03-14
categories: [TextProcessing]
published: false
---
{% include toc %}

LDML supports multiple numbering systems. The identifiers for those numbering systems are defined in the file bcp47/number.xml. For example, for the 'trunk' version of the data see bcp47/number.xml.

Details about those numbering systems are defined in supplemental/numberingSystems.xml. For example, for the 'trunk' version of the data see supplemental/numberingSystems.xml.

LDML makes certain stability guarantees on this data:

- Like other BCP47 identifiers, once a numeric identifier is added to bcp47/number.xml or numberingSystems.xml, it will never be removed from either of those files.
- If an identifier has type="numeric" in numberingSystems.xml, then
  - It is a decimal, positional numbering system with an attribute digits=X, where X is a string with the 10 digits in order used by the numbering system.
  - The values of the type and digits will never change.



-----

3.6.3 Time Zone Identifiers

LDML inherits time zone IDs from the tz database [Olson]. Because these IDs from the tz database do not satisfy the BCP 47 language subtag syntax requirements, CLDR defines short identifiers for the use in the Unicode locale extension. The short identifiers are defined in the file common/bcp47/timezone.xml.

The short identifiers use UN/LOCODE [LOCODE] (excluding a space character) codes where possible. For example, the short identifier for "America/Los_Angeles" is "uslax" (the LOCODE for Los Angeles, US is "US LAX"). Identifiers of length not equal to 5 are used where there is no corresponding UN/LOCODE, such as "usnavajo" for "America/Shiprock", or "utcw01" for "Etc/GMT+1", so that they do not overlap with future UN/LOCODE.

Although the first two letters of a short identifier may match an ISO 3166 two-letter country code, a user should not assume that the time zone belongs to the country. The first two letters in an identifier of length not equal to 5 has no meaning. Also, the identifiers are stabilized, meaning that they will not change no matter what changes happen in the base standard. So if Hawaii leaves the US and joins Canada as a new province, the short time zone identifier "ushnl" would not change in CLDR even if the UN/LOCODE changes to "cahnl" or something else.

There is a special code "unk" for an Unknown or Invalid time zone. This can be expressed in the tz database style ID "Etc/Unknown", although it is not defined in the tz database.

Stability of Time Zone Identifiers

Although the short time zone identifiers are guaranteed to be stable, the preferred IDs in the tz database (as those found in zone.tab file) might be changed time to time. For example, "Asia/Culcutta" was replaced with "Asia/Kolkata" and moved to backward file in the tz database. CLDR contains locale data using a time zone ID from the tz database as the key, stability of the IDs is cirtical.

To maintain the stability of "long" IDs (for those inherited from the tz database), a special rule applied to the alias attribute in the <type> element for "tz" - the first "long" ID is the CLDR canonical "long" time zone ID.

For example:

<type name="inccu" alias="Asia/Calcutta Asia/Kolkata" description="Kolkata, India"/>
Above <type> element defines the short time zone ID "inccu" (for the use in the Unicode locale extension), corresponding CLDR canonical "long" ID "Asia/Culcutta", and an alias "Asia/Kolkata".


-----

3.6.4 U Extension Data Files

The 'u' extension data is stored in multiple XML files located under common/bcp47 directory in CLDR. Each file contains the locale extension key/type values and their backward compatibility mappings appropriate for a particular domain. common/bcp47/collation.xml contains key/type values for collation, including optional collation parameters and valid type values for each key.

The 't' extension data is stored in common/bcp47/transform.xml.
