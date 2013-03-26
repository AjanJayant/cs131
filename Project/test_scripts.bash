export PATH=/usr/local/cs/bin:$PATH

./blake.bash
./bryant.bash
./gasol.bash
./howard.bash
./metta.bash

echo "IAMAT kiwi.cs.ucla.edu +27.5916+086.5640 `date +%s`" | telnet localhost 12590
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12590
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12591
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12592
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12593
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12594

echo "PEER howard tcp localhost 12591" | telnet localhost 12590
echo "PEER bryant tcp localhost 12592" | telnet localhost 12590
echo "PEER howard tcp localhost 12591" | telnet localhost 12593
echo "PEER bryant tcp localhost 12592" | telnet localhost 12593
echo "PEER metta tcp localhost 12594" | telnet localhost 12592

echo "IAMAT kiwi.cs.ucla.edu +27.5916+086.5640 `date +%s`" | telnet localhost 12590
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12590
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12591
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12592
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12593
echo "WHATSAT kiwi.cs.ucla.edu 100 2" | telnet localhost 12594
