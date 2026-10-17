# Writing Criteria

Every guide in this repo is written to the same standard. If you're
adding or editing a guide — human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language, never dumbed-down
   concepts. Explain jargon on first use; collect terms in the
   glossary.
2. **No hype.** No marketing adjectives, no "revolutionary," no
   promises about what something will do for the reader.
3. **Honest about limits.** Say what the thing *can't* do. State
   uncertainty instead of smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults, and specs are either
   measured or qualified with "depends on your setup." If it wasn't
   tested, say so.
5. **Checkable.** Commands are meant to be run, with "Check:" blocks
   showing what success looks like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out Windows/Mac/Linux
   differences. Don't assume a GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and points elsewhere for
   the rest. No guide pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after examples,
   symptom → fix. Scannable beats essay.

## Verification notes for this guide

Standard 3 and 4 applied to this guide, specifically:

**Verified by running, on the build machine:**
- Terraform v1.16.6 (official HashiCorp build,
  SHA-256 checked against the published sums),
  with providers hashicorp/local 2.9.1,
  hashicorp/random 3.9.1 and hashicorp/null 3.3.2,
  installed fresh from registry.terraform.io.
- The example project in `examples/` was run
  through its entire life in the lab: `fmt`
  (including a `-diff` capture of it fixing a
  deliberate misalignment), `init` with the lock
  file created, `validate`, `plan` (10 to add),
  `apply` (10 added), `terraform output`
  (including the sensitive value printing only as
  `<redacted>`, and a 16-character length check on
  the token that never printed it), `state list`
  and `state show`, and a follow-up plan reporting
  "No changes."
- A change to two variable values produced the
  quoted plan verbatim — 4 to add, 1 to change,
  3 to destroy: the settings resource updated in
  place, the page files were destroyed and
  recreated ("forces replacement"), a third stamp
  appeared, and a re-apply matched the plan
  exactly. The build log written by a local-exec
  provisioner gained its second line, as expected.
- Drift was produced for real by hand-editing a
  managed file; the next plan treated the file as
  gone and proposed recreating it. A later
  `destroy` removed the 10 resources still under
  management and left the log and the orphaned
  drifted file behind — both quoted, not tidied.
- A variable-validation failure was triggered and
  is quoted verbatim. Expression results in the
  Expressions chapter are from real
  `terraform console` evaluations. A saved plan
  (`plan -out`, `show`, `apply`) was run end to
  end. The example also initialised and planned
  unchanged under OpenTofu v1.13.1, which selected
  the same provider versions.
- `terraform fmt -check -recursive` passes on the
  shipped example files.

**Documented-only (not run), and why:**
- Everything involving a real cloud or remote
  API — AWS, Azure, GCP and all other providers
  beyond local/random/null — plus remote backends
  (S3, GCS, Azure Storage), state locking
  services, backend migration, and HCP Terraform
  (Terraform Cloud). No cloud accounts or
  credentials exist in the build lab, and none
  were invented. Where these are described, they
  follow HashiCorp's documentation.
- `terraform import`, import blocks, registry
  modules, `state mv`/`rm` surgery, workspaces,
  and `-target` are explained at the level the
  chapters mark as **(documented)**; only the
  local module in `examples/` was actually run.
