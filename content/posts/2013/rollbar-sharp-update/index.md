---
date: 2013-12-06T00:00:00Z
title: RollbarSharp updated to 0.3.0
categories:
  - Tech
  - Software
tags:
  - .NET
  - Rollbar
  - Open Source
aliases:
  - /2013/12/06/rollbarsharp-updated-to-0.3.0/
---

The new release adds two bits of missing functionality.

### Session data

Data from the `Session` object is now added to reports. Data is described/stringified as best we can, with non-value types being reported with their type name, hash code, and `.ToString()` value.

### Param scrubbing

Sensitive parameter values are now scrubbed. Each character is replaced with an asterisk. By default, any parameter in the following list will be scrubbed:

* `password`
* `password_confirmation`
* `confirm_password`
* `secret`
* `secret_token`
* `creditcard`
* `credit_card`
* `credit_card_number`
* `card_number`
* `ccnum`
* `cc_number`

You can override this list by setting the `Rollbar.ScrubParams` configuration option.


[View RollbarSharp on GitHub](https://github.com/mroach/rollbarsharp)
