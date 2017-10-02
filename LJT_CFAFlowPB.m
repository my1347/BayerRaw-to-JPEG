%Require wbmask (by RCSumner)
%%GetInfo
% info from dcraw
% Loading Leica M9 image from st.dng ...
% Black level 133, Top level(saturation) 16383, and
% multipliers 2.264263 1.000000 1.195190 1.000000

%%Source
% DNG Convertor http://supportdownloads.adobe.com/thankyou.jsp?ftpID=5855&fileID=5890

%% CFA
%DNF Direct

% DNF->TIFF
raw = double(imread('st.tiff'));
%% Normalized
black = 133;
saturation = 16383;
lin_bayer = (raw-black)/(saturation-black); % Normalized [0,1];
lin_bayer = max(0,min(lin_bayer,1)); 
%% WB Gainer
wb_multipliers = [2.264263, 1, 1.195190]; % RGB GAINNER
mask = wbmask(size(lin_bayer,1),size(lin_bayer,2),wb_multipliers,'rggb');
balanced_bayer = lin_bayer .* mask;
%% Demosaicking
temp = uint16(balanced_bayer/max(balanced_bayer(:)) * (2^16-1));
lin_rgb = double(demosaic(temp,'rggb'))/(2^16-1);
%% Color Space Conversion
sRGB2XYZ = [0.4124564 0.3575761 0.1804375;0.2126729 0.7151522 0.0721750;0.0193339 0.1191920 0.9503041];
% sRGB2XYZ diifer from each camera
XYZ2Cam = [7171 -1986 -648;-8085 15555 2718;-2170 2512 7457]/10000;
% 
sRGB2Cam = XYZ2Cam * sRGB2XYZ;
sRGB2Cam = sRGB2Cam./ repmat(sum(sRGB2Cam,2),1,3); % normalize each rows of sRGB2Cam to 1
Cam2sRGB = (sRGB2Cam)^-1;
lin_srgb = apply_cmatrix(lin_rgb, Cam2sRGB);
lin_srgb = max(0,min(lin_srgb,1)); % Always keep image clipped b/w 0-1
%% Brightness and Gamma Correction
grayim = rgb2gray(lin_srgb); % Consider only gray channel
grayscale = 0.25/mean(grayim(:));
bright_srgb = min(1,lin_srgb * grayscale); %  value less than 1
nl_srgb = bright_srgb.^(1/2.2);
%% Show in pair
imshow(raw)
imshow(lin_bayer)
imshow(balanced_bayer)
imshow(lin_rgb)
imshow(lin_srgb)
imshow(nl_srgb)

