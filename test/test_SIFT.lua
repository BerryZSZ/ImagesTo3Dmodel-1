NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua",true);
local filename = "Mod/ImagesTo3Dmodel/lena.png";
local array=imP.imread2Grey(filename);
local R=imP.HarrisCD(array)
imP.CreatTXT(R, "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/harris.txt");


