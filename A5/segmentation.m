directory = 'dataset/eval-data-gray/Basketball/';
num_iters = 25;
r_T = 15;

imgs = dir(fullfile(directory, '*.png'));
imgs_names = {imgs.name};

opticFlow = opticalFlowLK('NoiseThreshold',0.009);

for img_idx = 1:size(imgs_names,2)
    I = imread(string([directory, imgs_names{img_idx}]));
    frameGray = imsharpen(imsharpen(I));
    flow = estimateFlow(opticFlow,frameGray);
    
    [r, c] = size(frameGray);    
    mag = flow.Magnitude;
    mag(mag > 0.2) = 1;
    mag(mag < 0.2) = 0;
    vx = flow.Vx;
    vy = flow.Vy;
    mag(vx < 0.01) = 0;
    mag(vy < 0.01) = 0;
    coorx = (kron(ones(r, 1), 1:c) + vx) .* mag;
    coory = (kron(ones(c, 1), 1:r) + vy) .* mag;
    coorx(coorx > c) = c; coorx(coorx < 1) = 1;
    coory(coory > r) = r; coory(coory < 1) = 1;
    
    figure(1);
    subplot(1,3,1);
    imshow(I);
    hold on
    plot(floor(coorx), floor(coory),'r.');
    hold off
    
    mask = zeros(r,c) + mag;
    mask2 = imclose(mask, strel('square',60));    
    subplot(1,3,2); imshow(mask);
    seg = uint8(double(mask2) .* double(I));
    subplot(1,3,3); imshow(seg);
    
%     quiver(vx.*mag, vy.*mag);

    
%     pause(5);
end

function quiver_uv(u,v)
    scalefactor = 50/size(u,2);
    u_ = scalefactor * imresize(u, scalefactor, 'bilinear');
    v_ = scalefactor * imresize(v, scalefactor, 'bilinear');
    
    quiver(u_(end:-1:1,:), -v_(end:-1:1,:), 2);
    axis('tight');
end