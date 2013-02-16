`// ==UserScript==
// @name        Jon's Incredible JIRA Sprint Board Minor Improvements
// @namespace   http://gm.delphae.net/
// @description Add a few improvements to the JIRA sprint board, such as adding a context menu to issues.
// @include     *.atlassian.net/secure/RapidBoard.jspa*
// @grant       GM_addStyle
// @version     2
// ==/UserScript==
`

main = ($) ->
    API_URL = '/rest/api/2/'

    bindings = {}

    setImmediate = window.setImmediate ? (func, args) ->
       return window.setTimeout func, 0, args

    clearImmediate = window.clearTimeout

    insertDependencies = ->
        # http://www.trendskitchens.co.nz/jquery/contextmenu/
        `(function($){var menu,shadow,trigger,content,hash,currentTarget;var defaults={menuStyle:{listStyle:'none',padding:'1px',margin:'0px',backgroundColor:'#fff',border:'1px solid #999',width:'100px'},itemStyle:{margin:'0px',color:'#000',display:'block',cursor:'default',padding:'3px',border:'1px solid #fff',backgroundColor:'transparent'},itemHoverStyle:{border:'1px solid #0a246a',backgroundColor:'#b6bdd2'},eventPosX:'pageX',eventPosY:'pageY',shadow:true,onContextMenu:null,onShowMenu:null};$.fn.contextMenu=function(id,options){if(!menu){menu=$('<div id="jqContextMenu"></div>').hide().css({position:'absolute',zIndex:'500'}).appendTo('body').bind('click',function(e){e.stopPropagation()})}if(!shadow){shadow=$('<div></div>').css({backgroundColor:'#000',position:'absolute',opacity:0.2,zIndex:499}).appendTo('body').hide()}hash=hash||[];hash.push({id:id,menuStyle:$.extend({},defaults.menuStyle,options.menuStyle||{}),itemStyle:$.extend({},defaults.itemStyle,options.itemStyle||{}),itemHoverStyle:$.extend({},defaults.itemHoverStyle,options.itemHoverStyle||{}),bindings:options.bindings||{},shadow:options.shadow||options.shadow===false?options.shadow:defaults.shadow,onContextMenu:options.onContextMenu||defaults.onContextMenu,onShowMenu:options.onShowMenu||defaults.onShowMenu,eventPosX:options.eventPosX||defaults.eventPosX,eventPosY:options.eventPosY||defaults.eventPosY});var index=hash.length-1;$(this).bind('contextmenu',function(e){var bShowContext=(!!hash[index].onContextMenu)?hash[index].onContextMenu(e):true;if(bShowContext)display(index,this,e,options);return false});return this};function display(index,trigger,e,options){var cur=hash[index];content=$('#'+cur.id).find('ul:first').clone(true);content.css(cur.menuStyle).find('li').css(cur.itemStyle).hover(function(){$(this).css(cur.itemHoverStyle)},function(){$(this).css(cur.itemStyle)}).find('img').css({verticalAlign:'middle',paddingRight:'2px'});menu.html(content);if(!!cur.onShowMenu)menu=cur.onShowMenu(e,menu);$.each(cur.bindings,function(id,func){$('#'+id,menu).bind('click',function(e){hide();func(trigger,currentTarget)})});menu.css({'left':e[cur.eventPosX],'top':e[cur.eventPosY]}).show();if(cur.shadow)shadow.css({width:menu.width(),height:menu.height(),left:e.pageX+2,top:e.pageY+2}).show();$(document).one('click',hide)}function hide(){menu.hide();shadow.hide()}$.contextMenu={defaults:function(userDefaults){$.each(userDefaults,function(i,val){if(typeof val=='object'&&defaults[i]){$.extend(defaults[i],val)}else defaults[i]=val})}}})($)`
        

    isBlocked = (link) ->
        !!(link.type.outward is "blocks" and link.outwardIssue?.fields.status.name isnt "Done")

    setBlocked = (card, value = true) ->
        flag = $(card).find '.blocked-flag'

        if value then flag.show() else flag.hide()

    
    buildMenu = (id, items) ->
        elem = $('<div>').attr
            'class': 'contextMenu'
            'id': id

        elem.hide()

        ul = $ '<ul>'

        for id, config of items
            ul.append $("<li id='#{id}'>").text(config.name)

            bindings[id] = config.callback

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

                    blockedFlag.show() if label.toLowerCase() is 'blocked' and data.fields.status?.name isnt 'Done'

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
                    blockedFlag.show()
                    break
                

    initIssueCards = ->
        FIELDS = [
            'attachment'
            'comment'
            'issuelinks'
            'labels'
            'status'
        ]

        cards = $ '.ghx-issue'

        cards.contextMenu 'issueContextMenu',
            onContextMenu: (e) ->
                # Select the issue before firing context menu
                $(e.currentTarget).trigger 'click'

            menuStyle:
                'width': 'auto'

            itemHoverStyle:
                'background-color': 'rgb(217, 231, 243)'
                'border-color': 'rgb(180, 200, 210)'

            bindings: bindings
        
        for card in cards
            do (card) ->
                setImmediate ->
                    $.ajax "#{API_URL}issue/#{$(card).data('issueId')}?fields=#{FIELDS.join ','}",
                        dataType: 'json'
                        type: 'GET'

                        success: (data) ->
                            decorateCard card, data

                        error: (xhr, status, error) ->
                            console.debug "Jon: Error fetching data for issue #{$(card).data()}"

    # MAIN

    insertDependencies()
    buildMenu 'issueContextMenu',
        'view-story':
            name: 'View Story...'
            callback: (t) ->
                $(t).find('.js-detailview')[0].click()

        'edit-issue':
            name: 'Edit Story...'
            callback: GH.Shortcut.editIssue

        'edit-labels': 
            name: 'Edit Labels...'
            callback: GH.Shortcut.editIssueLabels

        'assign-to-me':
            name: 'Assign Story to Me'
            callback: GH.Shortcut.assignIssueToMe

        'links':
            name: 'Set to Blocked...'
            callback: GH.IssueOperationShortcuts.linkSelectedIssue

    initIssueCards()

    # TODO: Proper image zooming?
    $('#fancybox-outer').on 'dblclick', '#fancybox-img', (e) ->
        window.open $(this).attr 'src'

    $(document).bind "DOMNodeInserted", (e) ->
        # span#js-pool-end is added when 'work' is reloaded
        target = $ e.target
        initIssueCards() if target.attr('id') is 'js-pool-end'
        target.attr 'target', 'blank' if target.attr('class') is 'external-link'

        return true

    # Ugly hack to ensure the handler gets set
    setTimeout((-> $('#ghx-work').on 'dblclick', '.ghx-issue', (e) ->
        console.log "Clicked on ", $(e.currentTarget).find('.js-detailview')[0]
        $(e.currentTarget).find('.js-detailview')[0].click()
    ), 100)


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

    #ghx-plan .ghx-issue .ghx-type {
        display: none;
    }

    #ghx-plan .ghx-issue .ghx-priority {
        display: none;
    }

    #ghx-plan .ghx-issue .ghx-issue-fields {
        left: -40px;
        position: relative;
    }
"