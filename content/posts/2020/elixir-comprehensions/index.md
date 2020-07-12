---
title: "Generating static data with Elixir comprehensions"
date: 2020-07-11T00:00:00Z
draft: false
category:
  - Tech
  - Code
tags:
  - Elixir
---

A common requirement in software is to have a static data resource in your application or library. These are typically resources that changes so infrequently that releasing a new version for a data change is fine. Of course you can build these data by hand, but this is error-prone and makes rebuilding the static data more labour intensive. These problems are exacerbated by larger data sets. As good lazy (i.e. efficient) developers we can use code to solve these problems.

While developing {{< github "mroach/newsie" >}} I needed a list of countries and languages with their ISO codes. To satisfy my aversion to dependency creep, I built a module each for these languages and countries.

Transforming tab-delimited files in Elixir are a good fit for comprehensions.

## Data source

The [ISO 639-3] languages codes and [ISO 3166] country codes are publicly available from many sources. [SIL] and [TZDB] have tab-delimited files for language and country codes respectively. These flat files are even easier to process than structured data like JSON or YAML.

To make the file download easily repeatable, let's create a `Makefile`:

```makefile
priv/data/iso-639-3.tab:
	curl -Sso $(@D)/$(@F) https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab

priv/data/iso-3166.tab:
	curl -Sso $(@D)/$(@F) https://data.iana.org/time-zones/tzdb/iso3166.tab

data: priv/data/iso-639-3.tab priv/data/iso-3166.tab
```

Then to fetch the files you just need to run:

```shell
make data
```

### Structure

Let's examine the structure of the language data file, `iso-639-1.tab`. The first line of the file is a header with the column names:

```plain
Id	Part2B	Part2T	Part1	Scope	Language_Type	Ref_Name	Comment
```

The [SIL download][SIL] page provides descriptions:

```plain
Id        char(3)       The three-letter 639-3 identifier
Part2B    char(3)       Equivalent 639-2 identifier of the bibliographic applications
                        code set, if there is one
Part2T    char(3)       Equivalent 639-2 identifier of the terminology applications code
                        set, if there is one
Part1     char(2)       Equivalent 639-1 identifier, if there is one
Scope     char(1)       I(ndividual), M(acrolanguage), S(pecial)
Type      char(1)       A(ncient), C(onstructed),
                        E(xtinct), H(istorical), L(iving), S(pecial)
Ref_Name  varchar(150)  Reference language name
Comment   varchar(150)  Comment relating to one or more of the columns
```

We're interested in 3 columns:

* `Part1` - The two-char language code such sa `en` for English
* `Type` - Allows us to filter to living languages: `L`
* `Ref_Name` - The name of the language in English

A sample of the data:

```plain
jpn	jpn	jpn	ja	I	L	Japanese
eng	eng	eng	en	I	L	English
sam	sam	sam		I	E	Samaritan Aramaic
swe	swe	swe	sv	I	L	Swedish
tmr				I	E	Jewish Babylonian Aramaic (ca. 200-1200 CE)
```


## Comprehensions quick start

Elixir has a great guide to [getting started with comprehensions]. The quick summary is:

*Comprehensions are a concise way to transform and filter an enumerable.*

This is exactly what we need to do with our tab file.

### Generator

A comprehension starts with a generator. This can be anything that returns an [Enumerable]. We'll use [File.stream!/3] to read the file line by line:

```elixir
for line <- File.stream!("priv/data/iso-639-3.tab"), do: line
```

### Transformations

Now we can process each line of the file. Each line is a tab-delimited string that we can transform into a list of values by splitting on the tab character `\t`.

```elixir {hl_lines=[2]}
for line <- File.stream!("priv/data/iso-639-3.tab"),
    row = String.split(line, "\t"),
    do: row
```

### Filters

A comprehension can filter values. Any expression that returns `false` or `nil` will be excluded. In our case, we need to limit the list to "Living" languages denoted by the character `L` in column 5.

```elixir {hl_lines=[3]}
for line <- File.stream!("priv/data/iso-639-3.tab"),
            row = String.split(line, "\t")
            Enum.at(row, 5) == "L",
            do: row
```

### Extract and validate the language code

We can now get the language code from column 3 and ensure it's 2 characters long; this excludes any blanks or invalid codes. We'll convert the valid codes to atoms so they can be used as a key in a `Keyword` or `Map`.

