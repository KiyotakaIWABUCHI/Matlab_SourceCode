function [reconstructed_image]=Function_Reconstruction_MLE_Oversample(bitplane,alpha,q,K)
number_frame=size(bitplane,3);
[non,bitcount]=Function_Reconstruction_SUM(bitplane);
bitcount = imboxfilt(bitcount,K);
D = bitcount/(number_frame);

% 最尤推定
reconstructed_image = round(255/alpha*gammaincinv(1-D,q,'upper'));
reconstructed_image = 255*double(reconstructed_image>255)+reconstructed_image.*double(reconstructed_image<=255);