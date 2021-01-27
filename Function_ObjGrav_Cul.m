function [O]=Function_ObjGrav_Cul(bitplane,Down_Sample_Rate,M)
SIZE=size(bitplane);
[chi_2D]=Function_Module_Chi2MapCul_Mpixel(bitplane,Down_Sample_Rate,M);
chi_2D=imresize(chi_2D,[SIZE(1) SIZE(2)],'bicubic');
s = regionprops(ones([SIZE(1) SIZE(2)]),chi_2D,{'Centroid','WeightedCentroid'});
O=round(s.WeightedCentroid);
end