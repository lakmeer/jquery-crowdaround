
Crowdaround =

    setTransformOffset : (node, x, y) ->
        translate = "translate(#{x}px, #{y}px)"
        node.e.css({
           "-webkit-transform" : translate
           "-moz-transform"    : translate
           "-ms-transform"     : translate
           "-o-transform"      : translate
           "transform"         : translate
        })


    generateMetanodes : ($jqc) ->
        nodes = []
        $jqc.each ->
            $this = $(this)
            nodes.push(
                x : $this.offset().left + $this.width()  / 2
                y : $this.offset().top  + $this.height() / 2
                e : $this
                a : false
            )
        return nodes


    hypotenuse : (x, y) ->
        h = Math.sqrt(x*x + y*y)
        if isNaN h then return 0
        return h


    shape : (start, end, curr) ->
        x = curr - start
        y = end  - start
        i = (x*x) / (y*y)
        return i * y + start


    isAndroid : ->
        if navigator.userAgent.match(/Android/i)
            true
        else
            false



Crowdaround.computeOffset = (n, px, py, d, a) ->

    dx = n.x - px
    dy = n.y - py
    h  = Crowdaround.hypotenuse dx, dy

    if h < d
        s = -1 * (d - Crowdaround.shape(0, d, h)) / d * (a / 200)
        return { x :s*dx, y : s*dy }
    else
        return { x : 0, y : 0 }






$.fn.crowdAround = (options) ->

    # Extend defaults

    settings =
        touch    : true
        android  : false
        distance : 150
        strength : 20
    settings[k] = v for k, v of options


    # Effect is really slow on android browser ~2.2 - 2.3, so is disabled
    # by default. Add { android : true } to config to explicitly enable it.

    unless settings.android is on
        return this if Crowdaround.isAndroid()


    #
    # INIT
    #

    nodes = []

    move    = Crowdaround.setTransformOffset
    compute = Crowdaround.computeOffset

    init  = => nodes = Crowdaround.generateMetanodes(this)

    do init


    #
    # EVENT HANDLERS
    #

    # Handler - takes x|y coordinates from pointing device events and moves elements

    handler = (px, py) ->

        d  = settings.distance
        a  = settings.strength

        for n in nodes
            offset = compute(n, px, py, d, a)
            move n, offset.x, offset.y


    # Mouse interface to event handler

    mouseHandler = (event) -> handler(event.pageX, event.pageY)


    # Touch interface to event handler

    touchHandler = (event) ->
        event.preventDefault()
        touch = event.originalEvent.touches[0]
        handler touch.pageX, touch.pageY


    #
    # BIND EVENTS
    #

    $(document).on 'mousemove', mouseHandler

    # Because we're going to be preventDefault'ing the touch event, the user can't scroll
    # when crowding is happening. To combat this, scope the event capture to the collection's
    # parent container, so scrolling is still possible when the event begins outside it. Make
    # sure the parent container is clearfix'd or has height. If you don't care about touch,
    # set { touch : false } in the config.

    unless settings.touch is off
        @first().parent().on 'touchmove', touchHandler # Get collection's parent to re touchstart
        $(document).on       'touchstop', (event) -> move(n, 0, 0) for n in nodes


    # Reset node position metadata on page resize

    $(window).on 'resize', init



    # jQuery chaining

    return this

