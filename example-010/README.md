# example-010: Sentinel performance matrix

Measures how long a Sentinel policy check takes as the number of policies and the number of planned resources both grow.

- **Policy sets:** 100, 200, 300, 400, 500, 1100, and 1500 policies. Each policy checks every `null_resource`, `random_pet`, and `time_static` resource in `tfplan/v2` on every run, whatever its action (create, update, no-op, replace, or delete), and checks that the name starts with `sentinel-perf-`. Because every policy walks the full resource list, evaluation cost grows with both the policy count and the resource count.
- **Workspaces:** 1k, 2.5k, 3.75k, 5k, 7.5k, and 10k resources. Each workspace splits its total 50% `null_resource`, 30% `random_pet`, and 20% `time_static`, with each group produced by a `count`. The configs stay tiny while the plans get large. Each workspace also adds one `run_marker` resource that changes on every run (see [Why every run is checked](#why-every-run-is-checked)).

> **Dummy resources, safe to apply.** The workspaces use only the `null`, `random`, and `time` providers. They make no cloud API calls, so they need no credentials.

## Layout

```
example-010/
├── README.md
├── generate.sh
├── policy-sets/
│   ├── policies-100/
│   │   ├── policy-001.sentinel ... policy-100.sentinel
│   │   └── sentinel.hcl
│   ├── policies-200/        (policy-001 ... policy-200)
│   ├── policies-300/        (policy-001 ... policy-300)
│   ├── policies-400/        (policy-001 ... policy-400)
│   ├── policies-500/        (policy-001 ... policy-500)
│   ├── policies-1100/       (policy-001 ... policy-1100)
│   └── policies-1500/       (policy-001 ... policy-1500)
└── workspaces/
    ├── resources-1k/main.tf     (1000 resources + run_marker)
    ├── resources-2.5k/main.tf   (2500 resources + run_marker)
    ├── resources-3.75k/main.tf  (3750 resources + run_marker)
    ├── resources-5k/main.tf     (5000 resources + run_marker)
    ├── resources-7.5k/main.tf   (7500 resources + run_marker)
    └── resources-10k/main.tf    (10000 resources + run_marker)
```

Each policy file starts with a `# policy-NNN` header so every file is distinct. Resource names use the `prefix` variable and the numeric count, not the folder label. For example, a 2500-resource workspace with prefix `ws-a` produces `sentinel-perf-ws-a-2500-job-<index>` (`null_resource`), `sentinel-perf-ws-a-2500-pet-<index>` (`random_pet`), and `sentinel-perf-ws-a-2500-time-<index>` (`time_static`). The run marker is named `sentinel-perf-<prefix>-run-marker`. The `prefix` variable is required and has no default, so each workspace needs its own value. Otherwise two workspaces would produce identical resource names and their runs would be hard to tell apart.

## Why every run is checked

Each policy checks every `null_resource`, `random_pet`, and `time_static` resource in the plan, whatever its action. Policies do not filter by action, so creates, updates, no-ops, replacements, and deletes are all checked. On a later run, the N unchanged resources are still checked, not skipped.

Each workspace also has a `run_marker` resource. It is a `null_resource` whose `at` trigger is `timestamp()`, so it changes on every plan:

- **First run:** the plan adds N+1 resources (the N split resources plus `run_marker`).
- **Later runs:** the N split resources are no-ops, and only `run_marker` is replaced.

The marker keeps every plan non-empty, so the policy check always runs. It uses the same `sentinel-perf-` name prefix as every other resource, so it passes the same name rule.

## Regenerate

`policy-sets/` and `workspaces/` are generated. Do not edit them by hand.

```bash
./generate.sh
```

The script can be run from any directory. It deletes and recreates `policy-sets/` and `workspaces/` relative to its own location, so repeated runs produce byte-identical output.

## Run a pair in HCP Terraform

Repeat these steps for each cell in the matrix below.

1. **Create the policy set.** In HCP Terraform, go to *Organization settings → Policy sets → Create policy set* and choose the Sentinel type. Connect it to this repository and set the policies path to `example-010/policy-sets/policies-<P>`. Scope it to the workspace you are testing.
2. **Create the workspace.** Create a workspace connected to this repository. Set the Terraform working directory to `example-010/workspaces/resources-<L>`. No cloud credentials are needed, because the workspace uses only the `null`, `random`, and `time` providers.
3. **Set the Terraform variable `prefix` (unique per workspace).** Add a Terraform variable named `prefix` to the workspace, for example `ws-a` for one workspace and `ws-b` for another. Use only lowercase letters, digits, and hyphens, 1 to 20 characters, starting with a letter or digit. The variable has no default, so a plan fails until it is set. Two workspaces with the same value would produce the same resource names.
4. **Start a plan.** Choose *Start new plan*. Open the run's policy check step. Expected result: all policies pass, because every resource name starts with `sentinel-perf-`. Applying the run is safe, but the timing comes from the plan's policy check, so you do not need to apply.
5. **Record the timing.** Note the policy check duration in the matrix cell for this pair.
6. **Discard the run.** Choose *Discard run*. Then detach the policy set (or move to a different workspace) so that only one policy set applies to a workspace at a time.

## Results matrix

Rows are policy sets. Columns are workspaces. Fill in the policy check duration for each pair.

| Policies \ Resources | 1k | 2.5k | 3.75k | 5k | 7.5k | 10k |
| --- | --- | --- | --- | --- | --- | --- |
| 100 policies | | | | | | |
| 200 policies | | | | | | |
| 300 policies | | | | | | |
| 400 policies | | | | | | |
| 500 policies | | | | | | |
| 1100 policies | | | | | | |
| 1500 policies | | | | | | |
