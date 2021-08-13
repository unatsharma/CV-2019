clear all;
close all;
clc;

fn = 'stone1';

I = imread(char([fn, '.jpg']));

%% GUI
imshow(I);
h = imrect;
box = logical(createMask(h));
bbox = getPosition(h);

% bbox = fscanf(fopen(char([fn, '.txt'])),'%f');

%% INITIALIZATION
mask_I = false(size(I,1),size(I,2));
mask_I(bbox(2):bbox(4), bbox(1):bbox(3)) = true;

[TU, TB] = obtainSets(I, mask_I);
z = obtainColorSpace(I);
% Set alpha = 0 for BG and alpha = 1 for FG
alphas = obtainAlphas(size(I(:,:,1)), mask_I);

% constants
neighborhood = 4;
gamma = 50;

% beta = calcBeta(I,4)/10;
beta = calculate_beta(I)/10;



%% GMMs
K = 3; % Number of GMM components

fg = z(:,alphas == 1); % FG color space
bg = z(:,alphas == 0); % BG color space

% Initialize GMMs
disp('Initializing GMMs');
fg_gmm = fitgmdist(double(fg'), K, 'RegularizationValue',0.01);
bg_gmm = fitgmdist(double(bg'), K, 'RegularizationValue',0.01);

%% ITERATIONS START
itrs = 1;

for itr = 1:itrs
    disp(itr);
    %% ASSIGN K
    fg_idx = cluster(fg_gmm, double(z'))';
    bg_idx = cluster(bg_gmm, double(z'))';

    ks = alphas .* fg_idx + (~alphas) .* bg_idx;
    
    fg = z(:,alphas == 1); % FG color space
    bg = z(:,alphas == 0); % BG color space


    %% RE-ESTIMATE GMM PARAMETERS
    fg_gmm = fitgmdist(double(fg'), K, 'start', ks(alphas == 1),...
        'RegularizationValue',0.01);
    bg_gmm = fitgmdist(double(bg'), K, 'start', ks(alphas == 0),...
        'RegularizationValue',0.01);

    %% ESTIMATE SEGMENTATION
    % Smoothness term
    V = calcV(alphas, I, neighborhood, gamma, beta);
    % Surity cost
    KC = full(max(sum(V,2)));
    % Data term
    U = calcU(I, alphas, bg_gmm, fg_gmm, KC);
    nodes = length(alphas);
    G = createGraph(nodes, U, V);
    [~, ~, cs, ct] = maxflow(G, 1, nodes + 2); % cs => bg, ct => fg
    
    % TODO - based on cs and ct assign alphas
    cs = cs - 1; ct = ct - 1;
    cs = intersect(cs(cs > 0), cs(cs < nodes + 1));
    ct = intersect(ct(ct > 0), ct(ct < nodes + 1));
    
    alphas(cs) = 0;
    alphas(ct) = 1;
    
    mask = reshape(alphas',[size(I,2), size(I,1)])';
    oI = double(I) .* mask;
    figure(2);
    imshow(uint8(oI));
    
end

mask = reshape(alphas',[size(I,2), size(I,1)])';
oI = double(I) .* mask;
figure(2);
imshow(uint8(oI));

%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS
% z = RGB color space for each pixel in I. Size = (3,num_pix)
function [TU, TB] = obtainSets(I, mask_I)
    rI = I(:,:,1); gI = I(:,:,2); bI = I(:,:,3);
    
    TU_r = rI(mask_I); TB_r = rI(mask_I);
    TU_g = gI(mask_I); TB_g = gI(mask_I);
    TU_b = bI(mask_I); TB_b = bI(mask_I);
    
    TU = cat(3,TU_r,TU_g,TU_b);
    TB = cat(3,TB_r,TB_g,TB_b);    
end

% alphas = opacity value for each pixel. Size = (1,num_pix)
function alphas = obtainAlphas(sz, mask_I)
    alpha_mat = zeros(sz);
    alpha_mat(mask_I) =  1;
    alphas = reshape(alpha_mat',[1,numel(alpha_mat)]);
end












