Normal input wiht no arguments in the command line:

Trial 1:
time gzip <$input >gzip.gz

real 0m3.640s
user 0m3.050s
sys  0m0.054s

Trial 1:
time pigz <$input >pigz.gz

real 0m0.994s
user 0m5.674s
sys  0m0.101s

Trial 1:
time java JavaPigz <$input >JavaPigz.gz

real 0m1.177s
user 0m5.064s
sys  0m0.240s
-------------------------------------------------
Trial 2:
time gzip <$input >gzip.gz

real 0m3.571s
user 0m3.050s
sys  0m0.067s

Trial 2:
time pigz <$input >pigz.gz

real 0m0.977s
user 0m5.744s
sys  0m0.140s

Trial 2:
time java JavaPigz <$input >JavaPigz.gz

real 0m1.179s
user 0m5.226s
sys  0m0.256s
-------------------------------------------------
Trial 3:
time gzip <$input >gzip.gz

real 0m3.283s
user 0m3.042s
sys  0m0.048s

Trial 3:
time pigz <$input >pigz.gz

real 0m0.990s
user 0m5.662s
sys  0m0.125s

Trial 3:
time java JavaPigz <$input >JavaPigz.gz

real 0m1.228s
user 0m5.189s
sys  0m0.245s
-------------------------------------------------
Compression Ratio:

input file size: 62629892 bytes
gzip.gz: 20859530 bytes
compression ratio: 3.0025

input file size: 62629892 bytes
pigz.gz: 20804219 bytes
compression ratio: 3.0104

input file size: 62629892 bytes
JavaPigz.gz: 21231936 bytes
compression ratio: 2.9497
------------------------------------------------------------------------------
The three trials for gzip, pigz, and JavaPigz produced the data that is 
provided above. As can be seen, when there are no arguments in the command 
line then JavaPigz does an efficient job of compressing the input file. Pigz 
still has a better compression ratio and is faster when it comes to 
compressing the input file but this is because the code for pigz is written 
in C. My implementation of JavaPigz compresses the file at a good speed which 
is slightly short of that of pigz, and thus I feel it does a good job. As for 
the compression ratio of JavaPigz, it foes a good job compressing the input 
file since the file size of JavaPigz.gz is 427 KiB bigger than pigz.gz, and 
the file size of JavaPigz.gz is 372 KiB bigger than gzip.gz. Thus the 
compression done by JavaPigz is really good.
------------------------------------------------------------------------------
Output of pigz -d <JavaPigz.gz | cmp - $input was nothing.
This was what was required thus the code is working fine.
------------------------------------------------------------------------------
With -i in the input:

Trial 1:
time pigz -i <$input >pigz.gz

real 0m0.942s
user 0m5.157s
sys  0m0.143s

Trial 1:
time java JavaPigz -i <$input >JavaPigz.gz

real 0m1.237s
user 0m5.261s
sys  0m0.257s
-------------------------------------------------
Trial 2:
time pigz -i <$input >pigz.gz

real 0m0.919s
user 0m5.263s
sys  0m0.137s

Trial 2:
time java JavaPigz -i <$input >JavaPigz.gz

real 0m1.138s
user 0m5.188s
sys  0m0.216s
-------------------------------------------------
Trial 3:
time pigz -i <$input >pigz.gz

real 0m0.927s
user 0m5.228s
sys  0m0.137s

Trial 3:
time java JavaPigz -i <$input >JavaPigz.gz

real 0m1.216s
user 0m5.218s
sys  0m0.255s
------------------------------------------------------------------------------
Compression ratio for command line with -i:

input file size: 62629892 bytes
gzip.gz: 21214783 bytes
compression ratio: 2.9522

input file size: 62629892 bytes
JavaPigz.gz: 21231936 bytes
compression ratio: 2.9497
------------------------------------------------------------------------------
As can be seen from the data that was provided with the -i input in the 
command line, JavaPigz and pigz produced compressed files of almost the same 
size. The compression ratios are testimony to this since they are also almost 
the same.
------------------------------------------------------------------------------
For input with -p 10:

time pigz -p 10 <$input >pigz.gz

real 0m0.995s
user 0m4.723s
sys  0m0.142s

time java JavaPigz -p 10 <$input >JavaPigz.gz

real 0m1.285s
user 0m4.985s
sys  0m0.377s

------------------------------------------------------------------------------
For input with -p 100:

time pigz -p 100 <$input >pigz.gz

real 0m1.060s
user 0m5.312s
sys  0m0.214s

time java JavaPigz -p 100 <$input >JavaPigz.gz

real 0m1.175s
user 0m5.199s
sys  0m0.307s
------------------------------------------------------------------------------
For input with -p 1000:

time pigz -p 1000 <$input >pigz.gz

real 0m0.955s
user 0m5.117s
sys  0m0.374s

time java JavaPigz -p 1000 <$input >JavaPigz.gz

real 0m1.160s
user 0m5.199s
sys  0m0.471s
------------------------------------------------------------------------------
For input with -p 10000:

time pigz -p 10000 <$input >pigz.gz

real 0m1.208s
user 0m5.396s
sys  0m0.448s

time java JavaPigz -p 10000 <$input >JavaPigz.gz

real 0m1.192s
user 0m5.236s
sys  0m0.352s
------------------------------------------------------------------------------
As can be seen from the data above in which the command line included an input 
for processors, the real speed tends to increase with the number of processors 
up till a certain point after which it slows down a little bit because there 
is tolerance point up till which a certain number of threads can speed things 
up. As for the compression ratio, it remains the same as that in the first 
part of this report in which there were no extra arugments in the command line.
------------------------------------------------------------------------------
For my project, I was not able to implement the primer. I looked into the GZIP 
output stream and into the Deflator class. I tried working with the set 
dictionary but I was not able to figure out the primer. The primer would have 
definitely sped up the compressing of the JavaPigz. Everything else, though, 
was implemented. Even the -i was implemented, even though, in the case of my 
project, it does nothing since there is no primer. I still do no completely 
understand how to implement the primer.
------------------------------------------------------------------------------
As the file size of the input grows, the compression would be slowed down a 
little bit since in my code, I have implemented an array of threads which can 
never become greater than the number of processors. Otherwise, compression 
would still work fine with larger files, just a little bit slower. As for a 
large number of threads, there is only a certain point up to which more 
threads would make functionality faster. After that, it would not be as good 
since a lot of threads would have to wait for the threads in top of my thread 
array list to finish.

The method that would work best for a large input would include having more 
processors and running the code with the primer (as in no -i). This is because 
the primer would help locate patterns in compiling and this would make 
compilation much faster. 