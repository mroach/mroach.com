---
title: "Enum types in Ruby"
date: 2026-03-02T16:50:42+01:00
categories:
  - Tech
  - Software
  - Ruby
tags:
  - Ruby
  - PostgreSQL
---

When I start a new project in Ruby, the first module I copy over is my custom little `enum.rb`.

Many popular programming languages have built-in support for enums.
C, C++, C#, Go, Java, Rust, Swift, but also looser-typed languages like PHP and Python.

Ruby doesn't have native support for enum types, but it's not hard to add and
add some clarity and cleanliness to your code.

<!--more-->

## Enums?

Enums, or enumerated types, are a way to define a number of constant values that
are all related to the same purpose or parent type.
Typical use cases for these are lists of options or flags.

Another way to think about enums is as union types of their members.
For example *"a 'Protocol' is the value 'http' OR 'ftp' OR 'tftp'"*.

Here's how you may define an enum of protocols in C++, Java, or Rust:

```cpp
enum Protocol {
  HTTP,
  FTP,
  TFTP
}
```

Once defined, you can use the enum type for variables and compare those
variables to members of the enum.

```cpp
bool MakeRequest(Protocol proto) {
  if (proto == Protocol::HTTP) {
    // Do HTTP stuff
  }
}

MakeRequest(Protocol::HTTP)
```

Depending on the use case, you may not ever care about what the underlying value of
each enum member is. By default in most languages, the underlying value of each
enum member starts at `1` and increments in the order the members are defined.
You can usually override this if you need to or want to be explicit about it.

```cpp
enum Protocol {
  HTTP = 80,
  FTP  = 21,
  TFTP = 69
}
```

If you have to store the value somewhere such as a database or file, then you do start to care
and have to be careful about removing or re-adding members.

## But why?

An enum can be the single source of truth for a finite list of values that are
referenced in your codebase. If a member has to be added or removed, you're doing
it in one place. Your codebase becomes more self-describing as it's clear
what values are being worked with and what options are allowed.

If you see a function `MakeRequest(string proto)`, you end up having to explicitly
document what options are allowed, explicitly validate incoming arguments,
and callers to that function have to make sure they're sending something valid too.

If you see `MakeRequest(Protocol proto)` you have a big hint as to what values
are expected by this function.

## But Ruby doesn't use types

True. But it can still benefit from programmers not repeating the same values
all over the codebase by hardcoding strings, symbols, integers, whatever else.

A common pattern in Ruby applications is to use symbols. That doesn't provide
any value with regards to validation or option discovery. If you see `:http`
somewhere you're left asking...but what are the other options? Where is this defined? It's not defined.

## Rails has `enum`

It does have an [`enum`][Rails Enum] macro that can be used in ActiveRecord models.

```ruby
class Request < ApplicationRecord
  enum :protocol, [:http, :ftp, :tftp]
end
```

Like most other languages, Rails generates incrementing integer underlying values
for each enum member.

In this situation of models, you *know* these values are being persisted to the database
so you have to be very careful about not removing or re-ordering your enum definitions,
otherwise your existing data will map to incorrect enums in your model.

You can explicitly re-value them if you want though.

```ruby
enum :protocol, {http: 80, ftp: 21, tftp:69}
```

This all works, but has some usability issues:
* The default of storing integers in the database makes the data hard to understand by other apps sharing the database
* You end up hardcoding the labels elsewhere in your code e.g. `record.protocol = "http"`
* Can't use enum member labels in pattern matching
* It only works in ActiveRecord models

[Rails Enum]: https://api.rubyonrails.org/classes/ActiveRecord/Enum.html

## `Enum` module for Ruby

I want to be able to use enums outside of models, outside of Rails apps, and have
easy access to the values for pattern matching.

My first attempts were just defining modules with constants inside them.
This worked, but quickly ran into repeating code for things like listing the options, validating, casting, etc.

My solution: a simple `Enum` module that makes it possible to write code like this:

```ruby
class Request
  Protocol = Enum.define_from_values("http", "ftp", "tftp")
  
  # @param proto [Protocol]
  def make_request(proto)
    case proto
    in Protocol::HTTP
      # http stuff
    in Protocol::FTP | Protocol::TFTP
      # file stuff
    end
  end
end

req = Request.new
req.make_request(Request::Protocol::HTTP)

puts "Protocol options:"
puts Request::Protocol.members.map { |k, v| "#{k} = #{v}" }.join("; ")
```

There are a few things going on here worth pointing out.

