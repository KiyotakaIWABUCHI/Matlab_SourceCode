function [Image_White_Balanced]=Function_WhiteBalanced(Img,Ref1,Ref2,WP,BP)
Img=double(Img);
Ref1=double(Ref1);
Ref2=double(Ref2);
Inclination=(Ref1(WP(1),WP(2))-Ref1(BP(1),BP(2)))/(Ref2(WP(1),WP(2))-Ref2(BP(1),BP(2)));
Image_White_Balanced=Inclination*(Img-Ref2(BP(1),BP(2)))+Ref1(BP(1),BP(2));