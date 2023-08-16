# R SLF Development SOP

## Background

This SOP (Standard Operating Procedure) aims to provide background to and a framework for contributing to the SLF (Source Linkage Files) R project. It aims to be the first port of call for new contributors / team members, as well as a reference for existing team members.

Please feel free to edit this document with any additions or clarifications, either by committing directly or by opening a Pull Request (PR) and asking for input on your changes from others.

### Acronyms reference

 - SOP - Standard Operating Procedure
 - SLF - Source Linkage Files
 - GH - GitHub
 - PR - Pull Request

## Issues

Any piece of work required should be logged as [an issue on GitHub](https://github.com/Public-Health-Scotland/source-linkage-files/issues). This allows each piece of work to be assigned to an individual to work on. It provides a well-organised workflow for the team to work collaboratively. It's good practice to add issues you come up with ideas for changes or find bugs that need fixing, if nothing comes of it you can delete the issue later.

You should regularly check the issues page for any work that needs to be picked up, you should assign the issue to yourself so other people know that you are working on it. You can also create a branch for the issue from GitHub, this will be helpful later as GitHub will automatically link the issue when you open a PR.

### Labels, milestones and projects

It is useful to apply labels to your newly created issue, this categorises it and will allow easy searching later. Particularly useful is to apply a 'priority label'. When you or others are looking for an issue to work on, it is sensible to work on the highest priority issues first. 

It can also be useful to create a label for a given project or deadline e.g. a quarterly update. A label is the simplest way to manage this but milestones and projects can also be used for this purpose.

## Branching

Generally speaking, we use the [GitHub Flow model](https://docs.github.com/en/get-started/quickstart/github-flow) for R development, with the [master branch](https://github.com/Public-Health-Scotland/source-linkage-files/tree/master) being the base branch. 

<img width="600" alt="image" src="https://wac-cdn.atlassian.com/dam/jcr:8f00f1a4-ef2d-498a-a2c6-8020bb97902f/03%20Release%20branches.svg">

The `master` branch is kept as the 'production' version of the code which is the code used to run the last quarterly update.

Any new changes should be first merged into the `development` branch, this way all changes made are kept separate until they have been properly tested in a full run of the files. 

In the lead-up to an update, it may be useful to create an 'update' specific branch. This should be branched from `development` to include all the changes made between updates. The point of this update branch is to distinguish between changes that are important for the update, whilst allowing development to continue that will be included in a future update. The update branch name should include the word `update` so that [branch protections](https://github.com/Public-Health-Scotland/source-linkage-files/settings/branches) will be automatically applied. A recommended naming convention is: `update/MONTH-YEAR` e.g. `update/dec-2023`.

### Create a new branch

To work on a new issue, you will need to create a new branch. This is best done for even small changes such as renaming scripts/functions. To do this, make sure your `development` is the most up-to-date version. 

### From an issue
A nice way to create a new branch is to use GitHub to create one from the issue page.

<img width="259" alt="image" src="https://github.com/Public-Health-Scotland/source-linkage-files/assets/5982260/d05f27fa-ec0c-4136-aab2-2779f5189415">

Click 'create a branch' - by default, the 'branch source' will be `master`, so you will usually want to click 'change branch source' and select `development` (or otherwise).

<img width="367" alt="image" src="https://github.com/Public-Health-Scotland/source-linkage-files/assets/5982260/e519f326-cddd-4720-9469-3569bd6617ed">

Clicking 'Create branch' will create it and then in RStudio we will need to do a pull `git pull` (`git fetch` will also be enough) to make our local repository aware of it, we can then switch to it using the buttons or `git checkout <branch name>`.

### In RStudio

We can use the terminal, or just use the buttons.

- switch branches to `development` (or the quarterly update branch) - `git checkout`
- pull to ensure you have the latest version - `git pull` or `git pull --rebase`
- click the new branch button to the left of the current branch name to create your new branch,
- create a new branch, this should have a meaningful name, a useful convention is to use `type/thing` e.g. `bug/<issue_number>-fixing-bug-with-x` or `documentation/update-documentation-y`
  - `git checkout -b <branch name>` or `git branch <branch name>` + `git checkout <branch name>`
  - Note that RStudio automatically links the new branch to the remote (GitHub) for us, if using the terminal we need to do this step ourselves - `git push -u origin <new_branch_name>`

### Using a branch

You can now start to use your new branch by making changes to the code and [committing them](#committing).

Your branch is a safe place to make (and commit) changes. If you make a mistake, you can revert your changes, push additional changes to fix the mistake or reset completely to an older version. Your changes will not end up on any other branch until you merge your branch.

If something goes completely wrong, don't be afraid to just start again with a new branch. First, copy any files you have changed (that you want to keep), follow the steps above to properly create a new branch then paste and re-commit the changes.

Merges into `development` or `master` etc. need to be done through a PR (and GitHub will stop you if you try to do otherwise!) In the usual case, there should be one person in charge/making changes in each branch.


## Commits

Commits contain the changes you have carried out in your script. You can do this as little or often as you want. Ideally, each commit should contain an isolated, complete change. This makes it easy to revert your changes if needed. Good practice would be to make a commit after every 'block' of code is changed. More is generally better than fewer.

### Staging

Staging in Git is a process of collecting your changes before committing them to the repository. This allows you to review your changes and make sure you want to commit them all at once. It also allows you to group together related changes and commit them as a single unit, which can help to keep your commit history clean and organised.

You can stage individual 'chunks' for commit with the buttons, or use `Ctrl` and/or `Shift` to select individual lines to stage, this way you can break up changes into bite-sized commits easily. The equivalent for this in the terminal is to use `git add --patch` this will split your changes into 'chunks' and then give you menu options to skip that chunk (for now), commit it, or split it into smaller chunks.

### Committing

To commit your changes, use the commit button in the Git pane in RStudio, give each commit a descriptive message to help you and future contributors understand what changes the commit contains.

To commit using the terminal use `git add` to stage and `git commit` to commit. You can add all with the `-a` flag, and add a message with the `-m` flag e.g. `git commit -a -m "<Commit message>"` if you don't add a message in this way, git will open the default text editor (unless you change it, this will be [Vim](https://devhints.io/vim)).

#### The commit message

The 'title' of the commit should be imperitive e.g. 'Fix the bug with x' or 'Update documentation' i.e. what will the commit do to the codebase? The 'title' should be kept short (there is a limit of 72 characters before it 'overflows' into the description. You can add further details by leaving a new line and then writing some long-form comments. This is the place to provide context for what you've done (and why). 

GitHub will parse the commit message (title and description) for [markdown](https://www.markdownguide.org/cheat-sheet/), this means you can easily include links, bullet-point lists, syntax-highlighted code etc. in your commit message.
See [writing meaningful commit messages](https://reflectoring.io/meaningful-commit-messages/) for some in-depth advice. 

### Pushing commits back to GitHub

Before each commit, but absolutely before you push, you should make sure your code is documented, tested, checked and styled.

- **Document**: `Ctrl + Shift + D`, the 'Document' button under 'More' in the build pane, or running `devtools::document` will invoke [`{roxygen2}`](https://roxygen2.r-lib.org/articles/roxygen2.html) to build the documentation for your functions. Note that we have a GitHub action set-up which should automatically perform this step if it's missed.
- **Test**: `Ctrl + Alt + F7`, the 'Test Package' button under 'More' in the build pane, or running `devtools::test` will invoke [`{testthat}`](https://testthat.r-lib.org/) to run any new or existing tests which have been written. Writing tests and then checking that they are still working ensures that our functions do what they are supposed to, and will highlight when any changes we make inadvertently break existing behaviour.
- **Check**: `Ctrl + Shift + E`, the 'Check' button in the build pane, or running `devtools::check`. This can take a couple of minutes as it performs lots of checks, including the above steps of *document* and *test*. For some information on the steps performed see the [Automated checking](https://r-pkgs.org/r-cmd-check.html) chapter in the R for Packages book.
- **Style**: Use the [`{styler}`](https://styler.r-lib.org/) to style any files you've created or modified, this ensures that the code base has a consistent style. Note that we have a GitHub action set-up which should automatically perform this step if it's missed.

Once you are happy with your committed changes, push them to the remote version of your branch (on GitHub) using the push button or `git push` in the terminal.

### Changing history with `--amend` and `rebase`

***You should only change or rewrite the history when you haven't pushed the changes to GitHub, or at the very least before you have opened a PR. The risk here is that if someone else has checked out your branch then you re-write the history it will create a lot of confusing conflicts!***

Keeping the above warning in mind, re-writing the history can be really useful and allows you to keep your history clean and linear, which then makes it easier to review and see what you've done.

Use the 'Amend previous commit' tick box in RStudio or `git commit --amend` to change the previous commit. You might do this to fix a typo or add something to the commit message, or maybe you missed a very minor thing from the previous commit, so need to add an extra line or file.

You would use `git rebase` to re-order, combine or edit previous commits in the terminal do `git rebase -i HEAD~x` where `x` is the number of commits to rebase. You will then be given a text editor with a file to edit and some instructions. I find it easier to open that file in RStudio by navigating to `<location_of_repo>/source-linkage-files/.git/rebase-merge` and opening the file `git-rebase-todo` as RStudio is much nicer for editing text files than the terminal editor.

In this file, there are instructions which are quite easy to follow. When you save it (and close one open in the terminal) git will apply the changes you have requested in order, thus re-writing the history.

Another scenario where we might use `rebase` is when our local branch has diverged from the remote branch. This is / will be covered in a dedicated guide, but simply you would run.

```
git checkout <branch>
git fetch
git rebase origin/<branch>
```

This will start with the 'tip' of the remote branch then add your local commits to that, meaning that the commit history will stay nice and linear! Sometimes this may cause [merge conflicts](#merge-conflicts) which will need resolving.

## Pull Requests

A pull request is GitHub's method for allowing checks and reviews before one branch is merged into another. This will usually be your feature branch being merged into `main-R`.

You create a pull request in GitHub under the [Pull Request section](https://github.com/Public-Health-Scotland/source-linkage-files/pulls). On this tab, click 'new pull request', or if you've recently pushed changes GitHub will offer a pop-up to fast-track this process. You will then need to enter the base branch to merge to (usually `main-R`) and the branch to merge from (your feature branch). **Note** `master` will be the default base branch so this will always need changing. 

Give the pull request a meaningful title and description including any information that may help your team understand the changes you've made. This should include a summary of what you've done/changed as well as some background as to why the change is needed. Include any link to the issue the pull request is closing by entering `Closes #<issuenumber>`. 

More in-depth information on pull requests can be found [in the GitHub docs](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).

You should tag your PR with labels to help others quickly asses it. Particularly note the high and low priority labels, use `high-priority` when it's a serious bug or another PR is dependent on this change.

Finally, pick a reviewer(s), the simplest way is to select the source-linkage-files team, this will then randomly select a member of the team who has the fewest assigned reviews. You can also manually @mention or request a review from specific people if required for double-checking or assistance.


## Review Process

The reviewer(s) should leave questions, comments, and suggestions. They can comment on the whole pull request or add comments to specific lines. This includes suggesting edits to the code. 

Once the review has been completed, you can look at the comments and suggestions left. Your pull request will not be able to be merged until all there is an approved review and all conversations have been resolved.

If there are suggestions to the code these can be committed in GitHub by selecting 'commit suggestion', make sure to pull the updated branch in `R` and test that the suggestions do not break any code.

You can continue to commit and push changes in response to the review and your pull request will update automatically.

When you need a reviewer to take a second look, click the refresh button to send them a notification to re-review.


### Reviewing

Reviewing another branch is conducted in GitHub. You will be notified if you have been asked to review. 

To carry out a review:

- First update the branch to ensure you are seeing the changes as they will be once they're merged.
- Visually check the code using the 'files changed' tab. Check for any obvious issues, including broken code or style / good practice changes. Make comments and suggestions to fix these.
- If there were no (or very few suggestions): If the PR is very simple you could approve at this point, or if it's more complicated move to checking it in `R`.
- In RStudio, switch to the PR branch and do a pull to ensure you are looking at the latest version.
- First, do an `R CMD CHK` with `Ctrl + Shift + E`, the 'Check' button in the build pane, or run `devtools::check`. This will highlight any issues immediately and automatically.
- Make sure to install the package as it is on the current branch with `Ctrl + Shift + B` or the 'Install and Restart' option in the build pane.
- Check and run the code in any scripts which have had changes made, it should all run and produce output as expected.
- It might be useful to call the person who made the changes on Teams and run through the code together.
- If you needed to do checks which could be written as {testthat} tests then comment and ask for them to be added.
- Back on GitHub go to the 'files changed' tab which outlines changes made in this branch. This tab then allows you to add comments/suggestions through `+` by clicking on specific lines of code,  this can be dragged to include a large chunk of code. If you are just leaving a comment this can be entered in the box that pops up after the `+` is clicked. To make a suggestion on the code, click on the `±` 'add a suggestion' button, which allows you to write code to be used instead.

<img width="740" alt="image" src="https://github.com/Public-Health-Scotland/source-linkage-files/assets/5982260/9df46506-3c1c-47fe-9bf5-f6ee9d9408d7">

<details>
  <summary>R code to produce the flow diagram</summary>
```R
DiagrammeR::grViz("digraph {
# Graph options
graph[layout = dot, rankdir = LR]

# Nodes
start [label = 'PR review requested', shape = square]
gh_check [label = 'Check and review on GitHub']
any_changes_1 [label = 'Are changes required?']
any_changes_2 [label = 'Are changes required?']
pr_owner_makes_changes [label = 'PR owner makes changes', shape = square]
rstudio_check [label = 'Check in RStudio']
approval [label = 'PR approved and merged']

# Edges
start -> gh_check
gh_check -> any_changes_1
any_changes_1 -> pr_owner_makes_changes [label = 'yes']
pr_owner_makes_changes -> start [lable = 're-request a review']
any_changes_1 -> rstudio_check [label = 'no']
rstudio_check -> any_changes_2 
any_changes_2 -> pr_owner_makes_changes [label = 'yes']
any_changes_2 -> approval [label = 'no']
}") |>
  htmlwidgets::saveWidget("pr_flow.html")
```
</details>

### Merging

Once your pull request is approved, with no outstanding comments/suggestions, GitHub will allow you to merge your pull request. We recommend doing a 'squash and merge' in most cases, this will combine all of the commits into a single commit, with the PR title as the commit title and all the individual commit messages as the squashed commit's message.

After your PR has been approved and merged, your branch will be deleted automatically. This indicates that the work on the branch is complete and prevents you or others from accidentally using old branches. 

### Git

Most of the work carried out can be done using the RStudio GUI and GitHub but underlying all this is Git. Git commands can be used in the Terminal or using the buttons to push and pull to your branch. 

A cheat sheet can be found [here](https://training.github.com/downloads/github-git-cheat-sheet.pdf) which can help you if you need to use any of these.
