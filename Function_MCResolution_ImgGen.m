function [Imgs,ROI]=Function_MCResolution_ImgGen(SIZE,Num,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,N)

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
Obj_width_back=Obj_Size(2);
Obj_height_back=Obj_Size(1);

Start_pix=[StartPix(1) StartPix(2)];
[Imgs]=Function_Module_ResolutionCulculate_ImgGen(Imgs,[0 0],Start_pix,Obj_height_back,Obj_width_back,Obj_color);

%% Obj1 Gen

% Interval_Mov=Mov_Obj/(N-1);
% 
% 
% for n=1:N-1
% n_inv=N-(n);
% Start_pix=[StartPix(1) StartPix(2)+StartPix(3)*n_inv];
% 
% [Imgs]=Function_Module_ResolutionCulculate_ImgGen(Imgs,Mov_Obj-(n-1)*Interval_Mov,Start_pix,Obj_height_back,Obj_width_back,Obj_color);
% end


%% Imwrite
% for t=1:Num
%imshow(uint8(Imgs(:,:,1)))
ROI=double(Imgs(:,:,1)==Obj_color);
for j=(StartPix(2)+StartPix(3)*1):size(ROI,2)
    ROI(:,j)=0;
end
% %,['../Images/tmp/tmp_frame',pad(num2str(t),4,'left','0'),'.png']);
% end
%%%%%%%%%%%%% Main Ed%%%%%%%%%%%%%%%%%%%%%%%%