* Our list of protocol values is defined exactly once in our codebase.
* Each enum gets its own proper Ruby type.
* When code references our enum, it's clear what the source of truth is.
* Each member has its own constant. Useful for pattern matching.
* By default, underlying values are strings matching the label, making them portable
  and easy to understand in SQL database, JSON, etc.
* Members of an enum can be accessed as a hash and iterated.

## Source

```ruby
# Generates a class that has enum-like behaviour.
# Values are stored as constants an accessible in a hash-like way
# 
# Example:
#   Status = Enum.define_from_values(:ok, :error)
#   Status::OK => :ok
#   Status::ERROR => :error
module Enum
  # Define an enum with explicit labels and values
  # 
  # Example:
  #   Protocol = Enum.define({http: "H", ftp: "F", tftp: "T"})
  # 
  # @param members [Hash]
  #   Hash keys get converted into constants, so only use sensible values.
  # @return [Class]
  def self.define(members)
    raise ArgumentError, "must be a Hash" unless members.is_a?(Hash)

    if (duplicates = members.values.tally.select { |_v, c| c > 1 }).any?
      raise ArgumentError, "duplicate values are not allowed: #{duplicates.keys}"
    end

    klass = Class.new
    klass.extend(ClassMethods)

    members = members.to_h { |key, value| [key, value.freeze] }.freeze

    members.each do |key, value|
      const_name = key.to_s.parameterize.underscore.upcase.to_sym
      klass.const_set(const_name, value)
    end

    klass.define_singleton_method(:members) { members }
    klass
  end

  # Define an enum with values matching their labels
  # 
  # Example:
  #   Protocol = Enum.define_from_values("http", "ftp", "tftp")
  #
  # @param values [Array<String | Symbol>]
  #   Since values become constants, use only strings or symbols. 
  # @return [Class]
  def self.define_from_values(*values)
    define(values.flatten.to_h { [it, it] })
  end

  module ClassMethods
    def to_h
      members
    end

    def [](key)
      members.fetch(key)
    end

    def keys
      members.keys.to_set
    end

    def key(value)
      members.key(value)
    end

    def values
      members.values.to_set
    end

    def valid?(key)
      members.key?(key)
    end

    # Get several wanted values, validating that each is actually a valid enum member
    # Example:
    #   Protocol.values_at("http", "ftp")
    #   => Set["http", "ftp"]
    # 
    #   Protocol.values_at("http", "oscar")
    #   => ArgumentError "invalid keys requested: oscar"
    # 
    # @param wanted_keys [Array<String | Symbol>]
    # @return Set<String | Symbol>
    def values_at(*wanted_keys)
      wanted_keys = wanted_keys.flatten

      if (invalid_keys = wanted_keys - keys.to_a).any?
        raise ArgumentError, "invalid keys requested: #{invalid_keys}"
      end

      members.slice(*wanted_keys).values.to_set
    end
  end
end
```

## Rails integration

Tying it all together, I add a `string_enum` method to my base `ApplicationRecord`
class and override `enum` so that either way enums are created, I get an `Enum`
class defined on the model based on that definition.

I prefer storing enum values as strings in the database since it makes them
legible to other applications, including developers looking at the raw SQL queries or database.

If you want to, you can even create an [ENUM in PostgreSQL](https://www.postgresql.org/docs/current/datatype-enum.html)
to enforce validity at the database level.

```ruby
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class << self
    # @override Defined by Rails
    def enum(name, values = nil, **options)
      super

      const_name = name.to_s.classify.to_sym

      if const_defined?(const_name)
        warn("#{const_name} already defined on #{self.name}. Not overwriting")
        return
      end

      # The builtin `enum` method creates a hash of k=>v named by the plural form
      # of the enum. Use that to build a local enum class
      mapping = public_send(name.to_s.pluralize)

      const_set(const_name, Enum.define(mapping))
    end

    def string_enum(name, values, **options)
      values_hash = case values
      in Array | Set => arr
        arr.map(&:to_s).to_h { [it, it] }
      in Hash => h
        h.transform_keys(&:to_s).transform_values(&:to_s)
      end

      if values_hash.empty?
        raise ArgumentError, "no enum values provided"
      end

      enum(name, values_hash, **options)
    end
  end
end
```


### Use in a record

```ruby
class User < ApplicationRecord
  string_enum :theme, ["light", "dark", "auto"], suffix: true
end
```

```ruby
auto_users = User.auto_theme
new_auto_user = User(theme: User::Theme::AUTO)
```

## Wrapping up

I find it a code smell to hardcode values around a codebase. It's far too easy to
introduce typos, introduce bugs during a refactor, or have any grip on a source of truth
for such values. Enums can tidy things up nicely and bring some type safety and
comprehensibility to your code.
