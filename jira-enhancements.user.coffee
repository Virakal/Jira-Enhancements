`// ==UserScript==
// @name        Jon's Incredible JIRA Sprint Board Minor Improvements
// @namespace   http://gm.delphae.net/
// @description Add a few improvements to the JIRA sprint board, such as adding a context menu to issues.
// @include     *.atlassian.net/secure/RapidBoard.jspa*
// @grant       GM_addStyle
// @version     4.1
// ==/UserScript==
`
main = ($) ->
    API_URL = '/rest/api/2/'

    bindings = {}

    setImmediate = window.setImmediate ? (func, args) ->
       return window.setTimeout func, 0, args

    clearImmediate = window.clearTimeout

    isBlocked = (link) ->
        if link.type.inward is "is blocked by"
            return (!link.outwardIssue?) and link.inwardIssue?.fields.status.name isnt "Done"

    setBlocked = (card, value = true) ->
        flag = $(card).find '.blocked-flag'

        if value then flag.css('display', 'inline-block') else flag.hide()


    buildMenu = (id, items) ->
        bindings[id] ?= {}

        elem = $('<div>').attr
            'class': 'contextMenu'
            'id': id

        elem.hide()

        ul = $ '<ul>'

        for bindingId, config of items
            ul.append $("<li id='#{bindingId}'>").text(config.name)

            bindings[id][bindingId] = config.callback

        elem.append ul

        $('body').append elem

    decorateCard = (card, data) ->
        blockedFlag = $ '<img>'

        blockedFlag.hide()

        blockedFlag.attr
            'src': '/images/icons/emoticons/error.gif'
            'alt': ' (Blocked)'
            'title': 'This story is blocked!'
            'class': 'blocked-flag'

        $(card).find('.js-detailview').after blockedFlag

        if data.fields?
            flags = $(card).find '.ghx-flags'

            if data.fields.labels?.length
                list = $('<div>').attr('class', 'label-list').hide()

                $(card).append list

                for label in data.fields.labels
                    span = $ '<span>'
                    span.text label

                    list.append span

                    setBlocked(card) if label.toLowerCase() is 'blocked' and data.fields.status?.name isnt 'Done'

                list.show()

            if data.fields.attachment?.length
                attachmentFlag = $ '<span>'
                attachmentFlag.addClass 'uses-sprite has-attachment'

                flags.append attachmentFlag

            if data.fields.comment.comments?.length
                commentFlag = $ '<span>'
                commentFlag.addClass 'uses-sprite has-comments'

                flags.append commentFlag

            if data.fields.issuelinks?.length
                for link in data.fields.issuelinks when isBlocked(link) and data.fields.status?.name isnt 'Done'
                    setBlocked(card)
                    break


    initIssueCards = ->
        FIELDS = [
            'attachment'
            'comment'
            'issuelinks'
            'labels'
            'status'
        ]

        cards = $ '#ghx-work .ghx-issue'

        for card in cards
            do (card) ->
                setImmediate ->
                    $.ajax "#{API_URL}issue/#{$(card).data('issueId')}?fields=#{FIELDS.join ','}",
                        dataType: 'json'
                        type: 'GET'

                        success: (data) ->
                            decorateCard card, data

                        error: (xhr, status, error) ->
                            console.debug "Error fetching data for issue #{$(card).data()}"


    initPlanView = ->
        # PASS

    initIssueCards()
    initPlanView()

    # TODO: Proper image zooming?
    $('#fancybox-outer').on 'dblclick', '#fancybox-img', (e) ->
        window.open $(this).attr 'src'

    $(document).bind "DOMNodeInserted", (e) ->
        # span#js-pool-end is added when 'work' is reloaded
        # div.ghx-foot is added when 'plan' is reloaded
        target = $ e.target
        initIssueCards() if target.attr('id') is 'js-pool-end'
        initPlanView() if target.hasClass('ghx-foot')

    # Ugly hack to ensure the handler gets set in Firefox
    setTimeout((-> $('#ghx-work').on 'dblclick', '.ghx-issue', (e) ->
        $(e.currentTarget).find('.js-detailview')[0].click()
    ), 100)

    $(document.body).on 'click', 'a.external-link', (e) ->
        $(e.target).attr 'target', '_blank'


# Inject the JS in as a script tag to gain access to jQuery from AJS
script = document.createElement 'script'
script.textContent = "(#{main.toString()})(window.AJS.$);"
document.body.appendChild script

GM_addStyle "
    #ghx-work .ghx-issue .label-list span {
        background: #b4c8d2;
        border: 1px solid #d9e7f3;
        border-radius: 0.4em;
        margin-right: 0.5em;
        padding: 0 0.2em;
        position: relative;
        top: -1.15em;
    }

    #ghx-work .ghx-issue .ghx-type {
        display: none;
    }

    #ghx-work .ghx-issue .ghx-flags {
        top: 6px;
    }

    #ghx-work .ghx-issue .ghx-flags span:nth-of-type(2) {
        margin-top: 4px;
    }

    #ghx-work .ghx-issue .ghx-flags span {
        display: block;
        height: 14px;
        margin-bottom: 2px;
        vertical-align: middle;
        width: 16px;
    }

    #ghx-work .ghx-issue .ghx-flags .uses-sprite {
        background-image: url('https://mobilefun.atlassian.net/s/en_US-seakxi-418945332/6007/29/6.1-rc1/_/download/resources/com.pyxis.greenhopper.jira:gh-rapid-common/images/rapid/ghx-icon-sprite.png');
        background-repeat: no-repeat;
    }

    #ghx-work .ghx-issue .ghx-flags .has-attachment {
        background-position: 0 -350px;
    }

    #ghx-work .ghx-issue .ghx-flags .has-comments {
        background-position: 0 -325px;
    }

    #ghx-work .ghx-issue .blocked-flag {
        height: 1em;
        left: 0.33em;
        position: relative;
        top: 0.17em;
        width: 1em;
    }

    #ghx-plan .ghx-issue-compact .ghx-type {
        display: none;
    }

    #ghx-plan .ghx-issue-compact .ghx-flags {
        display: none;
    }

    #ghx-plan .ghx-issue-compact .ghx-issue-fields {
        left: -40px;
        position: relative;
    }
"