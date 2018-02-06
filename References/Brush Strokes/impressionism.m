function imgOut = impressionism(filename, varargin)
%impressionism takes an RGB image and "paints" it as though it were an
%impressionist painting.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function "paints" an impressionist like painting of an RGB image.
%
% USAGE
%
% imgOut = impressionism(filename, 'threshold', 50, 'brush sizes', ...
% [8 4 2], 'blur factor', 0.5, 'grid spacing', 1, 'brush curvature', ...
% 1, 'min length', 4, 'max length',16 );
%
% imgOut = impressionism(filename, 'threshold', 50, 'brush sizes', ...
% [8 4 2], 'blur factor', 0.5, 'grid spacing', 1, 'brush curvature', ...
% 1,  'pointillism', 1);
%
% PARAMETERS
%
% 'threshold' -  determines how closely the painting must approximate 
% the source image. Higher values of this threshold produce "rougher" 
% paintings.
% default thresh is 50
%
% 'brush sizes' - determines the brush sizes used in the painting. Brush 
% sizes dimensions are pixels and are specified as radii.
% default brushSzs = [8 4 2] areas of little detail will be painted with 
% large brush strokes. Areas with lots of detail will be painted with 
% little brush strokes
%
% 'blur factor'- A smaller blur factor allows more noise in the image, 
% producing a more "impressionistic" image standard deviation will
% be blurFactor * brushSz(k)
% default blurFactor = 0.5
%
% 'grid spacing' - (grid spacing = gridSpacing*brush radius)
% default gridSpacing = 1
%
% 'brush curvature' - brushstroke curvature filter constant. Used to limit 
% or exagerate curvature
% default brushCurve = 1
%
% 'min length' - minimum stroke length used in painting
% default minStrokeLength = 4
%
% 'max length' - maximum stroke length used in painting
% default maxStrokeLength = 16
%
% 'pointillism' - givs a pointillist style painting (sets min and max
% length to zero) Note: Do not use 'min length' or 'max length' while
% using 'pointillism'
%
% You can use the attached test images. Use the following combinations:
% imgOut = impressionism('landscape_test.jpg');
%
% This code was originally inspired by the paper "Painterly Rendering with 
% Curved Brush Strokes of Multiple Sizes" by Aaron Hertzmann.
%
%               Author: David Mills
%               email: dmills10@jhu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin == 0
    error('impressionism: No file was input.')
end

if ceil(mod(length(varargin),2)) > 0
    error('impressionism: Wrong arguments: must be name-value pairs.');
end

