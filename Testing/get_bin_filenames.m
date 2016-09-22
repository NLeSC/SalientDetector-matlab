% get_bin_filenames- obtain original and binarization filenames from path
%**************************************************************************
% [image_filenames, bin_filenames] = ...
%           get_bin_filenames(data_path, results_path)
%
% author: Elena Ranguelova, NLeSc
% date created: 21 Sept 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% data_path- path to the image data
% results_path - path to the resulting (binary) files
%**************************************************************************
% OUTPUTS:
% image_filenames- cell array with the original image filenames
% bin_filenames- cell array wtih binarized images filenames
%**************************************************************************
% NOTES: called from testing scripts
%**************************************************************************
% EXAMPLES USAGE: 
% see test_DDBinarizer.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [image_filenames, bin_filenames] = ...
           get_bin_filenames(data_path, results_path)
       
if nargin < 2
    error('get_bin_filenames requires 2 input arguments!');
end

% find out the number of png images in the data_path
image_fnames = dir(fullfile(data_path,'*.png'));
num_images = length(image_fnames);

% initialize the  filenames structure
image_filenames = cell(num_images,1);
bin_filenames = cell(num_images,1);

for i = 1:num_images
    [~,name,ext] = fileparts(image_fnames(i).name); 
    image_filenames{i} = fullfile(data_path,image_fnames(i).name);
    bin_name = strcat(name, '_bin', ext );
    bin_filenames{i} = fullfile(results_path,bin_name);    
end