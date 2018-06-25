# Barebones CMS Tools for ContentTools.
# (C) 2018 CubicleSoft.  All Rights Reserved.

class ContentTools.Tools.H1 extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'h1')

    @label = 'H1'
    @icon = 'h1'
    @tagName = 'h1'


class ContentTools.Tools.H2 extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'h2')

    @label = 'H2'
    @icon = 'h2'
    @tagName = 'h2'


class ContentTools.Tools.H3 extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'h3')

    @label = 'H3'
    @icon = 'h3'
    @tagName = 'h3'


class ContentTools.Tools.H4 extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'h4')

    @label = 'H4'
    @icon = 'h4'
    @tagName = 'h4'


class ContentTools.Tools.H5 extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'h5')

    @label = 'H5'
    @icon = 'h5'
    @tagName = 'h5'


class ContentTools.Tools.H6 extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'h6')

    @label = 'H6'
    @icon = 'h6'
    @tagName = 'h6'


class ContentTools.Tools.Blockquote extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'blockquote')

    @label = 'Blockquote'
    @icon = 'blockquote'
    @tagName = 'blockquote'


class ContentTools.Tools.Address extends ContentTools.Tools.Heading

    ContentTools.ToolShelf.stow(@, 'address')

    @label = 'Address'
    @icon = 'address'
    @tagName = 'address'


class ContentTools.EmbedTemplateDialog extends ContentTools.DialogUI

    # A dialog to support inserting templated HTML content mostly for ContentTools.EmbedDialog.

    constructor: ()->
        super('Insert Template')

        @_currSelection = '';
        @_fieldSets = {'': []}
        @_content = ''

    mount: () ->
        # Mount the widget.
        super()

        # Update dialog class.
        ContentEdit.addCSSClass(@_domElement, 'ct-embed-template-dialog')

        # Update view class.
        ContentEdit.addCSSClass(@_domView, 'ct-embed-template-dialog__view')

        # Template select.
        @_domTemplate = document.createElement('select')
        @_domTemplate.setAttribute('class', 'ct-embed-template-dialog__select')
        @_domTemplate.setAttribute('name', 'template')
        option = document.createElement('option')
        option.value = ''
        option.textContent = ContentEdit._('Select a template')
        @_domTemplate.appendChild(option)
        @_domView.appendChild(@_domTemplate)

        # Initialize templates and field sets.
        for template, num in ContentTools.EMBED_TEMPLATES
            option = document.createElement('option')
            option.value = '' + num
            option.textContent = template.name
            @_domTemplate.appendChild(option)

            fieldSet = []
            for field in template.fields
                if field.type == 'text' || field.type == 'switch' || field.type == 'select' || field.type == 'textarea' || field.type == 'file'
                    newfield = new EmbedTemplateFieldUI(this, field)
                    fieldSet.push(newfield)

            @_fieldSets['' + num] = fieldSet

        # Add controls.
        domControlGroup = @constructor.createDiv(['ct-control-group', 'ct-control-group--right'])
        @_domControls.appendChild(domControlGroup)

        # Insert button.
        @_domButton = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--insert',
            'ct-control--muted'
            ])
        @_domButton.textContent = ContentEdit._('Insert')
        domControlGroup.appendChild(@_domButton)

        # Add interaction handlers
        @_addDOMEventListeners()

    save: () ->
        # Save the template content.  This method triggers the save method against the dialog allowing the calling code to
        # listen for the 'save' event and manage the outcome.

        @dispatchEvent(@createEvent('save', {'content': @_content}))

    show: () ->
        # Show the widget.
        super()

        # Once visible automatically give focus to the template selector.
        @_domTemplate.focus()

    unmount: () ->
        # Unmount the component from the DOM.

        # Unselect any content.
        if @isMounted()
            @_domTemplate.blur()

        super()

        @_domButton = null
        @_domTemplate = null

    updateContent: () ->
        # Traverse fields in the field set to update the content.
        @_content = ''
        valid = true
        fieldMap = {}
        for fieldui in @_fieldSets[@_currSelection]
            if !fieldui.valid()
                valid = false
            else
                field = fieldui.getField()
                fieldMap[field.name] = field

        if valid && @_currSelection
            @_content = ContentTools.EMBED_TEMPLATES[parseInt(@_currSelection, 10)].content(fieldMap).trim()

        if @_content
            ContentEdit.removeCSSClass(@_domButton, 'ct-control--muted')
        else
            ContentEdit.addCSSClass(@_domButton, 'ct-control--muted')

    # Private methods.

    _changeTemplate: () ->
        # Unmount current fields.
        for field in @_fieldSets[@_currSelection]
            field.unmount()

        # Mount new fields.
        @_currSelection = @_domTemplate.value
        for field in @_fieldSets[@_currSelection]
            field.mount(@_domView)

        @updateContent()

    _addDOMEventListeners: () ->
        # Add event listeners for the widget.
        super()

        @_domTemplate.addEventListener 'change', (ev) =>
            @_changeTemplate()

        @_domTemplate.addEventListener 'keydown', (ev) =>
            @_changeTemplate()

        # Add support for saving the generated content whenever the button is selected.
        @_domButton.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check that content has been supplied.
            if @_content
                @save()


