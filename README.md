JIRA Enhancements
=================

This is a [GreaseMonkey][gm] userscript designed for [JIRA][jira] OnDemand
instances to make things more suitable for my workflow.

It is also fully compatible with [Chrom[e|ium]'s user script engine][cus] and was
written with Chrome in mind. This required some pretty ugly hacks to bypass
Chrome's extremely restrictive sandboxing.

Also note that this makes **a lot** of AJAX calls to get additional data from
the API.

[gm]: https://addons.mozilla.org/en-US/firefox/addon/greasemonkey/
[jira]: http://www.atlassian.com/software/jira/
[cus]: http://www.chromium.org/developers/design-documents/user-scripts

Features
--------

+ Work view
    + Context menu for issues
    + At-a-glance icons for issues with comments and/or attachments
    + Full list of labels directly on the issue card
    + Icon for issues with a "blocked" label
    + Double click attachment images in their lightbox to open in a new tab (for zooming, etc.)
    + Double click anywhere on an issue card to open the details pane


Upcoming Features
-----------------

+ General
    + Short-term caching of data to reduce AJAX calls
+ Work View
    + Show blocked icon for issues with an unfinished blocker issue link
    + Make all external links open in a new tab
    + Keyboard navigation for issue cards
+ Plan View
    + Context menu for issue listings
    + Expandable issue listings with more information, e.g. labels

Anti-features
-------------

Mostly in order to save space, I have removed some features that are of no
use to myself. Namely:

+ Issue type icons on user stories in work view are gone

Libraries
---------

This userscript uses the following libraries:

+  [jQuery Context Menu][http://www.trendskitchens.co.nz/jquery/contextmenu/]
   by Chris Domigan

Warranty
--------

**There is no warranty.** I take no responsibility for anything negative this
software does to you, your family, your computer or anything else. If it
breaks, I may be able to help, but I am under no obligation to do so.