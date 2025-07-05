# 16-Point Radix-2 DIT FFT 
16-point Radix-2 (DIT) FFT using a single butterfly engine with intra-stage pipelining and FIFO-based buffering. 
The architecture processes one stage at a time, with each stage fully pipelined for high throughput. 
Two 16-depth FIFOs are used to store intermediate results between the 3 computation stages.
