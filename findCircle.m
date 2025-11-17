function [coord, Hough_space] = findCircle(I, num_of_circles, radius)


%% Detect only RED regions 
if size(I,3) == 3
    % Normalize RGB channels to [0,1]
    I = im2double(I);
    % A pixel is "red" if Red is strong
    redMask = (I(:,:,1) > 0.6) & (I(:,:,2) < 0.4) & (I(:,:,3) < 0.4);
    redMask = bwareaopen(redMask, 30);
end

I = double(redMask);


Accumulator = zeros(size(I));

%% Hough voting for possible circle centers
for r = radius-2 : radius+2  % allow small radius variation
    for y = 1:size(I,1)
        for x = 1:size(I,2)
            if I(y,x) > 0   % red pixel found
                for theta = 0:360
                    b = abs(round(y - r*sind(theta)));
                    a = abs(round(x - r*cosd(theta)));
                    if a>0 && a<=size(I,2) && b>0 && b<=size(I,1)
                        Accumulator(b,a) = Accumulator(b,a) + 1;
                    end
                end
            end
        end
    end
end

%% Apply strong threshold to remove weak peaks 
threshold = 0.8 * max(Accumulator(:));  % keep only strong peaks
AccumulatorFiltered = Accumulator;
AccumulatorFiltered(AccumulatorFiltered < threshold) = 0;

%% Find circle centers from filtered accumulator 
coord = [];
AccumulatorTemp = AccumulatorFiltered;

for i = 1:num_of_circles
    [maxVal, linearIndexesOfMaxes] = max(AccumulatorTemp(:));
    if maxVal < threshold
        break;
    end

    [y, x] = ind2sub(size(AccumulatorTemp), linearIndexesOfMaxes);

    % Mask nearby region to avoid duplicates
    mask_size = 40;
    y1 = max(y - mask_size, 1);
    y2 = min(y + mask_size, size(AccumulatorTemp,1));
    x1 = max(x - mask_size, 1);
    x2 = min(x + mask_size, size(AccumulatorTemp,2));
    AccumulatorTemp(y1:y2, x1:x2) = 0;

    % Save coordinates
    coord = [coord; [x y]];
end

Hough_space = Accumulator;
end
