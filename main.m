%% Main script
clear all;
close all;
%image loading 
folder = 'input'; 
imageFiles = dir(fullfile(folder, '*.png'));
numImages = length(imageFiles);

% Read all imagess
images = cell(1, numImages);
for ii = 1:numImages
    currentfilename = imageFiles(ii).name;
    currentfilepath = fullfile(folder, currentfilename);
    images{ii} = imread(currentfilepath);
end

% Process images
for ii = 1:numImages
    fprintf('Processing image %d: %s\n', ii, imageFiles(ii).name);
    [digitizedArray, bingoFlag] = scanner(images{ii}, true); 
    fprintf('Digitized Array:\n');
    disp(digitizedArray);
    if bingoFlag
        fprintf('BINGO detected!\n\n');
    else
        fprintf('No bingo.\n\n');
    end
end