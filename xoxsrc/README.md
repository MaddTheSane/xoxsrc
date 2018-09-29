Welcome to Xox!
===
(This document is primarily for programmers.)

Xox is a game engine designed to help programmers create sprite based arcade games.  Xox takes care of the basics of sprite movement, animation, and collision detection, so many styles of games can be implemented easily.  Since Xox is object oriented, the classes provided in Xox can be reused; games are created by making slight modifications to the animation or tracking behavior of the supplied objects.  A primary goal in the creation of Xox was that games created under it would run as quickly and smoothly as possible.  Xox has optimizations to minimize sprite drawing and flushing and maximize the efficiency of collision detection, which are often the primary performance bottlenecks of arcade games.  I hope you find Xox to be an easy way to create fast, fun games!

If you have any comments or bug reports, you can reach me at:
	Xox@NeXT.com

I am also interested in seeing any games you create.
Although I am employed by NeXT Computer, Xox should not be construed as a product of NeXT. 

# Copying, Usage, & Warranty

Permission is granted to freely redistribute the Xox application and source code, and to use fragments of this code in your own applications if you find them to be useful.  The Xox application and code come with no warranty of any kind, and the user assumes all responsibility for its use.  I would prefer that you distribute the source code to any game modules you write, and that you make available source code to any application which is largely derivative of Xox.

# Features

