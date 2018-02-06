function paintImg = renderPaint(imgName,T,fg,fs,fc,maxLen,minLen,brushR,C) 
% Returns painterly non-photorealistic rendering (NPR) of image for given
% parameters defining the size of oil painting brush strokes. This program
% is an adaptation of the algorithm described in Aaron Hertzmann's 1998
% paper, "Painterly Rendering with Curved Brush Strokes of Multiple Sizes".
%
% The parameters are:
% imgName: character string of the file name of the image to be rendered.
% T:        the approximation threshold defining how close the stroke
%           colour is to original image. Higher T -> rougher painting.
% fg:       grid size. Scales the increment or spacing of the brush stroke
%           grid size. Step size is the brush radius size scaled by fg.  
% fs:       blur factor. Scales the standard deviation of Gaussian filter. 
%           Smaller -> more noise (more impressionist).
% fc:       curvature filter. Limits or exaggerates the brush stroke 
%           curvature.
% maxLen:   maximum length of stroke. Shorter stroke makes painting more
%           Pointillist.
% minLen:   minimum length of stroke. Longer stroke makes painting more
%           Expressionist.
% brushR:   brush sizes. A list of n brush sizes (radius). Fewer leads to
%           better performance.
% C:        canvas constant paint colour (background).
%
% A classic parameter set is the Impressionist style: T = 50, fg = 1, 
% fs = 0.5, fc = 1, maxLen = 16, minLen = 4, brushR = [8,4,2]. Or:
% renderPaint(FileName,50,1,0.5,1,16,4,[8,4,2],[128,128,128])
    
    img = imread(imgName); % original image
    paintImg = paint(img, brushR); % painterly rendering of image

    function painting = paint(origImg, R)    
        painting = zeros(size(origImg));
        R = sort(R,'descend'); % largest brush strokes painted first
        n = length(R);
        for i = 1:n % for each brush radius
            canvas = ones(size(origImg));
            canvas(:,:,1) = C(1).*canvas(:,:,1); % R
            canvas(:,:,2) = C(2).*canvas(:,:,2); % G
            canvas(:,:,3) = C(3).*canvas(:,:,3); % B
            % Gaussian filter of original image to smooth edges at
            % different radii
            filteredImg = imgaussfilt(origImg,fs*R(i));
            layer = paintLayer(canvas, filteredImg, R(i)); % paints layer
            % paints layer over blank canvas and over previous layers
            blank = (layer == 0);
            notLayer = canvas.*blank;
            painting = (painting).*(painting ~= 0).*(blank) + ...
                       (painting ~=0).*(layer ~= 0).*(layer) + ...
                       (notLayer + layer).*(painting == 0);
        end
        painting = uint8(painting); % output painting rendering
    end

    function layer = paintLayer(canvas, img, R)
        img = double(img);
        layer = zeros(size(canvas));
        % difference in canvas and image colour
        D = difference(canvas(:,:,1:3), img(:,:,1:3));
        % calculated luminance
        L = 0.299.*img(:,:,1) + 0.587.*img(:,:,2) + 0.114.*img(:,:,3);
        % gradient of luminance of image
        [Gx, Gy] = gradient(L);
        G = (Gx.^2 + Gy.^2).^(1/2); % gradient magnitude
        
        step = fg*R; % grid step size
        ygrid = step:step:size(img,1)-step;
        xgrid = step:step:size(img,2)-step;
        % randomly orders grid so strokes looks more artistic and creative
        yorder = ygrid(randperm(length(ygrid)));
        xorder = xgrid(randperm(length(xgrid)));
        
        for x0 = 1:length(xorder)
            j = xorder(x0)-(step/2)+1:xorder(x0)+(step/2);
            for y0 = 1:length(yorder)
                i = yorder(y0)-(step/2)+1:yorder(y0)+(step/2);
                aD = D(i,j); % grid area colour difference
                aErr = sum(sum(aD))/step^2;
                if aErr > T % only if area error exceeds threshold
                    [~, id] = max(aD(:)); % pixel with greatest error 
                    [yi, xi] = ind2sub(size(aD),id);
                    y1 = yorder(y0) + yi;
                    x1 = xorder(x0) + xi;
                    % coordinates/points of stroke of a certain RGB colour
                    [S, strokeRGB] = makeStroke(R,x1,y1,img,canvas,Gx,Gy,G);
                    if ~isempty(S)
                        tip = circle(R); % brush is circular element
                        tipX = floor(size(tip,2)/2);
                        tipY = floor(size(tip,1)/2);
                        tipR = tip*strokeRGB(1,1,1);
                        tipG = tip*strokeRGB(1,1,2);
                        tipB = tip*strokeRGB(1,1,3);
                        brush = cat(3,tipR,tipG,tipB);
                        
                        for p = 1:size(S,2) % for each stroke point
                            point = S(1:2,p);
                            x = point(1,1);
                            y = point(2,1);
                            xMax = size(img,2) - tipX;
                            xMin = 1 + tipX;
                            yMax = size(img,1) - tipY;
                            yMin = 1 + tipY;
                            % paints stroke on layer
                            if x >= xMin && x <= xMax && ...
                               y >= yMin && y <= yMax
                                area = layer(y-tipY:y+tipY,...
                                             x-tipX:x+tipX,1:3);
                                painted = (brush.*area ~= 0);
                                clean = (painted == 0);
                                layer(y-tipY:y+tipY,x-tipX:x+tipX,1:3)...
                                    = area + brush.*clean;
                            end    
                        end
                    end
                end
            end
        end
    end

    function diff = difference(img1,img2)
        % computes difference of three dimensional vector (e.g. RGB colour)
        diff = ((diffCh(img1(:,:,1),img2(:,:,1))).^2 + ...
                (diffCh(img1(:,:,2),img2(:,:,2))).^2 + ...
                (diffCh(img1(:,:,3),img2(:,:,3))).^2).^(1/2);
    end

    function dch = diffCh(ch1,ch2)
        % absolute difference of an one dimensional vector (e.g. a RGB 
        % colour channel)
        dch = abs(ch1-ch2);
    end

    function c = circle(R)
        % creates circular brush element for a given radius
        if R < 3 % keeps non-zero brush element circular and not square
            R = R + 1;
        end
        c = zeros(R);
        for x = R:-1:1 % for one quadrant of circle
            y = (R^2 - (x-1)^2)^(1/2);
            y = floor(y);
            c(y:-1:1,x) = ones(y,1);
        end
        % forms circle out of quadrant
        c = [c(end:-1:2,end:-1:2), c(end:-1:2,:); c(:,end:-1:2), c];
    end

    function [K, strokeClr] = makeStroke(R,x0,y0,img,canvas,Gx,Gy,G)
        % paints stroke given initial image coordinate, gradient, and
        % colour
        strokeClr = img(y0,x0,:); % colour of the stroke
        x = x0;
        y = y0;
        dxF = 0; % final gradient change
        dyF = 0;
        K = [x; y]; % points of stroke

        for i = 1:maxLen % stroke is limited by the maximum length
            % coordinate must be within image dimensions
            if x < 1 || y < 1 || x > size(img,2) || y > size(img,1)
                return;
            end
            
            colour = img(y,x,:); % colour at coordinate
            canvasClr = canvas(y,x,:); % colour of canvas
            diffR = diffCh(colour(:,:,1),canvasClr(:,:,1)) ... 
                    < diffCh(colour(:,:,1),strokeClr(:,:,1));
            diffG = diffCh(colour(:,:,2),canvasClr(:,:,2)) ...
                    < diffCh(colour(:,:,2),strokeClr(:,:,2));
            diffB = diffCh(colour(:,:,3),canvasClr(:,:,3)) ...
                    < diffCh(colour(:,:,3),strokeClr(:,:,3));
            diffColour = (diffR && diffG && diffB);
            % returns stroke if colour difference exceeded
            if (i > minLen) && (diffColour) 
                return;
            end

            if G(y,x) == 0 % returns if gradient zero
                return;
            end
            % normal gradient to stroke path
            dx = -Gy(y,x);
            dy = Gx(y,x);
            if (dxF*dx + dyF*dy < 0) % ensures positve normal gradient
                dx = -dx;
                dy = -dy;
            end
            % gradient curvature
            dx = fc*dx + (1-fc)*dxF;
            dy = fc*dy + (1-fc)*dyF;
            % normalises gradient
            dx = dx/(dx^2 + dy^2)^(1/2);
            dy = dy/(dx^2 + dy^2)^(1/2);
            % advances coordinate by integer amount of gradient scaled by
            % brush size
            x = floor(x + R*dx);
            y = floor(y + R*dy);
            dxF = dx;
            dyF = dy;
            K = [K, [x; y]]; % updates stroke points
        end
    end
end