```elixir {hl_lines=["4-6"]}
for line <- File.stream!("priv/data/iso-639-3.tab"),
    row = String.split(line, "\t"),
    Enum.at(row, 5) == "L",
    code = Enum.at(row, 3),
    String.length(code) == 2,
    code = String.to_atom(code),
    do: code
```

### Final steps

The `do:` keyword is an expression that renders the final form of each element in the comprehension. Until now we've been rendering single values for debugging purposes, but now we'll combine the `code` and `name` into a two-element tuple.

By default, a comprehension returns a new list. To instead return a `Map`, we can use the `into:` keyword with an empty `Map` as the accumulator for our collection.

```elixir {hl_lines=["7-9"]}
for line <- File.stream!("priv/data/iso-639-3.tab"),
    row = String.split(line, "\t"),
    Enum.at(row, 5) == "L",
    code = Enum.at(row, 3),
    String.length(code) == 2,
    code = String.to_atom(code),
    name = Enum.at(row, 6),
    do: {code, name},
    into: %{}
```

The result of this is a nice map with the two letter language code as our key and the English name of the language as the value

```elixir
%{
  cy: "Welsh",
  hz: "Herero",
  lv: "Latvian",
  qu: "Quechua",
  ...
}
```

## Compare to pipe syntax

As always in programming, there's more than one way to get the job done. For comparison, let's see how this would be done with the pipe syntax.

```elixir
"priv/data/iso-639-3.tab"
|> File.stream!()
|> Stream.map(&String.split(&1, "\t"))
|> Stream.filter(fn row -> Enum.at(row, 5) == "L" end)
|> Stream.map(fn row -> {Enum.at(row, 3), Enum.at(row, 6)} end)
|> Stream.filter(fn {code, _} -> String.length(code) == 2 end)
|> Enum.into(%{}, fn {code, name} -> {String.to_atom(code), name} end)
```

This gets the job done and depending on your tastes, may be a preferable style. I find it a bit verbose and harder to follow than a comprehension in this case.

## Next steps

The objective here was to generate *static* data. If this comprehension or pipeline were invoked at runtime, it wouldn't really be static since the result would depend on the file which could change. Even if it didn't change, it would be a lot of unnecessary re-processing.

To cement the data into code, it can be evaluated at compile time and its result assigned to a module attribute.

We also use some metaprogramming to define the `get_lang_name/1` function. More on that in the next post, [improving static data access with metaprogramming]({{< ref "elixir-performance-metaprogramming" >}}).

```elixir
defmodule MyApp.Languages do
  @iso_codes for line <- File.stream!("priv/data/iso-639-3.tab"),
                 row = String.split(line, "\t"),
                 Enum.at(row, 5) == "L",
                 code = Enum.at(row, 3),
                 String.length(code) == 2,
                 code = String.to_atom(code),
                 name = Enum.at(row, 6),
                 do: {code, name},
                 into: %{}

  @spec iso_codes() :: %{atom() => binary()}
  def iso_codes, do: @iso_codes

  @spec get_lang_name(atom()) {:ok, binary()} | {:error, :invalid}
  for {code, name} <- @iso_codes do
    def get_lang_name(unquote(code)), do: {:ok, unquote(name)}
  end

  def get_lang_name(_), do: {:error, :invalid}
end
```

## Conclusion

Comprehensions offer a way to perform concise transformations and filtering of an enumerable. Using a comprehension with a module attribute allows for the compile-time creation of a static data set. This provides great performance compared to reading the data from disk, a database, or any other source.

You can check out the final implementation of the [Newsie.Languages] and [Newsie.Countries] modules.

[ISO 639-3]: https://en.wikipedia.org/wiki/ISO_639-3
[ISO 3166]: https://en.wikipedia.org/wiki/ISO_3166
[SIL]: https://iso639-3.sil.org/code_tables/download_tables
[TZDB]: https://data.iana.org/time-zones/tzdb/
[getting started with comprehensions]: https://elixir-lang.org/getting-started/comprehensions.html
[Range]: https://hexdocs.pm/elixir/Range.html
[Enumerable]: https://hexdocs.pm/elixir/Enumerable.html
[Newsie.Countries]: https://github.com/mroach/newsie/blob/master/lib/newsie/countries.ex
[Newsie.Languages]: https://github.com/mroach/newsie/blob/master/lib/newsie/languages.ex
[File.Stream!/3]: https://hexdocs.pm/elixir/File.html#stream!/3
