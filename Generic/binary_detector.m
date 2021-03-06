% binary_detector.m- binary morphological detector
%**************************************************************************
% [saliency_masks] = binary_detector(ROI, morphology_parameters, ...
%                                saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 28 Sept 2015
% last modification date: 13 July 2016
% modification details: imfill uses now parameterised connectivity to match
% the Python version of the code (openCV also uses flag parameter for 
% floodFill for connectivuty)
% last modification date: 24 June 2016
% modification details: bwareaopen uses now parameterised connectivity; hard
% coded connectinvity 8 to match openCV
% last modification date: 30 May 2016
% modification details: added 2 more parameters- lambda_factor and
% connectivity; most parameters are grouped as morphology_parameters like
% in dmsr
% last modification date: 24 March 2016
% modification details: only 1 SE for all types of saliency is used now
% last modification date: 17 March 2016
% modification details: fixed indentations and protrusions in respect to
% large holes; removing ind. and protr. touching the image boundary
%**************************************************************************
% INPUTS:
% ROI- binary mask of the Region Of Interest
% [morphology_parameters] vector with 5 values corresponding to
%                   SE_size_factor- size factor for the structuring element
%                   area_factor - area factor for the significant connected 
%                   components (CCs)
%                   lambda_factor- factor for the parameter lambda for the
%                   morphological opening (noise reduction)
%                   connectivity - for the morhpological opening
%                   default values [0.02 0.05 3 4]
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
%                  and i =4-"protrusions"  if saliency_types is [1 1 1 1]
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks] = binary_detector(ROI, morphology_parameters
%                    saliency_type, visualise);
%                    as called from a gray level detector
%**************************************************************************
% REFERENCES: Ranguelova, E., Pauwels, E. J. ``Morphology-based Stable
% Salient Regions Detector'', International conference on Image and Vision
% Computing New Zealand (IVCNZ'06), Great Barrier Island, New Zealand,
% November 2006, pp.97-102
%**************************************************************************
function [saliency_masks] = binary_detector(ROI, morphology_parameters,...
    saliency_type, visualise)

%**************************************************************************
% input control
%--------------------------------------------------------------------------
if nargin < 4
    visualise = 0;
elseif nargin < 3
    saliency_type = [1 1 1 1];
if nargin < 3 || length(morphology_parameters) < 4
    morphology_parameters = [0.02 0.05 3 4]; 
end    
elseif nargin < 1
    error('binary_detector.m requires at least 1 input argument- the gray_level image!');
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

% morphology parameters
SE_size_factor = morphology_parameters(1);
area_factor = morphology_parameters(2);
lambda_factor = morphology_parameters(3);
connectivity = morphology_parameters(4);

% SE
SE_size = fix(SE_size_factor*sqrt(ROI_Area/pi));
SE = strel('disk',SE_size);

% area opening parameter
lambda = lambda_factor*SE_size;
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------

% saleincy masks
num_saliency_types = length(find(saliency_type));
saliency_masks = zeros(nrows, ncols, num_saliency_types);

% by type
if holes_flag || indentations_flag || protrusions_flag
    holes = zeros(nrows,ncols);
end
if islands_flag || indentations_flag || protrusions_flag
    islands = zeros(nrows,ncols);
end
if indentations_flag
    indentations = zeros(nrows,ncols);
end
if protrusions_flag
    protrusions = zeros(nrows,ncols);
end

if visualise
    f = figure;
end

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

filled_ROI = imfill(ROI,connectivity,'holes');
filled_ROI_inv = imfill(imcomplement(ROI),connectivity,'holes');

% visualisation
if visualise
    figure(f);subplot(221);imshow(ROI); title('ROI'); grid on;
    subplot(223);imshow(double(filled_ROI));title('filled ROI'); grid on;
    subplot(224);imshow(double(filled_ROI_inv));title('filled ROI (inverted)'); grid on;
end


%--------------------------------------------------------------------------
% parameters depending on preprocessing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% Inner type Salient Structures (ISS)- holes & islands
%..........................................................................
if islands_flag || indentations_flag || protrusions_flag
    islands = (filled_ROI_inv.*ROI);
    % remove small isolated bits
    islands = bwareaopen(islands,lambda,connectivity);
end

if holes_flag || indentations_flag || protrusions_flag
    holes = (filled_ROI.*imcomplement(ROI));
    % remove small isolated bits
    holes = bwareaopen(holes,lambda,connectivity);
end

% visualisation
if visualise
    f2 = figure;
    if holes_flag
        subplot(221);imshow(double(holes));title('holes'); grid on;
    end
    if islands_flag
        subplot(222);imshow(double(islands));title('islands'); grid on;
    end
end

%..........................................................................
% Border Saliency Structures (BSS) - indentations & protrusions
%..........................................................................
if (indentations_flag || protrusions_flag)
    % find significant CC
    [bw,num]=bwlabel(filled_ROI,connectivity);
    stats = regionprops(bw,'Area');
    [bwh,numh]=bwlabel(holes,connectivity);
    statsh = regionprops(bwh,'Area');
    [bwi,numi]=bwlabel(islands,connectivity);
    statsi = regionprops(bwi,'Area');
    
    % compute the areas of all regions (to find the most significant ones?)
    for i=1:numh
        if statsh(i).Area/ROI_Area >= area_factor;
            num_CCLH = num_CCLH + 1;
            region = (bwh==i);
            filled_region = imfill(region,connectivity,'holes');
            CCLH(filled_region)= num_CCLH;
        end
    end
    %already_detected = false;
    for i=1:numi
        if statsi(i).Area/ROI_Area >= area_factor;
            num_CCLI = num_CCLI + 1;
            region = (bwi==i);
            filled_region = imfill(region,connectivity,'holes');
%             if filled_region == filled_ROI
%                 already_detected = true;
%             end
            CCLI(filled_region)= num_CCLI;
        end
    end
    if visualise
        ff= figure;subplot(221);imshow(CCLH);title('Significant components (from holes) labelled'); grid on;
        subplot(222);imshow(CCLI);title('Significant components (from islands) labelled'); grid on;
    end
    
%    if not(already_detected)
        for i=1:num
            if stats(i).Area/ROI_Area >= area_factor;
                num_CCL = num_CCL + 1;
                region = (bw==i);
                CCL(region)= num_CCL;
            end
        end
 %   end
    
    % find the indentations and protrusions
    % inside the significant CCs
    for j = 1:num_CCLH
        SCCH = (CCLH==j);
        if indentations_flag
            % black top hat
            SCCH_bth = imbothat(SCCH,SE);
            SCCH_bth = bwareaopen(SCCH_bth,lambda,connectivity);
            % the indentaitons in the largeholes are actually protrusions in respect to the whole image!
            protrusions = protrusions|SCCH_bth;
        end
        if protrusions_flag
            % white top hat
            SCCH_wth = imtophat(SCCH,SE);
            SCCH_wth = bwareaopen(SCCH_wth,lambda,connectivity);
            % the prorusions in the large holes are actually indentaitions in respect to the whole image!            
            indentations = indentations|SCCH_wth;
        end
    end
    
    for j = 1:num_CCLI
        SCCI = (CCLI==j);
        if indentations_flag
            % black top hat
             SCCI_bth = imbothat(SCCI,SE);
             SCCI_bth = bwareaopen(SCCI_bth,lambda,connectivity);
            indentations = indentations|SCCI_bth;
        end
        if protrusions_flag
            % white top hat
            SCCI_wth = imtophat(SCCI,SE);
            SCCI_wth = bwareaopen(SCCI_wth,lambda,connectivity);
            protrusions = protrusions|SCCI_wth;
        end
    end
    
%    if not(already_detected)
        for j = 1:num_CCL
            SCCL = (CCL==j);
            if visualise
                figure(ff); subplot(223);imshow(SCCL); title('Significant components large'); grid on;
            end
            
            if indentations_flag
                % black top hat
                SCCA_bth = imbothat(SCCL,SE);
                SCCA_bth = bwareaopen(SCCA_bth,lambda, connectivity);
                indentations = indentations|SCCA_bth;
            end
            
            if protrusions_flag
                % white top hat
                SCCA_wth = imtophat(SCCL,SE);
                SCCA_wth = bwareaopen(SCCA_wth,lambda, connectivity);
                protrusions = protrusions|SCCA_wth;
            end
        end
 %   end
end


% clear the indentaitons and protrusions touching the image boundaries
if protrusions_flag
    protrusions = imclearborder(protrusions);
end
if indentations_flag
    indentations = imclearborder(indentations);
end

if visualise
    figure(f2);
    if indentations_flag
        subplot(223);imshow(indentations);title('indentations');grid on;
    end
    if protrusions_flag
        subplot(224);imshow(protrusions);title('protrusions'); grid on;
    end
end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
i = 0;
if holes_flag
    i = i+1;
    saliency_masks(:,:,i) = holes;
end
if islands_flag
    i = i+1;
    saliency_masks(:,:,i) = islands;
end
if indentations_flag
    i = i+1;
    saliency_masks(:,:,i) = indentations;
end
if protrusions_flag
    i = i+1;
    saliency_masks(:,:,i) = protrusions;
end

end