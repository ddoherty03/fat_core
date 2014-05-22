# FatCore

fat-core is a simple gem to collect core extensions and a few new classes that
I find useful in multiple projects.  The emphasis is on extending the Date
class to make it more useful in financial applications.

For example, the Date class adds two methods for determining whether a given
date is a US federal holiday or a NYSE holiday.

    Date.parse('2014-05-18').fed_holiday?  => true # It's a weekend
    Date.parse('2014-01-01').fed_holiday?  => true # It's New Years

All holidays defined by federal statute are recognized.

Likewise, days on which the NYSE is closed can be gotten with:

    Date.parse('2014-04-18').nyse_holiday? => true # It's Good Friday

Conversely, Date#fed_workday? and Date#nyse_workday? return true if they are
open for business on those days.

## Installation

Add this line to your application's Gemfile:

    gem 'fat_core', :git => 'https://github.com/ddoherty03/fat_core.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fat_core

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/fat_core/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
