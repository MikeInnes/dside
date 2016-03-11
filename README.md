# dside

Currently there's no good open-source web spreadsheet, and there's no good way to view a large amount of data without crashing your computer. This project is a (very early) attempt to rectify those issues.

dside implements a web spreadsheet component which lazily loads values from a given model, makign it able to handle arbitrary amounts of data without sacrificing on buttery-smooth scrolling (though it could probably be optimised further). Variable-width columns/rows and markers (for overlays like selections and images) are still TODO.

Live demo available on this projects [GitHub Pages](http://mikeinnes.github.io/dside/main.html).
