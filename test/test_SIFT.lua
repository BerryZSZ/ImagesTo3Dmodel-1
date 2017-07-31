--[[ Test SIFT lib:

NPL.load("(gl)Mod/ImagesTo3Dmodel/test/test_SIFT.lua");
local SIFT = commonlib.gettable("tests.SIFT");
SIFT:test_basics();
SIFT:test_XXXXX();
SIFT:test_YYYYY();
]]


local SIFT = commonlib.gettable("tests.SIFT");
function SIFT:test_basics()
  NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua");
  local filename = "Mod/ImagesTo3Dmodel/lena.png";
  local array=imP.imread2Grey(filename);
  local R=imP.HarrisCD(array)
  imP.CreatTXT(R, "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/harris.txt");

  local doubleR = R:DoubleSize()
  assert(#doubleR == #R * 2, "xxxxxxx");

  local doubleR = R:DoubleSize()
  assert(#doubleR == #R * 2, "xxxxxxx");
  
end
