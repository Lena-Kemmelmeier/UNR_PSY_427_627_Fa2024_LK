function circlePoints = circlePos(nPositions, radius)
% Usage: circlePoints = circlePos(nPositions, radius)
% 
% Computes `nPositions` points along a circle at radius `radius`
% Written by MDL 2024.10.22

% Default values
if ~exist('nPositions','var')
    nPositions = 12;
end
if ~exist('radius','var')
    radius = 5;
end

varargin{2}
% option 2
% if nargin < 2
%     radius = 5;
% end
% 
% if nargin < 1
%     nPositions = 12;
% end

angle_diff = 2 * pi / nPositions;
theta = 0:angle_diff:(2*pi-angle_diff);
[x, y] = pol2cart(theta, radius);

circlePoints = [x;y]';