# Motor position control
This repository includes the developement of software that allow us to control the position of a DC motor using an Arduino. 

## Introduction 
### Hardware

The experimental setup consits of two parts. 
- The first one includes the board with the Arduino and the electronics that closes the loop.
- The second one, which is the DC motor with one potentiometer and one tachometer embedded to him.

With the help of the two sensors, we can get feedback from the system we want to control (DC motor).
Unfortunately, there is no detailed schematic with the exact board and sensors used.

A high level diagram of the system is shown below.

<img width="292" alt="Screenshot 2022-06-14 204327" src="https://user-images.githubusercontent.com/61554467/173646627-3d279ef9-b1c3-474c-a6f9-b4f81f5bda02.png">


For the purpose of this experiment, we also need the transfer functions of the system. The generic block diagram of the layout is shown in the schematic below. The exact transfer functions will be determined as first step of the experiment.

<img width="354" alt="Screenshot 2022-06-14 204002" src="https://user-images.githubusercontent.com/61554467/173642274-6c28007b-ea8f-4f82-98d7-26219f4f3831.png">



### Software

The actual controller that will be integrated to the system through the Arduino will be implemented with software. Since we want to extract the experimental results easily, we will use MATLAB with the MATLAB® Support Package for Arduino® for the development.

## System modeling
### Parameter identification

The values of the unknown parameters in the system transfer functions will be calculated experimentaly. We can divide this procedure into two sequential steps.
- Calculation of $k_mk_r, T_m$ and $k_\mu$ :

We can easily extract that the transfer function $\frac{k_{m}k_{T}}{T_{m}s+1}$ has a steady state value $k_mk_T$ by taking the limit while $s\rightarrow0$. So, by calculating the gain we find the product $k_mk_r = \frac{8.28}{9.9} = 0.836$, where $9.9V$ is the input voltage and $8.28V$ is the output voltage $V_{tacho}$ that we meassured with a voltmeter.

In order to find $T_m$, we need to meassure the time the system needs to reach the $63.3$\% of its steady state value that is $5.241V$. After meassuring the response with an oscilloscope we find $T_{m} = 525ms$.

Finaly, $k_\mu$ describes the fraction of the output angle of rotation to the input angle of rotation. Our system setup allows us to change manualy the input angle of rotation. So, by changing the input manually, we observe the output diversion and we extract the value $k_\mu = 1/36$, as in a full input rotation of $360\degree$ the output axis turned $10\degree$.

- Calculation of $k_m, k_T$ and $k_0$

In order to continue with the rest of the calculations, we need to define the rate of change $\frac{\Delta x}{\Delta t} $. So, we meassure with an oscilloscope $\Delta x = 14.4V$ from the potentiometer, and the time it needs for this turn  $\Delta t = 945ms$. Also,  $\Delta t$ is equal with the output period, so we can find  $\omega_{out} = 63.49rpm$ and  $\omega = \omega_{out}/k_\mu = 2285.71rpm$.

With the above information we can define the rest of the parameters.  $\frac{\Delta x}{\Delta t} = k_{0}k_{\mu}\omega => k_0 = 0.24$,  $V_{tacho} = k_{T}\omega => k_T = 0.00362$ and  $k_{m}k_{T} = 0.836 => k_m = 231.04$.

So, finally we have:
- $k_m = 231.04 $
- $T_{m} = 525ms $
- $k_T = 0.00362 $
- $k_\mu = 1/36 $
- $k_0 = 0.24 $

Also, we need to calculate the exact operational voltages of our system in order to have them as reference.
So, by meassuring, we find $V_{ref} = 5.3V$ and $V_{7805} = 5.46V$.

### State equations determination

From the block diagram of the system, we can extract some equations for the values of interest in the frequency domain. So we have:
- $\Theta(s) = \frac{k_{0}k_{\mu}}{s}\Omega(s) => \mathcal{L}^{-1}[\Omega(s)] = \mathcal{L}^{-1}[\frac{s}{k_{0}k{\mu}}\Theta(s)] => \omega(t) = \frac{1}{k_{0}k{\mu}}\frac{d\theta(t)}{dt}$
- $V(s) = -k_{T}\Omega(s) => v(t) = -k_{T}\omega(t) => v(t) = \frac{-k_T}{k_{0}k{\mu}}\frac{d\theta(t)}{dt} $
- $\Omega(s) = -\frac{k_{m}}{T_{m}s+1}U(s)$ for our experiments we will have a step input (Heaviside) $u(t) = u, t>0 $. So  $U(s) = u/s$ and the initial equation can be transfered in the time domain as  $\omega(t) = -k_{m}(1-e^{-t/T_{m}})u => v(t) = k_Tk_{m}(1-e^{-t/T_{m}})u$.

We will choose the state variables:  $x_1 = \theta$ and  $x_2 = v$. So:
- $\dot{x_1} = \dot{\theta} => \dot{x_1} = \frac{-k_0k_{\mu}}{k_T}x_2$
- $\dot{x_2} = \dot{v} => \dot{x_2} = -\frac{1}{T_m}x_2 + \frac{k_mk_T}{T_m}u$