class EmbedTemplateFieldUI extends ContentTools.AnchoredComponentUI

    # Displays a line with a label and the specific UI element.

    constructor: (@parentDialog, @field) ->
        super()

        @field.value = @field.default

    # Methods

    valid: () ->
        # Validate the field.
        if (!(@field.required?) || (@field.required && @field.value)) && (!(@field.valid?) || @field.valid(@field.value))
            ContentEdit.removeCSSClass(@_domLabel, 'ct-section__input--invalid')
            return true
        else
            ContentEdit.addCSSClass(@_domLabel, 'ct-section__input--invalid')
            return false

    getField: () ->
        return @field

    mount: (domParent, before = null) ->
        # Mount the component to the DOM.

        # Section wrap.
        @_domElement = @constructor.createDiv(['ct-section-wrap'])

        # Section.
        @_section = @constructor.createDiv(['ct-section', 'ct-section--applied'])
        @_domElement.appendChild(@_section)

        # Label.
        @_domLabel = @constructor.createDiv(['ct-section__label'])
        @_domLabel.textContent = @field.title
        @_section.appendChild(@_domLabel)

        # Option.
        if @field.type == 'text'
            @_domInputWrap = @constructor.createDiv(['ct-section__input-wrap'])
            @_domInput = document.createElement('input')
            @_domInput.setAttribute('class', 'ct-section__input')
            @_domInput.setAttribute('type', 'text')
            @_domInput.setAttribute('value', @field.value)
            @_domInputWrap.appendChild(@_domInput)
            @_section.appendChild(@_domInputWrap)

        else if @field.type == 'switch'
            @_domInputWrap = @constructor.createDiv(['ct-section__switch-wrap'])
            @_domInput = @constructor.createDiv(['ct-section__switch'])
            @_domInputWrap.appendChild(@_domInput)
            @_section.appendChild(@_domInputWrap)

            if !@field.value
                ContentEdit.removeCSSClass(@_section, 'ct-section--applied')

        else if @field.type == 'select'
            @_domInputWrap = @constructor.createDiv(['ct-section__input-wrap'])
            @_domInput = document.createElement('select')
            @_domInput.setAttribute('class', 'ct-section__input')
            @_domInputWrap.appendChild(@_domInput)
            @_section.appendChild(@_domInputWrap)

            for key, val of @field.options
                option = document.createElement('option')
                option.value = key
                option.textContent = val
                if key == @field.value
                    option.setAttribute("selected", "true")
                @_domInput.appendChild(option)

        else if @field.type == 'textarea'
            @_domInputWrap = @constructor.createDiv(['ct-section__input-wrap', 'ct-section__textarea-wrap'])
            @_domInput = document.createElement('textarea')
            @_domInput.setAttribute('class', 'ct-section__input ct-section__textarea')
            @_domInput.textContent = @field.value
            @_domInputWrap.appendChild(@_domInput)
            @_section.appendChild(@_domInputWrap)

        else if @field.type == 'file'
            @_domInputWrap = @constructor.createDiv(['ct-section__input-wrap', 'ct-section__file-wrap'])
            @_domInput = @constructor.createDiv(['ct-section__input'])
            button = @constructor.createDiv(['ct-control--text'])
            button.textContent = ContentEdit._('Select file...')
            @_domInput.appendChild(button)
            @_domInputWrap.appendChild(@_domInput)
            @_section.appendChild(@_domInputWrap)

        super(domParent, before)

    # Private methods.

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget.

        if @field.type == 'text' || @field.type == 'textarea'
            @_section.addEventListener 'click', (ev) =>
                @_domInput.focus()

            @_domInput.addEventListener 'input', (ev) =>
                @field.value = @_domInput.value
                @parentDialog.updateContent()

        else if @field.type == 'select'
            @_section.addEventListener 'click', (ev) =>
                @_domInput.focus()

            @_domInput.addEventListener 'change', (ev) =>
                @field.value = @_domInput.value
                @parentDialog.updateContent()

            @_domInput.addEventListener 'keydown', (ev) =>
                @field.value = @_domInput.value
                @parentDialog.updateContent()

        else if @field.type == 'switch'
            @_section.addEventListener 'click', (ev) =>
                ev.preventDefault()

                @field.value = !@field.value

                if @field.value
                    ContentEdit.addCSSClass(@_section, 'ct-section--applied')
                else
                    ContentEdit.removeCSSClass(@_section, 'ct-section--applied')

                @parentDialog.updateContent()

        else if @field.type == 'file'
            @_section.addEventListener 'click', (ev) =>
                ev.preventDefault()

                @_domInput.click()

            @_domInput.addEventListener 'click', (ev) =>
                ev.preventDefault()
                ev.stopPropagation()

                # Set-up the dialog.
                app = ContentTools.EditorApp.get()

                # Dialog.
                dialog = new ContentTools.InsertFileDialog()

                # Support cancelling the dialog.
                dialog.addEventListener 'cancel', () =>
                    dialog.hide()
                    @parentDialog.busy(false)

                # Support saving the dialog.
                dialog.addEventListener 'save', (ev) =>
                    selected = ev.detail().selected

                    for item in selected
                        if item.info
                            @field.value = item

                    dialog.hide()
                    @parentDialog.busy(false)

                    @parentDialog.updateContent()

                # Show the dialog.
                app.attach(dialog)
                dialog.show()
                @parentDialog.busy(true)


