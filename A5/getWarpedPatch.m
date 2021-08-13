function patch = getWarpedPatch(I, W, x_T, r_T)
% GETWARPEDPATCH Gives warped image patch using W for points x_T within
% radius r_T.
% Inputs:
%   I       Image
%   W       Warping matrix. Size(2x3).
%   x_T     Contains [x_T y_T].Size(1x2)
%   r_T     Radius of patch.
% Output:
%   patch   Patch.Size((2*r_T+1)x(2*r_T+1))

    patch = zeros(2*r_T+1);
    
    max_coords = fliplr(size(I));
    WT = W';
    I = double(I);
    
    for x = -r_T:r_T
        for y = -r_T:r_T
            warped = x_T + [x y 1] * WT;
            
            if all(warped < max_coords & warped > [1 1])            
                floors = floor(warped);
                weights = warped - floors;
                a = weights(1); b = weights(2);

                % Bilinear combination
                patch(y + r_T + 1, x + r_T + 1) = (1-b) * (...
                (1-a) * I(floors(2), floors(1)) +...
                a * I(floors(2), floors(1)+1))...
                + b * (...
                (1-a) * I(floors(2)+1, floors(1)) +...
                a * I(floors(2)+1, floors(1)+1));
            end
            
        end
    end
    
end
