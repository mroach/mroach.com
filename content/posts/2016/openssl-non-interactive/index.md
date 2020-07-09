---
date: 2016-09-27T00:00:00Z
title: Generating openssl certificate non-interactively
categories:
  - tech
  - cheatsheet
tags:
  - openssl
aliases:
  - /2016/09/27/openssl-noninteractive/
---

Using `openssl` with the `--subject` argument allows you to generate certificates
without being prompted for any input. This non-interactive mode makes server
automation that much easier.

<!--more-->

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout testapp.key -out testapp.crt \
-subj /C=CA/ST=Quebec/L=Montreal/O=Poutine LLC/OU=devops/CN=*.poutine.net
```

### Subject vars

C
: ISO country code

ST
: State/Province/Subdivision

L
: Locality/City/Town

O
: Organisation/Company

OU
: Organisational Unit/Department

CN
: Common name. The most important! Your domain name! Wildcards supported.
