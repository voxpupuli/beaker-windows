# Beaker Windows

Beaker helper library for testing on Windows.

## Installation

Add this line to your application's Gemfile:

    gem 'beaker_windows'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install beaker_windows

## Methods

### join_path

Join paths together with a "\" Windows style path separator. This method will
accept path segments with mixed separators as well as leading and trailing
separators. Optionally you can specify to use an alternate path separator or
strip the drive letter off the combined path.

#### Example 1

    join_path('c:\dog', 'bark')

#### Example 2

    join_path('c:\dog', 'bark', :path_sep => '/')

#### Example 3

    join_path('c:\dog', 'bark', :path_sep => '/', :strip_drive => true)
