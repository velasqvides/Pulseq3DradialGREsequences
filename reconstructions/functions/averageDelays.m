function [Sx, Sy, Sz, Sxy, Sxz, Syz] = averageDelays(allDelays)

if abs(allDelays(1,1)) >= abs(allDelays(2,1))
    valueSign = sign(allDelays(1,1));
else
    valueSign = sign(allDelays(2,1));
end
Sx = (abs(allDelays(1,1)) + abs(allDelays(2,1)))/2;
Sx = Sx*valueSign;


if abs(allDelays(1,2)) >= abs(allDelays(3,1))
    valueSign = sign(allDelays(1,2));
else
    valueSign = sign(allDelays(3,1));
end
Sy = (abs(allDelays(1,2)) + abs(allDelays(3,1)))/2;
Sy = Sy*valueSign;

if abs(allDelays(2,2)) >= abs(allDelays(3,2))
    valueSign = sign(allDelays(2,2));
else
    valueSign = sign(allDelays(3,2));
end
Sz = (abs(allDelays(2,2)) + abs(allDelays(3,2)))/2;
Sz = Sz*valueSign; 
 

Sxy = allDelays(1,3);
Sxz = allDelays(2,3);
Syz = allDelays(3,3);

end