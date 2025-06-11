
# Matrix Multiplication Implementing Using a Systolic Architecture 

This project implements a scalable systolic array architecture for computing matrix multiplication on square matrices of configurable size 𝑀×𝑀, It uses a grid of multiply-and-accumulate processing elements (PEs), arranged such that data flows horizontally and vertically through the array in a pipelined and synchronized fashion. This enables high-throughput and efficient parallel computation. 


Systolic Array Architecture Design:
![alt text](docs/Systolic_array_1.jpg)

This image gives a simple illustration of how the systolic array architecture operates. Matrix A feeds in each of its rows as a stream padded with zeros. Likewise, matrix B feeds in each of its colunns as a stream padded with zeros. Zero padding for each stream is essential to keep the matrix pipeline synchronous. Each stream will pass in the same value to its neighboring processing element. Every processing element will multiply a and b and it add it to its previous result. The final result is an element for matrix C. 

## Main module
The main modules wraps around the feed modules and systolic array module

### Inputs:
- `clk`, assume positive edge triggers
- `rst`, an active high synchronous reset
- `a`, an array stream of rows from matrix A (flattened)
- `b`, an array stream of columns from matrix B (flattened)
- `vld_in`, handshake valid in
    - goes high when a and b is valid, indicating to start to using the systolic array
- `rdy_out`, ready out
    - goes high when the matrix multiplication accelerator's output has successfully been read from 

- Note: we want to use an array for our inputs in order for the systolic array to be reconfigurable for any MxM matrix

### Outputs:
- `rdy_in`, held high by the accelerator when it is ready to take a new input
- `c`, 2D array of the matrix C (flattened)
- `vld_out`, held high by the accelerator when its output is ready

## Feed modules
Delay module is simply a register that synchronously passes a_in to a_out every clock

Feed module feeds the stream of inputs to the systolic array. Based on the first image, each row of Matrix a and column of Matrix B is streamed in to the systolic array. This module is responsible for feeding in the stream to the systolic array. 

### Inputs
- `clk`, assume positive edge triggers
- `a_in`, an array stream of rows from matrix A (flattened)

### Outputs
- `a_out`, an array stream of rows from matrix a (flattened)


## Systolic Array Module

### Inputs:
- `clk`, assume positive edge triggers
- `rst`, an active high synchronous reset
- `a`, an array stream of rows from matrix A (flattened)
- `b`, an array stream of columns from matrix B (flattened)
- `vld_in`, handshake valid in
    - goes high when a and b is valid, indicating to start to using the systolic array
- `rdy_out`, ready out
    - goes high when the matrix multiplication accelerator's output has successfully been read from 

### Outputs:
- `rdy_in`, held high by the accelerator when it is ready to take a new input
- `c`, 2D array of the matrix C (flattened into 1D vector)
- `vld_out`, held high by the accelerator when its output is ready

## Multiply and Accumulate Processing Elements Modules

### Inputs:
- `clk`, assume positive edge triggers
- `rst`, an active high synchronous reset
- `a`, an 8 bit signal for an element from Matrix A
- `b`, an 8 bit signal for an element from Matrix B
- `en`, enable computing multiply and accumulate 

### Outputs:
- `c`, result of multiply and accumulate
- `a_out`, pass input a. This is necessary for passing a to the processing element to its right
- `b_out`, pass input a. This is necessary for passing b to the processing element to its bottom

## Synthesis
In order to pass synthesis successfully, none of the inputs or outputs of all modules can be multi-dimensional arrays; this is the case for most of the modules in our design. For the top (main) module, the values of the two input matrices were fed in one at a time into a buffer, which can then be read multiple values at a time (i.e. a buffer with serial input, parallel output). The array inputs/outputs of the internal modules (buffer, feed, and systolic array) are flattened into 1D vectors. The synthesis successfully completes. 

## Testbench & Simulation
Test 1 waveform:
![alt text](docs/systolic_arr_identity.png)

The first test does matrix multiplication between two 3x3 identity matrices. This is a simple case that gives us the desired results. 