class ContentTools.EmbedDialog extends ContentTools.DialogUI

    # A dialog to support inserting generic embedded HTML content.

    constructor: (@origcaption, @origcontent)->
        super('Embed HTML')

    mount: () ->
        # Mount the widget.
        super()

        # Update dialog class.
        ContentEdit.addCSSClass(@_domElement, 'ct-embed-dialog')

        # Update view class.
        ContentEdit.addCSSClass(@_domView, 'ct-embed-dialog__view')

        # Content.
        @_domInputContent = document.createElement('textarea')
        @_domInputContent.setAttribute('class', 'ct-embed-dialog__textarea')
        @_domInputContent.setAttribute('name', 'content')
        @_domInputContent.setAttribute(
            'placeholder',
            ContentEdit._('Paste embed code/HTML') + '...'
            )
        @_domInputContent.value = @origcontent
        @_domView.appendChild(@_domInputContent)

        # Add controls.
        domControlGroup = @constructor.createDiv(['ct-control-group', 'ct-control-group--left'])
        @_domControls.appendChild(domControlGroup)

        # Caption.
        @_domInputCaption = document.createElement('input')
        @_domInputCaption.setAttribute('class', 'ct-embed-dialog__input')
        @_domInputCaption.setAttribute('name', 'caption')
        @_domInputCaption.setAttribute(
            'placeholder',
            ContentEdit._('Caption') + '...'
            )
        @_domInputCaption.setAttribute('type', 'text')
        @_domInputCaption.setAttribute('value', @origcaption)
        domControlGroup.appendChild(@_domInputCaption)

        # Add buttons.
        domControlGroup = @constructor.createDiv(['ct-control-group', 'ct-control-group--right'])
        @_domControls.appendChild(domControlGroup)

        # Templates button.
        if ContentTools.EMBED_TEMPLATES.length
            @_domTemplatesButton = @constructor.createDiv([
                'ct-control',
                'ct-control--text',
                'ct-control--templates'
                ])
            @_domTemplatesButton.textContent = ContentEdit._('Templates...')
            domControlGroup.appendChild(@_domTemplatesButton)
        else
            @_domTemplatesButton = null

        # Embed button.
        @_domEmbedButton = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--insert'
            ])
        if !@origcaption and !@origcontent
            ContentEdit.addCSSClass(@_domEmbedButton, 'ct-control--muted')
        @_domEmbedButton.textContent = ContentEdit._('Embed')
        domControlGroup.appendChild(@_domEmbedButton)

        if ContentTools.EMBED_EDITOR
            ContentTools.EMBED_EDITOR.init({ dialog: this, content: @_domInputContent })

        # Add interaction handlers
        @_addDOMEventListeners()

    save: () ->
        # Save the embed content and caption.  This method triggers the save method against the dialog allowing the calling code to
        # listen for the 'save' event and manage the outcome.

        @dispatchEvent(@createEvent('save', {'content': @_domInputContent.value.trim(), 'caption': @_domInputCaption.value.trim()}))

    show: () ->
        # Show the widget.
        super()

        # Once visible automatically give focus to the content box.
        @_domInputContent.focus()

    unmount: () ->
        # Unmount the component from the DOM.

        # Unselect any content.
        if @isMounted()
            @_domInputContent.blur()
            @_domInputCaption.blur()

        super()

        @_domTemplatesButton = null
        @_domEmbedButton = null
        @_domInputCaption = null
        @_domInputContent = null

    # Private methods.

    _addDOMEventListeners: () ->
        # Add event listeners for the widget.
        super()

        # Change the Embed button's muted status when content exists.
        @_domInputContent.addEventListener 'input', (ev) =>
            if ev.target.value && @_domInputCaption.value
                ContentEdit.removeCSSClass(@_domEmbedButton, 'ct-control--muted')
            else
                ContentEdit.addCSSClass(@_domEmbedButton, 'ct-control--muted')

        @_domInputCaption.addEventListener 'input', (ev) =>
            if ev.target.value && @_domInputContent.value
                ContentEdit.removeCSSClass(@_domEmbedButton, 'ct-control--muted')
            else
                ContentEdit.addCSSClass(@_domEmbedButton, 'ct-control--muted')

        # Save the content if the button is enabled.
        @_domInputCaption.addEventListener 'keypress', (ev) =>
            if ev.keyCode is 13 && @_domInputContent.value && @_domInputCaption.value
                @save()

        # Add support for embed template dialog.
        if @_domTemplatesButton
            @_domTemplatesButton.addEventListener 'click', (ev) =>
                ev.preventDefault()

                # Set-up the dialog.
                app = ContentTools.EditorApp.get()

                # Dialog.
                dialog = new ContentTools.EmbedTemplateDialog()

                # Support cancelling the dialog.
                dialog.addEventListener 'cancel', () =>
                    dialog.hide()
                    @busy(false)

                # Support saving the dialog.
                dialog.addEventListener 'save', (ev) =>
                    content = ev.detail().content

                    @_domInputContent.value = @_domInputContent.value.trim() + '\n\n' + content
                    @_domInputContent.value = @_domInputContent.value.trim()

                    if @_domInputContent.value && @_domInputCaption.value
                        ContentEdit.removeCSSClass(@_domEmbedButton, 'ct-control--muted')
                    else
                        ContentEdit.addCSSClass(@_domEmbedButton, 'ct-control--muted')

                    dialog.hide()
                    @busy(false)

                # Show the dialog.
                app.attach(dialog)
                dialog.show()
                @busy(true)

        # Add support for saving the embed whenever the button is selected.
        @_domEmbedButton.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check that both values have been supplied.
            if @_domInputContent.value && @_domInputCaption.value
                @save()


class ContentTools.Tools.Embed extends ContentTools.Tool

    # Adds a tool to insert raw HTML.

    ContentTools.ToolShelf.stow(@, 'embed')

    @label = 'Embed'
    @icon = 'embed'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current element/selection.
        return not element.isFixed()

    @apply: (element, selection, callback) ->

        # Dispatch 'apply' event.
        toolDetail = {
            'tool': this,
            'element': element,
            'selection': selection
            }
        if not @dispatchEditorEvent('tool-apply', toolDetail)
            return

        # If supported allow store the state for restoring once the dialog is cancelled.
        if element.storeState
            element.storeState()

        # Set-up the dialog.
        app = ContentTools.EditorApp.get()

        # Modal.
        modal = new ContentTools.ModalUI()

        # Get the content from the node for the dialog.
        if element.type() is 'Embed'
            caption = element.getCaption()
            if element.attr('data-html')
                try
                    content = JSON.parse(element.attr('data-html'))
                catch e
                    content = element.attr('data-html')
            else
                content = element.getContent()
        else
            caption = ''
            content = ''

        # Dialog.
        dialog = new ContentTools.EmbedDialog(caption, content)

        # Support cancelling the dialog.
        dialog.addEventListener 'cancel', () =>

            modal.hide()
            dialog.hide()

            if element.restoreState
                element.restoreState()

            callback(false)

        # Support saving the dialog.
        dialog.addEventListener 'save', (ev) =>
            caption = ev.detail().caption
            content = ev.detail().content

            # Remove Javascript for preview.
            previewcontent = content.replace(/<\s*script[\S\s]*?>[\S\s]*?<\s*\/\s*script[\S\s]*?>/gi, '').trim()

            if element.type() is 'Embed'
                # Update the node with the new content.
                element.setCaption(caption)
                element.attr('data-html', JSON.stringify(content))
                element.setContent(previewcontent)

            else
                # Create new HTML embed.
                embed = new ContentEdit.Embed('div-embed', {'aria-label' : caption, 'data-html' : JSON.stringify(content)}, previewcontent)

                # Find insert position
                [node, index] = @_insertAt(element)
                node.parent().attach(embed, index)

                # Focus the new embed
                embed.focus()

            modal.hide()
            dialog.hide()

            callback(true)

            # Dispatch 'applied' event.
            @dispatchEditorEvent('tool-applied', toolDetail)

        # Show the dialog.
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()


