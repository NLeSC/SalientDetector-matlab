% mssr_binary.m- binary MSSR detector
%**************************************************************************
% [saliency_masks] = mssr_binary(ROI, SE_size_factor, area_factor, ...
%                                saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 25 Feb 2008
% last modification date: 13-05-2015
% modification details: the se_size_factor added as a parameter
%                       the visualization of the final result is taken out
%                       of the function into visualize_mssr_binary
%                       Major bug fix: islands are now comupted properly
%                       Protrusions and indentations are now computed also  
%                       from the found (significant) islands and holes.                                                                                                                                                                                             
%**************************************************************************
% INPUTS:
% ROI- binary mask of the Region Of Interest
% SE_size_factor- structuring element (SE) size factor
% area_factor - area factor for the significant connected components (CCs)
% [saliency_type]- array with 4 flags for the 4 saliency types 
%                (Holes, Islands, Indentations, Protrusions)
%                [optional], if left out- default is [1 1 1 1]   
% [visualise] - visualisation flag
%               [optional], if left out- default is 0, if set to 1, 
%               intermendiate steps of the detection are shown 
%**************************************************************************
% OUTPUTS:
% saliency_masks - 3-D array of the binary saliency masks of the regions
%                  saliency_masks(:,:,i) contains the salient regions per 
%                  type: i=1- "holes", i=2- "islands", i=3 - "indentaitons"
%                  and i =4-"protrusions" 
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks] = mssr_binary(ROI, se_size_factor, area_factor, ...
%                                saliency_type, visualise);
%                    as called from mssr_gray_level.m- TO DO!
%**************************************************************************
% REFERENCES: Ranguelova, E., Pauwels, E. J. ``Morphology-based Stable
% Salient Regions Detector'', International conference on Image and Vision 
% Computing New Zealand (IVCNZ'06), Great Barrier Island, New Zealand,
% November 2006, pp.97-102
%**************************************************************************
function [saliency_masks] = mssr_binary(ROI, SE_size_factor, area_factor,...
                                        saliency_type, visualise)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 5
    visualise = 0;
elseif nargin < 4
    saliency_type = [1 1 1 1];
elseif nargin < 3
    error('mssr_binary.m requires at least 3 input aruments!');
    saliency_masks = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% saliency flags
holes_flag = saliency_type(1);
islands_flag = saliency_type(2);
indentations_flag = saliency_type(3);
protrusions_flag = saliency_type(4);

% ROI
[nrows, ncols] = size(ROI);

% ROI area
ROI_Area = nrows*ncols;

% SE
SE_size = fix(sqrt(SE_size_factor*ROI_Area/(2 * pi)));
SE = strel('disk',SE_size);

% area opening parameter
lambda = 2*SE_size;

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
% saleincy masks
saliency_masks = zeros(nrows, ncols, 4);
% by type
holes = zeros(nrows,ncols);
islands = zeros(nrows,ncols);
indentations = zeros(nrows,ncols);
protrusions = zeros(nrows,ncols);

CCL = zeros(nrows,ncols);
CCLH = zeros(nrows,ncols);
CCLI = zeros(nrows,ncols);
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing

% counter of the significant connected components (CC)
num_CCL = 0;
num_CCLH = 0;
num_CCLI = 0;

filled_ROI = imfill(ROI,'holes');
filled_ROI_inv = imfill(imcomplement(ROI),'holes');

% visualisation
if visualise
    figure;subplot(221);imshow(ROI); title('ROI');
    subplot(223);imshow(filled_ROI);title('filled ROI');
    subplot(224);imshow(filled_ROI_inv);title('filled ROI (inverted)');
end


%--------------------------------------------------------------------------
% parameters depending on preprocessing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% Inner type Salient Structures (ISS)- holes & islands
%..........................................................................
if islands_flag  
    islands = (filled_ROI_inv.*ROI);
    % remove small isolated bits
    islands = bwareaopen(islands,lambda);
end

if holes_flag
    holes = (filled_ROI.*imcomplement(ROI));
    % remove small isolated bits
    holes = bwareaopen(holes,lambda);
end


% visualisation
if visualise
    f2 = figure;subplot(221);imshow(holes);title('holes');
    subplot(222);imshow(islands);title('islands');
end

%..........................................................................
% Border Saliency Structures (BSS) - indentations & protrusions
%..........................................................................
% find significant CC
[bw,num]=bwlabel(filled_ROI,4);
stats = regionprops(bw,'Area');
[bwh,numh]=bwlabel(holes,4);
statsh = regionprops(bwh,'Area');
[bwi,numi]=bwlabel(islands,4);
statsi = regionprops(bwi,'Area');

% compute the areas of all regions (to find the most significant ones?)
for i=1:numh
    if statsh(i).Area/ROI_Area >= area_factor;
        num_CCLH = num_CCLH + 1;
        region = (bwh==i);
        filled_region = imfill(region,'holes');
        CCLH(filled_region)= num_CCLH;
    end
end
already_detected = false;
for i=1:numi
    if statsi(i).Area/ROI_Area >= area_factor;
        num_CCLI = num_CCLI + 1;
        region = (bwi==i);
        filled_region = imfill(region,'holes');
        if filled_region == filled_ROI
            already_detected = true;
        end
        CCLI(filled_region)= num_CCLI;
    end
end
if visualise
    ff= figure;subplot(221);imshow(CCLH);title('Significant components (from holes) labelled');
    subplot(222);imshow(CCLI);title('Significant components (from islands) labelled');
end

if not(already_detected)
    for i=1:num
        if stats(i).Area/ROI_Area >= area_factor;
            num_CCL = num_CCL + 1;
            region = (bw==i);
            CCL(region)= num_CCL;
        end
    end
end

if (indentations_flag || protrusions_flag)
    % inside the significant CCs
    for j = 1:num_CCLH
        SCCH = (CCLH==j);

       if indentations_flag
        % black top hat
         SCCH_bth = imbothat(SCCH,SE);
         SCCH_bth = bwareaopen(SCCH_bth,lambda);
         indentations = indentations|SCCH_bth;
       end
    end
    for j = 1:num_CCLI
        SCCI = (CCLI==j);
        if protrusions_flag
        % white top hat       
         SCCI_wth = imtophat(SCCI,SE);
         SCCI_wth = bwareaopen(SCCI_wth,lambda);
         protrusions = protrusions|SCCI_wth;
       end               
    end
  
    if not(already_detected)
      for j = 1:num_CCL
            SCCL = (CCL==j);
            if visualise
                figure(ff); subplot(223);imshow(SCCL); title('Significant components large');
            end

           if indentations_flag
            % black top hat
             SCCA_bth = imbothat(SCCL,SE);
             SCCA_bth = bwareaopen(SCCA_bth,lambda);
             indentations = indentations|SCCA_bth;
           end

           if protrusions_flag
            % white top hat       
             SCCA_wth = imtophat(SCCL,SE);
             SCCA_wth = bwareaopen(SCCA_wth,lambda);
             protrusions = protrusions|SCCA_wth;
           end               
      end
    end    
end

if visualise
    figure;subplot(223);imshow(indentations);title('indentations');
    subplot(224);imshow(protrusions);title('protrusions');
end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
saliency_masks(:,:,1) = holes;
saliency_masks(:,:,2) = islands;
saliency_masks(:,:,3) = indentations;
saliency_masks(:,:,4) = protrusions;


end