And the equations of state will be:
$$\dot{x} = Ax + Bu$$
$$y = Cx + Du$$

where

$$ A = \begin{bmatrix}
0 & -k_0k_{\mu}/k_T \\
0 & -1/T_{m} 
\end{bmatrix}, B = \begin{bmatrix}
0  \\
k_mk_T/T_m   
\end{bmatrix}, C = \begin{bmatrix}
1 & 0
\end{bmatrix}, D = [0] $$

Lastly, we need to check if our system can be controled. So, we calculate the controllability matrix 

$$M = \begin{bmatrix}
B & AB 
\end{bmatrix} = \begin{bmatrix}
0 & -k_0k_{\mu}k_m/T_m \\
-k_mk_T/T_{m} & k_mk_T/T_{m}^2 
\end{bmatrix} $$

which has $det(M) = k_{\mu}k_0k_m^2k_T/T_m^2 \neq 0$, so the system is controllable.

## Linear state feedback control
### Theoretic Analysis
The linear state feedback controller is desribed by the relation: $u = -k_1x_1 - k_2x_2 + k_rr$ where $r$ is the new input. Our goal is to calculate the gains of the controller ($k_1, k_2, k_r$).

After the integration of the controller to the system, the new equations of state are shaped as:

$$ \dot{x} = \begin{bmatrix}
0 & -k_0k_{\mu}/k_T \\
-k_1k_mk_T/T_{m} & \frac{-k_2k_mk_T-1}{T_{m}} 
\end{bmatrix}x + \begin{bmatrix}
0 \\
k_Tk_rk_m/T_{m}  
\end{bmatrix}r$$

$$ y = \begin{bmatrix}
1 & 0 
\end{bmatrix}x$$

From the new matrix $\tilde{A}$, we can find the new characteristic polynomial of the system: $P_c(s) = det(sI - \tilde{A}) = s^2 + \frac{1+k_2k_mk_T}{T_m}s - \frac{k_1k_0k_mk_{\mu}}{T_m}$. Our first requirement is for our system to be stable, and by using the Routh–Hurwitz stability criterion we find the constrains:
$k_1<0, k_2> -\frac{1}{k_mk_T}$. Our second requirement is to make our system as fast as possible without oscillations. We can achieve this by having a damping ratio $\zeta = 1$. The characteristic polynomial can be written as $P_c(s) = s^2 + 2\zeta\omega_ns+\omega_n^2$. So, by corelating this form with the polynomial found above we find the relation: 

$$k_1 = -\frac{k_2^2k_m^2k_T^2+2k_2k_mk_T+1}{4T_mk_0k_mk_\mu}$$

Our final requirement is to have minimum steady state error. At the steady state:

$$\dot{x} = 0 => \tilde{A}x^* = -Bk_rr => x^* = -\tilde{A}^{-1}Bk_rr$$

For zero steady state error:

$$r = y_{ss} = Cx^* => r = -C\tilde{A}^{-1}Bk_rr = > k_r = -\frac{1}{C\tilde{A}^{-1}B}$$

And, by doing the calculation we find $k_r = - k_1$. Since the $k_2$ gain will be determined by trial-and-error during the experimental procedure, we are ready to continue with the practical aplication.

### Experimental Procedure

During the experimental procedure, the script *linear_state_feedback_controller.m* was developed and used. The value $k_2 = 1.3$ was selected after trial and error with the physical system. After this selection, the other parameters was calculated by the relations extracted during the theoretical analysis.

#### First stage

At the first stage of this experiment we will set the input of our system to  $r = \theta_{ref} = 5V$ and we will observe its behaviour. Our goal is for the system to converge to the input given. The initial position will be $\theta_{ref} = 5V$.

After we run the code on the actual system we got the results shown bellow:

<img width="385" alt="2_1_x1" src="https://user-images.githubusercontent.com/61554467/178112771-07a840a0-5f7b-4ab6-b249-55a6e6937574.png">

As we see, the position ($x_1$) is indeed converging to our input. The error is about $0.155V$, so $3.1$\%. The reason for this error are the imperfections of the physical system.

#### Second stage

During the second stage, we will perform the exact same procedure, but this time the system will operate under some external disturbances. More spesifcally, we will apply a magnetic break to the motor while rotating. 

<img width="379" alt="2_3_x1" src="https://user-images.githubusercontent.com/61554467/178112986-9bee83ac-0408-4c6f-979a-79f1ea353dae.png">

This time, the position doesn's converge to the $\theta_{ref}$ as the error is to big - $0.7713V$, $15.426$\%. 

In order to deal with this problem, we need ot change our controller. So, intead of a linear state feedback controler, we will use a dynamic state feedback controller, which has the abillity to depreciate disturbances.

