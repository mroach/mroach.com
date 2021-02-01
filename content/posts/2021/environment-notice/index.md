---
title: "Environment notice on Kubernetes"
date: 2021-02-01T13:45:57+01:00
categories:
  - Tech
tags:
  - bash
  - Kuberentes
  - Ruby
thumbnail: /2021/02/environment-notice-on-kubernetes/images/thumb.png
summary: |
  Give yourself an alert about the current Kubernetes namespace when launching a Bash
  shell or Rails console.
---

{{< figure src="images/thumb.png" class="float-right" >}}

A recent project of mine has been getting a Rails application set up on Kuberentes.

I've found myself frequently opening up shells and Rails consoles on the pods for debugging and testing.
It didn't take long before I almost ran something in production that I meant to run in the staging environment.

Sometimes a simple alert is enough to keep you from shooting yourself in the foot.

I created a simple Bash script, added it to the Docker image, and added it to both
the Bash and `irb` profiles so that it would be executed when starting either
a Bash shell or a Rails console and let me know which environment I'm in.

## env_alert.sh

In our setup, Kubernetes namespaces denote the environment such as *production* or *staging*.

On a running pod, you can read the current Kuberentes namespace from a file mounted by Kubernetes:

```shell
$ cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
edge
```

As a fallback, try reading the environment variable `KUBERNETES_NAMESPACE` which we set globally.
This could come in handy if the `namespace` file path ever changes.

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
  production) style="\e[91m\e[21m\e[7m" ;;
  staging)    style="\e[93m" ;;
  edge)       style="\e[36m" ;;
  *)          style="\e[95m" ;;
esac

echo
echo -e "  This is the ${style}${namespace}\e[0m environment."
echo
```

## Dockerfile

In the `Dockerfile`, `env_alert.sh` is added to `/opt/bin`.

To run it when starting an interactive Bash shell, append to `~/.bashrc`

To run it when starting a Rails console, add a line of Ruby to `~/.irbrc`

```Dockerfile
COPY docker/env_alert.sh /opt/bin/env_alert

RUN echo /opt/bin/env_alert >> ~/.bashrc
RUN echo 'system "/opt/bin/env_alert"' >> ~/.irbrc
```

## Result

Now the script runs every time a shell or Rails console is started.

Big warning in the _production_ environment:

{{< figure src="images/production.png" >}}

More subtle notice in the _edge_ environment:

{{< figure src="images/edge.png" >}}
