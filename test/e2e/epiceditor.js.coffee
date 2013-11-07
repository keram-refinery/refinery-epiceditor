refinery.admin.ImagesDialog.prototype.options.url = '/components/refinerycms-clientside/test/fixtures/images_dialog.json'
refinery.admin.ResourcesDialog.prototype.options.url = '/components/refinerycms-clientside/test/fixtures/resources_dialog.json'
refinery.admin.LinksDialog.prototype.options.url = '/components/refinerycms-clientside/test/fixtures/links_dialog.json'

refinery.epiceditor.EpicEditor.prototype.options.basePath = '../../'
refinery.epiceditor.EpicEditor.prototype.options.theme.base = 'styles/themes/base/epiceditor.css'
refinery.epiceditor.EpicEditor.prototype.options.theme.editor = 'styles/themes/preview/refinery.css'
refinery.epiceditor.EpicEditor.prototype.options.theme.preview = 'styles/themes/editor/refinery.css'

describe 'Refinery EpicEditor', ->

  before ->
    @container = $('#container')
    @container.html('<div class="field"><textarea cols=80 rows=5 id="textarea"></textarea></div>')
    @textarea = $('#textarea')

  after ->
    @container.empty()

  describe 'Instance', ->
    before ->
      @editor = new refinery.epiceditor.EpicEditor()

    after ->
      @editor.destroy()

    it 'is instance of refinery.Object', ->
      expect( @editor ).to.be.an.instanceof refinery.Object


  describe 'Initialization', ->
    before ->
      @editor = new refinery.epiceditor.EpicEditor()
      @editor.init($('#textarea').parent())

    after ->
      @editor.destroy()

    context '#container', ->
      it 'contains div.wysiwyg-editor-holder', ->
        expect( $('div.wysiwyg-editor-holder').length ).to.eq(1)

      it '#textarea is not visible', ->
        expect( $('#textarea').parent().hasClass('wysiwyg-editor-on') ).to.be.true


  describe 'Dialogs', ->
    before ->
      @editor = new refinery.epiceditor.EpicEditor()
      @editor.init($('#textarea').parent())
      @editable_area = $(@editor.editor.getElement('editor').body)
      @util_bar = $(@editor.editor.getElement('wrapper')).find('#epiceditor-utilbar');

    after ->
      @editor.destroy()

    it 'has Resources (files) dialog', ->
      expect( @util_bar.html() ).to.have.string('Files Dialog')

    it 'has Images dialog', ->
      expect( @util_bar.html() ).to.have.string('Images Dialog')

    it 'has Links dialog', ->
      expect( @util_bar.html() ).to.have.string('Links Dialog')


  describe 'Insert image', ->
    before (done) ->
      @editor = new refinery.epiceditor.EpicEditor()
      @editor.init($('#textarea').parent())
      @editable_area = $(@editor.editor.getElement('editor').body)
      @util_bar = $(@editor.editor.getElement('wrapper')).find('#epiceditor-utilbar');
      @editor.images_dialog.on 'load', ->
        done()
      @editor.images_dialog.on 'insert', (img) ->

      @util_bar.find('button.editor-images-dialog-btn').click()

    after ->
      @editor.destroy()

    context 'via Library', ->
      before (done) ->
        @util_bar.find('button.editor-images-dialog-btn').click()
        $('.ui-dialog:visible').find('.ui-tabs').tabs({ active: 0 })
        @expectation = '![Image alt](/refinerycms-clientside/test/fixtures/500x350.jpg)'

        $.getJSON '/components/refinerycms-clientside/test/fixtures/image_dialog.json', (response) ->
          ajaxStub = sinon.stub($, 'ajax')
          ajaxStub.returns(okResponse(response))

          uiSelect('#image-1')
          $('.ui-dialog:visible form').submit()
          done()

      after ->
        $.ajax.restore()
        @editable_area.empty()
        @textarea.val('')

      it 'include image tag to editable area', ->
        expect( @editable_area.html() ).to.have.string(@expectation)

      it 'include image tag to text area', ->
        expect( @textarea.val() ).to.have.string(@expectation)

    context 'via Url', ->
      before (done) ->
        @util_bar.find('button.editor-images-dialog-btn').click()
        $('.ui-dialog:visible').find('.ui-tabs').tabs({ active:  1 })
        url = 'http://localhost:9000/refinery-epiceditor/components/refinerycms-clientside/test/fixtures/sample.gif'
        @expectation = '![](' + url + ')'

        tab = @editor.images_dialog.holder.find('div[aria-expanded="true"]')
        tab.find('input[type="url"]').val(url)
        tab.find('input[type="submit"]:visible').click()
        done()

      after ->
        @editable_area.empty()
        @textarea.val('')

      it 'include image tag to editable area', ->
        expect( @editable_area.html() ).to.have.string(@expectation)

      it 'include image tag to text area', ->
        expect( @textarea.val() ).to.have.string(@expectation)


  describe 'Insert resource', ->
    before ->
      @editor = new refinery.epiceditor.EpicEditor()
      @editor.init($('#textarea').parent())
      @editable_area = $(@editor.editor.getElement('editor').body)
      @util_bar = $(@editor.editor.getElement('wrapper')).find('#epiceditor-utilbar');

    after ->
      @editor.destroy()

    context 'via Library', ->
      before (done) ->
        @expectation = 'programming_in_coffeescript.pdf'
        editor = @editor

        @libraryTab = ->
          $('a[href="#existing-resource-area"]').click()
          uiSelect($('.records li').first())
          done()

        editor.resources_dialog.on 'load', @libraryTab

        @util_bar.find('button.editor-resources-dialog-btn').click()
        expect( editor.resources_dialog.is('opened') ).to.be.true

      after ->
        @editable_area.empty()
        @textarea.val('')
        @editor.resources_dialog.off 'load', @libraryTab

      it 'include resource tag to editable area', ->
        expect( @editable_area.html() ).to.have.string(@expectation)

      it 'include resource tag to text area', ->
        expect( @textarea.val() ).to.have.string(@expectation)


  describe 'Insert link', ->
    before (done) ->
      @editor = new refinery.epiceditor.EpicEditor()
      @editor.init($('#textarea').parent())
      @editable_area = $(@editor.editor.getElement('editor').body)
      @util_bar = $(@editor.editor.getElement('wrapper')).find('#epiceditor-utilbar');
      @editor.links_dialog.on 'load', ->
        done()

      @util_bar.find('button.editor-links-dialog-btn').click()

    after ->
      @editor.destroy()

    context 'via Library', ->
      before (done) ->
        @util_bar.find('button.editor-links-dialog-btn').click()
        $('.ui-dialog:visible').find('.ui-tabs').tabs({ active: 0  })
        @expectation = '[Home](/)'
        @editor.links_dialog.on 'insert', ->
          done()
        uiSelect($('.records li').first())

      after ->
        @editable_area.empty()
        @textarea.val('')

      it 'include link tag to editable area', ->
        expect( @editable_area.html() ).to.have.string(@expectation)

      it 'include link tag to text area', ->
        expect( @textarea.val() ).to.have.string(@expectation)


    context 'via Url', ->
      before (done) ->
        @util_bar.find('button.editor-links-dialog-btn').click()
        $('.ui-dialog:visible').find('.ui-tabs').tabs({ active: 1 })
        url = 'http://localhost:9000/refinery-epiceditor/'
        @expectation = '[localhost:9000/refinery-epiceditor/](' + url + ')'

        $('a[href="#links-dialog-website"]').click()
        tab = @editor.links_dialog.holder.find('div[aria-expanded="true"]')
        tab.find('input[type="url"]').val(url)
        tab.find('input[type="submit"]').click()
        done()

      after ->
        @editable_area.empty()
        @textarea.val('')

      it 'include link tag to editable area', ->
        expect( @editable_area.html() ).to.have.string(@expectation)

      it 'include link tag to text area', ->
        expect( @textarea.val() ).to.have.string(@expectation)


    context 'as Email link', ->
      before (done) ->
        @util_bar.find('button.editor-links-dialog-btn').click()
        $('.ui-dialog:visible').find('.ui-tabs').tabs({ active: 2 })
        email = 'lorem@ipsum.sk'
        subject = 'Hello Philip'
        body = 'some body'
        @expectation = '[' + email + '](mailto:' +
          encodeURIComponent(email) +
          '?subject=' + encodeURIComponent(subject) +
          '&amp;body=' + encodeURIComponent(body) + ')'

        $('a[href="#links-dialog-email"]').click()
        tab = @editor.links_dialog.holder.find('div[aria-expanded="true"]')
        tab.find('#email_address_text').val(email)
        tab.find('#email_default_subject_text').val(subject)
        tab.find('#email_default_body_text').val(body)
        tab.find('input[type="submit"]').click()
        done()

      after ->
        @editable_area.empty()
        @textarea.val('')

      it 'include link tag to editable area', ->
        expect( @editable_area.html() ).to.have.string(@expectation)

      it 'include link tag to text area', ->
        expect( @textarea.val() ).to.have.string(@expectation)


  describe 'toggle button', ->
    before (done) ->
      @editor = editor = new refinery.epiceditor.EpicEditor()
      @editor.init($('#textarea').parent())
      @editable_area = $(@editor.editor.getElement('editor').body)
      @util_bar = $(@editor.editor.getElement('wrapper')).find('#epiceditor-utilbar');
      @expectation = 'lorem ipsum'
      @editable_area.html(@expectation)
      $('.wysiwyg-toggle-button').click()
      done()

    after ->
      @editor.destroy()
      @editable_area.empty()
      @textarea.val('')

    context 'first click', ->
      it 'shows textarea instead of editor', ->
        expect( $('#textarea').parent().hasClass('wysiwyg-editor-on') ).to.be.false

    context 'second click', ->
      before ->
        $('.wysiwyg-toggle-button').click()

      it 'shows again editor', ->
        expect( $('#textarea').parent().hasClass('wysiwyg-editor-on') ).to.be.true