class ContentTools.InsertFileDialog extends ContentTools.DialogUI

    # A dialog to support inserting an uploaded file into the DOM.

    constructor: ()->
        super('Insert File')

        @_runTimeout = null
        @_items = []
        @_uploads = 0;
        @_childModal = false;

    mount: () ->
        # Mount the widget.
        super()

        # Update dialog class.
        ContentEdit.addCSSClass(@_domElement, 'ct-insert-file-dialog')

        # Update view class.
        ContentEdit.addCSSClass(@_domView, 'ct-insert-file-dialog__view')

        # Search region.
        @_domSearch = @constructor.createDiv(['ct-insert-file-dialog__search', 'ct-insert-file-dialog__search--active'])
        @_domView.appendChild(@_domSearch)

        # Search fields wrapper.
        searchFieldsWrap = @constructor.createDiv(['ct-insert-file-dialog__search-fields-wrapper'])
        @_domSearch.appendChild(searchFieldsWrap)

        # Search fields region.
        searchFields = @constructor.createDiv(['ct-insert-file-dialog__search-fields'])
        searchFieldsWrap.appendChild(searchFields)

        # Search input field.
        searchField = @constructor.createDiv(['ct-insert-file-dialog__search-field-left'])
        searchFields.appendChild(searchField)
        @_domSearchInput = document.createElement('input')
        @_domSearchInput.setAttribute('class', 'ct-insert-file-dialog__search-input')
        @_domSearchInput.setAttribute('name', 'search')
        @_domSearchInput.setAttribute(
            'placeholder',
            ContentEdit._('Find') + '...'
            )
        @_domSearchInput.setAttribute('type', 'text')
        searchField.appendChild(@_domSearchInput)

        # Search limit select field.
        searchField = @constructor.createDiv(['ct-insert-file-dialog__search-field-right'])
        searchFields.appendChild(searchField)
        @_domSearchLimit = document.createElement('select')
        @_domSearchLimit.setAttribute('class', 'ct-insert-file-dialog__search-limit')
        @_domSearchLimit.setAttribute('name', 'limit')
        searchField.appendChild(@_domSearchLimit)

        # Search results region.
        @_domSearchResults = @constructor.createDiv(['ct-insert-file-dialog__search-results'])
        @_domSearch.appendChild(@_domSearchResults)

        # Upload region.
        @_domUpload = @constructor.createDiv(['ct-insert-file-dialog__upload'])
        @_domView.appendChild(@_domUpload)

        if ContentTools.INSERT_FILE_UPLOADER
            ContentTools.INSERT_FILE_UPLOADER.init({ dialog: this, upload: @_domUpload })
        else
            @_domUpload.innerHTML = ContentEdit._('ContentTools.INSERT_FILE_UPLOADER is not correctly configured.')

        # Controls.

        # Add tabs.
        domTabs = @constructor.createDiv(
            ['ct-control-group', 'ct-control-group--left'])
        @_domControls.appendChild(domTabs)

        # Search tab.
        @_domSearchTab = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--icon-search',
            'ct-control--active'
            ])
        @_domSearchTab.setAttribute('data-ct-tooltip', ContentEdit._('Find/Select'))
        domTabs.appendChild(@_domSearchTab)

        if !ContentTools.INSERT_FILE_FIND
            ContentEdit.addCSSClass(@_domSearchTab, 'ct-control--muted')

        # Upload tab.
        @_domUploadTab = @constructor.createDiv([
            'ct-control',
            'ct-control--icon',
            'ct-control--icon-upload'
            ])
        @_domUploadTab.setAttribute('data-ct-tooltip', ContentEdit._('Upload'))
        domTabs.appendChild(@_domUploadTab)

        if !ContentTools.INSERT_FILE_UPLOADER
            ContentEdit.addCSSClass(@_domUploadTab, 'ct-control--muted')

        # Add buttons.
        domControlGroup = @constructor.createDiv(['ct-control-group', 'ct-control-group--right'])
        @_domControls.appendChild(domControlGroup)

        # Insert button.
        @_domButton = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--insert',
            'ct-control--muted'
            ])
        @_domButton.textContent = ContentEdit._('Insert')
        domControlGroup.appendChild(@_domButton)

        if ContentTools.INSERT_FILE_FIND
            ContentTools.INSERT_FILE_FIND.init({ dialog: this, searchinput: @_domSearchInput, searchlimit: @_domSearchLimit })
            ContentTools.INSERT_FILE_FIND.run()
        else
            domSearchResult = @constructor.createDiv(['ct-insert-file-dialog__search-result'])
            domSearchResult.innerHTML = ContentEdit._('ContentTools.INSERT_FILE_FIND is not correctly configured.')
            @_domSearchResults.appendChild(domSearchResult)

        # Add interaction handlers.
        @_addDOMEventListeners()

    clearResults: (all) ->
        # Removes unselected items from the results list (including titles).
        # Optionally removes ALL items.
        items = []
        for item in @_items
            if !all && item instanceof FindResultItemUI && item.selected()
                items.push(item)
            else
                item.unmount()

        # Inserts a 'Selected' title before any selected items.
        if items.length
            titleUI = new FindResultTitleUI(ContentEdit._('Selected'), false)
            titleUI.mount(@_domSearchResults, items[0].domElement())
            items.unshift(titleUI)

        @_items = items

        @_updateInsertButton()

    addResultError: (message) ->
        # Prepends a new error message to the results.
        titleUI = new FindResultTitleUI(message, true)
        if @_items.length
            titleUI.mount(@_domSearchResults, @_items[0].domElement())
        else
            titleUI.mount(@_domSearchResults)
        @_items.push(titleUI)

    addResultTitle: (title) ->
        # Appends a new title to the results.
        titleUI = new FindResultTitleUI(title)
        titleUI.mount(@_domSearchResults)
        @_items.push(titleUI)

    addResultItem: (options, selected) ->
        # Appends a new item to the results.
        itemUI = new FindResultItemUI(this, options, selected)
        itemUI.mount(@_domSearchResults)
        @_items.push(itemUI)

        @_updateInsertButton()

    uploadStarted: () ->
        # Disable the insert and close buttons during an upload.
        @_uploads++

        @_updateInsertButton()

    uploadFinished: () ->
        # Enable the insert and close buttons when all uploads are finished.
        @_uploads--

        @_updateInsertButton()

    childModal: (display) ->
        @_childModal = display

        @_updateInsertButton()

    selectedItems: () ->
        items = []
        for item in @_items
            if item instanceof FindResultItemUI && item.selected()
                items.push(item.mode())

        return items

    save: () ->
        # Insert the selected items.  This method triggers the save method against the dialog allowing the calling code to
        # listen for the 'save' event and manage the outcome.

        if ContentTools.INSERT_FILE_FIND
            @dispatchEvent(@createEvent('save', {'selected': @selectedItems()}))
        else
            @dispatchEvent(@createEvent('save', {'selected': []}))

    unmount: () ->
        # Unmount the component from the DOM.

        # Unselect any content.
        if @isMounted()
            @_domSearchInput.blur()
            @_domSearchLimit.blur()

        super()

        @_domButton = null
        @_domSearchLimit = null
        @_domSearchInput = null

    # Private methods.

    _updateInsertButton: () ->
        # Manage the class for the insert button whenever state changes.
        if @_childModal || @_uploads
            @busy(true)
        else
            @busy(false)

        if @busy()
            ContentEdit.addCSSClass(@_domButton, 'ct-control--muted')
            return

        for item in @_items
            if item instanceof FindResultItemUI && item.selected()
                ContentEdit.removeCSSClass(@_domButton, 'ct-control--muted')
                return

        ContentEdit.addCSSClass(@_domButton, 'ct-control--muted')

    _findRunExecute: () ->
        @_runTimeout = null

        ContentTools.INSERT_FILE_FIND.run()

    _findRun: () ->
        if ContentTools.INSERT_FILE_FIND
            if @_runTimeout
                clearTimeout(@_runTimeout)

            @_runTimeout = setTimeout(
                () => @_findRunExecute(),
                250
                )

    _addDOMEventListeners: () ->
        # Add event listeners for the widget.
        super()

        @_domSearchInput.addEventListener 'input', (ev) =>
            @_findRun()

        @_domSearchLimit.addEventListener 'change', (ev) =>
            @_findRun()

        @_domSearchLimit.addEventListener 'keydown', (ev) =>
            @_findRun()

        @_domSearchResults.addEventListener 'click', (ev) =>
            @_updateInsertButton()

        @_domSearchTab.addEventListener 'mousedown', () =>
            ContentEdit.removeCSSClass(@_domUpload, 'ct-insert-file-dialog__upload--active')
            ContentEdit.removeCSSClass(@_domUploadTab, 'ct-control--active')
            ContentEdit.addCSSClass(@_domSearch, 'ct-insert-file-dialog__search--active')
            ContentEdit.addCSSClass(@_domSearchTab, 'ct-control--active')

        @_domUploadTab.addEventListener 'mousedown', () =>
            ContentEdit.removeCSSClass(@_domSearch, 'ct-insert-file-dialog__search--active')
            ContentEdit.removeCSSClass(@_domSearchTab, 'ct-control--active')
            ContentEdit.addCSSClass(@_domUpload, 'ct-insert-file-dialog__upload--active')
            ContentEdit.addCSSClass(@_domUploadTab, 'ct-control--active')

        # Add support for inserting the item(s) whenever the button is selected.
        @_domButton.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # Check that the button isn't muted.  The find callback is expected to update the button according to user input.
            if !@busy() && @_domButton.getAttribute('class').indexOf('ct-control--muted') == -1
                @save()


