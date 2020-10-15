function [Imgs,img_resion]=Function_TOP_ResolutionCulculate_Texture_ImgGen(SIZE,Num,Obj_Back_Size,Obj_Target_Size,Mov_back,Mov_target,Back_color,Obj_color_back,Obj_color_target,txt)

%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%
Imgs=zeros(SIZE(1),SIZE(2),Num);
Img_back=zeros(SIZE(1),SIZE(2));
%%%%%%%%%%%%% Initializes Ed%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%
%% BackGround Set
for i=1:SIZE(2)
    for j=1:SIZE(1)
        Img_back(i,j)=Back_color;
    end
end

for t=1:Num
    Imgs(:,:,t)=Img_back;
end

%% Obj1 Gen
Obj_width_back=Obj_Back_Size(2);
Obj_height_back=Obj_Back_Size(1);
Start_pix=[SIZE(1)/2-Obj_height_back/2 20]-Mov_back/2;

[Imgs]=Function_Module_ResolutionCulculate_ImgGen(Imgs,Mov_back,Start_pix,Obj_height_back,Obj_width_back,Obj_color_back);


%% Obj2 Gen
Obj_width_target=Obj_Target_Size(2);
Obj_height_target=Obj_Target_Size(1);
Start_pix=round([SIZE(1)/2-Obj_height_target/2 230-Obj_width_target]-Mov_target/2);

[Imgs,img_resion]=Function_Module_ResolutionCulculate_Texture_ImgGen(Imgs,Mov_target,Start_pix,Obj_height_target,Obj_width_target,Obj_color_target,txt);

%% Imwrite
  %for t=1:Num
      imshow(uint8(Imgs(:,:,t)))
% %,['../Images/tmp/tmp_frame',pad(num2str(t),4,'left','0'),'.png']);
  %end
%%%%%%%%%%%%% Main Ed%%%%%%%%%%%%%%%%%%%%%%%%
