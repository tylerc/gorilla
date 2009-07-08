Gorilla
=======

Using
-----

To get an idea of what Gorilla can do run this command:
ruby bug3.rb
or this if you want to be specific ('-f' is the file, '-p' is the port to start the server on)
ruby bug3.rb -f BUGS.tdb -p 8000

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

If you would like to delete a property click the 'Edit Properties' link and use the delete button on the page it takes you to.

After you have created your types, you can start creating your database entries. Just click the link that says 'New X' and you can create your entries.

After you have created a few entries, you should mess around with the filters. They're harder to explain than if you simply learn by using them.

If you would like to change the style sheet for Gorilla, change style.css, or if you would like to change the style only for your database, create a file with the same name as your ID field with the .css extension. Add your custom CSS into that file.

Purpose
-------

Gorilla is meant to be simple, and not do everything. Its focus is not speed, but simplicity and flexibility. Gorilla only scales for personal and small team use (so don't try to make the next wikipedia with it). See "Speed" below for more information.

Notice
------

Gorilla is decently stable, but is missing some features. All it is currently suitable for is a bug tracker, TODO list, and other simpler things. The goal for version 1.0 is to have it be able to be used as a wiki.

Speed
-----

Gorilla runs very quickly for all the practical use I've gotten out of it. But I decided to create more in-depth and stressful tests (see stress.rb and test.rb if you would like to run them yourself). 

What will interest most people is the usability benchmarks at the bottom, which shows what the user experiences as the database grows.

Parsing Benchmarks (averaged over 3 tests):
1,000 database entries: 0.04 seconds
10,000 database entries: 0.42 seconds
100,000 database entries: 4.55 seconds
1,000,000 database entries: 59.26 seconds
10,000,000 database entries: UNKNOWN (Ruby segfaults)
I should stop now...

Size Benchmarks (each line in the database is about the same which is unrealistic, but the statistics are still interesting):
1,000 database entries: 44.6 KB (45641 bytes)
10,000 database entries: 452.6 KB (463476 bytes)
100,000 database entries: 4.5 MB (4737312 bytes)
1,000,000 database entries: 46.1 MB (48371472 bytes)
10,000,000 database entries: 470.9 MB (493729964 bytes)

Usuability benchmarks:
1,000 database entries: The index listing of everything takes the longest. Everything else runs at top speed

10,000 database entries: Index listing of everything is still the slowest, to the point of becoming almost unusable. Everything else is noticeably slower

100,000 database entries: Gorilla becomes unuseable and uses 100% CPU, the process has to manually be killed to end the program (but, as this was originally designed for a bug database, I would hope you don't have 100,000 bugs!)
