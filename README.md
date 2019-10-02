Broker: ClassicTracking
=======================

Simple minimap tracking display with tracking selection in its tooltip.

**Requires a LibDataBroker [Display Addon][], like [StatBlockCore][] or
[ElvUI][].**

Also known as:

- Broker\_ClassicTracking
- Broker: Classic Tracking

Features
--------

- Displays the currently active minimap tracking
- Mouse-over tooltip to select a different tracking option
- Attempts to restore tracking after being resurrected

Notes
-----

- There is no configuration (since there is nothing to configure)
- Restoring tracking after being resurrected is on a best-effort basis,
  there are a number of reasons why this may fail, like reloading your
  UI or the Blizzard event timing being hugely off
- Looks (icon display, font and the like) depend on the
  [Display Addon][] you use

[Display Addon]: https://github.com/tekkub/libdatabroker-1-1/wiki/addons-using-ldb
[StatBlockCore]: https://www.curseforge.com/wow/addons/stat-block-core
[ElvUI]: https://www.tukui.org/classic-addons.php?id=2
