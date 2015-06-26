% mssr_visualise_one.m- script for displaying the extracted MSSR on 1 image
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 4 Mar 08
% last modification date: 27 Mar 08 
% modification details: asking about displaying the original region
%                       outlines before the feature filenames
%**************************************************************************
% NOTES: is part of image processed use the separate ROI mask!!
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% mssr_visualise_one
%
%and follow questions.
% Below is example of how to show the all regions as ellipsees and also 
% as outlines overlped with the original
% image (masked region of interest). The ellipse representations 
% have different colour depending on the saliency type;
% ellipse line thickness of 2 and scaling each feature by 3. Regions
% numbers are also shown.
% 
% ------------------------------------------------------------------
%  Visualisation: Morphology-based Stable Salient Regions (MSSR)    
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail_image.jpg
% Display image? [y/n]: y
% Detection was performed for the whole Image (I) or for Region Of Interest (ROI)? [I/R]: r
% Enter the full filename for the ROI mask file: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail.mat
% Show original region outlines? [y/n]: y
% Automatically generate the features filenames? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: y
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: y
% Enter the scaling factor: 3
% Thick line? [y/n]: y
% Enter line thickness: 2
% Show region numbers? [y/n]: y
% --------------- The End ---------------------------------
%
%.................................................................
% to show only every 10th region, no scaling, no original outlines:
% 
% ------------------------------------------------------------------
%  Visualisation: Morphology-based Stable Salient Regions (MSSR)    
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail_image.jpg
% Display image? [y/n]: n
% Detection was performed for the whole Image (I) or for Region Of Interest (ROI)? [I/R]: r
% Enter the full filename for the ROI mask file: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail.mat
% Show original region outlines? [y/n]: n
% Automatically generate the features filenames? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: y
% Display all regions? [y/n]: n
% Enter the list of region numbers as vector: [1:10:160]
% Scale the ellipses? [y/n]: n
% Thick line? [y/n]: n
% Show region numbers? [y/n]: y
% --------------- The End ---------------------------------
%.................................................................
%
% to display all regions without labels and independan on their type:
%
% ------------------------------------------------------------------
%  Visualisation: Morphology-based Stable Salient Regions (MSSR)    
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail_image.jpg
% Display image? [y/n]: n
% Detection was performed for the whole Image (I) or for Region Of Interest (ROI)? [I/R]: r
% Enter the full filename for the ROI mask file: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail.mat
% Show original region outlines? [y/n]: n
% Automatically generate the features filenames? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: n
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: y
% Enter the scaling factor: 2
% Thick line? [y/n]: y
% Enter line thickness: 2
% Show region numbers? [y/n]: n
% Different colour for each region? [y/n]: n
% --------------- The End ---------------------------------
%.................................................................
%
% to show only some regions each in different colour (as for example after
% matching): Note that positive answer to "Distinguis saliency types?"
% overrides the different colour option!!
% ------------------------------------------------------------------
%  Visualisation: Morphology-based Stable Salient Regions (MSSR)    
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail_image.jpg
% Display image? [y/n]: n
% Detection was performed for the whole Image (I) or for Region Of Interest (ROI)? [I/R]: r
% Enter the full filename for the ROI mask file: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\tails\na3683_2_tail.mat
% Show original region outlines? [y/n]: n
% Automatically generate the features filenames? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: n
% Display all regions? [y/n]: n
% Enter the list of region numbers as vector: [1 12 34 100 38 27 56 48 33 97]
% Scale the ellipses? [y/n]: y
% Enter the scaling factor: 2
% Thick line? [y/n]: y
% Enter line thickness: 2
% Show region numbers? [y/n]: y
% Different colour for each region? [y/n]: y
% --------------- The End ---------------------------------%

