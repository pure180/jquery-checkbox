( () ->
  'use strict'

  elements = '[data-type="checkbox"]'
  toggle   = '[data-toggle="checkbox"]'

  class Checkbox
    constructor: (element, options) ->
      @element         = $ element
      @data            = @element.data()
      @options         = $.extend {}, Checkbox.DEFAULTS, @data, options
      @parent          = @element.parent('label')

      @value           = null
      if @element.val() == 'on' || @element.val() == 1 || @element.val() == '1'
        @value = true
      else if @element.val() == 'off' || @element.val() == 0 || @element.val() == '0'
        @value = false

      if typeof @options.action == 'undefined'
        @options.action = 'load'

      if @options.action
        @[@options.action]()

    Checkbox.DEFAULTS =
      eventName:  'checkbox'
      toggle:     'checkbox'
      wrap:       'label'
      htmlClone:  '<ins />'
      class:      'checkbox-clone'

    load: () ->

      if @element[0].style.display != 'none' || !@element.is '.hidden'
        @randomID = @options.toggle + '_' + Math.floor((Math.random() * 1000000) + 10)
        @initialize()

    click: () ->
      if @value == true
        @uncheck()
      else if @value == false
        @check()

      @eventListener('toggle', @options.action)

    toggle: () ->
      @click()

    initialize: () ->
      @clone()
      @changeState()
      @element.css({'display': 'none', 'visibility': 'hidden'})

    clone: () ->
      if !@parent.length && !@parent.is 'label' || @options.wrap != false
        @element.wrap '<' + @options.wrap + ' class="' + @options.toggle + '-' + @options.wrap + '"></' + @options.wrap + ' >'
      @element.attr('data-id', @randomID)
      cloneProperties =
        id: @randomID
        class: @options.class + if @value then ' checked' else ''
        'data-toggle': 'checkbox'
        'data-id' : @randomID
        'tabindex': 1
      $( @options.htmlClone, cloneProperties ).one().insertAfter @element

    changeState: () ->
      if @value == true
        @check()
      else if @value == false
        @uncheck()

    check: () ->
      @element.attr 'checked', 'checked'
      @value = true

      if @element.val == 'on' || @element.val == 'off'
        @element.val('on')
      else
        @element.val(1)

      $('#' + @options.id).addClass('checked')
      @eventListener('checked', @options.action)

    uncheck: () ->
      @element.removeAttr 'checked'
      @value = false

      if @element.val == 'on' || @element.val == 'off'
        @element.val('off')
      else
        @element.val(0)

      $('#' + @options.id).removeClass('checked')
      @eventListener('unchecked', @options.action)

    eventListener: (name, action) ->
      event = $.Event name + '.' + @options.eventName
      event.checkbox = @options
      @element.trigger event
      return


  Plugin = (option) ->
    action = if typeof arguments[0] == 'string' && typeof arguments[0] != 'object' && typeof arguments[0] != 'undefined' then arguments[0] else undefined
    @.each () ->
      $this = $ this
      if typeof action != 'undefined'
        $this.data('action', action)
      else
        $this.data('action', 'load')
      data = $this.data()
      options = $.extend {}, Checkbox.DEFAULTS, data, option
      new Checkbox $this, options
      return

  old = $.fn.checkbox
  $.fn.checkbox = Plugin
  $.fn.checkbox.Constructor = Checkbox
  $.fn.checkbox.noConflict = () ->
    $.fn.checkbox = old
    return @

  initialize = (element, action, datas) ->
    if action
      $(element).data('action', action)
    if datas
      $(element).data(datas)
    data = $(element).data()
    options = $.extend {}, Checkbox.DEFAULTS, data
    Plugin.call $(element), options

  $(window).on 'load.checkbox.data-api', (event) ->
    initialize elements, event.type

  $(document).on 'click.checkbox.data-api', toggle, (event) ->
    data = $(this).data()
    target = 'input[data-id="' + data.id + '"]'
    initialize target, event.type, data

  $(document).on 'keypress.checkbox.data-api', toggle, (event) ->
    keycode = event.keyCode
    if keycode == 32 || keycode == 13
      data = $(this).data()
      target = 'input[data-id="' + data.id + '"]'
      initialize target, 'click', data

  $(elements).on 'toggle.checkbox', (event) ->
    #console.log(event)
).call(this)
