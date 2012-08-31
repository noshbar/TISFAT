##About

**TISFAT** *(This Is Stick Figure Animation Theatre)* is a free stick figure animation tool made in Delphi.

TISFAT was designed not only to be a self-contained single executable able run on any version of Windows (or Linux/MacOS via WINE), but also to be usable by anyone, of any age, without any prior animation experience.

In some ways, TISFAT has been successful in achieving this goal, with users of all ages and skill ranges.

Users have found TISFAT's simple tweening approach to animation easy to pick up and achieve desired results quickly, without the need to animate every frame.

It has however reached the point where it is no longer sensible to continue development on TISFAT, with development focus being moved on to a sequel. But if you're looking for a quick and easy way to make animations and export them to Flash, look no further than TISFAT.

##Features

* Drawing primitives (lines, rectangles, bitmaps, polygons, text)
* Simple ready-to-use stick figures
* The ability to create any custom stick figure, with as many limbs as you choose
* Attaching bitmaps to limbs
* Drawing stick figures as curves
* Create-A-Scene, enabling creating animation through physics
* Edit and run-time onion skinning
* Tracing of a video background
* Setting alpha values of every element
* Rotation of most elements
* Export to popular formats (Animated GIF, AVI, Flash)

If you can change it, you can tween it!


##Sanity Caution
Oh TISFAT.

I keep claiming it's the worst written code on the planet... and recently someone asked if they could have the source to "play around with" (more likely it would have its way with them).

After being quite happy that I had lost the source a while back and could not prove that theory... well, curiosity got the better of me and I played with some undelete tools on an old hard-drive I had.

So here it is, the source code for my 15 minutes of fame, released under the "don't tell anyone I wrote it unless they think it's awesome" license.

I've been hesitant to release it in the past, because it is truly awful, from over a decade ago, before I could program, or even knew what the "Object" in Object-Pascal meant (which should be quite obvious).
I'd hate for this ever to hurt my chances of anyone ever employing me based on this code, so I would just like to state that I am infinitely better now.
Infinitely.
But also, keep in mind that somehow I managed to keep working on this, understanding the mess, knowing exactly where in the bazillions of lines of code things happened... only a smart person could do that. Nod nod nod. Did I write smart? I meant to type "loony".

So anyway, use this at your own peril, don't blame me if [this](http://cdn2.holytaco.com/wp-content/uploads/2011/03/378433_main.jpg) happens.
It used to compile with Delphi 6 Personal Edition, and somewhere along the line I managed to use the ... Delphi... Studio... something... I don't remember what it was called, all I remember is that it required .NET 1.1, was incredibly bloated and slow, and crashed more than TISFAT.

And some of the many things I learnt doing this:

* Never put code directly in an event handler, make it call an objects function or something
* $I including files in Delphi is not smart, it's evil, and made debugging almost impossible (back in Delphi 5 days at least)
* Delphi objects... well, you don't need to allocate memory for them in the traditional malloc() way, nor do you need to use pointers to them... instance := object.Create() works juuust fine, and is a lovely way of doing things.
* When designing a file format, do just that, design it! The amount of fudges in the TISFAT format just to cater for tiny variances in previous versions... geez.
* I quite enjoy working in my own filth.
