---
title: "Improving static data performance with metaprogramming"
date: 2020-07-12T00:00:00Z
draft: false
categories:
  - Tech
  - Code
tags:
  - Elixir
  - Performance
  - Benchmarking
  - Metaprogramming
---

In my previous post [Generating static data with Elixir comprehensions] I showed how you can use comprehensions to generate static data in your Elixir application. That static data was stored as a `Map` in a module attribute and accessible with a function that returns the `Map` itself.

When building your application, you probably know how the static data will be accessed. Elixir has various ways of accessing data in a `List`, `Keyword`, or `Map`, and there are big differences in performance based on the size of tha data set. We'll use the library {{< github "bencheeorg/benchee" >}} to measure the differences between the built-in access functions and compare that to approaches based on metaprogramming.

## Where we left off

I'll simplify the comprehension here to generate the base set of data. Let's assume our source file is just tab-separated keys and values. This time around we'll use ISO country codes instead of languages since there are more two-character country codes than language codes and bigger lists show bigger performance differences. We'll store these as a `Keyword` in the module attribute `@iso_codes`.

```elixir
defmodule MyApp.Countries do
  @iso_codes for line <- File.stream!("priv/data/iso-3166.tab"),
                 [code, name] = String.split(line, "\t"),
                 code = String.to_atom(code),
                 do: {code, name}

  @spec iso_codes() :: keyword()
  def iso_codes, do: @iso_codes
end
```

Now we have a function `iso_codes/0` that returns the `Keyword` list, like `[au: "Australia", se: "Sweden", ...]`

## How does the data get used?

Before we benchmark data access, let's think about how the data is likely to be queried our application. It's safe to assume two main operations:

* Looking up names of countries by their codes e.g. `:au => "Australia"`
* Looking up country codes by their names e.g. `"Australia" => :au`

We should add public functions for these operations, but before we do, let's benchmark different ways of achieving these goals.

## Benchmarking

> If you can't measure it, you can't improve it. - Peter Drucker

We'll be using the {{< github "bencheeorg/benchee" >}} library for benchmarking Elixir code. You create a script with code that benchee will run as many times as possible to give you an average iterations per second. The more iterations, the better.

Let's create `country_code_bench.exs` to benchmark various approaches for getting the country name by the code.

First we'll read the `Keyword` into a local variable and create a second variable with the data as a `Map` so we can compare accessing the two.

Then we just need to write different functions for each data access strategy.

```elixir
# read the Keyword into a local value to reduce function calls
# create a Map from the same data source
codes_kw = Countries.iso_codes()
codes_map = Map.new(codes_kw)

# create a list of all 676 unique 2-char combos. :aa, :ab, :ac...
all_2char = for a <- ?a..?z, b <- ?a..?z, do: String.to_atom(<<a::utf8, b::utf8>>)

# each test iterates all 676 letter combos and tries to fetch the
# country name from the Keyword or Map in various ways.
Benchee.run(%{
  "Keyword.Access" => fn -> Enum.each(all_2char, &codes_kw[&1]) end,
  "Keyword.fetch"  => fn -> Enum.each(all_2char, &Keyword.fetch(codes_kw, &1)) end,
  "Keyword.get"    => fn -> Enum.each(all_2char, &Keyword.get(codes_kw, &1)) end,

  "Map.Access"     => fn -> Enum.each(all_2char, &codes_map[&1]) end,
  "Map.fetch"      => fn -> Enum.each(all_2char, &Map.fetch(codes_map, &1)) end,
  "Map.get"        => fn -> Enum.each(all_2char, &Map.get(codes_map, &1)) end
})
```

Now we can run this with:

```
mix run country_code_bench.exs
```

The result summary on my machine:

```plain
Name                     ips        average  deviation         median         99th %
Map.fetch            24.83 K       40.28 μs    ±26.29%          38 μs          85 μs
Map.get              20.41 K       49.00 μs    ±22.69%          46 μs         101 μs
Map.Access           17.76 K       56.32 μs    ±20.75%          53 μs         114 μs
Keyword.Access        3.38 K      295.66 μs    ±15.80%         282 μs         490 μs
Keyword.fetch         3.38 K      295.83 μs    ±13.89%         286 μs      474.68 μs
Keyword.get           3.37 K      296.61 μs    ±14.67%         282 μs         483 μs

Comparison:
Map.fetch            24.83 K
Map.get              20.41 K - 1.22x slower +8.72 μs
Map.Access           17.76 K - 1.40x slower +16.04 μs
Keyword.Access        3.38 K - 7.34x slower +255.38 μs
Keyword.fetch         3.38 K - 7.34x slower +255.55 μs
Keyword.get           3.37 K - 7.36x slower +256.33 μs
```

We see that accessing a key in `Keyword` is *significantly* slower than accessing a `Map`. And when using a `Map`, getting values using [Access] is 40% slower than `fetch/2`.

