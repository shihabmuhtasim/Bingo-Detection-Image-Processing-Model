function angle = findRotationAngle(M)



%Edge Detection using canny edge
    smoothing = imgaussfilt(M, 4);
    E_smoothing = edge(smoothing, 'sobel');
    [Hough_M, theta, rho] = hough(E_smoothing);
    [~, idx] = max(Hough_M(:));
    [~, col] = ind2sub(size(Hough_M), idx);
   
    angle = theta(col);


    %thesholding so that other lines are not taken into consideration

    if angle>45
        rot= abs(angle)-90;
    elseif angle<-45
        rot= 90-abs(angle);
    else
        rot = angle;
    end


angle= rot;














% function angle = findRotationAngle(M)
% FINDROTATIONANGLE - Finds the rotation angle of a card from FFT magnitude
% Input:
%   M - magnitude of FFT of edge image (2D matrix)
% Output:
%   angle - rotation angle in degrees (to straighten the image)

% Get size of FFT magnitude image
% Apply Canny edge detector on the FFT magnitude image
%edges = edge(M, 'Canny',0.2);

% Smooth the edges using a Gaussian filter
%edges_smoothed = imgaussfilt(double(edges), 4); % Adjust sigma as needed

%M=edges_smoothed;

% % Plot the resulting image
% figure;
% imshow(M, []);
% title('Thresholded FFT Magnitude');

