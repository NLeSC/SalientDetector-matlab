% test_thresholding.m- script to test gray-level image thresholding evolution
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 26-05-2015
% last modification date: 
% modification details:
%**************************************************************************
%% paramaters
interactive = false;
visualize_major = true;
visualize_minor = false;

% if visualize_major
%   load('MyColormaps','mycmap'); 
% end

%% image filename
if ispc 
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
if interactive 
    image_filename = input('Enter the test image filename: ','s');
else
    test_image = input('Enter test case: [boat|phantom|graffiti|leuven|thorax|bikes]: ','s');
    switch lower(test_image)
        case 'boat'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','boat','boat2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat3.png');
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat5.png');
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','boat','boat6.png');
        case 'phantom'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom.png');
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom_affine.png');
        case 'graffiti'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','graffiti','graffiti1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','graffiti','graffiti2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti3.png');
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti5.png');
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
                'Data','AffineRegions','graffiti','graffiti6.png');
        case 'leuven'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven3.png');    
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven5.png');    
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','leuven','leuven6.png');
        case 'bikes'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes1.png');    
            image_filename{2} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes2.png');
            image_filename{3} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes3.png');    
            image_filename{4} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes4.png');
            image_filename{5} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes5.png');    
            image_filename{6} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','bikes','bikes6.png');
        case 'thorax'
            image_filename{1} = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','CT','thorax1.jpg');
    end


end
 %% input parameters
if interactive
    min_level = input('Enter minimum gray level: ');
    max_level = input('Enter maximum gray level');
    num_levels = input('Enter number of gray-levels');
else
    min_level =  0; max_level = 255; num_levels = [10 20 50];
end

% smoothing with morphology
%se = strel('disk',2);

%% find out the number of test files
len = length(image_filename);

%% loop over all test images
for i = 1:len
    %% load the image
    image_data = imread(image_filename{i});
    if ndims(image_data) > 2
        image_data = rgb2gray(image_data);
    end

   % length(unique(image_data))
    if visualize_major
        % visualize original image
        f = figure; subplot(241); imshow(image_data); title('Original image ');
    end
    %% visualization
    if visualize_minor
        f0 = figure;
    end
    %% histogram equilization
    image_data = histeq(image_data);
    
    %% image blur
    h = fspecial('disk',2);
    image_data=imfilter(image_data,h);
    
    %% threshold the data
    
    [otsu_thr_global,d1,d2,d3] =  otsu_threshold(double(image_data(:)));
    if visualize_major
%        result = imclose(image_data >= otsu_thr_global,se)
        result = image_data >= otsu_thr_global;
        figure(f); subplot(245);imshow(result);
            title('Thresholded qustogram equalized original image');
    end

    num_levels_counter = 0;
    for n = num_levels
         num_levels_counter = num_levels_counter + 1;
%         step = fix((max_level - min_level)/n);
%         if step == 0
%             step = 1;
%         end
%         level_counter =0;
%         for level = min_level:step:max_level
%             level_counter = level_counter+1;
%             thresh_image  = image_data >= level;
%             thresh_data(:,:,level_counter) = thresh_image;
%             if visualize_minor
%                 figure(f0); imshow(thresh_image);
%                 title(['Segmented image at gray level: ' num2str(level)]);
%                 axis on; grid on;
%                 pause(0.2);
%             end
%         end

        %% obtain accumulative threshodilg scores
        quantized_data = gray2ind(image_data, n);
        [otsu_thr, d1, d2, d3] =  otsu_threshold(double(quantized_data(:)));
        %acc_thresh_data = sum(thresh_data,3);
        % [otsu_thr, d1, d2, d3] =  otsu_threshold(double(acc_thresh_data(:)));
        %     %% quantize the image
        %     levels = min_level:step:max_level;
        %     quant_image = imquantize(image_data, levels); % to be used only in versions after 2012b!
        %
        %% visualize
        if visualize_major
            % visualize quantized image
            figure(f);
            subplot(2,4,num_levels_counter+1);
            rgb = label2rgb(quantized_data);
            imshow(rgb); title(['Quantized image with number of levels: ' num2str(n)]);
            freezeColors;
            %imshow(acc_thresh_data,mycmap);
            %imagesc(acc_thresh_data);

            figure(f); subplot(2,4,num_levels_counter+5);
            %imhist(quantized_data);
            imshow(quantized_data >= otsu_thr);
            title('Thresholded his.eq. quantized image');
        end
    %     clear thresh_data;%  acc_thresh_data;
    end
   % clear image_data;
end