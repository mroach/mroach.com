---
title: Environment prompt for bash and irb
date: 2021-05-15T8:45:57+02:00
categories:
  - Tech
tags:
  - bash
  - Kuberentes
  - Ruby
  - Docker
thumbnail: /2021/05/environment-prompt-for-bash-and-irb/images/production.png
summary: |
  Include the current application environment in your prompts.
---

In the previous post ["Environment notice on Kubernetes"]({{< ref "/posts/2021/environment-notice" >}})
I setup an alert to be printed to the bash shell and Ruby console _irb_ on start.

I used  this setup for the past couple months and I noticed myself often double-checking
the current environment. Why? The original alert had scrolled out of view, and
owing to my healthy sense of environment paranoia, this was disconcerting.

One way to improve upon this is to embed the environment name into the prompts themselves
so they're never out of view and can't be ignored.

## stage-name.sh

We'll start with `env_alert.sh` from the previous post and modify it so that
instead of printing an alert to standard output, it prints only the colourised stage name.
This makes the script more reusable in different settings and easy to embed.

The only real change here is the printing at the end.

```bash
#!/bin/bash

set -euo pipefail

namespace=""

kse_namespace_file=/var/run/secrets/kubernetes.io/serviceaccount/namespace

if [ -f ${kse_namespace_file} ]; then
  namespace=$(cat ${kse_namespace_file})
else
  namespace=${KUBERNETES_NAMESPACE:-UNKNOWN}
fi

case ${namespace} in
  production) style="\e[91m" ;;
  staging)    style="\e[93m" ;;
  edge)       style="\e[36m" ;;
  *)          style="\e[95m" ;;
esac

echo -en "${style}${namespace}\e[0m"
```

## .bashrc

Now, let's use this new script to embed the colourised stage name into the bash prompt.

This file includes two styles. One with the stage name in the middle, and the other
with the stage name as a prefix to the prompt. After using both, I preferred
the first style with the prompt in the middle.

```bash
# Add the current stage name (edge, production, etc) to the prompt

# Style 1: Stage name in the middle
#          root@app-backend-web-74n7c6xfdc-nxbyg (production) /opt/app#
export PS1="\u@\h \e[2m(\e[0m$(/opt/bin/stage-name)\e[2m)\e[0m \[\e[01;34m\]\w\[\e[00m\]# "

# Style 2: Stage name prefix
# Example: [production] root@app-backend-web-74n7c6xfdc-nxbyg /opt/app#
# export PS1="[$(/opt/bin/stage-name)] \u@\h \[\e[01;34m\]\w\[\e[00m\]# "
```

Results in a prompt like:

```
root@app-backend-web-74n7c6xfdc-nxbyg (production) /opt/app#
```

## .irbrc

To customise the Ruby (and Rails) console, you add a profile to the hash at
`IRB.conf[:PROMPT][:MY_CUSTOM_PROMPT]` and then activate it with
`IRB.conf[:PROMPT_MODE] = :MY_CUSTOM_PROMPT`. Easy.

```ruby
stage_name = %x{/opt/bin/stage-name}

# Style 1: Stage inside the prompt
#          irb(main):001:0 (edge)>
prompt_base = "%N(%m):%03n:%i (#{stage_name})"

# Style 2: Stage as a prefix
#          [edge] irb(main):001:0>
# prompt_base = "[#{stage_name}] %N(%m):%03n:%i"

IRB.conf[:PROMPT][:ENV_ALERT] = {
  :PROMPT_I => "#{prompt_base}> ",
  :PROMPT_N => "#{prompt_base}> ",
  :PROMPT_S => "#{prompt_base}%l ",
  :PROMPT_C => "#{prompt_base}* ",
  :RETURN   => "=> %s\n"
}

IRB.conf[:PROMPT_MODE] = :ENV_ALERT
```

This causes `irb` and `rails` console to now include the environment:

```
Loading release environment (Rails 6.1.3.2)
irb(main):001:0 (edge)>
```

## Dockerfile

Finally, to add these changes to the release docker image, the stage script
and the two runtime config files needed to be added. That's it!

```Dockerfile
COPY docker/stage-name.sh /opt/bin/stage-name
COPY docker/bashrc /root/.bashrc
COPY docker/irbrc /root/.irbrc
```

## Result

Now the stage name is embedded into both the bash and Ruby prompts so it's never
out of view.

{{< figure src="images/edge.png" >}}
