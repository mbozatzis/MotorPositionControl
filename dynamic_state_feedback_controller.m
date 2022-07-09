setpos =5;

analogWrite(a,9,0);   
analogWrite(a,6,0);

Vref_arduino = 5.3; 
V_7805 = 5.46;

Tm = 0.525;
ku = 1/36;
k0 = 0.24;
kt = 0.00362;
km = 231.04;

k2 = 0.5;
ki = -0.8;
k1 = -0.6;


maxIter = 500;
i=1;
inputs = zeros(1, maxIter);
positions = zeros(1, maxIter);
velocities = zeros(1, maxIter);
zeta = zeros(1, maxIter);
time = zeros(1, maxIter);
tic;
z = 0;


    
while(i <= maxIter)
    velocity = analogRead(a,3);
    position = analogRead(a,5);
    x1 = 3 * Vref_arduino * position/1023;
    x2 = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);

    if i>1
        dz = (x1 - setpos) * (toc-time(i-1));
    else
        dz = (x1 - setpos)*toc;
    end
    
    time(i) = toc;
    z = z + dz;
    
    
    u = -k1*x1-k2*x2-ki*z

    if u>0
        analogWrite(a,6,0)
        analogWrite(a,9,min(round(u / 2 * 255 / Vref_arduino) , 255))
    else
        analogWrite(a,9,0)
        analogWrite(a,6,min(round(-u / 2 * 255 / Vref_arduino) , 255))
    end

    inputs(i) = u;
    velocities(i) = x2;
    positions(i) = x1;
    zeta(i) = z;
    i = i+1;    
end
analogWrite(a,6,0);
analogWrite(a,9,0);

plot(time, inputs)
hold on
plot(time, velocities)
plot(time, positions)
plot(time, zeta)
legend('u', 'x2', 'x1', 'z')