## Dynamic state feedback control
### Theoretical Analysis
The dynamic state feedback controller is desribed by the relation:  $u = -k_1x_1 - k_2x_2 - k_iz$ where  $\dot{z} = y - r$ with  $r$ the new input. Our goal is to calculate the gains of the controller ($k_1, k_2, k_i$).

After the integration of the controller to the system, the new equations of state are shaped as:

$$ \begin{bmatrix}
\dot{x_1}  \\
\dot{x_2}  \\
\dot{z}
\end{bmatrix} = \begin{bmatrix}
0 & -k_0k_{\mu}/k_T & 0 \\
-k_1k_Tk_m/T_m & -(1+k_2k_Tk_m)/T_{m} & -k_ik_Tk_m/T_m \\
1 & 0 & 0
\end{bmatrix}\begin{bmatrix}
x_1 \\
x_2  \\
z
\end{bmatrix} + \begin{bmatrix}
0 \\
0  \\
-1
\end{bmatrix}r$$

And the characteristic polynomial is:

$$P_c(s) = s^3 + \frac{1+k_2k_Tk_m}{T_m}s^2 - \frac{k_0k_1k_{\mu}k_m}{T_m}s - \frac{k_0k_{\mu}k_ik_m}{T_m}$$

We know that this controller will surely make our system follow the input as in the steady state $\dot{z} = 0 => y = r$. So, the only requirement is for our system to be stable. By aplying the Routh–Hurwitz stability criterion we find the constraints: $k_2>0, k_i < 0, k_1<\frac{T_mk_i}{1+k_Tk_mk_2}$. So, we can continue with the experiment.

### Experimental Procedure

During this experiment we repeated the procedure of the first experiment with the new controller, the script can be found in the file *dynamic_state_feedback_controller.m*. The results are:

Without the magnetic break:

<img width="352" alt="3without" src="https://user-images.githubusercontent.com/61554467/178113973-fcac2975-5352-4550-8332-0c5fc78502ba.png">

With the magnetic break:

<img width="374" alt="3with" src="https://user-images.githubusercontent.com/61554467/178113982-3bbd5579-ffe5-4c0b-a121-96d6e878f7d8.png">

In this case, we have a bigger error while running the experiment without the magnetic break ($5.38$\%) and smaller with the magnetic break ($10.4$\%). These errors are again consequences of the imperfections of the system.

## State observation and linear control

For this experiment, we consider that we don't have access to the value of the velocity $x_2$. So we need to develop a state observator before trying to control the system.

### Theoretical Analysis

First of all, we need to examine if our system is observable. We define the observation matrix:

$$W = \begin{bmatrix}
C \\
CA 
\end{bmatrix} = \begin{bmatrix}
1 & 0 \\
0 & -k_0k_{\mu}/k_T
\end{bmatrix}$$

and we see that $det(W) = -k_0k_{\mu}/k_T \neq 0$, so the system is observable.

For the observation we use the relation:

$$\dot{\hat{x}} = A\hat{x} + Bu +L(y - C\hat{x})$$

The matrix $L$ is defined as:

$$L = W^{-1}\tilde{W}\begin{bmatrix}
p_1-a_1 \\
p_2-a_2
\end{bmatrix}$$

where $a_i$ are the coefficients of the system characteristic polynomial, $p_i$ are the desirable coefficients of the observator characteristic polynomial and $\tilde{W}$ is given by the equation:

$$\tilde{W} = \begin{bmatrix}
1 & 0 \\
a_1 & 1
\end{bmatrix}^{-1} = \begin{bmatrix}
1 & 0 \\
-1/T_m & 1
\end{bmatrix}$$

So, we find:

$$ L = \begin{bmatrix}
p_1-1/T_m \\
\frac{k_T}{k_0k_{\mu}T_m}(1/T_m-p_1)+\frac{k_Tp_2}{k_0k_{\mu}}
\end{bmatrix}$$

The coefficients $p_i$ will be calculated through trial and error during the experimental procedure.

For the control, we will use the linear state feedback controller we developed in the first experiment.

### Experimental Procedure
#### First stage

As a first step we need to develop the observer. The code developed and used is in the file *observer.m*. In the diagrams below, we can see the quality of the observation.

<img width="370" alt="4_30_200_-" src="https://user-images.githubusercontent.com/61554467/178161532-f228349a-bce2-492d-9399-1e00bbfd2571.png">

As we see, the $x_{1t}$ and $x_{2t}$ can observe the two state variables good enough for our application. The big spikes of $x_{2t}$ are results of the steep variation of $x_1$, during the position change.

#### Second stage

Now, having the observer, we will try to control the system using the approximated state variables. The code is in the file *linear_state_feedback_controll_observer.m* and the results:

<img width="363" alt="4B" src="https://user-images.githubusercontent.com/61554467/178161759-9e3cc87d-765e-46de-96bc-ed35cc8793ba.png">

So, we see that even with the imperfetions of the approximated state variables by the observer, the system behaves as intended.
