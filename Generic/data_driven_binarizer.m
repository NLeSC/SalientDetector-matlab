% data_driven_binarizer.m- data-driven binarization
%**************************************************************************
% [binary_image, thresh] = data_driven_binarizer(input_image, step_size,...
%                              offset, otsu_only, morphology_parameters,...
%                              weights, execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 20.09.2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% input_image       matrix containing the colour or gray-scale image to  be
%                   binarized
% [step_size]       the size of the step between consequtive gray levels to
%                   process. Optional, default is 1
% [offset]          the offset (number of levels) from Otsu to be processed
%                   Optional, default value is 80
% [otsu_only]       flag to perform only Otsu thresholding
% [morphology_parameters] vector with 5 values corresponding to
%                   SE_size_factor- size factor for the structuring element
%                   Area_factor_very_large- factor for the area of CC to be
%                   considered 'very large'
%                   Area_factor_large- factor for the area of CC to be
%                   considered 'large'
%                   lambda_factor- factor for the parameter lambda for the
%                   morphological opening (noise reduction)
%                   connectivity - for the morhpological opening
%                   Optional, default values: [0.02 0.01 0.001 3 8]
% [weights]         vector with 3 weights for the linear combination for
%                   weight_all- the weight for the total number of CC
%                   weight_large- the weight for the number large CC
%                   weight_very_large- for the number of very large CC
%                   Optional, default value - [0.33 0.33 0.33], i.e equal
% [execution_flags] vector of 2 elements, controlling the execution
%                   verbose- verbose mode
%                   visualize- vizualize
%                   default value- [0 0]
%**************************************************************************
% OUTPUTS:
% binary_image      the binarized gray level image
% thresh            the threshold used for binarization- the max of
%                   the weighted combination among the 3 number of CCs
%**************************************************************************
% EXAMPLES USAGE:
% see test_DDBinarizer.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [binary_image, thresh] = data_driven_binarizer(input_image, step_size,...
                              offset, otsu_only, morphology_parameters, ...
                              weights, execution_flags)
%% input control
if nargin < 7 || length(execution_flags) < 3
    execution_flags = [0 0];
end
if nargin < 6 || length(weights) < 3
    weights = [0.33 0.33 0.33];
end
if nargin < 5 || length(morphology_parameters) < 5
    morphology_parameters = [0.02 0.01 0.001 3 8];
end
if nargin < 4
    otsu_only = false;
end
if nargin < 3
    offset = 80;
end
if nargin < 2
    step_size = 1;
end
if nargin < 1
    error('data_driven_binarizer.m requires at least 1 input argument!');
end


%% input parameters -> variables
% execution flags
python_test = 0; % for compatibility
execution_flags = [execution_flags python_test];

%% preprocessing
if ndims(input_image) > 2
    image_data = rgb2gray(input_image);
else
    image_data = input_image;
end
       
%% run the binarization

[binary_image, ~, ~, thresh] = max_conncomp_thresholding(image_data, step_size, ...
     offset, otsu_only, morphology_parameters, weights, execution_flags);
        
 
     
 end
    
