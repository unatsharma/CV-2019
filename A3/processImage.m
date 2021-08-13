function image = processImage(I, rescale_factor)
% PROCESSIMAGE Processes the image
%   Converts RGB to gray, downsamples the image and converts data type to
%   double.
% Inputs:
%   I = Image
%   rescale_factor = Scale for downsampling the image
% Output:
%   image = Processed image
       
    if size(I,3) == 3
        I = rgb2gray(I);
    end
    
    image = im2double(imresize(I, rescale_factor));
end

