--- here is the excerpt from original readme from 2003:

Melchior 1.00 beta 6
Server Monitoring Tool

What is Melchior?
=================
Melchior was coded for my personal use to quickly see what services are 
up/down on various servers in our corporate network. It serves as an 
overall accessibility status reporter for local servers. It works on any 
server though. So you can check if your favorite web server is up or 
down.

Beta?
=====
Yes several features (like explore network) are disabled since they 
do not work properly yet. The software is still very much beta though 
it's been tested a lot by myself.

There will be status histograms, several down alert methods, logging 
and network explore features in planned final version. (If I ever have 
time)

--- now back to 2009:

Apparently I didn't have time :)

Now, the source code
====================
Due to popular demand, I decided to release the source code to public. 
As a disclaimer, I must state that I'm really unhappy with this code. 
I think it's badly designed and coded. For instance, the code is 
unnecessarily CPU intensive and multithreaded operations are not very 
reliable despite the use of locked lists. I don't like the object 
hierarchy in service implementations either. Lack of comments makes it 
hard to read it. The compiled version crashed on Windows 7 and I'm not 
sure if it's just a one off thing or a problem with my code. 

I don't have a running Delphi available for my use so I'm not sure if 
it'll even compile. 

As I said, Melchior isn't perfect code. I hesitated to release it 
because I didn't want to provide false directions to new beginners. But 
later I thought it also had a lot of useful stuff as well. I believe 
releasing this in its current shape is much better than not doing it at 
all. At least, it could be a good example for "how not to write a 
network monitor" :) 

Anyway, this is public domain now. Do whatever you want with it.

Sedat "ssg" Kapanoglu
ssg@sourtimes.org
