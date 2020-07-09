---
date: 2019-04-11T00:00:00Z
layout: post
title: Developer idioms
categories:
  - fun
tags:
  - speech
  - language
aliases:
  - /2019/04/11/idioms/
---

Whenever I approach a new spoken language, I'm drawn to their idioms.
Expressions that when translated literally, make no sense, but often convey
a large concept in a fun way. German and Swedish are famous for their hilariously
odd idioms, and Brazilian Portuguese has some truly colourful great ones.

Some of my personal favourites come from the world of software development.

<!--more-->

## Bike Shedding

{{< figure src="images/bikeshed.gif" title="Bike shed" >}}

This is in reference to the *[Law of Triviality]* which states that disproportionate
time and emotional energy will be spent on the least important matters.

The core reason for this tends to be that: people either aren't capable of or
don't have the energy to understand the most complex aspects of a problem.
They don't want to be seen as not contributing to a project, so they focus
on the low-hanging fruit of trivial problems that anyone can understand.

The term bike shedding originates from a now famous [bikeshed email] from
Poul-Henning Kamp to the FreeBSD mailing list. After much discussion, planning,
and a careful implementation of a change, there was a backlash over its most
trivial aspects from people who didn't understand any of the complexity.

The bike shed metaphor itself comes from a 1960s writing by C. Northcote Parkinson
and was summarised well by Poul-Henning Kamp:

> Parkinson shows how you can go in to the board of directors and
get approval for building a multi-million or even billion dollar
atomic power plant, but if you want to build a bike shed you will
be tangled up in endless discussions.
>
> Parkinson explains that this is because an atomic plant is so vast,
so expensive and so complicated that people cannot grasp it, and
rather than try, they fall back on the assumption that somebody
else checked all the details before it got this far.
>
> A bike shed on the other hand.  Anyone can build one of those over
a weekend, and still have time to watch the game on TV.  So no
matter how well prepared, no matter how reasonable you are with
your proposal, somebody will seize the chance to show that he is
doing his job, that he is paying attention, that he is __here__.

This is an unfortunately persistent problem with humans in general. As our world
has become more complex, skillsets have become more specialised, meaning more
works seem like incomprehensible magic to nearly everyone else.
So the bits that the layman can understand, which will be the most trivial,
are the bits most easily targeted for criticism.

This is a problem I experience often enough in software. When designing a complex
system and presenting it to others, most criticism and feedback comes on the
most trivial parts. Try designing a robust and secure authentication and
authorisation system, and you'll get feedback from everyone on the wording of the
error messages and the colour of the links.


## Cargo Culting

{{< figure src="images/cargo-cult.jpg" title="Cargo Cult Airplane" >}}

When I first heard the story of the [cargo cult], I was amazed. I loved it.

During World War II, the United States used many islands in the Pacific as
bases of operations for the war effort. They built landing strips and flew in
cargo planes full of tinned food, medicine, vehicles, clothing, and other goods
that were a wonder to locals who had never seen anything like it. The soldiers
shared some goods with the locals. After the war, the armed forces left and the
planes never returned. The locals missed the shipments of interesting goods.
All they knew is that that when the large bird-shaped things came,
food and supplies came too. So they built airplane-shaped
structures and control towers out of sticks and whatever they could scrounge and
waited for all the cargo to return. Of course it never did.

This same concept is surprisingly pervasive in many industries, especially software development.
Open source software is a great thing for many reasons, not least of which is the
ability to learn from how others have done things. A downside to this can be
the propagation of practices by developers who want to achieve a similar goal,
but don't understand the code or tradeoffs behind the solution they copied.

You can easily detect cargo culting when you ask someone why they did something
and the answer is something to the effect of: "because I saw other people doing it."
I won't for a minute pretend I haven't done this. I think we all have. And eventually
when our cargo-culted solution breaks and we have to fix it, we have no idea how it
works or what we're doing and we're stuck...and we learn a lesson.


## Yak Shaving

{{< figure src="images/yak-shaving.png" title="Yak Shaving" >}}

When you have a task to do, but get side-tracked doing related tasks that you
feel like are pre-requisites. They're often not strictly necessary, but you do them
anyway.

Say you have to correct a UI typo an app you haven't touched in ages...

* You clone the repository
* You decide to Dockerize the application rather than install dependencies on your system
* Update the README for new Dockerizing approach
* Update outdated dependencies, some of which require some code changes
* Apply a linter/formatter to the codebase to correct inconsistencies
* ...

This goes on for half a day before you realise your five minute project has got out
of hand. You've spent the morning yak shaving. This list was easy to come up with
since I find myself doing exactly this list too often.

It's a hard problem since the tasks do add value and it feels good to work on them,
but they are not what you set out to do and they wreak havoc with your estimates.

This clip from Malcolm in the Middle is textbook yak shaving:

{{< youtube "8fnfeuoh4s8" >}}

There's no cut-and-dry answer to it. I usually allow myself to do a little bit of
yak shaving, get on with the task at hand, and create issues/tasks to follow-up
on the stuff I noticed along the way that should be handled.


[Law of Triviality]: https://en.wikipedia.org/wiki/Law_of_triviality
[bikeshed email]: http://phk.freebsd.dk/sagas/bikeshed/
[Cargo cult]: https://en.wikipedia.org/wiki/Cargo_cult