class FindResultTitleUI extends ContentTools.AnchoredComponentUI

    # A general-purpose title or error message line.

    constructor: (@title, @error = false) ->
        super()

    # Methods

    mount: (domParent, before = null) ->
        # Mount the component to the DOM.

        # Section wrap.
        @_domElement = @constructor.createDiv(['ct-section-wrap'])

        # Section.
        section = @constructor.createDiv(['ct-section'])
        if @error
            ContentEdit.addCSSClass(section, 'ct-section--error')
        else
            ContentEdit.addCSSClass(section, 'ct-section--title')
        @_domElement.appendChild(section)

        # Label.
        label = @constructor.createDiv(['ct-section__label'])
        label.textContent = @title
        section.appendChild(label)

        super(domParent, before)


class FindResultItemUI extends ContentTools.AnchoredComponentUI

    # Displays a line with a checkbox icon, label, preview/new tab icon, and mode switching icon.

    constructor: (@parentDialog, @options, selected) ->
        super()

        @_selected = selected
        @_mode = 0

    # Methods

    selected: (selected) ->
        # Get/Set the selected flag.
        if selected is undefined
            return @_selected

        # If the value is the same there's nothing to do.
        if @_selected is selected
            return

        @_selected = selected

        # Update the section class to reflect the applied value.
        if @_selected
            ContentEdit.addCSSClass(@_section, 'ct-section--applied')
        else
            ContentEdit.removeCSSClass(@_section, 'ct-section--applied')

    mode: () ->
        @options.modes[@_mode].label = @options.label

        return @options.modes[@_mode]

    mount: (domParent, before = null) ->
        # Mount the component to the DOM.

        # Section wrap.
        @_domElement = @constructor.createDiv(['ct-section-wrap'])

        # Section.
        @_section = @constructor.createDiv(['ct-section'])
        if @_selected
            ContentEdit.addCSSClass(@_section, 'ct-section--applied')
        @_domElement.appendChild(@_section)

        # Checkbox icon.
        @_domCheckbox = @constructor.createDiv(['ct-section__icon', 'ct-section__checkbox'])
        @_section.appendChild(@_domCheckbox)

        # Label.
        @_domLabel = @constructor.createDiv(['ct-section__label'])
        @_domLabel.textContent = @options.label
        @_section.appendChild(@_domLabel)

        # Preview/new tab icon.
        if @options.preview
            @_domPreviewWrap = @constructor.createDiv(['ct-section__icon', 'ct-section__preview'])
        else
            @_domPreviewWrap = @constructor.createDiv(['ct-section__icon', 'ct-section__new-tab'])
        @_section.appendChild(@_domPreviewWrap)

        # Mode switching icon.
        @_domModeWrap = @constructor.createDiv(['ct-section__icon', 'ct-section__mode-' + @options.modes[@_mode].icon])
        @_domModeWrap.title = @options.modes[@_mode].title
        @_section.appendChild(@_domModeWrap)

        super(domParent, before)

    unmount: () ->
        # Unmount the component from the DOM.
        super()

        @parentDialog = null

    # Private methods.

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget.

        @_domCheckbox.addEventListener 'click', (ev) =>
            ev.preventDefault()

            if @_selected
                @selected(false)
            else
                @selected(true)

        @_domLabel.addEventListener 'click', (ev) =>
            ev.preventDefault()

            if @_selected
                @selected(false)
            else
                @selected(true)

        if @options.preview
            @_domPreviewWrap.addEventListener 'click', (ev) =>
                ev.preventDefault()

                # Set up the preview.
                app = ContentTools.EditorApp.get()
                modal = new ContentTools.PreviewModalUI(@options.preview())

                modal.addEventListener 'cancel', (ev) =>
                    modal.hide()
                    @parentDialog.childModal(false)

                # Show the preview.
                app.attach(modal)
                modal.show()
                @parentDialog.childModal(true)

        else
            @_domPreviewWrap.addEventListener 'click', (ev) =>
                ev.preventDefault()

                # Trigger a click on the hidden/detached element.
                @options.link.click()

        # Cycle modes.
        @_domModeWrap.addEventListener 'click', (ev) =>
            ContentEdit.removeCSSClass(@_domModeWrap, 'ct-section__mode-' + @options.modes[@_mode].icon)

            @_mode++
            if @_mode >= @options.modes.length
                @_mode = 0

            ContentEdit.addCSSClass(@_domModeWrap, 'ct-section__mode-' + @options.modes[@_mode].icon)
            @_domModeWrap.title = @options.modes[@_mode].title


