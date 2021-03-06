Gorilla
=======

Purpose
-------

Gorilla is a simple database viewer and editor. It uses a custom database, that can be read and written by hand, but it is easier to write with Gorilla.

Gorilla is meant to be simple, and not do everything. Its focus is not speed, but simplicity and flexibility. Gorilla only scales for personal and small team use (so don't try to make the next wikipedia with it). See "Speed" below for more information.

Requirements
------------

To run this, all you should need is Ruby and a web browser! (http://ruby-lang.org )
By default Gorilla uses WEBrick (which comes with Ruby), but Gorilla also runs on mongrel, and you can install it with:
gem install mongrel

You don't have to, but we reccomend it!

Developers
----------

If you would like to help develop Gorilla (or hack on it for your own reasons) see DEVELOPERS.txt for information on the workings of Gorilla.

Using
-----

To get an idea of what Gorilla can do run this command:
ruby gorilla.rb
or this if you want to be specific ('-f' is the file, '-p' is the port to start the server on)
ruby gorilla.rb -f BUGS/BUGS.tdb -p 8000

If you navigate your web browser to localhost:8000 you should be able to see Gorilla in action!

You can create your own database just by specifying a file that doesn't exist or an empty file. Be sure the file name ends with .tdb (recommended) or .yml as those are the two supported types.

When you visit the page it will be almost empty, with just a few links.
To get started:
1. Click on the "New Property" link
2. Enter the name of the items you will be dealing with in name (Bugs, articles, etc.)
3. Set the type to "ID"
4. Click create property.

You should be redirected to the index and see the "Property Created" message

Now you can start defining other properties for your database.
Types explained:
ID - What your database is dealing with (TODOs, Bugs, articles, etc.) only create one ID property
STRING - Short strings/text (names, version numbers, contexts, etc.)
LSTRING - Long strings/text (descriptions, the text of articles, etc.)
CHOICE - Set choices (on or off, high medium or low, etc.) Place your choices in the 'Additional Data' field, separated by hyphens. Ex: Low-Medium-High

If you would like to delete or edit a property click the 'Edit Properties' link. For deletion, simply click the "Delete Property" link. If you want to edit a property you can change the name and its type (or choices if it is of the CHOICE type). Press "Save" to save your changes.

To rearrange properties, click the "Rearrange properties" link and change the numbers according to what you would like.

After you have created your types, you can start creating your database entries. Just click the link that says 'New X' and you can create your entries.

After you have created a few entries, you should mess around with the filters. They're harder to explain than if you simply learn by using them.

If you would like to change the global style sheet for Gorilla, change style.css, or if you would like to change the style only for your database, create a file with the same name as your database with the .css extension (i.e. BUGS.tdb.css). Add your custom CSS into that file.

If you would like to have custom code for your database create a file with the same name as your database with the .rb extension (i.e. BUGS.tdb.rb). It is in this file you can write your custom code (in Ruby).

By default gorilla uses Mongrel if you have it installed. If you would like to force webrick to be used, simply pass -w to gorilla. For example:
ruby gorilla.rb -f WIKI/WIKI.tdb -w

Speed
-----

Gorilla runs very quickly for all the practical use I've gotten out of it. But I decided to create more in-depth and stressful tests (see test/stress.rb and test/test.rb if you would like to run them yourself). 

What will interest most people is the usability benchmarks at the bottom, which shows what the user experiences as the database grows.

Saving Benchmarks:
1,000 database entries: 0.16 seconds
10,000 database entries: 15.37 seconds
100,000 database entries: Takes to long... (so we fake it for other benchmarks)

Parsing Benchmarks:
1,000 database entries: 0.06 seconds
10,000 database entries: 0.7 seconds
100,000 database entries: 13.81 seconds

Size Benchmarks (each line in the database is about the same which is unrealistic, but the statistics are still interesting):
1,000 database entries: 54.9 KB (56181 bytes)
10,000 database entries: 556.8 KB (570181 bytes)
100,000 database entries: 5.8 MB (6089076 bytes)

Usuability benchmarks:
1,000 database entries: The index listing of everything is a little slow. Everything else runs at top speed

10,000 database entries: Index listing of everything is still the slowest, to the point of becoming almost unusable. Everything else is noticeably slower

100,000 database entries: Gorilla becomes unuseable and uses 100% CPU, the process has to manually be killed to end the program (but, as this was originally designed for a bug database, I would hope you don't have 100,000 bugs!)

License
-------

Copyright (c) 2009 Tyler J Church

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
