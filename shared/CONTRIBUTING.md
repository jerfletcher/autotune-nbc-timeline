# Making changes to shared

The middleman rig, whether for graphics, editorial apps or autotune blueprints, is built for you, the developer, to make your life better. You should feel ownership over this stuff, and when it breaks or doesn't help you, feel free to make it better. This rig is by and for all who use it.

That said, shared spaces cannot be productive without shared norms, so here we go...

## Basics

Before making changes, remember you can override the templates, css, javascripts, etc. by copying files from `shared/source` to `source`. You should only make changes to shared if you are fixing a bug in a shared file, or if you are adding a feature that you plan to use in another project. If you are unsure if you might reuse something, do not add it to shared. Add the feature to shared the first time you _reuse_ it.

## Changes to master

If you are confident that changes you would like to make to shared will not change the behavior of existing features, you should commit and push to master.

If you are uncertain if your changes would impact others, you have two options:
- Create a branch, commit your changes and open a pull request (details below).
- Make your changes to master, but do not push. Schedule a 1-on-1 code review to discuss the changes before committing and pushing.

## Branches

All branches point to master. All changes to shared should ultimately end up on the master branch.

Branches should be created and named for specific feature additions or bugfixes. For example: `ryans-stuff` is bad, `share-button-fixes` is good; `vox` is bad; `vox-meta-tags` is good. By boxing in what a branch was created for, we're encouraging ourselves to merge it into master. Creating a branch with an open-ended name makes it unclear to others why the branch exists, and encourages that branch to continue to diverge from master.

The branch name...
- should hint at what it contains
- should contain the name of the vertical if the changes affect _only_ that vertical
- should not contain the name of your app or graphic
- should not contain your name or initials (your name is already all over it)

When you're satisfied with the changes in your branch, create a pull request. There is a template for the message in order to make this step super simple.

Once created, a core tools team engineer will review and merge the PR into master. The branch should be deleted after merge. Deleting the branch will not break your project, but it may mess up your local git repo. You can fix it with a `git submodule update`.

## Adding 3rd party scripts and css

If there is css or scripts you plan on using frequently, there is a place in shared for it.

```
shared/source/javascripts/_vendor_extra
shared/source/stylesheets/_vendor_extra
```

You should then load your script by including it at the top of your `app.js`:

```javascript
//= require '_vendor_extra/somescript'
```

For CSS, you should rename the file to have a `scss` extension when copying it to the vendor extra folder. You can then import that file in your `custom.scss` file:

```scss
@import '_vendor_extra/somecss';
```

When adding a script or css file to shared, make sure there is a comment at the top of the file which contains a link to the source and the version number, if available.

## CSS Framework

We're using Zurb Foundation 5 for everything.

This means that we should expect that all modules documented in the official documentation is available for you to use in your project. Those modules will look good and fit in with the visual design of your site.

The best way to make use of a framework is to build your entire project without writing any css. Only when you've done an initial pass writing only HTML, should you go back and tweak your layout with CSS.

By prohibiting yourself from writing CSS on a first pass, you force yourself to make full use of the CSS that has already been written.

If you cannot find a module in foundation to do what you need on your first pass, use a module that gets you the closest.

When you eventually get to writing CSS, make a point to not create new SCSS variables. Instead, refer to the file `shared/source/stylesheets/_settings.scss`. All variables in this file (even the commented ones) are available to you once the framework is imported. It's likely there is a foundation variable that is already set to what you need.

If you find a foundation variable that should provide what you need, but doesn't seem to be set to the value you need, you can and should add that variable with the appropriate value in your shared vertical SCSS settings file `shared/source/stylesheets/vertical/_settings.scss`. This way you can help make the built-in Foundation modules better.

Every vertical has three shared stylesheets. Each stylesheet is loaded at a different point in the process and will have different effects.

SCSS file order:
# `_framework.scss.erb` controls the loading of everything. `@import 'framework'` loads everything in your `custom.scss` file
# `_fonts.scss` loads fonts used in every vertical (icon font).
# `_settings.scss` includes a reference of every foundation variable and changes some foundation defaults for every vertical.
# `VERTICAL/_fonts.scss` should import and define web fonts and any shorthand SCSS variables, classes or mixins related to those webfonts. It should not contain any rules or variables that effect modules or page layout.
# `VERTICAL/_settings.scss` adjusts foundation variables for your vertical. Do not add new variable names unless there is no foundation equivalent to use. Good example of extra variables is Vox's extended color palette.
# `foundation` Loads all of foundation, makes sure all foundation variables and mixins are defined
# `_overrides.scss` specific css rules to override foundation behavior for all verticals
# `VERTICAL/_overrides.scss` specific css rules to override foundation behavior for your vertical

Before adding anything to an overrides file, make sure to check if there is a scss variable that can be changed to get the same result.

## Images

Images in this setup are really tricky. Every image we add to shared is automatically added to every project. This results in lots and lots of copies of images. So it's best to not add stuff in there.

## Javascript

The scripts `bottom.js` and `top.js.erb` load the contents of the `_bottom` and `_top` folders and initialize those scripts. This javascript is included everywhere, always. Any changes to those folders affect all projects.

Scripts in `_vendor` are loaded on every page.

There is no affordance for adding vertical-specific javascript. We can change that if necessary.
