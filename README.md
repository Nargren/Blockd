Blockd
======

Block-d is a script that can block websites of your choice on the network level. 
It looks for specific words going through your network interface and if it finds the word, a reset packet is sent and the connection is terminated.

Virtually countless websites can be blocked at the same time, it is likely that only your CPU's capacity is the real limit.

There are some websites pre-set in the code that you can run fast, but you can also build an own list or make a temporary list.

Perfect if you want to make sure that noone is following you and you don't want to leave any tracks.

The script uses ngrep, you can install it by
apt-get install ngrep