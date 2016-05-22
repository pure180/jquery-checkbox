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

      $('#text').text(@value)

      if @options.action
        @[@options.action]()

    Checkbox.DEFAULTS =
      toggle:     'checkbox'
      wrap:       'label'
      htmlClone:  '<ins />'
      class:      'checkbox-clone'

    load: () ->
      @randomID = @options.toggle + '_' + Math.floor((Math.random() * 1000000) + 10)

      if @element[0].style.display != 'none' || !@element.is '.hidden'
        @initialize()

    click: () ->
      if @value == true
        @uncheck()
      else if @value == false
        @activate()

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
      $( @options.htmlClone, cloneProperties ).insertAfter @element

      console.log @parent

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

    uncheck: () ->
      @element.removeAttr 'checked'
      @value = false
      if @element.val == 'on' || @element.val == 'off'
        @element.val('off')
      else
        @element.val(0)
      $('#' + @options.id).removeClass('checked')


  Plugin = (option) ->
    @.each () ->
      $this = $ this
      options = $.extend {}, Checkbox.DEFAULTS, option
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

).call(this)
