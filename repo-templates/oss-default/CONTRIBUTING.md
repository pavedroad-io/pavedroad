{% if contributing == 'contrib-cncf' %}
## How to Contribute

The {{project}} project from {{orgazization}} is under [Apache 2.0 license](LICENSE). We accept contributions via
GitHub pull requests. This document outlines some of the conventions related to
development workflow, commit message formatting, contact points and other
resources to make it easier to get your contribution accepted.

## Certificate of Origin

By contributing to this project you agree to the Developer Certificate of
Origin (DCO). This document was created by the Linux Kernel community and is a
simple statement that you, as a contributor, have the legal right to make the
contribution. See the [DCO](DCO) file for details.

Contributors sign-off that they adhere to these requirements by adding a
Signed-off-by line to commit messages. For example:

```
This is my commit message

Signed-off-by: Random J Developer <random@developer.example.org>
```

Git even has a -s command line option to append this automatically to your
commit message:

```
git commit -s -m 'This is my commit message'
```

If you have already made a commit and forgot to include the sign-off, you can amend your last commit
to add the sign-off with the following command, which can then be force pushed.

```
git commit --amend -s
```

We use a [DCO bot](https://github.com/apps/dco) to enforce the DCO on each pull
request and branch commits.

## Getting Started

- Fork the repository on GitHub
- Read the [install](INSTALL.md) for build and test instructions
- Play with the project, submit bugs, submit patches!

## Contribution Flow

This is a rough outline of what a contributor's workflow looks like:

- Create a branch from where you want to base your work (usually master).
- Make your changes and arrange them in readable commits.
- Make sure your commit messages are in the proper format (see below).
- Push your changes to the branch in your fork of the repository.
- Make sure all linters and tests pass, and add any new tests as appropriate.
- Submit a pull request to the original repository.

## Building

Details about building the {{project}} project can be found in [INSTALL.md](INSTALL.md).

## Coding Style and Linting

The {{project}} project is written in Go. Coding style is enforced by
[golangci-lint](https://github.com/golangci/golangci-lint). The {{project}} project linter
configuration is [documented here](.golangci.yml). Builds will fail locally and
in CI if linter warnings are introduced:
    {% if False %}
```bash
$ make build
==> Linting /REDACTED/go/src/github.com/{{org}}io/{{org}}/cluster/charts/{{org}}
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, no failures
20:31:42 [ .. ] helm dep {{org}} 0.1.0-136.g2dfb012.dirty
No requirements found in /REDACTED/go/src/github.com/{{org}}io/{{org}}/cluster/charts/{{org}}/charts.
20:31:42 [ OK ] helm dep {{org}} 0.1.0-136.g2dfb012.dirty
20:31:42 [ .. ] golangci-lint
pkg/clients/azure/redis/redis.go:35:7: exported const `NamePrefix` should have comment or be unexported (golint)
const NamePrefix = "acr"
      ^
20:31:55 [FAIL]
make[2]: *** [go.lint] Error 1
make[1]: *** [build.all] Error 2
make: *** [build] Error 2
```
    {% endif %}

Note that Jenkins builds will not output linter warnings in the build log.
Instead `upbound-bot` will leave comments on your pull request when a build
fails due to linter warnings. You can run `make lint` locally to help determine
whether you've fixed any linter warnings detected by Jenkins.

In some cases linter warnings will be false positives. `golangci-lint` supports
`//nolint[:lintername]` comment directives in order to quell them. Please
include an explanatory comment if you must add a `//nolint` comment. You may
also submit a PR against [`.golangci.yml`](.golangci.yml) if you feel
particular linter warning should be permanently disabled.

## Comments

Comments should be added to all new methods and structures as is appropriate for the coding
language. Additionally, if an existing method or structure is modified sufficiently, comments should
be created if they do not yet exist and updated if they do.

The goal of comments is to make the code more readable and grokkable by future developers. Once you
have made your code as understandable as possible, add comments to make sure future developers can
understand (A) what this piece of code's responsibility is within the {{project}} project architecture and (B) why it
was written as it was.

The below blog entry explains more the why's and how's of this guideline.
https://blog.codinghorror.com/code-tells-you-how-comments-tell-you-why/

For Go, the {{project}} project follows standard godoc guidelines.
A concise godoc guideline can be found here: https://blog.golang.org/godoc-documenting-go-code

## Commit Messages

We follow a rough convention for commit messages that is designed to answer two
questions: what changed and why. The subject line should feature the what and
the body of the commit should describe the why.

```
aws: add support for RDS controller

this commit enables controllers and apis for RDS. It
enables provisioning a RDS database.
```

The format can be described more formally as follows:

```
<subsystem>: <what changed>
<BLANK LINE>
<why this change was made>
<BLANK LINE>
<footer>
```

The first line is the subject and should be no longer than 70 characters, the
second line is always blank, and other lines should be wrapped at 80 characters.
This allows the message to be easier to read on GitHub as well as in various
git tools.


## Adding New Resources

### Project Organization
The {{project}} project is based on and intially created by using [Kubebuilder is a framework for building Kubernetes APIs](https://github.com/kubernetes-sigs/kubebuilder).

The {{project}} project organizes resources (api types and controllers) by grouping them by Cloud Provider with further sub-group by resource type 

The Kubebuilder framework does not provide good support for projects with multiple groups and group tiers which contain resources with overlapping names. 
    {% if False %}
For example:
```
pkg
├── apis
│   ├── aws
│   │   ├── apis.go
│   │   └── database
│   │       ├── group.go
│   │       └── v1alpha1
│   │           ├── doc.go
│   │           ├── rds_instance_types.go
│   │           ├── rds_instance_types_test.go
│   │           ├── register.go
│   │           ├── v1alpha1_suite_test.go
│   │           └── zz_generated.deepcopy.go
│   └── gcp
│       ├── apis.go
│       └── database
│           ├── group.go
│           └── v1alpha1
│               ├── cloudsql_instance_types.go
│               ├── cloudsql_instance_types_test.go
│               ├── doc.go
│               ├── register.go
│               ├── v1alpha1_suite_test.go
│               └── zz_generated.deepcopy.go
└── controller
    ├── aws
    │   ├── controller.go
    │   └── database
    │       ├── database_suite_test.go
    │       ├── rds_instance.go
    │       └── rds_instance_test.go
    └── gcp
        ├── controller.go
        └── database
            ├── cloudsql_instance.go
            ├── cloudsql_instance_test.go
            └── database_suite_test.go
```
In above example we have two groups with sub-group (tiers):
- aws/rds
- gcp/cloudsql

In addition both groups contain types with the same name: `Instance`
    {% endif %}

### Creating New Resource
There are several different ways you can approach the creation of the new resources:
#### Manual
Good ol' copy & paste of existing resource for both apis and controller (if new controller is needed for your resource) and update the copied code to tailor your needs.

#### Kubebuilder With New Project
Create and Initialize a new (temporary) kubebuilder project and create new resources: apis and controller(s), then copy them into the {{project}} project following the established project organization.

To verify that new artifacts run: 
```bash
make build test
```

## Local Build and Test

To learn more about the developer iteration workflow, including how to locally test new types/controllers, please refer to the [Local Build](cluster/local/README.md) instructions.
{% elif contributing == 'contrib-guide' %}
# Contributing

## How do I... <a name="toc"></a>

* [Use This Guide](#introduction)?
* Ask or Say Something?
  * [Request Support](#request-support)
  * [Report an Error or Bug](#report-an-error-or-bug)
  * [Request a Feature](#request-a-feature)
* Make Something?
  * [Project Setup](#project-setup)
  * [Contribute Documentation](#contribute-documentation)
  * [Contribute Code](#contribute-code)
* Manage Something
  * [Provide Support on Issues](#provide-support-on-issues)
  * [Label Issues](#label-issues)
  * [Clean Up Issues and PRs](#clean-up-issues-and-prs)
  * [Review Pull Requests](#review-pull-requests)
  * [Merge Pull Requests](#merge-pull-requests)
  * [Tag a Release](#tag-a-release)
  * [Join the Project Team](#join-the-project-team)
* Add a Guide Like This One [To My Project](#attribution)?

## Introduction

Thank you so much for your interest in contributing!. All types of contributions are encouraged and valued. See the [table of contents](#toc) for different ways to help and details about how this project handles them!

Please make sure to read the relevant section before making your contribution! It will make it a lot easier for us maintainers to make the most of it and smooth out the experience for all involved.

The [Project Team](#join-the-project-team) looks forward to your contributions.

## Request Support

If you have a question about this project, how to use it, or just need clarification about something:

* Open an Issue at https://github.com/wealljs/weallcontribute/issues
* Provide as much context as you can about what you're running into.
* Provide project and platform versions (nodejs, npm, etc), depending on what seems relevant. If not, please be ready to provide that information if maintainers ask for it.

Once it's filed:

* The project team will [label the issue](#label-issues).
* Someone will try to have a response soon.
* If you or the maintainers don't respond to an issue for 30 days, the [issue will be closed](#clean-up-issues-and-prs). If you want to come back to it, reply (once, please), and we'll reopen the existing issue. Please avoid filing new issues as extensions of one you already made.

## Report an Error or Bug

If you run into an error or bug with the project:

* Open an Issue at https://github.com/wealljs/weallcontribute/issues
* Include *reproduction steps* that someone else can follow to recreate the bug or error on their own.
* Provide project and platform versions (nodejs, npm, etc), depending on what seems relevant. If not, please be ready to provide that information if maintainers ask for it.

Once it's filed:

* The project team will [label the issue](#label-issues).
* A team member will try to reproduce the issue with your provided steps. If there are no repro steps or no obvious way to reproduce the issue, the team will ask you for those steps and mark the issue as `needs-repro`. Bugs with the `needs-repro` tag will not be addressed until they are reproduced.
* If the team is able to reproduce the issue, it will be marked `needs-fix`, as well as possibly other tags (such as `critical`), and the issue will be left to be [implemented by someone](#contribute-code).
* If you or the maintainers don't respond to an issue for 30 days, the [issue will be closed](#clean-up-issues-and-prs). If you want to come back to it, reply (once, please), and we'll reopen the existing issue. Please avoid filing new issues as extensions of one you already made.
* `critical` issues may be left open, depending on perceived immediacy and severity, even past the 30 day deadline.

## Request a Feature

If the project doesn't do something you need or want it to do:

* Open an Issue at https://github.com/wealljs/weallcontribute/issues
* Provide as much context as you can about what you're running into.
* Please try and be clear about why existing features and alternatives would not work for you.

Once it's filed:

* The project team will [label the issue](#label-issues).
* The project team will evaluate the feature request, possibly asking you more questions to understand its purpose and any relevant requirements. If the issue is closed, the team will convey their reasoning and suggest an alternative path forward.
* If the feature request is accepted, it will be marked for implementation with `feature-accepted`, which can then be done by either by a core team member or by anyone in the community who wants to [contribute code](#contribute-code).

Note: The team is unlikely to be able to accept every single feature request that is filed. Please understand if they need to say no.

## Project Setup

So you wanna contribute some code! That's great! This project uses GitHub Pull Requests to manage contributions, so [read up on how to fork a GitHub project and file a PR](https://guides.github.com/activities/forking) if you've never done it before.

If this seems like a lot or you aren't able to do all this setup, you might also be able to [edit the files directly](https://help.github.com/articles/editing-files-in-another-user-s-repository/) without having to do any of this setup. Yes, [even code](#contribute-code).

If you want to go the usual route and run the project locally, though:

* [Install Node.js](https://nodejs.org/en/download/)
* [Fork the project](https://guides.github.com/activities/forking/#fork)

Then in your terminal:
* `cd path/to/your/clone`
* `npm install`
* `npm test`

And you should be ready to go!

## Contribute Documentation

Documentation is a super important, critical part of this project. Docs are how we keep track of what we're doing, how, and why. It's how we stay on the same page about our policies. And it's how we tell others everything they need in order to be able to use this project -- or contribute to it. So thank you in advance.

Documentation contributions of any size are welcome! Feel free to file a PR even if you're just rewording a sentence to be more clear, or fixing a spelling mistake!

To contribute documentation:

* [Set up the project](#project-setup).
* Edit or add any relevant documentation.
* Make sure your changes are formatted correctly and consistently with the rest of the documentation.
* Re-read what you wrote, and run a spellchecker on it to make sure you didn't miss anything.
* Write clear, concise commit message(s) using [conventional-changelog format](https://github.com/conventional-changelog/conventional-changelog-angular/blob/master/convention.md). Documentation commits should use `docs(<component>): <message>`.
* Go to https://github.com/wealljs/weallcontribute/pulls and open a new pull request with your changes.
* If your PR is connected to an open issue, add a line in your PR's description that says `Fixes: #123`, where `#123` is the number of the issue you're fixing.

Once you've filed the PR:

* One or more maintainers will use GitHub's review feature to review your PR.
* If the maintainer asks for any changes, edit your changes, push, and ask for another review.
* If the maintainer decides to pass on your PR, they will thank you for the contribution and explain why they won't be accepting the changes. That's ok! We still really appreciate you taking the time to do it, and we don't take that lightly.
* If your PR gets accepted, it will be marked as such, and merged into the `latest` branch soon after. Your contribution will be distributed to the masses next time the maintainers [tag a release](#tag-a-release)

## Contribute Code

We like code commits a lot! They're super handy, and they keep the project going and doing the work it needs to do to be useful to others.

Code contributions of just about any size are acceptable!

The main difference between code contributions and documentation contributions is that contributing code requires inclusion of relevant tests for the code being added or changed. Contributions without accompanying tests will be held off until a test is added, unless the maintainers consider the specific tests to be either impossible, or way too much of a burden for such a contribution.

To contribute code:

* [Set up the project](#project-setup).
* Make any necessary changes to the source code.
* Include any [additional documentation](#contribute-documentation) the changes might need.
* Write tests that verify that your contribution works as expected.
* Write clear, concise commit message(s) using [conventional-changelog format](https://github.com/conventional-changelog/conventional-changelog-angular/blob/master/convention.md).
* Dependency updates, additions, or removals must be in individual commits, and the message must use the format: `<prefix>(deps): PKG@VERSION`, where `<prefix>` is any of the usual `conventional-changelog` prefixes, at your discretion.
* Go to https://github.com/wealljs/weallcontribute/pulls and open a new pull request with your changes.
* If your PR is connected to an open issue, add a line in your PR's description that says `Fixes: #123`, where `#123` is the number of the issue you're fixing.

Once you've filed the PR:

* Barring special circumstances, maintainers will not review PRs until all checks pass (Travis, AppVeyor, etc).
* One or more maintainers will use GitHub's review feature to review your PR.
* If the maintainer asks for any changes, edit your changes, push, and ask for another review. Additional tags (such as `needs-tests`) will be added depending on the review.
* If the maintainer decides to pass on your PR, they will thank you for the contribution and explain why they won't be accepting the changes. That's ok! We still really appreciate you taking the time to do it, and we don't take that lightly.
* If your PR gets accepted, it will be marked as such, and merged into the `latest` branch soon after. Your contribution will be distributed to the masses next time the maintainers [tag a release](#tag-a-release)

## Provide Support on Issues

[Needs Collaborator](#join-the-project-team): none

Helping out other users with their questions is a really awesome way of contributing to any community. It's not uncommon for most of the issues on an open source projects being support-related questions by users trying to understand something they ran into, or find their way around a known bug.

Sometimes, the `support` label will be added to things that turn out to actually be other things, like bugs or feature requests. In that case, suss out the details with the person who filed the original issue, add a comment explaining what the bug is, and change the label from `support` to `bug` or `feature`. If you can't do this yourself, @mention a maintainer so they can do it.

In order to help other folks out with their questions:

* Go to the issue tracker and [filter open issues by the `support` label](https://github.com/wealljs/weallcontribute/issues?q=is%3Aopen+is%3Aissue+label%3Asupport).
* Read through the list until you find something that you're familiar enough with to give an answer to.
* Respond to the issue with whatever details are needed to clarify the question, or get more details about what's going on.
* Once the discussion wraps up and things are clarified, either close the issue, or ask the original issue filer (or a maintainer) to close it for you.

Some notes on picking up support issues:

* Avoid responding to issues you don't know you can answer accurately.
* As much as possible, try to refer to past issues with accepted answers. Link to them from your replies with the `#123` format.
* Be kind and patient with users -- often, folks who have run into confusing things might be upset or impatient. This is ok. Try to understand where they're coming from, and if you're too uncomfortable with the tone, feel free to stay away or withdraw from the issue. (note: if the user is outright hostile or is violating the CoC, [refer to the Code of Conduct](CODE_OF_CONDUCT.md) to resolve the conflict).

## Label Issues

[Needs Collaborator](#join-the-project-team): Issue Tracker

One of the most important tasks in handling issues is labeling them usefully and accurately. All other tasks involving issues ultimately rely on the issue being classified in such a way that relevant parties looking to do their own tasks can find them quickly and easily.

In order to label issues, [open up the list of unlabeled issues](https://github.com/wealljs/weallcontribute/issues?q=is%3Aopen+is%3Aissue+no%3Alabel) and, **from newest to oldest**, read through each one and apply issue labels according to the table below. If you're unsure about what label to apply, skip the issue and try the next one: don't feel obligated to label each and every issue yourself!

Label | Apply When | Notes
--- | --- | ---
`bug` | Cases where the code (or documentation) is behaving in a way it wasn't intended to. | If something is happening that surprises the *user* but does not go against the way the code is designed, it should use the `enhancement` label.
`critical` | Added to `bug` issues if the problem described makes the code completely unusable in a common situation. |
`documentation` | Added to issues or pull requests that affect any of the documentation for the project. | Can be combined with other labels, such as `bug` or `enhancement`.
`duplicate` | Added to issues or PRs that refer to the exact same issue as another one that's been previously labeled. | Duplicate issues should be marked and closed right away, with a message referencing the issue it's a duplicate of (with `#123`)
`enhancement` | Added to [feature requests](#request-a-feature), PRs, or documentation issues that are purely additive: the code or docs currently work as expected, but a change is being requested or suggested. |
`help wanted` | Applied by [Committers](#join-the-project-team) to issues and PRs that they would like to get outside help for. Generally, this means it's lower priority for the maintainer team to itself implement, but that the community is encouraged to pick up if they so desire | Never applied on first-pass labeling.
`in-progress` | Applied by [Committers](#join-the-project-team) to PRs that are pending some work before they're ready for review. | The original PR submitter should @mention the team member that applied the label once the PR is complete.
`performance` | This issue or PR is directly related to improving performance. |
`refactor` | Added to issues or PRs that deal with cleaning up or modifying the project for the betterment of it. |
`starter` | Applied by [Committers](#join-the-project-team) to issues that they consider good introductions to the project for people who have not contributed before. These are not necessarily "easy", but rather focused around how much context is necessary in order to understand what needs to be done for this project in particular. | Existing project members are expected to stay away from these unless they increase in priority.
`support` | This issue is either asking a question about how to use the project, clarifying the reason for unexpected behavior, or possibly reporting a `bug` but does not have enough detail yet to determine whether it would count as such. | The label should be switched to `bug` if reliable reproduction steps are provided. Issues primarily with unintended configurations of a user's environment are not considered bugs, even if they cause crashes.
`tests` | This issue or PR either requests or adds primarily tests to the project. | If a PR is pending tests, that will be handled through the [PR review process](#review-pull-requests)
`wontfix` | Labelers may apply this label to issues that clearly have nothing at all to do with the project or are otherwise entirely outside of its scope/sphere of influence. [Committers](#join-the-project-team) may apply this label and close an issue or PR if they decide to pass on an otherwise relevant issue. | The issue or PR should be closed as soon as the label is applied, and a clear explanation provided of why the label was used. Contributors are free to contest the labeling, but the decision ultimately falls on committers as to whether to accept something or not.

## Clean Up Issues and PRs

[Needs Collaborator](#join-the-project-team): Issue Tracker

Issues and PRs can go stale after a while. Maybe they're abandoned. Maybe the team will just plain not have time to address them any time soon.

In these cases, they should be closed until they're brought up again or the interaction starts over.

To clean up issues and PRs:

* Search the issue tracker for issues or PRs, and add the term `updated:<=YYYY-MM-DD`, where the date is 30 days before today.
* Go through each issue *from oldest to newest*, and close them if **all of the following are true**:
  * not opened by a maintainer
  * not marked as `critical`
  * not marked as `starter` or `help wanted` (these might stick around for a while, in general, as they're intended to be available)
  * no explicit messages in the comments asking for it to be left open
  * does not belong to a milestone
* Leave a message when closing saying "Cleaning up stale issue. Please reopen or ping us if and when you're ready to resume this. See https://github.com/wealljs/weallcontribute/blob/latest/CONTRIBUTING.md#clean-up-issues-and-prs for more details."

## Review Pull Requests

[Needs Collaborator](#join-the-project-team): Issue Tracker

While anyone can comment on a PR, add feedback, etc, PRs are only *approved* by team members with Issue Tracker or higher permissions.

PR reviews use [GitHub's own review feature](https://help.github.com/articles/about-pull-request-reviews/), which manages comments, approval, and review iteration.

Some notes:

* You may ask for minor changes ("nitpicks"), but consider whether they are really blockers to merging: try to err on the side of "approve, with comments".
* *ALL PULL REQUESTS* should be covered by a test: either by a previously-failing test, an existing test that covers the entire functionality of the submitted code, or new tests to verify any new/changed behavior. All tests must also pass and follow established conventions. Test coverage should not drop, unless the specific case is considered reasonable by maintainers.
* Please make sure you're familiar with the code or documentation being updated, unless it's a minor change (spellchecking, minor formatting, etc). You may @mention another project member who you think is better suited for the review, but still provide a non-approving review of your own.
* Be extra kind: people who submit code/doc contributions are putting themselves in a pretty vulnerable position, and have put time and care into what they've done (even if that's not obvious to you!) -- always respond with respect, be understanding, but don't feel like you need to sacrifice your standards for their sake, either. Just don't be a jerk about it?

## Merge Pull Requests

[Needs Collaborator](#join-the-project-team): Committer

TBD - need to hash out a bit more of this process.

## Tag A Release

[Needs Collaborator](#join-the-project-team): Committer

TBD - need to hash out a bit more of this process. The most important bit here is probably that all tests must pass, and tags must use [semver](https://semver.org).

## Join the Project Team

### Ways to Join

There are many ways to contribute! Most of them don't require any official status unless otherwise noted. That said, there's a couple of positions that grant special repository abilities, and this section describes how they're granted and what they do.

All of the below positions are granted based on the project team's needs, as well as their consensus opinion about whether they would like to work with the person and think that they would fit well into that position. The process is relatively informal, and it's likely that people who express interest in participating can just be granted the permissions they'd like.

You can spot a collaborator on the repo by looking for the `[Collaborator]` or `[Owner]` tags next to their names.

Permission | Description
--- | ---
Issue Tracker | Granted to contributors who express a strong interest in spending time on the project's issue tracker. These tasks are mainly [labeling issues](#label-issues), [cleaning up old ones](#clean-up-issues-and-prs), and [reviewing pull requests](#review-pull-requests), as well as all the usual things non-team-member contributors can do. Issue handlers should not merge pull requests, tag releases, or directly commit code themselves: that should still be done through the usual pull request process. Becoming an Issue Handler means the project team trusts you to understand enough of the team's process and context to implement it on the issue tracker.
Committer | Granted to contributors who want to handle the actual pull request merges, tagging new versions, etc. Committers should have a good level of familiarity with the codebase, and enough context to understand the implications of various changes, as well as a good sense of the will and expectations of the project team.
Admin/Owner | Granted to people ultimately responsible for the project, its community, etc.

## Attribution

This guide was generated using the WeAllJS `CONTRIBUTING.md` generator. [Make your own](https://npm.im/weallcontribute)!
{% elif contributing == 'contrib-flow' %}
# Contributing
We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github
We use github to host code, to track issues and feature requests, as well as accept pull requests.

## We Use [Github Flow](https://guides.github.com/introduction/flow/index.html), So All Code Changes Happen Through Pull Requests
Pull requests are the best way to propose changes to the codebase (we use [Github Flow](https://guides.github.com/introduction/flow/index.html)). We actively welcome your pull requests:

1. Fork the repo and create your branch from `master`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Any contributions you make will be under the MIT Software License
In short, when you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using Github's [issues](https://github.com/briandk/transcriptase-atom/issues)
We use GitHub issues to track public bugs. Report a bug by [opening a new issue](); it's that easy!

## Write bug reports with detail, background, and sample code
[This is an example](http://stackoverflow.com/q/12488905/180626) of a bug report I wrote, and I think it's not a bad model. Here's [another example from Craig Hockenberry](http://www.openradar.me/11905408), an app developer whom I greatly respect.

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can. [My stackoverflow question](http://stackoverflow.com/q/12488905/180626) includes sample code that *anyone* with a base R setup can run to reproduce what I was seeing
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

People *love* thorough bug reports. I'm not even kidding.

## Use a Consistent Coding Style
I'm again borrowing these from [Facebook's Guidelines](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)

* 2 spaces for indentation rather than tabs
* You can try running `npm run lint` for style unification

## License
By contributing, you agree that your contributions will be licensed under its MIT License.

## References
This document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)
{% else %}
# Contributing to the {{project}} project

We love pull requests from everyone. By participating in this project, you
agree to abide by the {{organization}} [code of conduct].

[code of conduct]: {{conduct_link}}

Fork, then clone the repo:

    git clone {{clone_link}}

Set up your machine.
Make sure the tests pass.
Make your change. Add tests for your change. Make the tests pass.

Push to your fork and [submit a pull request][pr].

[pr]: {{pull_link}}
At this point you're waiting on us.
    {% if False %}
We like to at least comment on pull requests
within three business days (and, typically, one business day). We may suggest
some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

* Write tests.
* Follow our [style guide][style].
* Write a [good commit message][commit].
    {% endif %}
{% endif %}
{% include 'do-not-edit.md' %}
