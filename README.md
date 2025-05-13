# Async_fifo
Asynchronous FIFO (first_in first_out)

**design features**

designed an async fifo which is usefull to tackle the clock domain crossing issues.

used an extra bit for read and write pointers for the detection of full and empty signals appropriately.

**further improvements **

-- need to synchronize the read pointer to write clock domain and read pointer to write clock domain using 2 flop synchroniser 

-- before passing the pointers to flop synchroniser need to convert then to greycode so that there will be minimal changes in the siganl 
 
