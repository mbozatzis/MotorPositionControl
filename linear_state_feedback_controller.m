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

k2 = 0.003;
k1 = -(1 + 2*k2*km*kt + kt^2*k2^2*km^2)/(4*Tm*ku*km*k0);
kr = -k1;
 
maxIter = 500;
i=1;
inputs = zeros(1, maxIter);
positions = zeros(1, maxIter);
velocities = zeros(1, maxIter);
time = zeros(1, maxIter);
tic;
while(i <= maxIter)
    
    velocity = analogRead(a,3);
    position = analogRead(a,5);
    x1 = 3 * Vref_arduino * position/1023;
    x2 = (2 * velocity * Vref_arduino / 1023 - V_7805);

    u = -k1*x1-k2*x2+kr*setpos

    if u>0
        analogWrite(a,9,0)
        analogWrite(a,6,min(round(u / 2 * 255 / Vref_arduino) , 255))
    else
        analogWrite(a,6,0)
        analogWrite(a,9,min(round(-u / 2 * 255 / Vref_arduino) , 255))
    end

    inputs(i) = u;
    velocities(i) = x2;
    positions(i) = x1;
    time(i) = toc;
    i = i+1;
end

analogWrite(a,9,0);   
analogWrite(a,6,0);

plot(time, inputs)
hold on
plot(time, velocities)
plot(time, positions)
legend('u', 'x1', 'x2')

