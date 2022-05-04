# R SLF Development SOP

## Background

This SOP aims to provide background to and a framework for contributing to the SLF (Source Linkage Files) R project.

## Issues

Any piece of work required will be logged as [an issue on GitHub](https://github.com/Public-Health-Scotland/source-linkage-files/issues). This allows each piece of work to be assigned to an individual to work on. It provides a well-organised workflow for the team to work collaboratively.

## Branching

Generally speaking, we use the [GitHub Flow model](https://docs.github.com/en/get-started/quickstart/github-flow) for R development, with the [main-R branch](https://github.com/Public-Health-Scotland/source-linkage-files/tree/main-R) being the base branch. The `master` branch is left untouched with changes merged onto the `main-R` branch. 

### Create a new branch

To work on a new issue, you will need to create a new branch. This is best done for even small changes such as renaming scripts/functions. To do this, make sure your `main-R` is the most up-to-date version. This can be done in `R`.

Firstly, 

- switch branch (checkout) `main-R` and pull,

- click the new branch button to the left of the current branch name to create your new branch,

- name your new branch something meaningful and descriptive.

Once you have completed this, you can start to use your new branch.


Your branch is a safe place to make changes. If you make a mistake, you can revert your changes or push additional changes to fix the mistake. Your changes will not end up on the default branch until you merge your branch. There should be one person in charge/making changes in each branch.


## Commits

Commits contain the changes you have carried out in your script. You can do this as little or often as you want. Ideally, each commit should contain an isolated, complete change. This makes it easy to revert your changes if needed. A good working practice can be committing after completion of your script, or at end of the day working, then after any requested changes to your script.

To commit your changes, use the commit button in the Git pane in RStudio, give each commit a descriptive message to help you and future contributors understand what changes the commit contains. See [writing meaningfull commit messages](https://reflectoring.io/meaningful-commit-messages/) for some in-depth advice.

Once you have committed your changes, push this to your branch using the push button or `git push` in the terminal.

If you have created a new function which requires documentation, make sure to run `devtools::documentation`.

Another good practice is to run a `check` on the script in the `build` tab. 


## Pull Requests

A pull request is how your branch is merged onto `main-R` but not before thorough checks and feedback. 

To create a pull request this is done in GitHub under the Pull Request section of your team's repository. On this tab, click 'new pull request'. You will then need to enter which branch is being merged into which. Make sure to change the `base` to `main-R` not `master`. Then under `compare` select your current branch. Then give the pull request a meaningful name and description including any information that may help your team understand/work the script. Include any link to the issue the pull request is closing by entering `Closes #<issuenumber>`. 

More in-depth information on pull requests can be found [here](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).

Other options can be entered to help categorise the pull request, such as labels and projects. Please enter these to keep the repo in good working order. Also, you will need to select who the reviewer/s may be. The best way is to select your team name under 'Reviewers', this will then randomly select members of your team who have fewer requests to review. You can also manually @mention or request a review from specific people if required for double-checking or assistance.


## Review Process

The reviewer/s should leave questions, comments, and suggestions. They can comment on the whole pull request or add comments to specific lines. This includes suggesting edits to the code. 

Once the review has been completed, you can go look at the comments and suggestions left. Your pull request will not be able to be merged until all changes are complete. If there are suggestions to the code left these can be committed in GitHub by selecting 'commit suggestion', make sure to pull the updated branch in `R` and test that the suggestions do not break any code.

You can continue to commit and push changes in response to the review and your pull request will update automatically.


### Reviewing

Reviewing another branch is conducted in GitHub. You will be notified if you have been asked to review. 

To review:

- on `R`, switch to review branch,

- run the code contained on the scripts, make sure to check all scripts on the branch as some may require new functions to be run for the code to work, this should be outlined in the description of the pull request,

- check everything is working as expected,

- head back to GitHub on the pull request, there is the 'files changed' tab which outlines the scripts included in the branch. This tab then allows you to add comments/suggestions through `+` by clicking on specific lines of code,  this can be dragged to include a large chunk of code. If you are just leaving a comment this can be entered in the box that pops up after the `+` is clicked. To make a suggestion on the code, click on the `±` 'add a suggestion' button, which allows you to write code to be used instead.


### Merging

Once your pull request is approved, with no outstanding comments/suggestions, GitHub will allow you to merge your pull request. This will automatically merge your branch so that your changes will now appear in `main-R`.

This may result in some merge conflicts which will need to be resolved before merging. The best practice for this is to keep your branch up-to-date with `main-R` throughout your editing process. This can be done by using `git rebase`. 


After your pull request has been approved, delete your branch. This indicates that the work on the branch is complete and prevents you or others from accidentally using old branches. This may be done automatically by GitHub. 


### Git

Most of the work carried out can be done solely on `R` and GitHub but underlying all this is Git. Git commands can be used in the Terminal or using the buttons to push and pull to your branch. 

A cheat sheet can be found [here](https://training.github.com/downloads/github-git-cheat-sheet.pdf) which can help you if you need to use any of these.
