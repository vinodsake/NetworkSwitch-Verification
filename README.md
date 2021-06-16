# NetworkSwitch-Verification
Design and Verify a Network Switch using UVM Testbench

Network Switch with 1 input port and 4 output ports
Header - 32 bit (8 bit srcid, 8 bit payload length, rest garbage for now)
payload - 32 bit array (0-255)

Port B doesnt have a id, which means srcid's other than A,B,C go to D
							 ___________
							|           |
Input port -->|           |--> A
							|           |
							|           |--> B
							|           |
							|           |--> C
							|           |
							|           |--> D
							 ___________
           
-> Design Adds payload lenghth to the header and sends to the respective o/p port
-> All ports can route packets inorder

Next Steps: 
-> Adding more I/p ports
-> Adding outof order packets routing
