CrowdAround
===========

Nifty magnetic mouseover effect for grid-arranged lists of things.

Demo available: http://lakmeer.github.com/jquery-crowdaround

Uses CSS transforms to increase performance and maintain page flow. Supports touch events.
Degrades back to static layout gracefully.


### Requires:

* jQuery 1.7  (but only because of $().on, feel free to swap '.on' for '.bind' to use with old versions)
* Browser support for css transform:translate.


Usage
-----

- Include crowdaround.min.

- `$(yourCollection).crowdAround(options);`


### Options

#### distance (150)

Attractor distance. Radius in pixels inside which elemetns will respond to the cursor


#### strength (20)

Excursion of elements being attracted. Tried hard to tie this number to some kind of concrete units,
but the best I can do is to say that reasonable values are between 0-100.


#### touch (true)

Enables touch event listeners. Switch off if you don't need them with `false`


#### android (false)

Effect can be slow on Android devices in browser version ~2.2-2.3, particularly if there are images 
in the grid. For this readon Android devices are excluded by default. Set this to `true` to explicitly
allow it.


