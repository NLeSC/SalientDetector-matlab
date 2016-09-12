% compute_region_props.m- computing region properties from salient binary masks
%**************************************************************************
% [regions_props , conn_comp] = compute_region_props(saliency_masks, ...
%                                                    conn, list_props)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 Oct 2015
% last modification date: 12 Sep 2016
% modification details: using bw_compute_region_props
% last modification date: 03 Feb 2016
% modification details: connected components are also output
% last modification date: 12 Feb 2016
% modification details: new parameter conenctivity is aded
%**************************************************************************
% INPUTS:
% saliency_masks-  the binary masks of the extracted salient regions
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
% [regions_properties, conn_comp] = compute_region_props(bw, conn, list)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [regions_props, conn_comp] = compute_region_props(saliency_masks, ...
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
    error('compute_region_props.m requires at least 1 input argument!');
    region_properties = [];
    connn_comp = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% how many types of regions?
sal_types = size(saliency_masks,3);

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
regions_props=  struct([]);
conn_comp = [];

%**************************************************************************
% computations
%--------------------------------------------------------------------------
j = 0;
if sal_types > 0
    j = j+ 1;
    bw = saliency_masks(:,:,j);
    [regions_props, CC] = bw_compute_region_props(bw, conn, list_props);
    conn_comp{j} = CC;
end
for s = 1: sal_types - 1
    j = j+ 1;
    bw = saliency_masks(:,:,j);
    [new_props, CC] = bw_compute_region_props(bw, conn, list_props);
    conn_comp{j} = CC;
    regions_props = append_props(regions_props, new_props,...
        list_props);
end
%**************************************************************************
% nested functions
%--------------------------------------------------------------------------
    function appended_props = append_props(old_props, new_props, list_props)
        for l = 1: length(list_props)
            appended_props = old_props;
            new_props_per_type = new_props.list_props{l};
            appended_props.list_props{l} = [appended_props.list_props{l} ...
                new_props_per_type];
        end
    end

end