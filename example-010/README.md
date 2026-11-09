# example-010: Sentinel performance matrix

Measures how long a Sentinel policy check takes as the number of policies and the number of planned resources both grow.

- **Policy sets:** 100, 200, 300, 400, 500, and 1500 policies. Each policy iterates every `aws_s3_bucket` create/update change in `tfplan/v2` and checks that the name starts with `sentinel-perf-`. Because every policy walks the full resource list, evaluation cost grows with both the policy count and the resource count.
- **Workspaces:** 1k, 2.5k, 5k, 7.5k, and 10k `aws_s3_bucket` resources, each produced by a single `count`. The configs stay tiny while the plans get large.

> **PLAN ONLY.** Never confirm or apply these workspaces. Creating 1k to 10k S3 buckets would hit account bucket quotas, requires globally unique names, and costs money. Every run should be discarded after the policy check finishes.

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
│   └── policies-1500/       (policy-001 ... policy-1500)
└── workspaces/
    ├── resources-1k/main.tf     (count = 1000)
    ├── resources-2.5k/main.tf   (count = 2500)
    ├── resources-5k/main.tf     (count = 5000)
    ├── resources-7.5k/main.tf   (count = 7500)
    └── resources-10k/main.tf    (count = 10000)
```

Each policy file starts with a `# policy-NNN` header so every file is distinct. Bucket names use the `prefix` variable and the numeric count (`sentinel-perf-<prefix>-2500-<index>`), not the folder label, because dots are not valid in S3 bucket names. The `prefix` variable is required and has no default, so each workspace needs its own value. Otherwise two workspaces that create the same names would conflict, since S3 bucket names are global.

## Regenerate

`policy-sets/` and `workspaces/` are generated. Do not edit them by hand.

```bash
./generate.sh
```

The script can be run from any directory. It deletes and recreates `policy-sets/` and `workspaces/` relative to its own location, so repeated runs produce byte-identical output.

## Run a pair in HCP Terraform

Repeat these steps for each cell in the matrix below.

1. **Create the policy set.** In HCP Terraform, go to *Organization settings → Policy sets → Create policy set* and choose the Sentinel type. Connect it to this repository and set the policies path to `example-010/policy-sets/policies-<P>`. Scope it to the workspace you are testing.
2. **Create the workspace.** Create a workspace connected to this repository. Set the Terraform working directory to `example-010/workspaces/resources-<L>`. Add AWS credentials as workspace variables. A plan still needs provider configuration, but nothing is created.
3. **Set the Terraform variable `prefix` (unique per workspace).** Add a Terraform variable named `prefix` to the workspace, for example `ws-a` for one workspace and `ws-b` for another. Use only lowercase letters, digits, and hyphens, 1 to 20 characters, starting with a letter or digit. The variable has no default, so a plan fails until it is set. Two workspaces with the same value would try to create the same bucket names.
4. **Start a plan.** Choose *Start new plan*. Do not confirm or apply. Open the run's policy check step. Expected result: all policies pass, because every bucket name starts with `sentinel-perf-`.
5. **Record the timing.** Note the policy check duration in the matrix cell for this pair.
6. **Discard the run.** Choose *Discard run*. Then detach the policy set (or move to a different workspace) so that only one policy set applies to a workspace at a time.

## Results matrix

Rows are policy sets. Columns are workspaces. Fill in the policy check duration for each pair.

| Policies \ Resources | 1k | 2.5k | 5k | 7.5k | 10k |
| --- | --- | --- | --- | --- | --- |
| 100 policies | | | | | |
| 200 policies | | | | | |
| 300 policies | | | | | |
| 400 policies | | | | | |
| 500 policies | | | | | |
| 1500 policies | | | | | |
