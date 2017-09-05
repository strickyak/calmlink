# calmlink
Configs for using svxlink to connect an EchoLink station by RF to an existing repeater, calmly, without extra noise.

Svxlink is very modular and flexible, but seems to be designed primarily for the case
where Svxlink is your repeater controller.  For instance,
it supports DTMF commands sent by users over RF, and has voice responses to such,
and other voice announcements about connections & disconnections, module
activations & deactivations, etc.

In my case, we have an existing repeater N6NFI/R, and it has a repeater controller already.
I want to connect my echolink station W6REK-R by RF to N6NFI/R (as a repeater user),
but no human operators will be talking by RF to my echolink station.
They'll only connect to it via the internet.

So I want to disable DTMF commands and all kinds of over-the-air announcements,
except for the legally required ID after the echolink transmitter is used.

I call this "calmlink", since it doesn't make any noise on the repeater
except for the voices of EchoLink stations using the repeater, and the
legally required ID, which is only in Morse Code (MCW).
No robot voice will come from the calmlink station through the repeater.

## ABOUT THE FILES:

* `*.conf` -- config files, to be customized & copied to /usr/local/calmlink/
* `*.tcl` -- config scripts, to be customized & copied to /usr/local/calmlink/
* `push-demo.bash` -- a prototype script (for you to copy and edit) to customize and copy the above files.
* `run.sh` -- a shell loop to run svxlink and keep its output as log files.

## HOW TO USE

You can "git clone" the latest svxlink from https://github.com/sm0svx/svxlink
or my hacked version of it from https://github.com/strickyak/svxlink
and build it (according to its INSTALL instructions).   After you run
"make install" on it, you can install these configs alongside it
(using your edited copy of `push-demo.bash`) and run with the calmlink.conf configuration.
