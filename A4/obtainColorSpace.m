function z = obtainColorSpace(I)
%OBTAINCOLORSPACE Obtains color space (RGB) matrix of I.
% Inputs:
%   I = Image
% Outputs:
%   z = RGB for each pixel. Size = (3,num_pix).

    rI = I(:,:,1); gI = I(:,:,2); bI = I(:,:,3);
    num_pix = numel(rI);
    
    z = [reshape(rI',[1,num_pix]);...
         reshape(gI',[1,num_pix]);...
         reshape(bI',[1,num_pix])];
     
end
