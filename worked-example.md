# A Worked Example

One project, its whole life, with the real output
at each step. The project is the one in
`examples/` — copy it to a folder of your own to
follow along; everything runs locally.

**The cast.** A banner file ships with the
project and is *read* (data source). Terraform
generates a pretend server name (`random_pet`), a
build ID (`random_id`), and an admin token
(`random_password`). For each name in
`page_names` it writes a page file (`for_each`);
it writes `copies` identical build stamps
(`count`); a local module writes a release note;
a settings snapshot is stored by the built-in
`terraform_data`; and a `null_resource` appends
to a build log whenever the pages change.

## Step 1: apply from nothing

`init` (Providers chapter) then `plan` — **10 to
add, 0 to change, 0 to destroy** — then apply:

```
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
...
server_name = "correct-dane"
```

**Check:** the output directory holds both pages,
both stamps, the note, and one line in the log:

```
$ ls out/
build.log  dev-about.txt  dev-index.txt  note.txt  stamp-0.txt  stamp-1.txt

$ cat out/build.log
applied dev on correct-dane
```

A second `plan` now reports "No changes. Your
infrastructure matches the configuration." — the
baseline is real.

## Step 2: change two variables

Edit `terraform.tfvars`: a new `message`, and
`copies` from 2 to 3. Plan again. Read this one
slowly; it is the most instructive plan in the
guide:

```
  # local_file.pages["about"] must be replaced
-/+ resource "local_file" "pages" {
      ~ content              = <<-EOT # forces replacement
            FIELD NOTES - generated locally, managed by Terraform.
            Page: about
            Server: correct-dane
          - Message: Deployed by hand the first time.
          + Message: Updated by Terraform, not by hand.
        EOT
      ~ content_sha256       = "d72b357d..." -> (known after apply)
    }

  # local_file.pages["index"] must be replaced
        (the same content change)

  # local_file.stamp[2] will be created

  # null_resource.build_log must be replaced
      ~ triggers = { # forces replacement
          ~ "pages_sha" = "d70910c7..." -> (known after apply)
        }

  # terraform_data.settings will be updated in-place
      ~ input  = {
          ~ message     = "Deployed by hand the first time." -> "Updated by Terraform, not by hand."
            # (2 unchanged attributes hidden)
        }

Plan: 4 to add, 1 to change, 3 to destroy.
```

*(Two hash values shortened with `...`; the plan
also lists the pages' remaining checksum
attributes, each changing the same way.)*

Four different behaviours from one edit:

- **In-place update (`~`, the "1 to change").**
  The settings snapshot just changes a value.
- **Replacement (`-/+`, "must be replaced").**
  The page files' content changed — and for
  `local_file`, content *is* the file's identity
  (its ID is the content hash), so the provider
  destroys and recreates. Providers decide, per
  attribute, whether a change updates or replaces;
  the plan always tells you, with `# forces
  replacement` naming the attribute responsible.
  In cloud resources this is the line that
  separates "edit a tag" from "rebuild the
  database" — read it every time.
- **Creation (`+`).** `stamp[2]` exists because
  `copies` rose to 3. The `for_each` pages didn't
  churn: their keys were untouched.
- **Replacement by trigger.** The build log's
  `pages_sha` no longer matches (page contents
  changed), so the `null_resource` is replaced
  and its provisioner will re-run.

Apply agrees with the plan, as it must:

```
Apply complete! Resources: 4 added, 1 changed, 3 destroyed.
```

**Check:** `out/` now holds `stamp-2.txt`, the
pages carry the new message, and `build.log` has
a second line — the provisioner re-ran.

## Step 3: drift, by hand

Edit `out/dev-index.txt` with a text editor —
append a line Terraform didn't write — and plan:

```
  # local_file.pages["index"] will be created
  + resource "local_file" "pages" {
      + content              = <<-EOT
            FIELD NOTES - generated locally, managed by Terraform.
            Page: index
            Server: correct-dane
            Message: Updated by Terraform, not by hand.
        EOT
      + filename             = "./out/dev-index.txt"
      # (checksum attributes: known after apply)
    }

Plan: 2 to add, 0 to change, 1 to destroy.
```

Not "update", not "fix": **create**. Refresh
re-read the file, its content-hash ID no longer
matched what state recorded, and since the
content *is* this resource's identity, Terraform
concluded the managed file was gone and proposed
writing the desired one afresh (the extra add
and destroy are the build-log resource, whose
recorded hash also moved). Real resources usually
drift more gently — a changed tag plans as an
in-place `~` — but the mechanism is the same:
refresh sees what is, plan proposes restoring
what should be. Drift is treated fully in
Working Safely.

## Step 4: destroy, and what survives it

```
$ terraform destroy
...
Destroy complete! Resources: 10 destroyed.
```

Ten, not eleven: the drifted page had already
fallen out of state during Step 3's refresh, so
destroy no longer managed it. Afterwards:

```
$ ls out/
build.log  dev-index.txt

$ cat out/dev-index.txt
FIELD NOTES - generated locally, managed by Terraform.
Page: index
Server: correct-dane
Message: Updated by Terraform, not by hand.
a hand edit Terraform did not make
```

Two survivors, each a lesson. `build.log` was a
provisioner's side effect — Terraform tracks the
`null_resource`, not the line it appended.
`dev-index.txt` survived because it was orphaned
by drift before destroy ran: **destroy deletes
what state tracks, and only that.** On real
infrastructure the equivalent surprises are
buckets with versioning, load-balancer logs, and
anything a provisioner or a colleague made by
hand. The state is the inventory; keep it
accurate.
