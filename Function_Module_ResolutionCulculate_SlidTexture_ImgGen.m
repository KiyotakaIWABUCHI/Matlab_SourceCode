function [Imgs_Update,img_resion]=Function_Module_ResolutionCulculate_SlidTexture_ImgGen(Imgs_Origin,Mov,Start_pix,Obj_height,Obj_width,Obj_color,slid_num)
%%
img_resion=zeros(size(Imgs_Origin,1),size(Imgs_Origin,2));
%%%%%%%%%%%%% Initializes %%%%%%%%%%%%%%%%%%%%%%%%
Imgs_Update=Imgs_Origin; %Initializes
Num_Imgs=size(Imgs_Origin,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj_img=ones(Obj_height,Obj_width)*Obj_color;
for s=1:slid_num
    obj_img(s*10+(s-1)*4+1:s*10+(s-1)*4+4,:)=Imgs_Origin(1,1,1);
end

%%%%%%%%%%%%%%% Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mov_per_frame=Mov/(Num_Imgs-1);
for t=1:Num_Imgs
    delta_mov=round(mov_per_frame*(t-1));
    Imgs_Update(Start_pix(1)+delta_mov(1):Start_pix(1)+Obj_height-1+delta_mov(1),Start_pix(2)+delta_mov(2):Start_pix(2)+Obj_width-1+delta_mov(2),t)=obj_img;
end
img_resion(Start_pix(1):Start_pix(1)+Mov(1)+Obj_height,Start_pix(2):Start_pix(2)+Mov(2)+Obj_width)=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
