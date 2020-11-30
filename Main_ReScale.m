close all
clear

A=imread(['../Images/Output/Resolution_MCblur/Result_Num_of_Frame2.png']);
B=imread(['../Images/Output/Resolution_MCblur/Result_Num_of_Frame25.png']);


s=60
start=100
start_h=150

A_scale=imresize(A(start_h:start_h+s,start:start+s),3,'nearest');
B_scale=imresize(B(start_h:start_h+s,start:start+s),3,'nearest');

imshow(A_scale)
figure
imshow(B_scale)

%imwrite(A_scale,['../Images/Output/Resolution_MCblur/Scale_Result_Num_of_Frame2.png']);
%imwrite(B_scale,['../Images/Output/Resolution_MCblur/Scale_Result_Num_of_Frame25.png']);
