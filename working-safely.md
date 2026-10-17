# Working Safely

Terraform's whole safety model is one idea: *you
see the change before it happens*. Everything in
this chapter is ways people defeat that idea, and
how not to.

## Read the plan like you mean it

- **Destroys and replacements first.** Scan for
  `-` and `-/+` before anything else, and for the
  words `# forces replacement` with the attribute
  named. A tag edit that secretly rebuilds a
  database announces itself exactly there — the
  Worked Example showed a harmless version, a
  file recreated over a changed line.
- **Check the summary against your intent.** You
  edited two values; the plan says "4 to add, 1 to
  change, 3 to destroy". Can you explain all
  seven? If not, stop. Explaining a plan is
  always possible; un-applying one is not.
- **Read the outputs diff too.** Values leaving
  the configuration (tokens, addresses) change
  there, visibly.
- **Prefer saved plans for anything shared.** The
  `plan -out` flow from Plan and Apply — reviewed
  file, applied verbatim — closes the gap between
  "the plan I approved" and "the plan that ran"
  while you were getting coffee.

## Drift: reality moves first

Terraform learns about the world by **refreshing**:
every plan re-reads the real objects behind the
state before diffing. Changes made outside
Terraform — a colleague's console click, another
tool, your own hand edit — therefore show up as
plans proposing to restore the configured state,
exactly as the Worked Example demonstrated
(comically strongly: a hand-edited file read as
*missing*, because its content was its identity).

Working rules:

- Drift is information, not an error. A plan
  showing drift on things *nobody admits to
  touching* is worth investigating before
  applying over it.
- `terraform plan -refresh-only` **(documented)**
  reports drift and updates state without
  proposing fixes — the reporting-only mode.
- `terraform apply -refresh-only` then updates
  state to accept reality as the new baseline.
  Know which direction you're reconciling before
  you run either.
- Repeated drift on the same attribute usually
  means another system owns it. Take the
  attribute out of your configuration (or give it
  to the other system) instead of fighting
  forever.

## Import: adopting what already exists **(documented)**

Not run in this guide — the lab had nothing
pre-existing to adopt — but the shape matters.
Many real projects begin with infrastructure that
was created by hand and must come under
management without being recreated. `terraform
import <address> <real-world-id>` (or declarative
`import` blocks, the modern form) records an
existing object into state at a configuration
address; you then write configuration to match
it, and iterate `plan` until it reports no
changes. Import teaches nothing to the object
itself; it is bookkeeping, done carefully, with
a plan diff as the proof that config and reality
now describe the same thing.

## -target: a scalpel, not a hammer **(documented)**

`terraform apply -target=random_pet.server`
restricts an operation to one resource (and its
dependencies). It exists for emergencies: a
broken resource blocking an unrelated apply, a
surgical repair. As a routine habit it corrupts
the model's one promise — that the configuration
and reality converge — because everything *not*
targeted is silently left unexamined. If you use
it, the very next run is a full, untargeted plan.

## State, handled safely

The rules from the State chapter, operationalised:

- **Back up before surgery.** `state mv` /
  `state rm` **(documented)** exist to rename
  resources in configuration without recreating
  them, and to forget resources without
  destroying them. Both rewrite state; both want
  a copy of `terraform.tfstate` taken first and a
  verifying plan after.
- **Remote state for anything shared**
  **(documented)**: once a second person or a CI
  system applies, local files are disqualified —
  no locking, no shared truth. Moving is a
  one-time `terraform init -migrate-state` after
  adding the backend block; Terraform offers to
  copy the state up. HCP Terraform (formerly
  Terraform Cloud) is HashiCorp's hosted version
  of the same idea — state, locking, and runs in
  their service.
- **Secrets hygiene is state hygiene.** State
  holds generated secrets in plain text (proven
  in the State chapter). Keep state and `*.tfvars`
  out of Git, keep backends access-controlled,
  and feed secrets from environment variables or
  a secrets manager **(documented)** rather than
  typing them into files that get committed.

## The boring habits that prevent the stories

- Pin Terraform and providers; commit
  `.terraform.lock.hcl`.
- One configuration, one state, one environment:
  don't multiplex production and experiments
  into one state to save effort. (**Workspaces**
  — several named states for one configuration —
  exist **(documented)**; most teams outgrow
  them into separate configurations.)
- In CI: plan on the pull request, post the plan
  where reviewers see it, apply the *saved* plan
  after merge. No applies from laptops once a
  pipeline exists.
- Small configurations over monoliths: the blast
  radius of a plan is the state it can see.
