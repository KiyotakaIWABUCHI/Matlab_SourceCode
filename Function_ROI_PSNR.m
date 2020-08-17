function [Psnr,Ssim]=Function_ROI_PSNR(Img,GT,ROI)
Img=double(uint8(Img));
GT=double(uint8(GT));
Img_ROI=Img(ROI(1):ROI(1)+ROI(3)-1,ROI(1):ROI(2)+ROI(4)-1);
GT_ROI=GT(ROI(1):ROI(1)+ROI(3)-1,ROI(1):ROI(2)+ROI(4)-1);
imshow(uint8(Img_ROI))
ROI_size=size(GT_ROI);
MSE=sum(sum((Img_ROI-GT_ROI).*(Img_ROI-GT_ROI)))/(ROI_size(1)*ROI_size(2));
Psnr=20*log10(255.0/sqrt(MSE));
Ssim=ssim(Img_ROI,GT_ROI);