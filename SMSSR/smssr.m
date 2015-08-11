% smssr- main function of the SMSSR detector 
%**************************************************************************
% [num_regions, features, saliency_masks] = smssr(image_data,ROI_mask,...
%                                           num_levels, saliency_type, ...
%                                           thresh_type, ...    
%                                           region_params, execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 May 2015
% last modification date: 11 August 2015
% modification details: more modular code
% last modification date: 11 June 2015
% modification details: added hysteresis thresholding for binarization
% modification date: 22 June 2015
% modification details: added parameter for the type of  thresholding- 
%                       <m>ultithresholding or <h>ysteresis
%**************************************************************************
% INPUTS:
% image_data        the input gray-level image data
% [ROI_mask]        the Region Of Interenst binary mask [optional]
%                   if specified should contain the binary array ROI
%                   if left out or empty [], the whole image is considered
% [num_levels]      number of gray levels to consider
% [saliency_type]   array with 4 flags for the 4 saliency types 
%                   (Holes, Islands, Indentations, Protrusions)
%                   [optional], if left out- default is [1 1 1 1]
% [thresh_type]     character 's' for simple thresholding, 
%                   'm' for multithresholding or 'h' for
%                   hysteresis, [optional], if left out default is 'h'
% [region_params]   region parameters [SE_size_factor, area_factor, saliency_thresh]
%                   SE_size_factor- structuring element (SE) size factor  
%                   area_factor- area factor for the significant CC, 
%                   saliency_thresh- percentage of kept regions
% [execution_flags] vector with 3 flags [verbose, visualise_major, ...
%                                                       visualise_minor]
%                   [optional], if left out- default is [0 0 0]
%                   visualise_major "overrides" visualise_minor
%**************************************************************************
% OUTPUTS:
% num_regions       number of detected salient regions
% features          the features of the equivalent ellipses to the salient 
%                   regions in format [x y a b c t], where (x,y)- ellipse 
%                   centroid coords, a(x-u)^2 + 2b(x-u)(y-v) + c(y-v)^2 = 1
%                   is the ellipse equation,
%                   t- region type (1= Hol | 2= Isl | 3=Ind | 4=Pr)
% saliency_masks    3-D array of the binary saliency masks of the regions
%                   for example saliency_masks(:,:,1) contains the holes
%**************************************************************************
% SEE ALSO
% mssr- the MSSR detector 
%**************************************************************************
% EXAMPLES USAGE: 
% cl;
% if ispc 
%     starting_path = fullfile('C:','Projects');
% else
%     starting_path = fullfile(filesep,'home','elena');
% end
% image_filename = fullfile(starting_path,'eStep','LargeScaleImaging',...
%            'Data','AffineRegions','Phantom','phantom.png');
% image_data =imread(image_filename);
% [num_regions, features, saliency_masks] = ...
%                                      smssr(image_data);
% finds all types of saleint regions for the image
%--------------------------------------------------------------------------
% [num_regions, features, saliency_masks] = ...
%                        smssr(image_data,[],[],[1 1 1 1],'m',[],[1 1 0 0]);
% finds only the 'holes' and 'islands' for the whole image in verbose mode
% multithresholding is used as binarization method
%--------------------------------------------------------------------------
% load ROI_mask; 
% [num_regions, features, saliency_masks] = ...
%               smssr(image_data, ROI_mask);
% finds all types of salient regions within the presegmented ROI (tail)
%--------------------------------------------------------------------------
% see also test_mssr.m
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [num_regions, features, saliency_masks] = smssr(image_data,ROI_mask,...
                                           num_levels, saliency_type, ...
                                           thresh_type,...
                                           region_params, execution_flags)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 7 || length(execution_flags) <3
    execution_flags = [0 0 0];
end
if nargin < 6 || isempty(region_params) || length(region_params) < 3
    region_params = [0.02 0.03 0.7];
end
if nargin < 5
    thresh_type = 's';
end
if nargin < 4 || isempty(saliency_type) || length(saliency_type) < 4
    saliency_type = [1 1 1 1];
end
if nargin < 3 || isempty(num_levels)
    num_levels = 25;
end
if nargin < 2
    ROI_mask = [];
end
if nargin < 1
    error('smssr.m requires at least 1 input argument- the gray_level image!');
    num_regions = 0;
    featurs = [];
    saliency_masks = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% structuring element (SE) size factor  
SE_size_factor=region_params(1);
if ndims(region_params) > 1
    % area factor for the significant CC
    area_factor = region_params(2);
else
    area_factor = 0.03;
end
if ndims(region_params) > 2   
    % thresholding the salient regions
    saliency_thresh = region_params(3);
else
    saliency_thresh =  0.7;
end

% saliency flags
holes_flag = saliency_type(1);
islands_flag = saliency_type(2);
indentations_flag = saliency_type(3);
protrusions_flag = saliency_type(4);

% execution flags
verbose = execution_flags(1);
visualise_major = execution_flags(2);
visualise_minor = execution_flags(3);    

if visualise_minor
    visualise_major = 1;  
end

%**************************************************************************
% parameters
%--------------------------------------------------------------------------
% image dimensions
[nrows, ncols] = size(image_data);

% set up the figures positions
bdwidth = 5;
topbdwidth = 80;

set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
wait_pos = [0.2*scnsize(3), 0.2*scnsize(4),scnsize(3)/4, scnsize(4)/20 ];

if visualise_minor || visualise_major
    pos1  = [bdwidth,... 
        1/2*scnsize(4) + bdwidth,...
        scnsize(3)/2 - 2*bdwidth,...
        scnsize(4)/2 - (topbdwidth + bdwidth)];

         pos2 = [pos1(1) + scnsize(3)/2,...
         pos1(2),...
         pos1(3),...
         pos1(4)];
    
        pos3 = [pos1(1) + scnsize(3)/2,...
         bdwidth,...
         pos1(3),...
         pos1(4)];

    f1 = figure('Position',pos1);
    f2 = figure('Position',pos3);
    if holes_flag
       f3 = figure('Position',pos2);
    end
    if indentations_flag
        f4 = figure('Position',pos3);
    end
    if islands_flag
        f5 = figure('Position',pos2);
    end
    if protrusions_flag
        f6 = figure('Position',pos3);
    end
    load('MyColormaps','mycmap'); 
end

figs = [f1 f2];
if holes_flag
    figs(3) = f3;
else
    figs(3) = -1;
end
if indentations_flag
    figs(4) = f4;
else
    figs(4) = -1;
end
if islands_flag
    figs(5) = f5;
else
    figs(5) = -1;
end
if protrusions_flag
    figs(6) =  f6;
else
    figs(6) = -1;
end
    
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------

% saliency masks
acc_masks = zeros(nrows,ncols,4);
saliency_masks = zeros(nrows,ncols,4);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
if verbose
    disp('Preprocessing...');
end

tic;
t0 = clock;

% apply the ROI mask if given and get the range of gray levels
if ~isempty(ROI_mask)
    ROI_only = image_data.*uint8(ROI_mask);
else
    ROI_only = image_data;
end

%..........................................................................
% segment each thresholded image and obtain the accumulated saliency masks
%..........................................................................
[acc_masks] = smssr_acc_masks(ROI_only, num_levels, thresh_type,...
                               SE_size_factor, area_factor,...
                               saliency_type, execution_flags, figs);


%..........................................................................
% threshold the cumulative saliency masks 
%..........................................................................
[saliency_masks] = smssr_thresh_masks(acc_masks, saliency_thresh, verbose);

  
%visualisation
if visualise_major
    holes_thresh = saliency_masks(:,:,1);
    islands_thresh = saliency_masks(:,:,2);
    indentations_thresh = saliency_masks(:,:,3);
    protrusions_thresh = saliency_masks(:,:,4); 
    visualise_regions();
end

    
%..........................................................................
% get the equivalent ellipses
%..........................................................................
if verbose
    disp('Computing the equivalent ellipses...');
end

tic;


if verbose
   disp('Elapsed time for computing the equivalent ellipses: ');toc
end

num_regions = 0;
sub_features = [];
features = [];

for i=1:4
    binary_mask = saliency_masks(:,:,i);
    if find(binary_mask)
        [num_sub_regions, sub_features] = binary_mask2features(binary_mask,4, i);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end

if verbose
       disp(['Total elapsed time:  ' num2str(etime(clock,t0))]);
end

    function visualise_regions()

        % define colors
        blue = [0 0 255];
        yellow = [255 255 0];
        green = [0 255 0];
        red = [255 0 0];

        % holes
        if holes_flag && ~isempty(find(holes_thresh, 1))

            rgb = image_data;
            rgb = imoverlay(rgb, holes_thresh, blue);

            figure(f3);
            subplot(223);imshow(holes_thresh);
            title('thresholded holes');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected holes');
        end
        % indentations
        if indentations_flag && ~isempty(find(indentations_thresh,1))
            rgb = image_data;
            rgb = imoverlay(rgb, indentations_thresh, green);

            figure(f4);
            subplot(223);imshow(indentations_thresh);
            title('thresholded indentations');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected indentations');
        end
        % islands
        if islands_flag && ~isempty(find(islands_thresh,1))
            rgb = image_data;
            rgb = imoverlay(rgb, islands_thresh, yellow);

            figure(f5);
            subplot(223);imshow(islands_thresh);
            title('thresholded islands');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected islands');
        end
        % protrusions
        if protrusions_flag && ~isempty(find(protrusions_thresh,1))
            rgb = image_data;
            rgb = imoverlay(rgb, protrusions_thresh, red);

            figure(f6);
            subplot(223);imshow(protrusions_thresh);
            title('thresholded protrusions');axis image;axis on;
            drawnow;
            subplot(224); imshow(rgb); axis on; title('Detected protrusions');
        end
    end

end