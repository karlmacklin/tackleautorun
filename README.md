# Tackle's Autorun

A mod for Factorio v2.0

## Download

Either via ingame mod manager, or zipfile from this repo or from mod page at <https://mods.factorio.com/mod/tackleautorun>

## Description

This mod lets you autorun, autowalk, automove, whatever we call it.
Let your fingers rest, avoid RSI!

You start by walking and then press a dedicated button to latch the movement (default mouse button 5).
You then cancel the automatic movement by either moving in any direction, or by pressing a dedicated 'stop move' key (default mouse button 4)

You might want to rebind the buttons to something that suits you better. Also note that if you have the map view open and use the movement keys you will cancel out the autorunning. Pan the map with the mouse in that case instead.

If you have any issues please raise them on github.

- NOTE: This does not work well in multiplayer, as the global state for this mod is affecting player movement direction instead of you pressing keys. It technically works in multiplayer, but the latency induces weird choppy movement so it's not a smooth experience.
- NOTE: After 0.17 update Factorio has default binds to both buttons mouse 4 and 5. This mod collides on that bind, so either figure out something suitable for yourself or do what I did - unbind the default game binds on those buttons. This mod consumes the input for any binds that collide, so rebind either this mods keys if you want to keep default binds, or change the defaults.
- NOTE: For the 2.0 update it now works fine to keep running with the map open.
- NOTE: Also for 2.0 the explicit cancelling toggle defaults to true instead of false.
