---
date: 2019-03-28T00:00:00Z
title: Upgrades and dot-zero versions
categories:
  - Tech
  - Opinion
  - Software
tags:
  - Software
  - Versioning
aliases:
  - /2019/03/28/thoughts-on-upgrades/
---

In my early days with software, I couldn't wait to upgrade to the latest versions of everything. Service Packs, patches, major new versions. I wanted to be running the latest and greatest versions of every piece of software I could on day zero.

At my first job, our tech lead who had been at this a lot longer than me took a more conservative approach. We wouldn't upgrade major software like our database or operating systems without at least one service release being available. We wouldn't adopt new major versions of language platforms until there had been a service release either. I was sometimes disappointed to have to wait for the latest and greatest, but I went along with it.

More than a decade later and I'm now completely on board with this. And there's no zealot like a convert, so here I am writing about it.

<!--more-->

[Semantic Versioning] is the modern day law of the land at least with open source applications and libraries. The quick summary is that all versions follow the `X.Y.Z` format where `X` is **major**, `Y` is **minor**, and `Z` is **patch**. Changes that are *breaking or backwards-incompatible* require a *major* bump. Changes that add new functionality but *shouldn't break* backwards compatibility require a *minor* bump. Bug fixes, security patches, and small performance tweaks bump the *patch*. Every time a version part is bumped, everything to the right goes to zero. So `2.3.1`, `2.3.2`, `2.4.0`, `3.0.0`.

When you're running a production system that is stable, you have to ask yourself: *why would this change be good for our product*? Any time you make a change, you're introducing the chance for something to go wrong. Even if it shouldn't go wrong and the maintainers say it is backwards compatible, you can't know that for certain because they didn't test your application with their new version.

When it comes to `x.y.0` versions, you're dealing with changes that have introduced new behaviours and possibly broken existing ones. As a `.0` version, this is the *first public release* of this new behaviour. So the question comes down to: do you need that new functionality so much that you're willing to be a guinea pig? Is it acceptable for this update breaks your app in production? Do you have the time to investigate bugs and open pull requests to the maintainer? If so, that's great! Software only gets better when it's put to the test in the real world and is updated to patch unforeseen issues.

If on the other hand you can't risk the downtime and don't have the time or capability to be a bug hunter, why would you do this to yourself? Let the others who *need* this new functionality take it out for a test drive and submit patches for bugs they find. Then when you get to at least patch version `x.y.1`, you'll have a safer upgrade. Can you recall a dot-zero release standing the test of time such that no patches were released before the next minor or major bump?

I do not in any way mean to knock the developers behind these projects. If developers waited for their software to be perfectly bug-free and absolutely guaranteed not to cause backwards compatibility issues, you'd see far fewer releases, perpetual betas, and more abandoned projects. Nobody wants that.

So decide if you need the new feature so much that you're willing to work through bugs, incorrect documentation, possible performance issues, and whatever else, then by all means go for that latest dot-zero release. Heck, go for unreleased versions! That's currently why I'm using [phoenix_live_view] and [circuits_gpio] even though neither have had a major release. I want the functionality and want to contribute to the projects. Plus, who doesn't love the feeling of submitting a pull request that causes a new version to be released?

[Semantic Versioning]: https://semver.org/
[phoenix_live_view]: https://github.com/phoenixframework/phoenix_live_view
[circuits_gpio]: https://github.com/elixir-circuits/circuits_gpio
