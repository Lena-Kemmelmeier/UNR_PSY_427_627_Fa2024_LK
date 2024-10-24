% Default values
if ~exist('nPositions','var')
    nPositions = 12;
end

if ~exist('radius','var')
    radius = 5;
end
angle_diff = 2 * pi / nPositions;
theta = 0:angle_diff:(2*pi-angle_diff);
[x, y] = pol2cart(theta, radius);

circlePoints = [x;y]'