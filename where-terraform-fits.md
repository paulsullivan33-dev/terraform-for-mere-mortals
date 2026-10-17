# Where Terraform Fits

Terraform's home ground is the cloud, but its
range is "anything with an API", and its honest
place in a smaller setup is narrower than its
reputation. A quick tour, with the parts that
weren't run in this guide marked as before.

## Cloud: the main habitat **(documented)**

The major providers — AWS, Azure, Google Cloud,
and a long tail of SaaS platforms (DNS hosts,
monitoring, identity, Git hosting) — each expose
thousands of resources, and this is where
Terraform earns its keep: a whole environment —
network, machines, database, records, permissions
— declared once, reviewable in a pull request,
rebuildable in another region from the same
files. Everything in the earlier chapters applies
unchanged; the providers are bigger, the plans
longer, the `# forces replacement` lines more
expensive to ignore. Nothing about cloud usage
was run for this guide.

## On premises **(documented)**

Providers exist for VMware vSphere, Proxmox,
libvirt, and common network platforms, and many
organisations Terraform their own racks the same
way. The mechanics differ in one respect: the
"API" is your own infrastructure, so provider
bugs and capacity limits are yours too. The
workflow — plan, read, apply — is identical.

## The home lab, honestly

Most home setups are a handful of machines that
change rarely. For those, the honest ranking is:

- **One host running services:** Docker Compose
  (its own guide in this series) — a YAML file and
  a daemon, no state to guard.
- **What runs inside machines:** Ansible (also in
  this series) — packages, users, configuration —
  is the daily tool.
- **Terraform earns its place** when cloud
  resources enter the picture (a VPS, DNS, object
  storage), when you want an environment you can
  destroy and rebuild identically, or — as this
  guide demonstrates — as the way to *learn*
  infrastructure as code with local providers
  before anything is at stake.

Reaching for Terraform to manage three static
machines is not wrong, but it buys a state file
to protect and a plan habit to maintain in
exchange for automation you may run twice a year.

## Next to its neighbours

- **Kubernetes:** a common division of labour is
  Terraform provisions the cluster and its
  surroundings; Kubernetes manifests (or Helm)
  then own what runs inside it. Terraform has a
  Kubernetes provider too; teams argue about the
  seam, but the seam exists.
- **GitOps:** Terraform configurations in Git,
  applied by pipelines on merge, are the push
  based dialect of the same desired-state idea
  the GitOps guide in this series describes.

## OpenTofu: the fork, plainly

In August 2023 HashiCorp relicensed Terraform
from the open-source MPL-2.0 to the Business
Source License (BUSL-1.1) — source-available,
but no longer open source by the usual
definitions. The community forked the last
MPL release as **OpenTofu**, now a Linux
Foundation project under MPL-2.0, with its own
registry and a `tofu` CLI mirroring Terraform's
commands. Configurations are, by the project's
design, largely compatible between the two.

That compatibility claim was spot-checked for
this guide rather than repeated: the example
project in `examples/` was initialised and
planned, unmodified, under **OpenTofu v1.13.1**.
It selected the same provider versions
(local 2.9.1, random 3.9.1, null 3.3.2) and
proposed creating the same ten resources. One
small local project is not a migration proof —
providers, state history, and edge cases are
where migrations get interesting **(documented)**
— but the floor of the claim held.

Which to choose is a governance and licensing
judgement more than a technical one: both tools
run the same language, and skills transfer
entirely. New learners can pick either and lose
nothing; teams should read both licences and
decide with their eyes open.

## Where to go next

- Your cloud provider's own Terraform tutorials,
  once a real account is in play.
- The registry documentation for the providers
  you actually use — the true reference for every
  resource.
- The [Writing Criteria](criteria.md) page lists
  exactly which parts of this guide were verified
  by running, and which are documentation only.
