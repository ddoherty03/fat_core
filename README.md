[![Build Status](https://travis-ci.org/ddoherty03/fat_core.svg?branch=master)](https://travis-ci.org/ddoherty03/fat_core)

# FatCore

fat-core is a simple gem to collect core extensions and a few new classes that
I find useful in multiple projects.  The emphasis is on extending the Date
class to make it more useful in financial applications.

## Usage

You can extend classes individually by requiring the corresponding file:

```
    require 'fat_core/array'
    require 'fat_core/bigdecimal'
    require 'fat_core/date'
    require 'fat_core/enumerable'
    require 'fat_core/hash'
    require 'fat_core/kernel'
    require 'fat_core/numeric'
    require 'fat_core/range'
    require 'fat_core/string'
    require 'fat_core/symbol'
```

Or, you can require them all:

```
    require 'fat_core/all'
```

Many of these have little that is of general interest, but there are a few
goodies.

### Date

For example, the `Date` class adds two methods for determining whether a given
date is a US federal holiday as defined by federal law, including such things as
federal holidays established by executive decree:

```
    require 'fat_core/date'
    Date.parse('2014-05-18').fed_holiday?  => true # It's a weekend
    Date.parse('2014-01-01').fed_holiday?  => true # It's New Years
```

Likewise, days on which the NYSE is closed can be gotten with:

```
    Date.parse('2014-04-18').nyse_holiday? => true # It's Good Friday
```

Conversely, `Date#fed_workday?` and `Date#nyse_workday?` return true if the
federal government and the NYSE respectively are open for business on those
days.

In addition, the Date class, as extended by FatCore, adds `#next_<chunk>`
methods for calendar periods in addition to those provided by the core Date
class: `#next_half`, `#next_quarter`, `#next_bimonth`, and `#next_semimonth`,
`#next_biweek`. There are also `#prior_<chunk>` variants of these, as well as
methods for finding the end and beginning of all these periods (e.g.,
`#beginning_of_bimonth`) and for querying whether a Date is at the beginning or
end of these periods (e.g., `#beginning_of_bimonth?`, `#end_of_bimonth?`, etc.).

FatCore also provides convenience formatting methods, such as `Date#iso` for
quickly converting a Date to a string of the form 'YYYY-MM-DD', `Date#org` for
formatting a Date as an Emacs org-mode timestamp, and several others.

Finally, it provides a `#parse_spec` method for parsing a string, typically
provided by a user, allowing all the period chunks to be conveniently and
tersely specified by a user.  For example, the string '2Q' will be parsed as the
second calendar quarter of the current year, while '2014-3Q' will be parsed as
the third quarter of the year 2014.

### Range

You can also extend the Range class with several useful methods that emphasize
coverage of one range by one or more others (`#spanned_by?` and `#gaps`),
contiguity of Ranges to one another (`#contiguous?`, `#left_contiguous`, and
`#right_contiguous`, `#join`), and the testing of overlaps between ranges
(`#overlaps?`, `#overlaps_among?`). These are put to good use in the
'fat_period' (https://github.com/ddoherty03/fat_period) gem, which combines
fat_core's extended Range class with its extended Date class to make a useful
Period class for date ranges, and you may find fat_core's extended Range class
likewise useful.

For example, you can use the `#gaps` method to find the gaps left in the
coverage on one Range by an Array of other Ranges:

```
    require 'fat_core/range'
    (0..12).gaps([(0..2), (5..7), (10..12)])  => [(3..4), (8..9)]
```

### Enumerable

FatCore::Enumerable extends Enumerable with the `#each_with_flags` method that
yields the elements of the Enumerable but also yields two booleans, `first` and
`last` that are set to true on respectively, the first and last element of the
Enumerable.  This makes it easy to treat these two cases specially without
testing the index as in `#each_with_index`.

### Hash

FatCore::Hash extends the Hash class with some useful methods for element
deletion (`#delete_with_value`) and for manipulating the keys
(`#keys_with_value`, `#remap_keys` and `#replace_keys`) of a Hash. It also
provides `#each_pair_with_flags` as an analog to Enumerable's
`#each_with_flags`.

### TeX Quoting

Several of the extension, most notably 'fat_core/string', provides a
`#tex_quote` method for quoting the string version of an object so as to allow
its inclusion in a TeX document and quote characters such as '$' or '%' that
have a special meaning for TeX.

### String

FatCore::String has methods for performing matching of one string with another
(`#matches_with`, `#fuzzy_match`), for converting a string to title-case as
might by used in the title of a book (`#entitle`), for converting a String into
a useable Symbol (`#as_sym`) and vice-versa (`#as_string` also
`Symbol#as_string`), for wrapping with an optional hanging indent (`#wrap`),
cleaning up errant spaces (`#clean`), and computing the Damerau-Levenshtein
distance between strings (`#distance`). And several others.

### Numbers

FatCore::Numeric has methods for inserting grouping commas into a number
(`#commas` and `#group`), for converting seconds to HH:MM:SS.dd format
(`#secs_to_hms`), for testing for integrality (`#whole?` and `#int_if_whole`), and
testing for sign (`#signum`).

## Installation

Add this line to your application's Gemfile:

```
    gem 'fat_core', :git => 'https://github.com/ddoherty03/fat_core.git'
```

And then execute:

```
    $ bundle
```

Or install it yourself as:

```
    $ gem install fat_core
```

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/fat_core/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
