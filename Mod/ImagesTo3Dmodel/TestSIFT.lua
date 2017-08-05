--[[
Title: TestSIFT
Author(s): BerryZSZ
Date: 2017/8/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/TestSIFT.lua"£¬true);
------------------------------------------------------------
]]

NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua",true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SIFT.lua",true);

--[[local imP = commonlib.gettable("Mod.ImagesTo3Dmodel.imP");
local tensor = commonlib.inherit(nil, commonlib.gettable("Mod.ImagesTo3Dmodel.imP.tensor"));
]]
local zeros = imP.tensor.zeros;
local zeros3 = imP.tensor.zeros3;
local Round = imP.Round;
local imread = imP.imread;
local rgb2gray = imP.rgb2gray;
local CreatTXT = imP.CreatTXT;
local DotProduct = imP.tensor.DotProduct;
local ArraySum = imP.tensor.ArraySum;
local ArrayShow = imP.tensor.ArrayShow;
local ArrayShow3 = imP.tensor.ArrayShow3;
local ArrayMutl = imP.tensor.ArrayMutl;
local ArrayAdd = imP.tensor.ArrayAdd;
local ArrayAddArray = imP.tensor.ArrayAddArray;
local Array2Max = imP.tensor.Array2Max;
local Array2Min = imP.tensor.Array2Min;
local Array3Max = imP.tensor.Array3Max;
local Array3Min = imP.tensor.Array3Min;
local GetGaussian = imP.GetGaussian;
local GaussianF = imP.GaussianF;
local DoG = imP.DoG;
local meshgrid = imP.tensor.meshgrid;
local conv2 = imP.tensor.conv2;
local Det2 = imP.tensor.Det2;
local Trace2 = imP.tensor.Trace2;
local HarrisCD = imP.HarrisCD;
local GetColumn = imP.tensor.GetColumn;
local MatrixMultiple = imP.tensor.MatrixMultiple;
local det = imP.tensor.det;
local SubMartrix = imP.tensor.SubMartrix;
local inv = imP.tensor.inv;
local find = imP.tensor.find;
local subvector = imP.tensor.subvector;
local submatrix = imP.tensor.submatrix;
local connect = imP.tensor.connect;
local reshape = imP.tensor.reshape;
local transposition = imP.tensor.transposition;
local norm = imP.tensor.norm;
local dot = imP.tensor.dot;

local HalfSize = SIFT.HalfSize;
local DoubleSize = SIFT.DoubleSize;
local gaussian = SIFT.gaussian;
local diffofg = SIFT.diffofg;
local localmax = SIFT.localmax;
local extrafine = SIFT.extrafine;
local orientation = SIFT.orientation;
local descriptor = SIFT.descriptor;
local DO_SIFT = SIFT.DO_SIFT;
local match = SIFT.match;

local Im1_filename = "Mod/ImagesTo3Dmodel/demo-data/fountain/6.JPG";
local Im2_filename = "Mod/ImagesTo3Dmodel/demo-data/fountain/7.JPG";

local TXT1_filename = "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/demo-data/fountain/1.txt";
local TXT2_filename = "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/demo-data/fountain/1.txt";


local Im1 = imread(Im1_filename);
local Im2 = imread(Im2_filename);

local I = rgb2gray(Im1);
local I2 = rgb2gray(Im2);

--CreatTXT(I1, TXT1_filename);
--CreatTXT(I2, TXT2_filename);

--local loc_max = {{I1}, {I1}, {I1}};
--local J = localmax(loc_max, 0.02, -1);

--local frames1, descriptors1, scalespace1, difofg1 = DO_SIFT(I1);
--local frames2, descriptors2, scalespace2, difofg2 = DO_SIFT(I2);


