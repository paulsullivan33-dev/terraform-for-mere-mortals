# Terraform for Mere Mortals

**Terraform** is a tool for describing
infrastructure — servers, networks, DNS records,
files, whole cloud accounts — as text files, and
then making the real world match the description.
You write what should exist. Terraform works out
what has to change, shows you the list, and only
then touches anything.

The files are the point. Because the desired end
state lives in text, it can be reviewed, versioned
in Git, and rebuilt from nothing — the idea called
**infrastructure as code**.

This guide teaches the tool itself, not a cloud.
Every command was run against providers that
operate entirely on one ordinary machine — writing
files, generating names and numbers — so the full
lifecycle you will use on real infrastructure
(init, plan, apply, change, destroy) happens here
with nothing at stake. What could not be run that
way — real cloud resources, remote state backends,
Terraform Cloud — is marked **(documented)**
wherever it appears.

It assumes you use a terminal and have edited
configuration files before. No cloud account is
needed for anything in the guide.

## What this guide covers

- [**What Terraform is**](what-terraform-is.md) —
  desired state, providers, and where Terraform's
  job ends and configuration management begins
- [**Your first configuration**](your-first-configuration.md) —
  installing the tool, and the anatomy of the
  language it reads
- [**Providers and resources**](providers-and-resources.md) —
  the plugins that do the work, version pinning,
  and the lock file
- [**Plan and apply**](plan-and-apply.md) — the
  core loop: read the diff before you agree to it
- [**State**](state.md) — the file Terraform
  cannot work without, and why it holds your
  secrets in plain text
- [**Variables and outputs**](variables-and-outputs.md) —
  inputs with defaults and validation, outputs
  worth reading back, and the sensitive ones
- [**Expressions and repetition**](expressions-and-repetition.md) —
  `count`, `for_each`, functions, conditionals,
  locals, and data sources
- [**Modules**](modules.md) — packaging
  configuration into a reusable, callable unit
- [**A worked example**](worked-example.md) — one
  small project through its whole life: apply,
  inspect, change, drift, destroy
- [**Working safely**](working-safely.md) —
  reading plans like you mean it, drift, import,
  and the sharp tools to reach for last
- [**Where Terraform fits**](where-terraform-fits.md) —
  cloud, premises, and home lab; and OpenTofu, the
  community fork
- [**Glossary**](glossary.md) — the terms,
  collected in one place

## What it doesn't cover

Any specific cloud provider in depth (each is a
guide of its own), Kubernetes provisioning,
writing your own provider, and HCP Terraform /
Terraform Cloud beyond naming what it is for.

## How to use this guide

The lifecycle in these chapters is real. Terraform
v1.16.6 ran the example project in `examples/`
from an empty directory to a clean destroy,
including a deliberate mis-formatting for `fmt` to
fix, a variable change that replaced some
resources and updated one in place, and a
hand-edited file that Terraform then treated as
drift. Every output block presented as a run is
quoted from those runs. The criterion-by-criterion
account is in [Writing Criteria](criteria.md).
