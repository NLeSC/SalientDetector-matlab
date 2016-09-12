% bw_compute_region_props.m- computing region properties from a binary mask
%**************************************************************************
% [regions_properties, conn_comp] = bw_compute_region_props(bw, conn, ...
%                                                           list_properties)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 Oct 2015
% last modification date: 03 Feb 2016
% modification details: connected components are also output
% last modification date: 12 Feb 2016
% modification details: new parameter conenctivity is aded
%**************************************************************************
% INPUTS:
% bw-  a binary image/mask of the extracted salient regions
% conn- neighbourhood connectivity to compute to obtain the regions from
%       the binary masks
% list_props- the list of desired region properties (see help
%                  regionprops for all values)
%**************************************************************************
% OUTPUTS:
% region_props- structure with all region properties. The fileds of
%                   the structure are as required in list_properties
% conn_comp - the connected components derived from the saliency_masks
%**************************************************************************
% EXAMPLES USAGE:
% a = rgb2gray(imread('circlesBrightDark.png'));
% bw = a < 100;
% conn = 4;
% imshow(bw); title('Image with Circles'); axis on, grid on;
% list = {'Centroid', 'Area', 'PixelList'};
% [regions_properties, conn_comp] = bw_compute_region_props(bw, conn, list)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [regions_props, conn_comp] = bw_compute_region_props(bw, ...
    conn, list_props)

%**************************************************************************
% input control
%--------------------------------------------------------------------------
if nargin < 3
    list_props = {'Area', 'Centroid','ConvexArea', ...
        'Eccentricity', 'EquivDiameter', 'MinorAxisLength',...
        'MajorAxisLength', 'Orientation', 'Solidity'};
elseif nargin < 2
    conn = 4;
elseif nargin < 1
    error('bw_compute_region_props.m requires at least 1 input argument!');
    region_properties = [];
    connn_comp = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
regions_props=  struct([]);
conn_comp = [];

%**************************************************************************
% computations
%--------------------------------------------------------------------------
conn_comp = bwconncomp(bw, conn);
regions_props = regionprops(conn_comp, list_props);
