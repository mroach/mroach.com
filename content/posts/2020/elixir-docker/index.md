---
title: "Elixir development with Docker"
date: 2020-07-07T15:40:51-04:00
draft: false
categories:
  - Tech
  - Software
  - Guides
tags:
  - Software
  - Development
  - Docker
  - Elixir
author: mroach
---

When I start a new project or get setup to contribute to an existing one, the first thing on my mind is: show me the `Dockerfile`.

## Why?

One of the main purposes of Docker is packaging an application with its dependencies into a portable image that can be run on most any host, thus simplifying deployments. Yet when it comes to development of these applications, Docker is often not part of the picture. Why go through the headache of installing version managers and other dependencies when Docker exists?

Even for simple libraries there's still great value in using Docker so you can easily test your application against multiple versions of the language or framework.

## Anatomy of an Elixir Dockerfile

### Elixir version as a build arg

If you're developing a library, you should be testing it against all the versions of Elixir that you support. This can be done by using [docker build args] to parameterize the base image tag.

```dockerfile
ARG elixir_ver=1.10

FROM elixir:${elixir_ver}-slim
```

The `elixir_ver` build argument defaults to `1.10` and is used in specifying the base image tag.
This can be easily overridden when building the image.

```shell
docker build --tag my_app_elixir_1.7 --build-arg elixir_ver=1.7 .
```

### Installing hex and rebar3

By default, hex and rebar3 are not available in the base Docker image for Elixir.
These are necessary for fetching dependencies.

```dockerfile
RUN mix local.hex --force && \
    mix local.rebar --force
```

### Storing dependencies and build artifacts in the image

By default, mix stores fetched dependencies in `./deps` and build artifacts in `./_build`.

There are two problems with this when using Docker: performance and build artifacts across versions.

The 2017 article [Docker on Mac Performance] describes the performance problem well. The short of it: on non-Linux hosts, bind mounts are slow since Docker is running in a virtual machine and mounts into VMs are done with local network shares. Building a slew of dependencies over a bind mount is slow.

The other issue is the build artifacts themselves. If you run your app, stop it, switch Elixir versions, then try to run your app again, it will detect that the build artifacts were built with a different version of Elixir and recompile them. This creates all kinds of headaches especially if you're using a language server like [ElixirLS] that will constantly trigger recompiles.

#### Overriding the defaults

These paths can be overridden using the [mix environment variables] `MIX_DEPS_PATH` and `MIX_BUILD_PATH`.

```dockerfile
ENV MIX_DEPS_PATH=/opt/mix/deps
ENV MIX_BUILD_PATH=/opt/mix/build
```

Caveat: `MIX_DEPS_PATH` is only supported as of Elixir 1.10. You can still use this with previous versions of Elixir though by reading it in your `mix.exs` file:

```elixir
def project do
  [
    app: :my_app,
    elixir: "~> 1.7",
    deps_path: System.get_env("MIX_DEPS_PATH") || "./deps"
  ]
end
```

### Compiling in the image

For quick startup of your app, tests, or iex, pre-compile the dependencies. This requires that app configuration be present along with the `mix.exs` and `mix.lock` files.

If you're only going to be running tests in the image, consider setting `MIX_ENV=test` and only fetching dependencies for this environment.

```dockerfile
ENV MIX_ENV=test

WORKDIR /opt/code

COPY config ./config
COPY mix.exs mix.lock ./

RUN mix do deps.get --only $MIX_ENV, deps.compile
```

### Putting it all together

With all these requirements taken care of, here's the final `Dockerfile`:

```dockerfile
ARG elixir_ver=1.10

FROM elixir:${elixir_ver}-slim

RUN mix local.hex --force && \
    mix local.rebar --force

# this env var is only picked-up automatically by Elixir >= 1.10
# for previous versions, set it in mix.exs file in `project/0`:
#   deps_path: System.get_env("MIX_DEPS_PATH") || "./deps"
ENV MIX_DEPS_PATH=/opt/mix/deps

# build inside the image and not on the mounted volume to prevent
# recompiles with different Elixir versions
ENV MIX_BUILD_PATH=/opt/mix/build

ENV MIX_ENV=test

WORKDIR /opt/code

# add config before compiling. it will likely affect compile-time options
COPY config ./config
COPY mix.exs mix.lock ./

RUN mix do deps.get --only $MIX_ENV, deps.compile

VOLUME /opt/code
```

## Makefile

Now that we have a nice `Dockerfile`, let's make it easy to use with a `Makefile`.
A `Makefile` is another developer treat to keep your documentation short and sweet and your steps to get up and running even easier.

Taking the example of a paramaterized `Dockerfile` for testing against multiple Elixir versions, let's add some targets to use them.

```makefile
ELIXIR_VER := 1.10
DOCKER_TAG := newsie_elixir_$(ELIXIR_VER)

.PHONY: docker/build docker/test docker/iex

docker/build:
  docker build --tag $(DOCKER_TAG) --build-arg elixir_ver=$(ELIXIR_VER) .

docker/test: docker/build
  docker run --rm -v $(PWD):/opt/code $(DOCKER_TAG) mix test

docker/iex: docker/build
  docker run --rm -it -v $(PWD):/opt/code $(DOCKER_TAG) iex -S mix
```

Now to build the base image and run your unit tests, a developer needs to just run:

```shell
make docker/test
```

If you want to change the Elixir version, pass it as an argument:

```shell
make docker/test ELIXIR_VER=1.7
```

## Wrapping up

Having a Dockerized development environment allows for easy testing of your app against different Elixir versions and reduces friction for developers getting started with contributing to your project. Use a `Makefile` to make common development tasks even easier.

[docker build args]: https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg
[mix environment variables]: https://hexdocs.pm/mix/Mix.html#module-environment-variables
[Docker on Mac Performance]: https://www.amazee.io/blog/post/docker-on-mac-performance-docker-machine-vs-docker-for-mac
[ElixirLS]: https://github.com/elixir-lsp/elixir-ls
