clear all;
close all;

img = imread('tomatos.jpg');
global T;
T = 100;
global fg;
fg = 1;
global fs;
fs = 0.5;
global fc;
fc = 1;
global maxL;
maxL = 16;
global minL;
minL = 4;

painting = paint(img,[2,4,8]);

figure;
subplot(1,2,1);
imshow(img);
subplot(1,2,2);
imshow(painting);

function painting = paint(srcImg, R)    
    global fs;
    srcImg = double(srcImg);
    painting = zeros(size(srcImg));
    R = sort(R,'descend');
    n = length(R);
    
    for i = 1:n
        canvas = 255.*ones(size(srcImg));
        refImg = imgaussfilt(srcImg,fs*R(i));
        layer = paintLayer(canvas, refImg, R(i));
        painting = layer + canvas;
    end
    painting = uint8(painting);
end

function layer = paintLayer(canvas, refImg, R)
    global fg;
    global T;
    layer = zeros(size(canvas));
    S = [];
    D = difference(canvas, refImg);
    step = fg*R;
    h = size(refImg,1);
    w = size(refImg,2);
    ygrid = step:step:h-step;
    xgrid = step:step:w-step;
    yorder = randperm(floor(h/step)-1);
    ygrids = ygrid(yorder);
    xorder = randperm(floor(w/step)-1);
    xgrids = xgrid(xorder);
    
    for x = 1:length(xgrids)
        j = xgrids(x)-(step/2)+1:xgrids(x)+(step/2);
        for y = 1:length(ygrids)
            i = ygrids(y)-(step/2)+1:ygrids(y)+(step/2);
            aD = D(i,j);
            aErr = sum(sum(aD))/step^2;
            if aErr > T
                [maxErr, id] = max(aD(:));
                [y1, x1] = ind2sub(size(aD),id);
                y1 = ygrids(y) + y1;
                x1 = xgrids(x) + x1;
                stroke = makeStroke(R,x1,y1,refImg,canvas);
                S = [S, {stroke}];
            end
        end
    end
    
    if ~isempty(S)
        tip = circle(R);
        for s = 1:length(S)
            sColour = S{s}{1}{1};
            tipR = tip*sColour(1,1,1);
            tipG = tip*sColour(1,1,2);
            tipB = tip*sColour(1,1,3);
            brush = cat(3,tipR,tipB,tipG);
            for p = 2:length(S{s})
                point = S{s}{p};
                x = point(1);
                y = point(2);
                if x >= R && y >= R && x <= size(refImg,2)-R && y <= size(refImg,1)-R
                    painted = (brush.*layer(y-R+1:y+R-1,x-R+1:x+R-1,:) ~= 0);
                    clean = (painted == 0);
                    layer(y-R+1:y+R-1,x-R+1:x+R-1,:) = brush.*clean;
                end    
            end
        end
    end
end

function diff = difference(img1,img2)
    diff = ((img1(:,:,1)-img2(:,:,1)).^2 + (img1(:,:,2)-img2(:,:,2)).^2 + (img1(:,:,3)-img2(:,:,3)).^2).^(1/2);
end

function c = circle(R)
    c = zeros(R);
    for x = R:-1:1
        y = (R^2 - (x-1)^2)^(1/2);
        y = round(y);
        c(y:-1:1,x) = ones(y,1);
    end
    c = [c(end:-1:2,end:-1:2), c(end:-1:2,:); c(:,end:-1:2), c];

end

function K = makeStroke(R,x0,y0,refImg,canvas)
    global fc;
    global maxL;
    global minL;
    
    sColour = refImg(y0,x0,:);
    K = {sColour};
    x = x0;
    y = y0;
    dxF = 0;
    dyF = 0;
    K = {K,[x; y]};
    L = 0.30.*refImg(:,:,1) + 0.59.*refImg(:,:,2) + 0.11.*refImg(:,:,3);
    [Gx, Gy] = imgradientxy(L);
    [Gmag, Gdir] = imgradient(Gx, Gy);
    
    for i = 1:maxL
        if x < 1 || y < 1 || x > size(refImg,2) || y > size(refImg,1)
            return;
        end
        
        colour = refImg(y,x,:);
        cColour = canvas(y,x,:);
        if (i > minL) && (difference(colour,cColour) < difference(colour,sColour))
            return;
        end

        if Gmag(y,x) == 0
            return;
        end
        
        dx = -Gy(y,x);
        dy = Gx(y,x);
        
        if (dxF*dx + dyF*dy < 0)
            dx = -dx;
            dy = -dy;
        end
        
        dx = fc*dx + (1-fc)*dxF;
        dy = fc*dy + (1-fc)*dyF;
        dx = dx/(dx^2 + dy^2)^(1/2);
        dy = dy/(dx^2 + dy^2)^(1/2);
        x = floor(x + R*dx);
        y = floor(y + R*dy);
        dxF = dx;
        dyF = dy;
        K = [K, [x, y]];
    end
end