function [Imgs_Update]=Function_Module_ResolutionCulculate_ImgGen(Imgs_Origin,Mov,Start_pix,Obj_height,Obj_width,Obj_color)
%%
%%%%%%%%%%%%% Initializes %%%%%%%%%%%%%%%%%%%%%%%%
Imgs_Update=Imgs_Origin; %Initializes
Num_Imgs=size(Imgs_Origin,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%% Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mov_per_frame=Mov/(Num_Imgs-1);
for t=1:Num_Imgs
    delta_mov=round(mov_per_frame*(t-1));
    Imgs_Update(Start_pix(1)+delta_mov(1):Start_pix(1)+Obj_height-1+delta_mov(1),Start_pix(2)+delta_mov(2):Start_pix(2)+Obj_width-1+delta_mov(2),t)=Obj_color;
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
