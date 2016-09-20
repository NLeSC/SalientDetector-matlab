% test_DDBinarizer- testing the data-driven binarization (data_driven_binarizer)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 20-09-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT NOTE
% Please, change the starting and project paths to point at your repo directory!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details:
%**************************************************************************
%% paramaters
verbose = false;
visualize = true;
if visualize
    set(0,'Units','pixels')
    scnsize = get(0,'ScreenSize');
end


%% parameters
SE_size_factor = 0.02;
Area_factor_very_large = 0.01;
Area_factor_large = 0.001;
lambda_factor = 3;
step_size = 1;
offset = 80;
otsu_only = false;
conn = 8;
weight_all = 0.33;
weight_large = 0.33;
weight_very_large = 0.33;

%% image filename
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','SalientDetector-matlab');
data_path = fullfile(project_path, 'TestData');
results_path = fullfile(project_path, 'TestResults');


test_images = {'gray'};
detector = 'DMSR';

mask_filename =[];

disp('**************************** Testing data-driven binaization *****************');
%% run for all test cases
for test_image = test_images
    data_path_full = fullfile(data_path, char(test_image));
    results_path_full = fullfile(results_path, char(test_image));
    [image_filenames, features_filenames, regions_filenames] = ...
        get_filenames_path(detector, data_path_full, results_path_full);
    disp('Test case: ');disp(test_image);
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    %for i = 1:len
    for i = 1
        disp('Test image #: ');disp(i);
        %disp(image_filenames{i});
        %% load the image & convert to gray-scale if  color
        image_data = imread(char(image_filenames{i}));        
        
        %% run the binarization
        
        j = 0;
        
        morphology_parameters = [SE_size_factor Area_factor_very_large ...
            Area_factor_large lambda_factor conn];
        weights = [weight_all weight_large weight_very_large];
        execution_flags = [verbose visualize];
        
        [binary_image, thresh] = data_driven_binarizer(image_data, ...
            step_size, offset, otsu_only, ...
            morphology_parameters, weights, ...
            execution_flags);
        
    end
    %% visualization
    if visualize
        figure('Position',scnsize);
        
        subplot(121); imshow(image_data); title('Gray-scale image'); axis on, grid on;                        
        subplot(122); imshow(double(binary_image)); axis on;grid on;
        title(['Binarized image at level ' num2str(thresh)]);
        
    end    
   
    
    disp('****************************************************************');
end
disp('--------------- The End ---------------------------------');