%..........................................................................
% example of a whole image processed
% 
% ------------------------------------------------------------------
%     Morphology-based Stable Salient Regions (MSSR) Detection      
% ------------------------------------------------------------------
%                                                                   
% Enter the full filename of the input image: V:\WIR\Video_processing\projects\saliency\mssr_demo\test_images\other\graffiti1.jpg
% Display image? [y/n]: y
% Process the Image (I) or a Region Of Interest (ROI)? [I/R]: i
% Default saliency types [holes-Yes islands-Yes indent.-Yes protr.-Yes]? Y/N: y
% Verbose mode? [y/n]: n
% Vusualise major detection steps? [y/n]: n
% Vusualise minor detection steps? [y/n]: n
% ------------------------------------------------------------------
%                                                                   
%                                                                   
% ------------------------------------------------------------------
% Save the extracted regions (for viewing/ processing)? [y/n]: y
% Automatically generate results filenames? [y/n]: y
% Visualise the extracted regions? [y/n]: y
% Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: y
% Display all regions? [y/n]: y
% Scale the ellipses? [y/n]: n
% Thick line? [y/n]: n
% Show region numbers? [y/n]: y
% Different colour for each region? [y/n]: n
% --------------- The End ---------------------------------

%**************************************************************************


clc; 
disp('------------------------------------------------------------------');
disp(' Visualisation: Morphology-based Stable Salient Regions (MSSR)    ');
disp('------------------------------------------------------------------');
disp('                                                                  ');

% input image and ROI
image_fname = input('Enter the full filename of the input image: ','s');

I_or = imread(image_fname);

% display
im_disp = input('Display image? [y/n]: ','s');

if lower(im_disp)=='y'
    f1 = figure; imshow(I_or); title(image_fname, 'Interpreter','none');
end

% ROI
roi = input('Detection was performed for the whole Image (I) or for Region Of Interest (ROI)? [I/R]: ','s');

if lower(roi)=='r'
    ROI_mask_fname = input('Enter the full filename for the ROI mask file: ','s');
else
    ROI_mask_fname = [];
end

        or = input('Show original region outlines? [y/n]: ','s');
        if lower(or)=='y'
            original = 1;
        else
            original = 0;
        end

% read the saved features
    sav_fnames = input('Automatically generate the features filenames? [y/n]: ','s');
    if lower(sav_fnames)=='y'
        i = find(image_fname =='.');
        j = i(end);
        if isempty(j)
            features_fname = [image_fname '.mssr'];   
            if original
                regions_fname = [image_fname '_regions.mat'];    
            else 
                regions_fname =[];
            end
        else
            features_fname = [image_fname(1:j-1) '.mssr'];
            if original
                regions_fname = [image_fname(1:j-1) '_regions.mat'];    
            else 
                regions_fname = [];
            end
        end
    else
    
        features_fname = input('Enter the full filename for the features (ellipse representation): ','s');
        if original
            regions_fname = input('Enter the full filename for the features (regions masks): ','s');
        else
            regions_fname = [];
        end
    end
    
% visualise
typ = input('Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: ','s');
if lower(typ)=='y'
     type = 1;
else
    type = 0;
end
    
    % open the saved regions
    [num_regions, features, saliency_masks] = mssr_open(features_fname, regions_fname, type);
    
    % enter the visualisation parameters
    all = input('Display all regions? [y/n]: ','s');
    if lower(all)=='y'
        list_regions = [];
    else
        list_regions = input('Enter the list of region numbers as vector: ');
    end
    
    scale = input('Scale the ellipses? [y/n]: ','s');
    if lower(scale)=='y'
        scaling = input('Enter the scaling factor: ');
    else
        scaling = 1;
    end

    line = input('Thick line? [y/n]: ','s');
    if lower(line)=='y'
        line_width = input('Enter line thickness: ');
    else
        line_width = 1;
    end

    lab = input('Show region numbers? [y/n]: ','s');
    if lower(lab)=='y'
        labels = 1;
    else
        labels = 0;
    end
    
    if ~type
        col = input('Different colour for each region? [y/n]: ','s');
        if lower(col)=='y'
            col_ellipse = [];
            load list_col_ellipse.mat
    %        col_ellipse = input('Enter the list of colours (one RGB triple per region): ');
            if lower(all)=='y'
                col_ellipse = list_col_ellipse(1:num_regions,:);
            else
                for i=1:length(list_regions)
                    col_ellipse = [col_ellipse; list_col_ellipse(list_regions(i),:)];  
                end
            end

        else
            col_ellipse = [];
        end
    else
        col_ellipse=[];
    end
    col_label = []; % use default for now
    
   
    display_features(image_fname, features_fname, ROI_mask_fname, ...
                  regions_fname,...  
                  type, list_regions, scaling, labels, col_ellipse, ...
                  line_width, col_label, original);
    title('MSSR');

    disp('--------------- The End ---------------------------------');


