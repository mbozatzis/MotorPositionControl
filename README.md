# Motor position control
This repository includes the developement of software that allow us to control the position of a DC motor using an Arduino. 

## Hardware

The experimental setup consits of two parts. 
- The first one includes the board with the Arduino and the electronics that closes the loop.
- The second one, which is the DC motor with one potentiometer and one tachometer embedded to him.

With the help of the two sensors, we can get feedback from the system we want to control (DC motor).
Unfortunately, there is no detailed schematic with the exact board and sensors used.

A high level diagram of the system is shown below.

[motschem.pdf](https://github.com/miltosmp/motor-position-control/files/8902103/motschem.pdf)

For the purpose of this experiment, we also need the transfer functions of the system. The generic block diagram of the layout is shown in the schematic below. The exact transfer functions will be determined as first step of the experiment.

<img width="354" alt="Screenshot 2022-06-14 204002" src="https://user-images.githubusercontent.com/61554467/173642274-6c28007b-ea8f-4f82-98d7-26219f4f3831.png">



## Software



