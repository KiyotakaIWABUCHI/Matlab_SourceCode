function [Imgs,ROI]=Function_Dist_ImgGen_2Obj_Inverse(SIZE,Num,Obj_Size,Mov_Obj,Back_color,Obj_color,Obj_color2,StartPix)

%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%
Imgs=zeros(SIZE(1),SIZE(2),Num);
Img_back=zeros(SIZE(1),SIZE(2));
%%%%%%%%%%%%% Initializes Ed%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%
%% BackGround Set
for i=1:SIZE(1)
    for j=1:SIZE(2)
        Img_back(i,j)=Back_color;
    end
end

for t=1:Num
    Imgs(:,:,t)=Img_back;
end
Obj_width_back=Obj_Size(2);
Obj_height_back=Obj_Size(1);

Start_pix=[StartPix(1) StartPix(2)];
[Imgs]=Function_Module_ResolutionCulculate_ImgGen(Imgs,Mov_Obj,Start_pix,Obj_height_back,Obj_width_back,Obj_color);

%% Obj2 Gen


Start_pix=[StartPix(1) StartPix(2)+StartPix(3)+Obj_width_back];
[Imgs]=Function_Module_ResolutionCulculate_ImgGen(Imgs,Mov_Obj,Start_pix,Obj_height_back,Obj_width_back,Obj_color2);



%% Imwrite
ROI=logical(zeros(SIZE));
for t=1:Num
    ROI=ROI | double(Imgs(:,:,t)==Obj_color) | double(Imgs(:,:,t)==Obj_color2);
    %imshow(uint8(Imgs(:,:,t)))
end

ROI=double(ROI);
% ROI=double(Imgs(:,:,1)==Obj_color);
% for j=(StartPix(2)+StartPix(3)*1):size(ROI,2)
%     ROI(:,j)=0;
% end
% %,['../Images/tmp/tmp_frame',pad(num2str(t),4,'left','0'),'.png']);
% end

%%%%%%%%%%%%% Main Ed%%%%%%%%%%%%%%%%%%%%%%%%
