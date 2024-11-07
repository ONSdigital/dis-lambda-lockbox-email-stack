# Contributing Guidelines

## Pre-commit

We encourage the use of `pre-commit` locally, this reduces the amount of common mistakes and engineers can just focus on reviewing the actual changes.

```bash
# Install pre-commit
brew install pre-commit
# Install dependencies
brew install terraform-docs tflint trivy checkov terrascan tfupdate jq
# This will enable pre-commit to run every time you git commit
pre-commit install
```

If you want to do an adhoc run of pre-commit

> :warning: This will only run on files that are staged in git

```bash
pre-commit run --all-files
```

If you want to commit and skip checks

```bash
git commit --no-verify -m "some message"
```

## Reporting Bugs/Feature Requests

We welcome you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue, please check existing open, or recently closed, issues to make sure somebody else hasn't already
reported the issue. Please try to include as much information as you can. Details like these are incredibly useful:

* A reproducible test case or series of steps
* The version of our code being used
* Any modifications you've made relevant to the bug
* Anything unusual about your environment or deployment

## Pull Request Process

When contributing to this repository, please first discuss the change you wish to make via issue, slack, or any other method with the owners of this repository before making a change.

We use Trunk-Based Development (TBD), please adhere to the following depending on the task you're performing:

### Creating a feature

1. Clone the repo

    ```bash
    git clone git@github.com:ONSDigital/<repo_slug>.git
    cd <repo_slug>
    ```

1. Create a new branch off `main`. Name the branch something related to the work being done, there is no strict convention

    ```bash
    git switch -c feature/<feature_name>
    ```

1. Make your changes and commit

1. Push your branch, this will trigger checks via the pipeline

    ```bash
    git push origin feature/<feature_name>
    ```

1. Create a PR against the `main` branch to start a discussion, if you have access to Slack raise a review request in [\#dev_code_review](https://uk-ons.enterprise.slack.com/archives/C4ERLBBNH) and, if needed, tag engineers to alert them

> :warning: At this point you may see merge conflicts, this is most likely because another change has gone in to `main` since you created your branch. If this is the case follow the steps in [Rebasing](#rebasing), then continue here.

1. Make any changes after review if required

1. Once everything looks good (your PR **must** have the approval of at least one engineer who has not contributed any commits to the PR, before) it can be merged and pushed to `origin`

### Rebasing

Rebasing is heavily encouraged using TBD as all history needs to be linear

```bash
git switch main
git pull --rebase origin main
git switch feature/<feature_name>
git rebase main
git push origin feature/<feature_name> --force-with-lease
```

> `--force-with-lease` flag - This will allow git to overwrite the history of the remote branch, if changes are detected since your last rebase then you will be notified. If we don’t do this Git will error when it sees that the local and remote branches' histories differ.

### Creating a release

```bash
git switch main                   # switch to our main branch
git pull --rebase origin main     # ensure that our local main is up-to-date with the remote main
git switch -c release/1.1.0       # create the Release branch
git push origin release/1.1.0     # push Release branch to remote
```

### Creating a tag

```bash
git switch release/1.1.0
git tag -a -m "Releasing version 1.1.0" v1.1.0
git push origin v1.1.0
```
