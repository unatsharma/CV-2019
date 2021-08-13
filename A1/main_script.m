
I = imread('Distorted/IMG_5455.JPG');
I_g = rgb2gray(I);
%%
% Image preprocessing
I_b = imbinarize(I_g, 0.3);
I_m = imdilate(I_b,strel('rectangle', [17,90]));

% Detecting points using Harris Detector
corners = detectHarrisFeatures(I_m);
n = 45;
a = corners.selectStrongest(n);
loc = a.Location();

% LUT for 2D and 3D points
lut2D = [133, 271, 1;...
         895, 339, 1;...
         1651, 375, 1;...
         2433, 429, 1;...
         3236, 450, 1;...
         4059, 495, 1;...
         4917, 536, 1;...
         194, 1049, 1;...
         929, 1107, 1;...
         1672, 1159, 1;...
         2437, 1209, 1;...
         3222, 1263, 1;...
         4032, 1351, 1;...
         4870, 1414, 1;...
         660, 2094, 1;...
         1435, 2155, 1;...
         2223, 2236, 1;...
         3028, 2308, 1;...
         3860, 2379, 1;...
         4721, 2458, 1;...
         326, 2405, 1;...
         1157, 2461, 1;...
         1981, 2546, 1;...
         2838, 2627, 1;...
         3732, 2717, 1;...
         4635, 2790, 1;...
         821, 2821, 1;...
         1705, 2910, 1;...
         2620, 2996, 1;...
         3570, 3081, 1;...
         4539, 3166, 1;...
         467, 3220, 1;...
         1411, 3311, 1;...
         2382, 3402, 1;...
         3384, 3498, 1];
lut3D = [216, 72, 0, 1;...
         180, 72, 0, 1;...
         144, 72, 0, 1;...
         108, 72, 0, 1;...
         72, 72, 0, 1;...
         36, 72, 0, 1;...
         0, 72, 0, 1;...
         216, 36, 0, 1;...
         180, 36, 0, 1;...
         144, 36, 0, 1;...
         108, 36, 0, 1;...
         72, 36, 0, 1;...
         36, 36, 0, 1;...
         0, 36, 0, 1;...
         180, 0, 36, 1;...
         144, 0, 36, 1;...
         108, 0, 36, 1;...
         72, 0, 36, 1;...
         36, 0, 36, 1;...
         0, 0, 36, 1;...
         180, 0, 72, 1;...
         144, 0, 72, 1;...
         108, 0, 72, 1;...
         72, 0, 72, 1;...
         36, 0, 72, 1;...
         0, 0, 72, 1;...
         144, 0, 108, 1;...
         108, 0, 108, 1;...
         72, 0, 108, 1;...
         36, 0, 108, 1;...
         0, 0, 108, 1;...
         144, 0, 144, 1;...
         108, 0, 144, 1;...
         72, 0, 144, 1;...
         36, 0, 144, 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%     PART-1     %%%%%%%%%%%%%%%%%%%%%%%%%%%

% DLT
pts_2D = lut2D([1,5,7,12,24,17],:);
pts_3D = lut3D([1,5,7,12,24,17],:);

P = calcProjMatrix(pts_2D, pts_3D);
[K_1, R_1, t_1] = decompose_P(P);

close all; imshow(I); hold on; plot(a);
genPts2D = genReprojPts(P, lut3D);
hold on;
plot(genPts2D(:,1), genPts2D(:,2), '+y');
legend('Actual image points', 'Reprojected image points');
title('Actual image points and reprojected image points (DLT)');
% Reprojection Error
err = (lut2D - genPts2D).^2;
err = sum(sqrt(sum(err(:,1:2), 2)));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%     PART-2     %%%%%%%%%%%%%%%%%%%%%%%%%%%
% DLT using Ransac
[P_2, K_2, R_2, t_2] = calibrateCameraRansac(lut2D, lut3D);

figure;imshow(I); hold on; plot(a);
genRansacPts2D = genReprojPts(P_2, lut3D);
hold on;
plot(genRansacPts2D(:,1), genRansacPts2D(:,2), '+y');
legend('Actual image points', 'Reprojected image points');
title('Actual image points and reprojected image points (DLT using Ransac)');
errRansac = (lut2D - genRansacPts2D).^2;
errRansac = sum(sqrt(sum(errRansac(:,1:2), 2)));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%     PART-3     %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radial distortion
syms k_1 k_2;
r = lut2D(:,1).^2 + lut2D(:,2).^2;
d = 1 + (k_1.*r) + (k_1.*(r.^2));
corr2D = lut2D./d;

corr2D = subs(corr2D, {k_1,k_2}, {0,25});
figure;imshow(I); hold on; plot(a);
hold on;
plot(corr2D(:,1), corr2D(:,2), '+y');
legend('Distorted image points', 'Undistorted image points');
title('Radial Distortion Correction');
%%
% I = imread('Zhangs/IMG_5456.JPG');
% J = undistortImage(I, cameraParams_2);
% subplot(1,2,1); imshow(I);
% subplot(1,2,2); imshow(J);

imagefiles = dir('Zhangs/*.JPG');      
nfiles = length(imagefiles);    % Number of files found

for index=1:nfiles
   currentfilename = imagefiles(index).name;
   I = imread(currentfilename);
   J = undistortImage(I, cameraParams_2);
   imwrite(J, currentfilename);
end

%%
I = imread('Assignment1_Data/IMG_5455.JPG');
J = undistortImage(I, cameraParams_2);



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%     PART-6,7     %%%%%%%%%%%%%%%%%%%%%%%%%%%

imagefiles = dir('Zhangs/*.JPG');      
nfiles = length(imagefiles);    % Number of files found

images = {};
for index=1:nfiles
   currentfilename = imagefiles(index).name;
   images{index} = currentfilename;
end

[imagePoints,boardSize] = detectCheckerboardPoints(images);
squareSize = 29;
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

I = imread(images{1});
imageSize = [size(I,1),size(I,2)];

cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                       'ImageSize',imageSize);