Xox is designed to implement 2 dimensional sprite-based games, which means it should be good for implementing the old classic arcade-style games.  It is less useful for creating full-scrolling games with a solid background and 3 dimensional simulations.  (There's nothing that keeps you from doing such games; however, Xox wasn't designed for such games and can't optimize the display of such games, although the collision detection could still be useful in the 2-D case.)

One reason that Xox games can be quick is that it attempts to minimize the amount of drawing and flushing that can be done.  Accordingly, graphics is Xox can be buffered or unbuffered, and you can mix the 2 in a single game.  Objects can be drawn into a static background buffer (where they are only drawn once), or they can be animated into an off-screen buffer (where they can be erased and redrawn without visible flicker) or they can be drawn directly onto the screen, which is the fastest case and can flicker but is sometimes acceptable for small objects or odd effects.  Drawing done into the buffer is coalesced so that a minimum amount of drawing is performed to bring the contents of the buffer up onto the screen.

Xox is also able to perform fairly arbitrary collision detection.  The algorithm used definitely tends towards quick and dirty rather than canonically accurate; however, in use it has proven to be flexible and usually better than people's ability to detect where it is wrong.  (In arcade games, perception is everything and speed is of the essence!)  Every object has a shape, be it a rectangle, circle, array of rectangles, or a list of lines, which should be good enough to describe most sprites.  The collision routine knows how to either collide each shape against another or decompose a shape into something it knows how to collide.

# Concepts

A game under Xox is defined as a scenario that describes to the engine how the game is to be created.  The engine loads the scenario, then queries it (via the protocol defined in scenario.h) as to what objects are required by the specific game.  The game objects, which typically resemble sprites, are customized subclasses of Actor, which is a class that implements generic sprite behavior of drawing, movement, animation, and collision detection.  An actor subclass may specify a custom image, animation rate, etc, and it may extend the provided methods to provide (for example) custom movement behavior in order to follow another object.

The engine initially queries the scenario on how to create level 1.  The concept of a level can be very abstract; a game may only have one level.  The scenario responds by telling the Actor Manager that it would like so many objects of various Actor subclasses for the current level.  The Actor Manager instantiates or reuses the appropriate actors and sets them into motion.  Since Actors know how to do their own thing, the scenario need not be directly involved with game management.  However, the scenario can be informed of each animation step, which it may find useful to create additional actors at specified times.  Furthermore, the scenario is informed of every key press, so it can take game-specific action (like forwarding the keys to the appropriate actors) and the scenario is informed of the employment and retirement of every actor (useful, for example, for tracking object deaths as a result of collisions.)

Actors get reused rather than being allocated and freed.  This is because system memory allocation tends to be too slow for the requirements of an arcade game, where sprites may come and go at a rapid rate.  Thus, the Actor class contains an implementation that allows class variables, and each subclass of Actor tracks all of the instances of itself.  When actors are required, the Actor Manager queries the appropriate class to see if the class has any unemployed instances.  If so, they are reused; otherwise they are instantiated as required.

Besides the Actor Manager, there are managers for sound, the display (the screen image) and the cache used for double-buffering.  The use of the Sound Manager fairly obvious; it provides sound mixing for the game.  The Display Manager is used by the engine to track unbuffered objects.  The function of the Cache Manager may be more interesting to game programmers.  It potentially keeps two images, which are its virgin buffer and cache.  The virgin buffer contains an image that changes infrequently and is used to erase images drawn into the cache.  The virgin buffer is primarily useful for static background images, though with a little hackery you can draw non-moving actors into the virgin buffer to save yourself the overhead of erasing and drawing them every frame.  (This technique costs more than it saves if the object is moving.)  The actual buffered game animation happens in the cache; the cache is cleared out before every frame (taking the image from the virgin buffer if there is one), then actors are drawn into the cache.  Next, the cache manager coalesces the touched regions of the cache in order to minimize drawing, and regions from the cache are brought on-screen to simultaneously erase the old frame and draw the new one without flicker.

An animation step goes roughly as follows:

* Erase the old animation frame, bringing the cache back to virgin status.
* Move all actors without drawing.
* Detect collisions.
* Notify actors of collisions, getting consent to collide.
* Collide actors as appropriate.
* Living actors schedule drawing to be done.
* Drawing is actually performed.

This may seem a bit labyrinthine, but it provides a lot of flexibility; all actors know of collisions before they happen, so an actor can store pre-collision info about its nemesis, if useful.  All collisions are done before any drawing is scheduled, so an actor can modify its own behavior or request that its nemesis alter its without problems.

Collision detection can be very expensive; it tends to be an n-squared algorithm in the simple case.  For example, colliding 100 objects amongst themselves requires 5000 tests.  The Xox engine provides a couple of collision paradigms; first the simple case where every object is collided against every other.  Secondly, it can provide a good versus evil paradigm, where actors are separated into lists based on alliance, and only actors within a specified distance (the global collisionDistance) of the universe center are added to the lists.  This technique can eliminate a bunch of uninteresting collision cases, keeping you lower on the n-squared curve.  If neither of these paradigms is appropriate, the scenario can specify a collision delegate and perform all collisions itself.

Xox can create a scrolling world by translating the global x and y values of the center of the universe.  These values are kept in the `gx` and `gy` global variables.  The distance from the corner of the main view to the center of the screen is kept in the xOffset and yOffset globals.    These values can be useful for bouncing an object that gets to the edge of the screen or "wrapping" and object that gets too far from the center of the universe; methods to do this are provided in the Actor class.  Xox can be effective in creating a scrolling space game, as demonstrated by the Xoxeroids game, but games with solid backgrounds will tend to scroll slowly, since the entire screen will need to be flushed for each frame.

# Collisions

If an actor has a complex collision shape, the first time in any given frame that an object collides with its bounding box it will be asked to construct its complex shape.  This shape is an array of lines, and it should be dense enough that most objects inside the actor will collide with at least one of the lines.  The default collision routine leaves behind some info (in an actor's collisionReason and collisionThing instance variables) that may be useful in ascertaining why a collision was detected.  Though this information may be helpful, it generally isn't enough to do accurate bouncing of objects for example.  Sigh.  Great collision resolution is beyond the scope of Xox, though there is an Actor method (`bounceOff:`) that may be useful for bouncing some objects off of a stationary rectangle.

# Namespace Collisions

The possibility for namespace collisions exists in Xox.  To avoid these, you should put a prefix in front of all names of your classes, global variables, images, sounds, and functions.  For example, if your name is Ben Xylophone, you might consider naming your spaceship class BXShip to avoid a collision with the Ship class provided in Xox.  Namespace collisions may prevent games from loading, or they could mean that a game could get images from other objects.  Prefixing your names is (unfortunately) the only way to prevent this from happening.

# Time in Xox

Xox keeps a millisecond timer value in the timeInMS global.  Xox also maintains a variable timeScale, which is the time between iterations compared to a theoretical "perfect" value where 10 frames per second would yield a timeScale of 1.0.  All motion should be multiplied by timeScale to ensure games play at the same rate on fast or slow machines.  timeScale will never exceed maxTimeScale, which can be set by each scenario (it defaults to 1.5) in an attempt to ensure that objects won't fly through each other without colliding. 

# Key Timers

Xox provides a a class called KeyTimer which can be useful in tracking how long keys were down for.  Without a key timer timing a key, you can really only sample the state of a key, which doesn't give you very good responsiveness.  A key timer gives you a value for how long the key was down as a percentage of a tenth of a second theoretical frame. 

# Creating Rotated Images

If you find yourself with a need for several frames of a rotated image (like the Xoxeroids spaceship, for example) you may find Linus' ShipBuilder program useful.  It takes a large TIFF or EPS image, rotates, scales, and anti-aliases it down and dumps the resulting frames into an image useful to Xox.  Many thanks to Linus for the useful utility.

# The Example Games

I provide a few example games that were useful for testing Xox.  Here's why they might be interesting:

## Xoxeriods
The Ship demonstrates how to translate the universe.  The other actors wrap when they get too far from the ship.  The RotBox class demonstrates the construction of complex weird collision shapes.  The RocketMatrix class demonstrates the use of an ActorMatrix, which can be used to tie objects together in a rectangular grid, which can optimize collision detection.  The Rocket class exhibits some pretty neat tracking behavior.  The Ship class demonstrates the use of key timers to guess how much rotation and thrust needs to be applied.

## SpaxeWars
This is a very simple example that distributes keyboard events to 2 different actors.  Has a simple algorithm for simulating orbits.

## Boink
Demonstrates the use of a background.  Also, the brick in the center draws itself into the virgin buffer so that it doesn't need to be drawn and erased every frame.  The balls also hopefully bounce off the center brick in a believable fashion.  Demonstrates how a scenario can constrain window sizing.

# Still To Do

(These are things that I intend to test or do whenever I find time...): 

* Make .Xox bundles click to load
* Use dot products to calculate bounce vectors off rotated boxes.
(I currently use (slow) transcendentals up the wazoo in this (rare) case)
* Make Xoxeroid level restart after ship dead for a while.
I currently wait for explosions to go away, which is a poor assumption
* Test rect-array collisions.
never used or tested!
* Should there be an option to free actors and sounds?
* since window must be retained, support for multiple cache managers should work.  I need to test…
* need a method for pre-instantiating x number of actors
* need pause indication


# Bugs
game writers must know a lot about the default implementations to be aware of their responsibilities when modifying behavior

direct access to instance variables makes games fast, but may make distributing games difficult.

# document history
940213 sam - created