class ContentTools.PreviewModalUI extends ContentTools.WidgetUI

    # This modal UI component provides a second element over both the page and a parent dialog and shows a single element as a preview.

    # Methods
    constructor: (@preview) ->
        super()

    mount: () ->
        # Mount the widget to the DOM.

        # Modal.
        @_domElement = @constructor.createDiv([
            'ct-widget',
            'ct-modal',
            'ct-preview-modal'
            ])
        @parent().domElement().appendChild(@_domElement)

        # Inner region.
        innerElement = @constructor.createDiv([
            'ct-preview-modal-inner'
            ])
        @_domElement.appendChild(innerElement)

        # Clone the element.  Useful for making audio/video stop playing when the dialog goes away.
        @_domPreview = @preview.cloneNode(true)
        innerElement.appendChild(@_domPreview)

        # Update the editor to let it know that a new modal is mounted.
        app = ContentTools.EditorApp.get()
        app.addedModal()

        # Add interaction handlers.
        @_addDOMEventListeners()

    unmount: () ->
        # Unmount the widget from the DOM.

        # Update the editor to let it know that the modal is unmounted.
        app = ContentTools.EditorApp.get()
        app.removedModal()

        super()

    # Private methods.

    _handleEscape: (ev) =>
        if ev.keyCode is 27
            @dispatchEvent(@createEvent('cancel'))

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget.

        # Using the escape key.
        document.addEventListener('keyup', @_handleEscape)

        # Trigger a custom event for clicks on the modal.
        @_domElement.addEventListener 'click', (ev) =>
            @dispatchEvent(@createEvent('cancel'))

    _removeDOMEventListeners: () ->

        document.removeEventListener('keyup', @_handleEscape)