[imagePoints,boardSize] = detectCheckerboardPoints(I);
[rotationMatrix,translationVector] = extrinsics(...
    imagePoints,worldPoints,cameraParams);

Proj = cameraMatrix(cameraParams,rotationMatrix,translationVector);

homogeneousWorldPts = [worldPoints, zeros(length(worldPoints), 1), ones(length(worldPoints), 1)]';
homogeneousImgPts = Proj' * homogeneousWorldPts;
homogeneousImgPts = homogeneousImgPts./homogeneousImgPts(3,:);

% Show actual and reprojected image points
imshow(I); hold on;
plot(imagePoints(:,1), imagePoints(:,2), '+r');
plot(homogeneousImgPts(1,:), homogeneousImgPts(2,:), '+g');
title('Zhangs method');
legend('Actual Image Points', 'Reprojected Image Points');

% Reprojection Error
errZhang = (imagePoints - homogeneousImgPts(1:2,:)').^2;
errZhang = sum(sqrt(sum(errZhang(:,1:2), 2)));

% Show wireframe
figure;
imshow(I); hold on;
plot(homogeneousImgPts(1,:), homogeneousImgPts(2,:));
title('Wireframe obtained by using Projection matrix obtained from Zhangs method');
xlabel('X axis');
ylabel('Y axis');
%%%%%%%%%%%%%%%%%%%%%%%%%%%     PART-8     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Image of world origin
origin = [zeros(3,1); 1];
originImage = Proj' * origin;
originImage = originImage/originImage(3);
hold on;
plot(originImage(1), originImage(2), '+r');
text(originImage(1), originImage(2), ['Origin (', num2str(originImage(1)), ',', num2str(originImage(2)), ')'],...
    'Color', 'green');

%%%%%%%%%%%%%%%%%%%%%%%%%%%     PART-10     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Generate checkerboard
hold off;
cb = [zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128);...
      ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128);...
      zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128);...
      ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128);...
      zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128);...
      ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128);...
      zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128);...
      ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128);...
      zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128), ones(128,128), zeros(128,128)];

imshow(cb*255);

%%
I = imread('MyCamDLT/1.jpg');
I_g = rgb2gray(I);
I_b = I_g;
I_b(I_g > 50) = 255;
I_b(I_g <= 50) = 0;
I_m = imerode(I_b, ones(2,2));
% close ; imshow(I_m)
%%
corners = detectHarrisFeatures(I_m);
a = corners.selectStrongest(25);
% close all;
% imshow(I); hold on;
% plot(corners.selectStrongest(25));

lut2D = [108, 55, 1; 181, 56, 1; 266, 62, 1; 357, 67, 1; 108, 140, 1;...
         180, 148, 1; 258, 155, 1; 342, 162, 1; 108, 217, 1;...
         176, 226, 1; 248, 237, 1; 328, 248, 1; 68, 255, 1;...
         143, 270, 1; 225, 284, 1; 312, 300, 1; 13, 303, 1;...
         99, 319, 1; 191, 340, 1; 292, 361, 1];