for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case 'threshold'
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1}) && ...
                    varargin{i+1} > 0 && varargin{i+1} < 255 
                T=varargin{i+1};
            else
                error('impressionism: threshold must be a scalar number between 1 and 254')
            end
        case 'brush sizes'
            if isnumeric(varargin{i+1})
                bS = sort(reshape(floor(varargin{i+1}),...
                    1,numel(varargin{i+1})),'descend');
            else
                error('impressionism: brushsizes must be numeric')
            end
        case 'min length'
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1})
                minSL=varargin{i+1};
            else
                error('impressionism: lengths must be numeric')
            end
        case 'max length' 
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1})
                maxSL=varargin{i+1};
            else
                error('impressionism: lengths must be numeric')
            end
        case 'blur factor'
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1})
                bF=varargin{i+1};
            else
                error('impressionism: blur factor must be scalar and numeric')
            end
        case 'brush curvature'
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1})
                bC=varargin{i+1};
            else
                error('impressionism: brush curvature must be scalar and numeric')
            end
        case 'grid spacing'
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1})
                gS=varargin{i+1};
            else
                error('impressionism: grid spacing must be scalar and numeric')
            end
        case 'pointillism'
            minSL=0; maxSL=0;
        otherwise
            error([' impressionism:''' varargin{i} ''' is not a valid option.'])
    end
end
% Assign default settings if not assigned
if ~exist('T', 'var'), T = 50; end
if ~exist('bS', 'var'), bS = [8 4 2]; end
if ~exist('minSL', 'var'), minSL = 4; end
if ~exist('maxSL', 'var'), maxSL = 16; end
if ~exist('bF', 'var'), bF = 0.5; end
if ~exist('bC', 'var'), bC = 1; end
if ~exist('gS', 'var'), gS = 1; end

filename = imread(filename);

warning('off','all')
% code
[m,n,l] = size(filename);

if l ~= 3
    error('impressionism: input image must be an RGB image')
end

% output image
canvas = ones(size(filename))*128;
imgOut = zeros(size(filename));
for k=1:numel(bS)
    imgBlank = zeros(size(filename));
    R = bS(k);
    grid = gS * R; % establish grid
    
    % create brush stroke shape (circle)
    SE = strel('disk',R,8);
    SE = getnhood(SE);
    [mskR, mskC] = size(SE);
    
    % create reference image using gaussian blur
    refImg = imgaussfilt(filename,bF*R);
    ref2 = double(refImg);
    
    % get luminance
    lum = rgb2ycbcr(refImg);
    lum = lum(:,:,1);

    % get gradient properties
    [Gx, Gy] = imgradientxy(lum, 'sobel');
    [Gmag,~] = imgradient(Gx,Gy);
    
    % get difference between canvas and ref image
    diff = (canvas - double(refImg)).^2;
    diff = (diff(:,:,1) + diff(:,:,2) + diff(:,:,3)).^(1/2);

    % randomly assign grid order
    rows = grid:grid:m-grid;
    rows = rows(randperm(numel(rows)));
    columns = grid:grid:n-grid;
    columns = columns(randperm(numel(columns)));
    
    % scan the grid
    for i = 1:numel(rows)
        r = rows(i);
        for j = 1:numel(columns)
            c = columns(j);
            K = zeros(2,1);
            % make mask of the difference
            diffMask = diff(r-(grid/2)+1:r+(grid/2),c-(grid/2)+ 1:c+(grid/2),:);
            % sum the error in the mask
            areaError = sum(sum(diffMask)) / grid^2;
            if areaError > T
                % find largest error point
                [~, idx] = max(diffMask(:));
                [y, x] = ind2sub(size(diffMask),idx);
                y = r + y; x = c + x; % position of pix in src
                % get color of point from ref image
                strokeColor = ref2(y, x, :);
                K(1,1) = x; K(2,1) = y;
                lastDx = 0; lastDy = 0;
                
                % determine set of points in stroke
                si = 0;
                for s = 1:maxSL
                    if y > m || x > n || y < 1 || x < 1
                        break
                    end
                    si = si + 1;
                    if si > minSL && ...
                            abs(ref2(y,x,1)-canvas(y,x,1)) < ...
                            abs(ref2(y,x,1)-strokeColor(1)) && ...
                            abs(ref2(y,x,2)-canvas(y,x,2)) < ...
                            abs(ref2(y,x,2)-strokeColor(2)) && ...
                            abs(ref2(y,x,3)-canvas(y,x,3)) < ...
                            abs(ref2(y,x,3)-strokeColor(3))
                        break
                    end
                    if Gmag(y,x) == 0
                        break
                    end

                    % first point direction
                    dx = -Gy(y,x); dy = Gx(y,x);
                    % if necessary, reverse direction
                    if (lastDx * dx + lastDy * dy < 0)
                        dx = -dx; dy = -dy;
                    end
                    % filter the stroke direction
                    dx = bC*dx + (1-bC)*(lastDx);
                    dy = bC*dy + (1-bC)*(lastDy);
                    dx = dx /(dx^2 + dy^2)^(1/2);
                    dy = dy /(dx^2 + dy^2)^(1/2);
                    x = floor(x + R*dx); y = floor(y + R*dy);
                    lastDx = dx; lastDy = dy;
                    K(1,s+1) = x; K(2,s+1) = y;
                end

                % paint the stroke
                for s = 1:size(K,2)
                    y = K(2,s);
                    x = K(1,s);
                    clear mask
                    mask(:,:,1) = strokeColor(1)*SE; 
                    mask(:,:,2) = strokeColor(2)*SE;
                    mask(:,:,3) = strokeColor(3)*SE;
                    rowMin = y - floor(mskR/2);
                    rowMax = y + floor(mskR/2);
                    colMin = x - floor(mskC/2);
                    colMax = x + floor(mskC/2);
                    if rowMax<= m && rowMin > 0 && ...
                            colMax<=n  && colMin > 0
                        ovlp = ~(mask & imgBlank(rowMin:rowMax,colMin:colMax,1:3));
                        mask = mask.*ovlp;
                        mask = mask + imgBlank(rowMin:rowMax,colMin:colMax,1:3);
                        imgBlank(rowMin:rowMax,colMin:colMax,1:3) = mask;
                    end
                end
            end
        end
    end
    mask = ~(imgBlank ~=0);
    imgOut = imgOut.*mask;
    imgOut = imgOut + imgBlank;
    canvas = imgOut;
    canvas = double(canvas);
end

canvas = ones(size(filename))*128;
ovlp = ~(imgOut & canvas);
canvas = canvas.*ovlp;
imgOut = imgOut + canvas;
imgOut = uint8(imgOut);
end