class ContentTools.Tools.InsertFile extends ContentTools.Tool

    # Adds a tool to insert a file from an asset's file library.

    ContentTools.ToolShelf.stow(@, 'insert-file')

    @label = 'Insert file'
    @icon = 'insert-file'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current element/selection.
        return not element.isFixed()

    @apply: (element, selection, callback) ->

        # Dispatch 'apply' event.
        toolDetail = {
            'tool': this,
            'element': element,
            'selection': selection
            }
        if not @dispatchEditorEvent('tool-apply', toolDetail)
            return

        # Calculate the insertion point for new links.
        if selection
            startpos = selection.get(0)[1]
        else
            startpos = 0

        if element.content
            while startpos < element.content.characters.length and element.content.characters[startpos].hasTags('a')
                startpos++

        # If supported allow store the state for restoring once the dialog is cancelled.
        if element.storeState
            element.storeState()

        # Set-up the dialog.
        app = ContentTools.EditorApp.get()

        # Modal.
        modal = new ContentTools.ModalUI()

        # Dialog.
        dialog = new ContentTools.InsertFileDialog()

        # Support cancelling the dialog.
        dialog.addEventListener 'cancel', () =>

            modal.hide()
            dialog.hide()

            if element.restoreState
                element.restoreState()

            callback(false)

        # Support saving the dialog.
        dialog.addEventListener 'save', (ev) =>
            selected = ev.detail().selected
            haslink = false

            for item in selected
                if item.element == 'img'
                    # Create new image.
                    img = new ContentEdit.Image({'src' : item.url, 'width' : item.width, 'height' : item.height, 'data-src-info' : JSON.stringify(item.info)})

                    # Find insert position.
                    [node, index] = @_insertAt(element)
                    node.parent().attach(img, index)

                    # Focus the new image.
                    img.focus()

                else if item.element == 'a'
                    # Insert content and create new link.
                    if !element.content
                        # The current block element does not have support for content.  Create a new 'p' tag to house the link.
                        text = new ContentEdit.Text('p', {}, '')

                        # Find insert position.
                        [node, index] = @_insertAt(element)
                        node.parent().attach(text, index)

                        # Focus the new text.
                        text.focus()

                        element = text

                    element.content = element.content.insert(startpos, ' ' + item.label + ' ', false)
                    startpos++
                    linkopts = {'href' : item.url, 'data-src-info' : HTMLString.String.encode(JSON.stringify(item.info)).replace(/"/g, '&quot;')}
                    if item.target
                        linkopts.target = item.target
                    a = new HTMLString.Tag('a', linkopts)
                    element.content = element.content.format(startpos, startpos + item.label.length, a)
                    startpos += item.label.length + 1

                    haslink = true

                else if item.element == 'div-embed'
                    # Create new HTML embed.
                    embed = new ContentEdit.Embed('div-embed', {'aria-label' : item.label}, item.html)

                    # Find insert position.
                    [node, index] = @_insertAt(element)
                    node.parent().attach(embed, index)

                    # Focus the new embed.
                    embed.focus()

            if haslink
                # Update the element.
                element.content.optimize()
                element.updateInnerHTML()

                # Make sure the element is marked as tainted.
                element.taint()

            modal.hide()
            dialog.hide()

            callback(true)

            # Dispatch 'applied' event.
            @dispatchEditorEvent('tool-applied', toolDetail)

        # Show the dialog.
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()


class ContentTools.CropImageDialog extends ContentTools.DialogUI

    # A dialog to support cropping an image.

    constructor: (@element)->
        super('Crop Image')

        @_resizeTimeout = null
        @_items = []
        @_selected = -1

    mount: () ->
        # Mount the widget.
        super()

        # Update dialog class.
        ContentEdit.addCSSClass(@_domElement, 'ct-crop-image-dialog')

        # Update view class.
        ContentEdit.addCSSClass(@_domView, 'ct-crop-image-dialog__view')

        # Add buttons.
        domControlGroup = @constructor.createDiv(['ct-control-group', 'ct-control-group--right'])
        @_domControls.appendChild(domControlGroup)

        # Initialize crop view.
        if ContentTools.CROP_IMAGE
            # Add ratio selection region.
            @_domRatios = @constructor.createDiv(['ct-crop-image-dialog__ratios'])
            @_domView.appendChild(@_domRatios)

            # Add cropping region.
            @_domCrop = @constructor.createDiv(['ct-crop-image-dialog__crop'])
            @_domView.appendChild(@_domCrop)

            # Add a button for setting a default if the operation is supported.
            if ContentTools.CROP_IMAGE.setdefault
                # Set default button.
                @_domSetDefaultButton = @constructor.createDiv([
                    'ct-control',
                    'ct-control--text',
                    'ct-control--muted'
                    ])
                @_domSetDefaultButton.textContent = ContentEdit._('Set default')
                domControlGroup.appendChild(@_domSetDefaultButton)
        else
            domViewInfo = @constructor.createDiv(['ct-crop-image-dialog__view-info'])
            domViewInfo.innerHTML = ContentEdit._('ContentTools.CROP_IMAGE is not correctly configured.')
            @_domView.appendChild(domViewInfo)

        # Apply button.
        @_domApplyButton = @constructor.createDiv([
            'ct-control',
            'ct-control--text',
            'ct-control--apply',
            'ct-control--muted'
            ])
        @_domApplyButton.textContent = ContentEdit._('Apply')
        domControlGroup.appendChild(@_domApplyButton)

        if ContentTools.CROP_IMAGE
            try
                ContentTools.CROP_IMAGE.init({ dialog: this, crop: @_domCrop, info: JSON.parse(@element.attr('data-src-info')) })
            catch e

        # Add interaction handlers.
        @_addDOMEventListeners()

    addCropRatio: (ratio, display, info) ->
        # Appends a new ratio item to the list.
        itemUI = new CropRatioItemUI(this, ratio, display, info)
        itemUI.mount(@_domRatios)
        @_items.push(itemUI)

    selectCropRatio: (newratio) ->
        @_selected = -1

        for item, index in @_items
            if item.ratio() != newratio
                item.selected(false)
            else
                item.selected(true)
                @_selected = index

        if @_selected < 0
            ContentEdit.addCSSClass(@_domApplyButton, 'ct-control--muted')

            if ContentTools.CROP_IMAGE.setdefault
                ContentEdit.addCSSClass(@_domSetDefaultButton, 'ct-control--muted')
        else
            ContentTools.CROP_IMAGE.ratio(newratio, @_items[@_selected].info())

            ContentEdit.removeCSSClass(@_domApplyButton, 'ct-control--muted')

            if ContentTools.CROP_IMAGE.setdefault
                ContentEdit.removeCSSClass(@_domSetDefaultButton, 'ct-control--muted')

    updateCropRatioInfo: (newinfo) ->
        @_items[@_selected].info(newinfo)

    selectedCropRatio: () ->
        return @_items[@_selected].ratio()

    getCropRatioInfo: () ->
        return @_items[@_selected].info()

    save: () ->
        # Save the crop information.  This method triggers the save method against the dialog allowing the calling code to
        # listen for the 'save' event and manage the outcome.

        crops = {}
        for item in @_items
            crops[item.ratio()] = item.info()

        # The handler for this dialog expects 'src', 'width', 'height', and 'info' in the response.
        result = ContentTools.CROP_IMAGE.save(@_items[@_selected].ratio(), crops)

        @dispatchEvent(@createEvent('save', result))

    # Private methods.

    _handleWindowResizeFinal: () ->
        @_resizeTimeout = null

        ContentTools.CROP_IMAGE.resize()

    _handleWindowResize: (ev) =>
        if ContentTools.CROP_IMAGE && ContentTools.CROP_IMAGE.resize
            if @_resizeTimeout
                clearTimeout(@_resizeTimeout)

            @_resizeTimeout = setTimeout(
                () => @_handleWindowResizeFinal(),
                250
                )

    _addDOMEventListeners: () ->

        # Add event listeners for the widget.
        super()

        if ContentTools.CROP_IMAGE && ContentTools.CROP_IMAGE.setdefault
            @_domSetDefaultButton.addEventListener 'click', (ev) =>
                ev.preventDefault()

                if @_selected > -1
                    ContentTools.CROP_IMAGE.setdefault(@_items[@_selected].ratio(), @_items[@_selected].info())

        @_domApplyButton.addEventListener 'click', (ev) =>
            ev.preventDefault()

            if @_selected > -1
                @save()

        window.addEventListener('resize', @_handleWindowResize)

    _removeDOMEventListeners: () ->

        window.removeEventListener('resize', @_handleWindowResize)


class CropRatioItemUI extends ContentTools.AnchoredComponentUI

    # Displays a line with a radio button icon and label.

    constructor: (@parentDialog, ratio, @display, info) ->
        super()

        @_selected = false
        @_ratio = ratio
        @_info = info

    # Methods

    selected: (selected) ->
        # Get/Set the selected flag.
        if selected is undefined
            return @_selected

        # If the value is the same there's nothing to do.
        if @_selected is selected
            return

        @_selected = selected

        # Update the section class to reflect the applied value.
        if @_selected
            ContentEdit.addCSSClass(@_section, 'ct-section--applied')
        else
            ContentEdit.removeCSSClass(@_section, 'ct-section--applied')

    ratio: () ->
        return @_ratio

    info: (newinfo) ->
        if newinfo is undefined
            return @_info

        @_info = newinfo

    mount: (domParent, before = null) ->
        # Mount the component to the DOM.

        # Section wrap.
        @_domElement = @constructor.createDiv(['ct-section-wrap'])

        # Section.
        @_section = @constructor.createDiv(['ct-section'])
        @_domElement.appendChild(@_section)

        # Radio button icon.
        @_domRadio = @constructor.createDiv(['ct-section__icon', 'ct-section__radio'])
        @_section.appendChild(@_domRadio)

        # Label.
        @_domLabel = @constructor.createDiv(['ct-section__label'])
        @_domLabel.textContent = @display
        @_section.appendChild(@_domLabel)

        super(domParent, before)

    unmount: () ->
        # Unmount the component from the DOM.
        super()

        @parentDialog = null

    # Private methods.

    _addDOMEventListeners: () ->
        # Add DOM event listeners for the widget.

        @_section.addEventListener 'click', (ev) =>
            ev.preventDefault()

            if !@_selected
                @parentDialog.selectCropRatio(@_ratio)


class ContentTools.Tools.CropImage extends ContentTools.Tool

    # Adds a tool to crop an image element.

    ContentTools.ToolShelf.stow(@, 'crop-image')

    @label = 'Crop image'
    @icon = 'crop-image'

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current element/selection.
        return element.type() == 'Image' && element.attr('data-src-info') && not element.isFixed()

    @apply: (element, selection, callback) ->

        # Dispatch 'apply' event.
        toolDetail = {
            'tool': this,
            'element': element,
            'selection': selection
            }
        if not @dispatchEditorEvent('tool-apply', toolDetail)
            return

        # If supported allow store the state for restoring once the dialog is cancelled.
        if element.storeState
            element.storeState()

        # Set-up the dialog.
        app = ContentTools.EditorApp.get()

        # Modal.
        modal = new ContentTools.ModalUI()

        # Dialog.
        dialog = new ContentTools.CropImageDialog(element)

        # Support cancelling the dialog.
        dialog.addEventListener 'cancel', () =>

            modal.hide()
            dialog.hide()

            if element.restoreState
                element.restoreState()

            callback(false)

        # Support saving the dialog.
        dialog.addEventListener 'save', (ev) =>
            details = ev.detail()

            # Clone the current image element's attributes.
            attributes = {}
            for key, val of element._attributes
                attributes[key] = val;

            attributes.src = details.src
            attributes.width = details.width
            attributes.height = details.height
            attributes['data-src-info'] = JSON.stringify(details.info)

            # Create a new image.
            img = new ContentEdit.Image(attributes, element.a)

            # Find insert position.
            [node, index] = @_insertAt(element)
            node.parent().attach(img, index)

            # Focus the new image.
            img.focus()

            # Detach the current element.
            element.parent().detach(element)

            modal.hide()
            dialog.hide()

            callback(true)

            # Dispatch 'applied' event.
            @dispatchEditorEvent('tool-applied', toolDetail)

        # Show the dialog.
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()


ContentTools.DEFAULT_TOOLS = [
    [
        'bold',
        'italic',
        'link',

        'align-left',
        'align-center',
        'align-right'
    ], [
        'paragraph',
        'h2',
        'h3',

        'h4',
        'h5',
        'h6',

        'blockquote',
        'preformatted',
        'line-break',

        'unordered-list',
        'ordered-list',
        'table',

        'indent',
        'unindent',
        'embed'
    ], [
        'insert-file',
        'crop-image'
    ], [
        'undo',
        'redo',
        'remove'
    ]
]

ContentTools.EMBED_EDITOR = null

ContentTools.EMBED_TEMPLATES = []

ContentTools.INSERT_FILE_FIND = null
ContentTools.INSERT_FILE_UPLOADER = null

ContentTools.CROP_IMAGE = null
