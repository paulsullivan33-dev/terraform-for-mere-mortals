# What Terraform Is

**Terraform** is an open-source tool, written by
HashiCorp, for defining infrastructure in files and
then creating, changing, and deleting that
infrastructure to match. "Infrastructure" is said
broadly: cloud servers and networks, DNS records,
database instances, Kubernetes clusters — and, for
learning purposes, plain files on a disk. Anything
with an API that can create, read, update, and
delete things is fair game.

## Desired state, not steps

Most automation is a recipe: *do this, then this,
then check that*. Terraform configurations are
not recipes. They are a description of an end
state:

```hcl
resource "local_file" "note" {
  filename = "./out/note.txt"
  content  = "Deployed by Terraform.\n"
}
```

This says "a file with this name and this content
should exist" — not how or when to write it. When
you run Terraform, it compares the description
with what it last saw (its **state**, covered in
the State chapter), works out the difference, and
proposes the changes. That comparison step is the
**plan**, and it is the heart of the tool: you
always get to read the diff before agreeing to
it.

Two consequences follow from working this way:

- **Rerunning is safe.** Apply the same
  configuration twice and the second run changes
  nothing, because reality already matches. The
  word for this is *idempotent*.
- **Files are the source of truth.** The
  configuration can live in Git, be reviewed like
  code, and be re-applied to rebuild everything
  from nothing. This is the practice called
  **infrastructure as code**.

## Terraform core proposes; providers dispose

Terraform itself knows nothing about files, AWS,
or DNS. Two parts share the work:

- **Terraform core** (the `terraform` program)
  reads the configuration, keeps the state, and
  computes plans. It is the bookkeeper and the
  diff engine.
- **Providers** are plugins — one per platform —
  that know how to talk to a real API: create this
  bucket, read that record, delete that server.
  When a plan is applied, providers do the actual
  work.

Wherever this guide runs something for real, it
uses three small providers that operate entirely
on the local machine: `local` (files), `random`
(names, IDs, passwords), and `null` (a placeholder
that can run a script). The workflow is identical
to driving a cloud; only the stakes are lower.

## Where Terraform stops

Terraform **provisions**: it brings infrastructure
objects into existence and manages their whole
lifecycle, from creation to destruction. It is
deliberately weak at what happens *inside* a
running system — which packages are installed,
what a config file says, which services are
enabled. That is **configuration management**, the
job of tools like Ansible (covered in its own
guide in this series).

A rough boundary that works in practice:

| Question | Tool |
| --- | --- |
| Should this server / network / record exist at all? | Terraform |
| What is installed and configured on that server? | Ansible and friends |
| The thing's whole life, birth to deletion? | Terraform |
| Day-to-day contents of the operating system? | Configuration management |

The boundary is not a wall — providers can run a
script at creation time, and the worked example in
this guide does exactly that once — but treating
provisioning and configuration as separate jobs
keeps both tools doing what they are good at.

## The family resemblance to GitOps

If you have met **GitOps** (also covered in this
series), the idea will feel familiar: the desired
state of a system is declared in Git, and
something works to make reality match it.
Terraform is the older, manual member of that
family — reconciliation happens when a human (or a
CI pipeline) runs `plan` and `apply`, rather than
an agent watching the repository continuously.
The mental model transfers directly.

## What Terraform is not

- Not a configuration manager (see above).
- Not a monitoring tool: it checks reality when
  you run it, not continuously.
- Not automatic: nothing changes until somebody
  applies a plan.
- Not cloud-only: providers exist for on-premises
  hypervisors, network gear, SaaS tools, and the
  local machine you are learning on.

Next: install the tool and take a configuration
apart to see what the pieces are called.
