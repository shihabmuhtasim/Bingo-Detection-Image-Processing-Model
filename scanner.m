function [digitizedArray, bingoFlag] = scanner(imageMatrix, verbose)

if nargin < 2
    verbose = false;
end

% Convert to HSV and Create Brightness Mask
hsvI = rgb2hsv(imageMatrix);          % Convert RGB to HSV color space
value = hsvI(:,:,3);                  % Extract brightness (Value) channel

% Create mask for bright areas
threshold = 0.2;                     
masked = value > threshold;          

%Convert logical mask to grayscale 
maskedGray = uint8(masked) * 255;     

grayImage = rgb2gray(imageMatrix);
stretchedImage = imadjust(maskedGray, stretchlim(maskedGray), []);


%% Edge detection 
edges = edge(stretchedImage, 'Prewitt', 0.17);

%% Rotation correction using FFT
F = fft2(edges);
F = fftshift(F);
Magnitude = log(double(abs(F)) + 1e-9);

angleOfRotation = findRotationAngle(Magnitude);
rotatedGray = imrotate(grayImage, angleOfRotation);
rotatedOriginal = imrotate(imageMatrix, angleOfRotation, 'bicubic', 'loose');
rotatedEdges = imrotate(edges, angleOfRotation);



%Cropping the top 18% of the rotaeted edge image and later will map if /
%adjust with the gray image using the offset

cropOffset = round(size(rotatedEdges,1) * 0.18);
rotatedEdges = rotatedEdges(cropOffset:end, :);

% Expand the thickness of the white pixels in the rotatedEdges 
se = strel('line', 3, 0);  
rotatedEdges = imdilate(rotatedEdges, se);  

%Find lines using hough transform
[H_lines, theta, rho] = hough(rotatedEdges);
% 15 peaks with the side boxs and then later remove, not 16 because cropped
% top 20%

numPeaks = 15;

P = houghpeaks(H_lines, numPeaks, 'threshold', ceil(0.3*max(H_lines(:))));

% converting the peaks to normal space in lines
lines = houghlines(rotatedEdges, theta, rho, P, 'FillGap', 20, 'MinLength', 30);


% Filter unique lines based on theta and rho as due to holes some lines may
% be detected multiple times
thetas = [lines.theta];
rhos = [lines.rho];
t_r = [thetas' rhos'];
[~, uniqueIdx] = unique(t_r, 'rows');
lines = lines(uniqueIdx);


% Adjusting with the rotated image the cropped part so that the coordinates
% match
for i = 1:length(lines)
    lines(i).point1(2) = lines(i).point1(2) + cropOffset;
    lines(i).point2(2) = lines(i).point2(2) + cropOffset;
end

%% Detect circle centers
%rough value for the number of circles
numCircles = 11;
radiusEstimate = 55;
[centers, HoughCircles] = findCircle(rotatedOriginal, numCircles, radiusEstimate);

%Sorting the centers
if ~isempty(centers)
    centers = sortrows(centers, [2,1]); 
end

%% Map detected centers  to digitized
digitizedArray = zeros(5,5);    

if ~isempty(centers)
    centers = double(centers);  

    % --- Separate vertical and horizontal lines ---
    verticalLines = [];
    horizontalLines = [];
    for k = 1:length(lines)
        x1 = lines(k).point1(1); x2 = lines(k).point2(1);
        y1 = lines(k).point1(2); y2 = lines(k).point2(2);
        if abs(x1-x2) < abs(y1-y2)
            verticalLines(end+1) = mean([x1 x2]);
        else
            horizontalLines(end+1) = mean([y1 y2]);
        end
    end

    verticalLines = sort(unique(verticalLines));
    horizontalLines = sort(unique(horizontalLines));
    
    % fprintf('Vertical lines: '); disp(verticalLines);
    % fprintf('Horizontal lines: '); disp(horizontalLines);

    % Remove the first vertical line and the last vertical line as those
    % are outer box lines
    
    verticalLines(1) = [];
    verticalLines(end) = [];

    horizontalLines(end) = [];

    %need later for plotting bingo
    colEdges = [verticalLines(1), verticalLines(end)];
    rowEdges = [horizontalLines(1), horizontalLines(end)];
    colBoundaries = linspace(colEdges(1), colEdges(2), 6);
    rowBoundaries = linspace(rowEdges(1), rowEdges(2), 6);



    %% Assign detected centers to 5x5 grid 
    for k = 1:size(centers,1)
        cx = centers(k,1);
        cy = centers(k,2);

        colIdx = find(cx >= verticalLines(1:end-1) & cx < verticalLines(2:end), 1);
        if isempty(colIdx)
            if cx < verticalLines(1)
                colIdx = 1;
            elseif cx >= verticalLines(end)
                colIdx = 5;
            end
        end

        rowIdx = find(cy >= horizontalLines(1:end-1) & cy < horizontalLines(2:end), 1);
        if isempty(rowIdx)
            if cy < horizontalLines(1)
                rowIdx = 1;
            elseif cy >= horizontalLines(end)
                rowIdx = 5;
            end
        end

        if ~isempty(rowIdx) && ~isempty(colIdx)
            rowIdx = min(max(rowIdx,1),5);
            colIdx = min(max(colIdx,1),5);
            digitizedArray(rowIdx, colIdx) = 1;
            % fprintf('Center (%.1f, %.1f) -> Cell (%d, %d)\n', cx, cy, rowIdx, colIdx);
        
        end
    end
