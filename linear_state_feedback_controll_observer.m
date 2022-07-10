setpos = 5;

analogWrite(a,9,0);   
analogWrite(a,6,0);

Vref_arduino = 5.3; 
V_7805 = 5.46;

Tm = 0.525;
ku = 1/36;
k0 = 0.24;
kt = 0.00362;
km = 231.04;

A = [0, -k0*ku/kt ; 0, -1/Tm];
B = [0; -km*kt/Tm];
P1 = 30;
P2 = 200;
L = [(P1-1/Tm); ((kt/(k0*ku*Tm))*(1/Tm - P1) + P2*kt/(k0*ku))]

k2 = 1.3;
k1 = -(1 + 2*k2*km*kt + kt^2*k2^2*km^2)/(4*Tm*ku*km*k0);
kr = -k1;

i = 1;
maxIter = 300;
inputs = zeros(1, maxIter);
positions = zeros(1, maxIter);
velocities = zeros(1, maxIter);
positionsnew = zeros(1, maxIter);
velocitiesnew = zeros(1, maxIter);
time = zeros(1, maxIter);
tic;

xt = [0; 0];

while(i <= maxIter)
    velocity = analogRead(a,3);
    position = analogRead(a,5);
    x1 = 3 * Vref_arduino * position/1023;
    x2 = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);
    
    if i > 1
        dxt = (A * xt + B*u + L * (x1-xt(1))) * (toc - time(i-1));
    else
        dxt = (A * xt + B*u + L * (x1-xt(1))) * (toc);
    end
    xt = xt + dxt;
    
    u = -k1*x1-k2*xt(2)+kr*setpos
    
    if u>0
        analogWrite(a,6,0)
        analogWrite(a,9,min(round(u / 2 * 255 / Vref_arduino) , 255))
    else
        analogWrite(a,9,0)
        analogWrite(a,6,min(round(-u / 2 * 255 / Vref_arduino) , 255))
    end
   
    time(i) = toc;
    inputs(i) = u;
    velocities(i) = x2;
    positions(i) = x1;
    velocitiesnew(i) = xt(1);
    positionsnew(i) = xt(2);
    i = i+1;    
end

analogWrite(a,6,0)
analogWrite(a,9,0)

plot(time, velocities)
hold on
plot(time, inputs)
plot(time, positions)
legend('x2', 'u', 'x1')