lut3D = [0, 32, 0, 1; 16, 32, 0, 1; 32, 32, 0, 1; 48, 32, 0, 1;...
         0, 16, 0, 1; 16, 16, 0, 1; 32, 16, 0, 1; 48, 16, 0, 1;...
         0, 0, 0, 1; 16, 0, 0, 1; 32, 0, 0, 1; 48, 0, 0, 1;...
         0, 0, 16, 1; 16, 0, 16, 1; 32, 0, 16, 1; 48, 0, 16, 1;...
         0, 0, 32, 1; 16, 0, 32, 1; 32, 0, 32, 1; 48, 0, 32, 1];

%%
pts_2D = lut2D([17,2,4,9,20,11],:);
pts_3D = lut3D([17,2,4,9,20,11],:);

P = calcProjMatrix(pts_2D, pts_3D);
[K_1, R_1, t_1] = decompose_P(P);

close all; imshow(I); hold on; 
plot(lut2D(:,1), lut2D(:,2), '+g');
genPts2D = genReprojPts(P, lut3D);
hold on;
plot(genPts2D(:,1), genPts2D(:,2), '+y');
legend('Actual image points', 'Reprojected image points');
title('Actual image points and reprojected image points (DLT)');
% Reprojection Error
err = (lut2D - genPts2D).^2;
err = sum(sqrt(sum(err(:,1:2), 2)));
%%
% Wireframe
close all;
imshow(I);
hold on;
plot(genPts2D(:,1), genPts2D(:,2));
title('Wireframe obtained by using P obtained from DLT method');
xlabel('X axis');
ylabel('Y axis');

%%
% DLT using Ransac
[P_2, K_2, R_2, t_2] = calibrateCameraRansac(lut2D, lut3D);

genRansacPts2D = genReprojPts(P_2, lut3D);
close all;
figure;imshow(I); hold on; 
plot(lut2D(:,1), lut2D(:,2), '+g');
hold on;
plot(genRansacPts2D(:,1), genRansacPts2D(:,2), '+y');
legend('Actual image points', 'Reprojected image points');
title('Actual image points and reprojected image points (DLT using Ransac)');

% Reprojection error
errRansac = (lut2D - genRansacPts2D).^2;
errRansac = sum(sqrt(sum(errRansac(:,1:2), 2)));

%%
% Wireframe
close all;
imshow(I);
hold on;
plot(genRansacPts2D(:,1), genRansacPts2D(:,2));
title('Wireframe obtained by using P obtained from DLT using Ransac');
xlabel('X axis');
ylabel('Y axis');

%%
% Applying Zhangs method
imagefiles = dir('MyCamZhang/*.JPG');      
nfiles = length(imagefiles);    % Number of files found
images = {};
for index=1:nfiles
   currentfilename = imagefiles(index).name;
   images{index} = currentfilename;
end

[imagePoints,boardSize] = detectCheckerboardPoints(images);
squareSize = 16;
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

I = imread(images{1});
imageSize = [size(I,1),size(I,2)];

cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                       'ImageSize',imageSize);

[imagePoints,boardSize] = detectCheckerboardPoints(I);
[rotationMatrix,translationVector] = extrinsics(...
    imagePoints,worldPoints,cameraParams);

Proj = cameraMatrix(cameraParams,rotationMatrix,translationVector);

homogeneousWorldPts = [worldPoints, zeros(length(worldPoints), 1),...
    ones(length(worldPoints), 1)]';
homogeneousImgPts = Proj' * homogeneousWorldPts;
homogeneousImgPts = homogeneousImgPts./homogeneousImgPts(3,:);

figure;
imshow(I);
hold on;
plot(imagePoints(:,1), imagePoints(:,2), '+g');
hold on;
plot(homogeneousImgPts(1,:), homogeneousImgPts(2,:), '+y');
title('Zhang Method');
legend('Actual image points', 'Reprojected image points');

% Reprojection Error
errZhang = (imagePoints - homogeneousImgPts(1:2,:)').^2;
errZhang = sum(sqrt(sum(errZhang(:,1:2), 2)));

% Wireframe
imshow(I);
hold on;
plot(homogeneousImgPts(1,:), homogeneousImgPts(2,:));
title('Wireframe obtained by using P obtained from Zhangs method');
xlabel('X axis');
ylabel('Y axis');