end

% Free box adding 1
digitizedArray(3,3) = 1;



%% Step 8: Check bingo
bingoFlag = checkBingo(digitizedArray);

%% Step 9: Visualization
if verbose
    figure('Name','Scanner Debug','NumberTitle','off','Units','normalized','Position',[0.05 0.05 0.9 0.7]);

    subplot(2,3,1); imshow(imageMatrix); title('Original Image');

    subplot(2,3,2); imagesc(Magnitude); axis image; colormap jet; colorbar; title('FFT magnitude');

    subplot(2,3,3); imshow(rotatedOriginal); title(sprintf('Rotated Original (angle=%.2f°)', angleOfRotation));

    %% Step 4 Visualization: Line Hough Space (enhanced like solution)
    subplot(2,3,4);
    imshow(imadjust(mat2gray(H_lines)), 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit');
    colormap(gca, 'gray');
    colorbar;
    xlabel('\theta (degrees)'); ylabel('\rho (pixels)'); axis on; axis normal; hold on; title('Line Hough Transform');
    % Convert peak indices into theta and rho coordinates
    x_peaks = theta(P(:,2));
    y_peaks = rho(P(:,1));
    % Plot peaks as red squares
    plot(x_peaks, y_peaks, 'rs', 'LineWidth', 2, 'MarkerSize', 8);

    %% Subplot 5: Circle Hough Transform with Peaks 
    subplot(2,3,5); imagesc(HoughCircles); colormap(gray); colorbar; axis image tight; title('Circle Hough Transform'); hold on;

    % Find the peaks in HoughCircles (accumulator)
    thresh = max(HoughCircles(:)) * 0.85; % % of the maximum vote
    [yc, xc] = find(HoughCircles > thresh);  % peak positions
    % Plot red squares at detected peaks
    plot(xc, yc, 'rs', 'LineWidth', 2, 'MarkerSize', 8); hold off;


    %% LAST PLOT
    subplot(2,3,6);  
imshow(rotatedGray); hold on;
title('Detected Centers & Grid Lines');

% Plot detected circle centers
if ~isempty(centers)
    viscircles(centers, ones(size(centers,1),1)*10, 'EdgeColor','r','LineWidth',0.8);
end 

% --- Plot vertical lines ---
for i = 1:length(verticalLines)
    x = [verticalLines(i), verticalLines(i)];
    y = [min(horizontalLines), max(horizontalLines)]; % extend between first and last horizontal line
    plot(x, y, 'b-', 'LineWidth', 2);
end

% --- Plot horizontal lines ---
for j = 1:length(horizontalLines)
    y = [horizontalLines(j), horizontalLines(j)];
    x = [min(verticalLines), max(verticalLines)]; % extend between first and last vertical line
    plot(x, y, 'b-', 'LineWidth', 2);
end



    if ~isempty(centers)
        viscircles(centers, ones(size(centers,1),1)*10, 'EdgeColor','r','LineWidth',0.8);
    end 
    
    %Find bingo line will return rowWin row number if bingo row wise, or column
    %no if column wise, then 1 if normal diagoral 2 if anti diag
  
    [rowWin, colWin, diagFlag] = findBingoLine(digitizedArray);
    
    % Draw green bingo line using grid boundaries 
    if exist('rowBoundaries','var') && exist('colBoundaries','var')
        
        if ~isempty(rowWin)
            % Horizontal bingo - average the top and bottom boundary of that row
            ycoord = mean([rowBoundaries(rowWin), rowBoundaries(rowWin+1)]);
            plot([1 size(rotatedGray,2)], [ycoord ycoord], 'g-', 'LineWidth', 4);
            
    
        elseif ~isempty(colWin)
            % Vertical bingo - average the left and right boundary of that column
            xcoord = mean([colBoundaries(colWin), colBoundaries(colWin+1)]);
            plot([xcoord xcoord], [1 size(rotatedGray,1)], 'g-', 'LineWidth', 4);
            
    
        elseif diagFlag == 1
            % Main diagonal 
            plot([colBoundaries(1) colBoundaries(end)], ...
                 [rowBoundaries(1) rowBoundaries(end)], 'g-', 'LineWidth', 4);
           
    
        elseif diagFlag == 2
            % Anti-diagonal 
            plot([colBoundaries(end) colBoundaries(1)], ...
                 [rowBoundaries(1) rowBoundaries(end)], 'g-', 'LineWidth', 4);
            
        end    
    end
    end
    



