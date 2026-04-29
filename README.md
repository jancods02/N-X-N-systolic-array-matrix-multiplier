# N-X-N-systolic-array-matrix-multiplier
The repository has the design of an Output Stationary Systolic Array Matrix multiplication done during my masters course.
Matrix multiplication is a fundamental operation widely used in applications such as digital signal processing, machine learning, and scientific computing. Traditional architectures suffer from high latency due to sequential computation. To overcome this limitation, a systolic array architecture is employed, which enables parallel processing and efficient data reuse.

<img width="944" height="512" alt="image" src="https://github.com/user-attachments/assets/4f8a7131-1294-4a9b-a4b6-3c4280e61620" />
•	The Above diagram represents a 8 X 8 Systolic Array matrix multiplier designed with N = 8 and data width of elements also of 8 bits.

•	The model uses 8 column and 8 row synchronous FIFOs to store the matrices A and B and is sequentially provided as per the controller state. When controller state is in IDLE, there is no multiplication going on. 

•	Inside the systolic array there are 8 X 8 Processing Elements (PE) which multiply and accumulate the patrix products and stores it. 

•	Controller has three states IDLE, RUN and DONE.

•	When the controller is the in IDLE no multiplication happens, when the controller is in RUN, controller sends the start signal and loads the FIFO contents in to the Processing elements which multiply and accumulates the result in Processing element itself producing matrix multiplication.

•	After all the results are computed, controller pulls the done flag high and goes to DONE state.


This project focuses on designing a parameterized systolic array matrix multiplier capable of multiplying two N×N matrices with 8-bit data width and implementing a complete ASIC design flow from RTL to GDS.
