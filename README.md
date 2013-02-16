# JIRA Enhancements #

## Overview ##

This is a [GreaseMonkey][greasemonkey] userscript designed for Atlassian 
[JIRA][jira] OnDemand instances to make things more suitable for my workflow.

It is also fully compatible with Google Chrome's 
[user script engine][chrome-user-scripts] and was written with Chrome in mind. This
required some pretty ugly hacks to bypass Google Chrome's extremely restrictive
sandboxing.

Also note that this makes *a lot* of AJAX calls to get additional data from
the API.

## Installation ##

To get the extension from BitBucket, click the [source][bitbucket-source] tab and
select the `jira-enhancements.user.js` file from the list. Make sure you don't
choose the `.coffee` file by mistake!

Depending on which browser you are using, you will then need to take the respective
following steps.

### Firefox ###

Using this extension on Firefox requires the [GreaseMonkey][greasemonkey] extension.
Once you have that installed, the fastest way to install is to simply click the
"Raw" button to the top right of the source.

This should bring up the GreaseMonkey install dialogue box. After installing, the
extension should work by opening/refreshing your JIRA page.

### Google Chrome ###

Due to Chrome's recent clamping down on userscript extensions, installation on
Chrome is slightly more involved.

On the source page, click the "Raw" button. This should automatically download the
extension to your hard disk (possibly dpeending on settings). On the download
toolbar at the bottom of your browser, you can then click the downward-facing arrow
next to the filename to bring up a context menu. From this menu, choose
"Show in Folder" and leave this window open.

Next, you must open the extensions list in Chrome. You may do this by clicking the
menu button (≡) and choosing Settings. From this page you can then choose
"Extensions" from the left-hand menu.

Alternatively, you can paste the URL `chrome://extensions/` into a new tab.

You must now drag and drop the file from the folder window you opened earlier into
Chrome's extensions window. This should open the extension install dialogue. Once
the extension has been successfully installed, it should work by opening/refreshing
your JIRA page.

## Features ##

+ Work view
    + Context menu for issues
    + At-a-glance icons for issues with comments and/or attachments
    + Full list of labels directly on the issue card
    + Show blocked icon for issues with an unfinished blocker issue link or issues
      with a "blocked" label
    + Double click attachment images in their lightbox to open in a new tab (for
      zooming, etc.)
    + Double click anywhere on an issue card to open the details pane
    + Make all external links open in a new tab
+ Plan View
    + Context menu for issue listings

## Upcoming Features ##

+ General
    + Short-term caching of data to reduce AJAX calls
+ Work View
    + Keyboard navigation for issue cards
+ Plan View
    + More context menu options
    + Expandable issue listings with more information, e.g. labels

## Removed Features ##

Mostly in order to save space, I have removed some features that are of no
use to myself. Namely:

+ Issue type icons on user stories in work view are gone

## Libraries ##

This userscript uses the following libraries:

+  [jQuery Context Menu][jquery-context-menu]
   by Chris Domigan


## Warranty ##

**There is no warranty.** I take no responsibility for anything negative this
software does to you, your family, your computer or anything else. If it
breaks, I may be able to help, but I am under no obligation to do so.

[chrome-user-scripts]: http://www.chrome.org/developers/design-documents/user-scripts
[greasemonkey]: https://addons.mozilla.org/en-US/firefox/addon/greasemonkey/
[jira]: http://www.atlassian.com/software/jira/
[jquery-context-menu]: http://www.trendskitchens.co.nz/jquery/contextmenu/
[bitbucket-source]: https://bitbucket.org/jongoodger/jira-enhancements/src