## What is metaprogramming?

The definition and scope of metaprogramming varies based on the language you're using. As Elixir is a compiled language, metaprogramming generally refers to, among other things, using code to generate code at compile time. That's what we're going to do here.

## Generating functions with metaprogramming

Let's add a function `get_name/1` to our module that takes a country code atom and returns its name. This will be functionally equivalent to `Map.get/2` where a successful lookup returns the name, and unsuccessful lookup returns `nil`.

This code is added in the module body:

```elixir
@doc "Get a country name by its ISO code as an atom"
@spec get_name(atom()) :: nil | binary()

for {code, name} <- @iso_codes do
  def get_name(unquote(code)), do: unquote(name)
end

def get_name(_), do: nil
```

The `for` comprehension is evaluated at compile time. The body defines a function `get_name/1` and uses pattern matching in the head to match the literal `code` atom and return the `name`. You can think of `unquote` here like string interpolation. We want to inject the values of `code` and `name` rather than defining variables named `code` and `name` in the function.

We're able to use the special `@doc` and `@spec` attributes to define documentation and a typespec as usual.

The compiled result of this is equivalent to manually defining functions:

```elixir
@doc "Get a country name by its ISO code as an atom"
@spec get_name(atom()) :: nil | binary()
def get_name(:ad), do: "Andorra"
def get_name(:ae), do: "United Arab Emirates"
def get_name(:af), do: "Afghanisatan"
...
def get_name(:zw), do: "Zimbabwe"
def get_name(_), do: nil
```

## Benchmark again.

Let's add this `get_name/1` function to our benchmark script and run it again to see if we've made any improvements.

```elixir
# add to country_code_bench.exs
"fn_pattern_match" => fn -> Enum.each(all_2char, &Countries.get_name/1) end,
```

```plain {hl_lines=[2,11]}
Name                       ips        average  deviation         median         99th %
fn_pattern_match       30.30 K       33.00 μs    ±22.89%          32 μs          70 μs
Map.fetch              25.28 K       39.56 μs    ±27.95%          37 μs          85 μs
Map.get                21.25 K       47.07 μs    ±20.19%          45 μs          98 μs
Map.Access             18.17 K       55.03 μs    ±20.29%          53 μs         113 μs
Keyword.get             3.44 K      290.60 μs    ±13.58%         281 μs      475.55 μs
Keyword.fetch           3.43 K      291.93 μs    ±13.80%         280 μs      474.35 μs
Keyword.Access          3.33 K      300.34 μs    ±12.97%         289 μs         466 μs

Comparison:
fn_pattern_match       30.30 K
Map.fetch              25.28 K - 1.20x slower +6.56 μs
Map.get                21.25 K - 1.43x slower +14.07 μs
Map.Access             18.17 K - 1.67x slower +22.03 μs
Keyword.get             3.44 K - 8.81x slower +257.60 μs
Keyword.fetch           3.43 K - 8.85x slower +258.93 μs
Keyword.Access          3.33 K - 9.10x slower +267.34 μs
```

Look at that! Our generated functions that use pattern matching are 20% faster than our previous performance king `Map.fetch`.

## Reverse lookups

Now we need to look up country codes by their names. We'll take a similar approach to generate functions where we pattern match the country name in the head. To support case-insensitive matching, we'll define the generated functions as private and create a public function that downcases the input and uses the private functions.

```elixir
@doc "Lookup a country's ISO code by name"
@spec get_code(binary()) :: nil | atom()
def get_code(name) do
  name
  |> String.downcase()
  |> get_code_by_lcase_name()
end

for {code, name} <- @iso_codes, name = String.downcase(name) do
  defp get_code_by_lcase_name(unquote(name)), do: unquote(code)
end
defp get_code_by_lcase_name(_), do: nil
```

Now we have a nice public API for querying country codes by name:

```elixir
Countries.get_code("australia")
:au

Countries.get_code("GERMANY")
:de
```

## Tradeoffs and final thoughts

Metaprogramming can be a powerful tool to help achieve better performance for accessing static data. Of course there's always a tradeoff and in this case the tradeoff is complexity of the code. It's always worth considering how code golf or fancy (i.e. less conventional) solutions will be understood by other developers.

When writing code that will be executed frequently, this tradeoff may be well worth making. Given this example, imagine you're processing a data source with tens of thousands of records and looking up country names from ISO codes. Our 20% performance boost will be nice to have.

Benchmarking code is a great way to prove theories on performance. When benchmarks lead to coding somewhat unconventional solutions, be kind to the next developer and leave a comment there explaining what you're doing and why you chose this approach.

There are entire books published about this, such as [Metaprogramming Elixir](https://pragprog.com/titles/cmelixir/) written by Chris McCord, author of Phoenix.


[Generating static data with Elixir comprehensions]: {{< ref elixir-comprehensions >}}
[Access]: https://hexdocs.pm/elixir/Access.html