local S = 3;
local omin = 0;
local O = 4;
local sigma0 = 1.6 * 2^(1 / S);
local sigman = 0.5;
local thresh = 0.1 / S; --0.01/S;
local r = 18;
local NBP = 4;
local NBO = 8;
local magnif = 3;
local frames = {{}, {}, {}, {}};
local descriptors = {};
LOG.std(nil,"debug","SIFT","---------- Extract SIFT features from an image ----------");
LOG.std(nil,"debug","SIFT","SIFT: constructing scale space with DoG ..."); 
local scalespace = gaussian(I, O, S, omin, -1, S + 1);
--print(#scalespace.octave, #scalespace.octave[1], #scalespace.octave[1][1], #scalespace.octave[1][1][1], "ssssssss");
local difofg = diffofg(scalespace);
--print(type(difofg.octave), "ddddddddddddddddddddd");
--print(type(difofg.octave[1]))
--print(scalespace.O, difofg.O)
for o = 1, scalespace.O do
	LOG.std(nil,"debug","SIFT","SIFT: computing octave: %f", o-1 + omin);
--	local max_octave = difofg.octave[o];
--	print(#max_octave)
--	print(#max_octave[1])
--	print(#max_octave[1][1])
	local oframesPrime = localmax(difofg.octave[o], 0.8 * thresh, difofg.smin);
    print(#oframesPrime, #oframesPrime[1])
	LOG.std(nil,"debug","SIFT","SIFT: initial keypoints: %f", #oframesPrime[1]);


	-- Remove pointd too close to the boundary
	local red = {}; 
	local oframesLength = #oframesPrime[3];
	for i = 1, oframesLength do 
		red[i] = magnif * scalespace.sigma0 * (2^(oframesPrime[3][i] / scalespace.S)) * NBP / 2;
	end
	local oframes = {};
	for i = 1, 3 do
		oframes[i] = {};
	end
	local oframesCount = 0;
	for i = 1, oframesLength do
		if((oframesPrime[1][i]-red[i]>=1) and
		(oframesPrime[1][i] + red[i]<=(#scalespace.octave[o][1][1])) and
		(oframesPrime[2][i]-red[i]>=1) and
		(oframesPrime[2][i] + red[i]<=(#scalespace.octave[o][1]))) then
			oframesCount = oframesCount + 1;
			oframes[1][oframesCount] = oframesPrime[1][i];
			oframes[2][oframesCount] = oframesPrime[2][i];
			oframes[3][oframesCount] = oframesPrime[3][i];
		end
	end
	LOG.std(nil,"debug","SIFT","SIFT: keypoints # %f", oframesCount, " after discarding from boundary");
    -- Refine the location, threshold strength and remove points on edges
	local oframesExtrafined = extrafine(oframes, difofg.octave[o], difofg.smin, thresh, r);
	LOG.std(nil,"debug","SIFT","SIFT: keypoints # %f", #oframesExtrafined[1], " after discarding from low constrast and edges");
	LOG.std(nil,"debug","SIFT","SIFT: compute orientations of keypoints");
    -- Computer the orientations
	local oframesOrientation = orientation(oframesExtrafined, scalespace.octave[o], scalespace.S, scalespace.smin, scalespace.sigma0);
    -- Store frames
	for i = 1, #oframesOrientation[1] do
		frames[1][i] = 2^(o-1 + scalespace.omin) * oframesOrientation[1][i];
		frames[2][i] = 2^(o-1 + scalespace.omin) * oframesOrientation[2][i];
		frames[3][i] = 2^(o-1 + scalespace.omin) * scalespace.sigma0 * 2^(oframesOrientation[3][i] / scalespace.S);
		frames[4][i] = oframesOrientation[4][i];
	end
	LOG.std(nil,"debug","SIFT","SIFT: keypoints # %f", #oframesOrientation[1], " after orientation computation");
    -- Descriptors
	LOG.std(nil,"debug","SIFT","SIFT: computer descriptors...");
	local sh = descriptor(scalespace.octave[o], oframesOrientation, scalespace.sigma0, scalespace.S, scalespace. smin, magnif, NBP, NBO);
	if o == 1 then 
		descriptors = sh;
	elseif o > 1 then
		descriptors = connect(descriptors, sh);
	end
end
LOG.std(nil,"debug","SIFT","SIFT: total keypoints: %f", #frames[1]);
