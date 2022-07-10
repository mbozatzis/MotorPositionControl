u = 7;

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

i = 1;
maxIter = 300;
positions = zeros(1, maxIter);
velocities = zeros(1, maxIter);
positionsnew = zeros(1, maxIter);
velocitiesnew = zeros(1, maxIter);
time = zeros(1, maxIter);
tic;



if u>0
    analogWrite(a,6,0)
    analogWrite(a,9,min(round(u / 2 * 255 / Vref_arduino) , 255))
else
    analogWrite(a,9,0)
    analogWrite(a,6,min(round(-u / 2 * 255 / Vref_arduino) , 255))
end


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
    
    time(i) = toc;
    velocities(i) = x2;
    positions(i) = x1;
    velocitiesnew(i) = xt(2);
    positionsnew(i) = xt(1);
    i = i+1;    
end

analogWrite(a,6,0)
analogWrite(a,9,0)

plot(time, velocities)
hold on
plot(time, positions)
plot(time, positionsnew)
plot(time, velocitiesnew)
legend('x2', 'x1', 'x1t', 'x2t')