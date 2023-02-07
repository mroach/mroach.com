---
title: URL Validation in Ruby
date: 2023-02-07T13:49:55+07:00
categories:
  - Ruby
  - Programming
  - Code
tags:
  - Ruby
---

When it comes to validation, I don't like to re-invent the wheel. Many programming
languages have built-in modules for common types of data, such as a URL.

In Ruby, we have the `URI` module which is often used to generate, parse, and
manipulate a URI. It has a method `URI.parse` which accepts a string and creates
an instance of a `URI`.

For a time, I thought this was a decent approach to use. You could validate a string
as a URL doing something like:

```ruby
def valid_url?(input)
  URI.parse(input)
  true
rescue URI::InvalidURIError
  false
end
```

I ran into an issue where my code had accepted a malformed URL `"https:/?q="`.
I thought: this is obviously not a valid URL. It doesn't have two slashes after the scheme,
there's no host, and no port. And yeah, it's not a URL: but it is a URI.

## URL != URI

Often on the web the labels URL and URI are used interchangeably which is not correct.

The naming provides a hint. *Uniform Resource* ***Identifier*** versus ***Locator***.
An identifier can be just about any value, but a locator needs more information
such as a protocol/scheme and network address.

Because of this, the `URI` module is permissive to the point of being useless for validating a URL.

## Example

Which of the following inputs do you think will fail to parse as a URI?

```ruby
[
  "https:/...",
  "http:/?",
  "foo:/.bar:999999",
  "ftp",
  ".",
  "",
  "1",
  RUBY_VERSION,
].to_h do
  [_1, (URI.parse(_1) rescue "INVALID")]
end
```

The answer is: none of them. They're all accepted.

```ruby
{"https:/..."=>#<URI::HTTPS https:/...>,                                 
 "http:/?"=>#<URI::HTTP http:/?>,
 "foo:/.bar:999999"=>#<URI::Generic foo:/.bar:999999>,
 "ftp"=>#<URI::Generic ftp>,
 "."=>#<URI::Generic .>,
 ""=>#<URI::Generic >,
 "1"=>#<URI::Generic 1>,
 "3.1.2"=>#<URI::Generic 3.1.2>}
```

## Now what?

To deal specifically with web URLs, a wrapper around `URI` to add some sanity
checks can do a nice job without having to resort to regular expressions or custom parsing.

The main things to check:

1. It's not a blank string
2. The _scheme_ is `"http"` or `"https"`
3. There's a hostname

```ruby
module WebUrl
  class InvalidWebUrlError < StandardError; end

  SUPPORTED_SCHEMES = ["http", "https"]

  extend self

  def parse(value)
    if value.blank?
      raise InvalidWebUrlError, "can't be blank"
    end

    uri = URI.parse(value)

    unless SUPPORTED_SCHEMES.include?(uri.scheme)
      raise InvalidWebUrlError, "invalid scheme '#{uri.scheme}'"
    end

    if uri.host.blank?
      raise InvalidWebUrlError, "host is blank"
    end

    uri
  rescue URI::InvalidURIError => err
    raise InvalidWebUrlError, err.message
  end

  def valid?(value)
    parse(value)
    true
  rescue InvalidWebUrlError
    false
  end
end
```

## Usage

Now with this module, we can validate and parse strings that should be URLs.

```ruby
WebUrl.parse("https://example.org:1234/path?query=test")
=> #<URI::HTTPS https://example.org:1234/path?query=test>

WebUrl.parse("https:/.foo")
/opt/app/lib/web_url.rb:16:in `parse': host is blank (WebUrl::InvalidWebUrlError)
```
