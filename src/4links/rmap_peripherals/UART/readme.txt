readme for UART to RMAP (Initiator) Bridge IP.

UART Tranmission order (Bytes)

0 			- Target Logical Address : > 31
1 			- Target Memory Address : 0 - 255
2 			- Instruction : 0th bit, set '1' for Write, set '0' for Read, 1st bit set '1' for increment address, set '0' for static address
3 			- Payload Size : Payload size of Data to Write/Read From Target
4 to 4+256 		- Byte Payload Data : if Write, attach payload data here. 


Only replies containing data will be pushed to UART TX interface. Byte order is:

0 			- Target logical Address
1 			- Data Length
2 to 2+256		- Reply Data


FoR UART-Target IP:

Target Memory Address bits (7 downto 6) are IO address bits where:

0b00 -> Target UART Tx (16 Byte)			
0b01 -> Target Memory (16 Byte)
0b10 -> Target LEDs   (1 Byte)
0b11 -> Target GPIO   (1 Byte)

When using the IPs together, never perform a read/write LARGER than 16 bytes.