% 
% [height, width] = size(M);
% 
% % Mask the center to ignore DC peak and low frequency noise
% % PARAMETER TWEAK: maskSize - Try reducing this for subtle rotations
% maskSize = 2; % Changed from 10 to 5
% center_y = height/2;
% center_x = width/2;
% M(round(center_y)-maskSize:round(center_y)+maskSize, ...
%   round(center_x)-maskSize:round(center_x)+maskSize) = 0;
% 
% % PARAMETER TWEAK: Add a threshold to suppress low-magnitude noise
% % This is crucial for distinguishing true peaks from background noise, especially for subtle rotations.
% magnitude_noise_threshold = 0.02 * max(M(:)); % Experiment with 0.01 to 0.05
% M(M < magnitude_noise_threshold) = 0;
% 
% % Optional: Small Gaussian blur to make peaks more coherent and reduce isolated noise points
% M = imgaussfilt(M, 3); % Experiment with sigma = 0.5 to 2
% 
% % Find the brightest point (global maximum) in the masked and possibly filtered magnitude spectrum
% [~, idx] = max(M(:));
% [y_peak, x_peak] = ind2sub(size(M), idx);
% 
% % If after thresholding, M is all zeros, or peak is at center, it implies no clear orientation.
% if y_peak == round(center_y) && x_peak == round(center_x)
%     angle = 0; % Assume no rotation if peak is (or was) at center
%     warning('No clear dominant orientation found. Assuming zero rotation.');
%     return;
% end
% 
% % Compute displacement of the peak from the center of the magnitude spectrum
% dY = y_peak - center_y;
% dX = x_peak - center_x;
% 
% % Calculate the angle of the line connecting the center to the peak, relative to the positive x-axis.
% peak_angle_rads = atan2(dY, dX);
% peak_angle_deg = rad2deg(peak_angle_rads);
% 
% % Normalize peak angle to [0, 180) range (line orientation)
% if peak_angle_deg < 0
%     peak_angle_deg = peak_angle_deg + 180;
% end
% if peak_angle_deg >= 180
%     peak_angle_deg = peak_angle_deg - 180;
% end
% 
% % Calculate the orientation of the dominant features in the spatial domain (perpendicular to Fourier peak).
% spatial_orientation_deg = peak_angle_deg - 90;
% 
% % Normalize spatial orientation to [-45, 45] for shortest rotation
% if spatial_orientation_deg > 45
%     spatial_orientation_deg = spatial_orientation_deg - 90;
% elseif spatial_orientation_deg < -45
%     spatial_orientation_deg = spatial_orientation_deg + 90;
% end
% 
% % The angle to rotate the image by to make its features horizontal is the negative of this orientation.
% angle = -spatial_orientation_deg;
% 
% 
% % 
% % % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % % function angle = findRotationAngle(M)
% % % % FINDROTATIONANGLE - Finds the rotation angle of a card from FFT magnitude
% % % % Input:
% % % %   M - magnitude of FFT of edge image (2D matrix)
% % % % Output:
% % % %   angle - rotation angle in degrees (to straighten the image)
% % % 
% % % % Size of FFT
% % % [height, width] = size(M);
% % % 
% % % % Mask the center to ignore DC peak
% % % maskSize = 20;
% % % M(round(height/2)-maskSize:round(height/2)+maskSize, ...
% % %   round(width/2)-maskSize:round(width/2)+maskSize) = 0;
% % % 
% % % % Find the brightest point (max value)
% % % [~, idx] = max(M(:));
% % % [y, x] = ind2sub(size(M), idx);
% % % 
% % % % Compute displacement from center
% % % dY = y - height/2;
% % % dX = x - width/2;
% % % 
% % % % Angle relative to horizontal
% % % angle = atan2d(dY, dX);
% % % 
% % % end
% % % 
% % % 
% % % % function angle = findRotationAngle(M)
% % % % % Finds rotation angle using multiple peaks in FFT magnitude
% % % % 
% % % % [height, width] = size(M);
% % % % 
% % % % % Mask center (DC / low frequency)
% % % % maskSize = 2;
% % % % center_y = height/2;
% % % % center_x = width/2;
% % % % M(center_y-maskSize:center_y+maskSize, center_x-maskSize:center_x+maskSize) = 0;
% % % % 
% % % % % Remove low-magnitude noise
% % % % noise_thresh = 0.02 * max(M(:));
% % % % M(M < noise_thresh) = 0;
% % % % 
% % % % % Slight blur
% % % % M = imgaussfilt(M, 1);
% % % % 
% % % % % Find top N peaks
% % % % N = 5;  % number of peaks to consider
% % % % angles = zeros(N,1);
% % % % tempM = M;
% % % % 
% % % % for k = 1:N
% % % %     [~, idx] = max(tempM(:));
% % % %     [y_peak, x_peak] = ind2sub(size(tempM), idx);
% % % % 
% % % %     % compute angle from center
% % % %     dY = y_peak - center_y;
% % % %     dX = x_peak - center_x;
% % % %     peak_angle = rad2deg(atan2(dY, dX));
% % % %     if peak_angle < 0
% % % %         peak_angle = peak_angle + 180;
% % % %     end
% % % %     angles(k) = peak_angle;
% % % % 
% % % %     % mask out a small neighborhood around this peak so next peak is different
% % % %     mask_radius = 5;
% % % %     y1 = max(y_peak-mask_radius,1); y2 = min(y_peak+mask_radius,height);
% % % %     x1 = max(x_peak-mask_radius,1); x2 = min(x_peak+mask_radius,width);
% % % %     tempM(y1:y2,x1:x2) = 0;
% % % % end
% % % % 
% % % % % Take median of top peaks
% % % % peak_angle_deg = median(angles);
% % % % 
% % % % % Dominant features are perpendicular to Fourier peak
% % % % spatial_orientation = peak_angle_deg - 90;
% % % % 
% % % % % Normalize to [-45,45]
% % % % if spatial_orientation > 45
% % % %     spatial_orientation = spatial_orientation - 90;
% % % % elseif spatial_orientation < -45
% % % %     spatial_orientation = spatial_orientation + 90;
% % % % end
% % % % 
% % % % % Angle to rotate image
% % % % angle = -spatial_orientation;
% % % % 
% % % % end
% % % % 
% % % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % % 
% % 
% % % function angle = findRotationAngle(M)
% % % % FINDROTATIONANGLE - Estimate rotation angle of a grid from FFT magnitude
% % % % Input: M - 2D FFT magnitude (log) of edge image
% % % % Output: angle - rotation angle in degrees
% % % 
% % % % Step 1: Get image size
% % % [height, width] = size(M);
% % % 
% % % % Step 2: Mask out low-frequency central region
% % % maskSize = 1; % can tweak
% % % centerY = round(height/2);
% % % centerX = round(width/2);
% % % M(centerY-maskSize:centerY+maskSize, centerX-maskSize:centerX+maskSize) = 0;
% % % 
% % % % Step 3: Find maximum value in the masked magnitude
% % % [~, linearIndex] = max(M(:));
% % % [yMax, xMax] = ind2sub(size(M), linearIndex);
% % % 
% % % % Step 4: Compute relative coordinates to center
% % % dx = xMax - centerX;
% % % dy = centerY - yMax; % image coordinates have y downward
% % % 
% % % % Step 5: Compute angle in degrees
% % % angle = atan2d(dy, dx);
% % % 
% % % end