function[Labeled_MD_Map,Centroid_Poit,Num_of_Moving_Area]=Function_Culcurate_Centroid(MD_map)

[Labeled_MD_Map,NUM] = bwlabeln(uint8(MD_map),8);
Centroid_Poit=zeros(NUM,2);
centroid_array = regionprops(uint8(Labeled_MD_Map),'centroid');
Num_of_Moving_Area(1:NUM)=0;
for k=1:NUM
    tmp=centroid_array(k).Centroid;
    Centroid_Poit(k,1)=tmp(2);
    Centroid_Poit(k,2)=tmp(1);
    
    Num_of_Moving_Area(k)=sum(sum(double(Labeled_MD_Map==k)));
end