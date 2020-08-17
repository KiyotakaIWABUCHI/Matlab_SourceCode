function [reconstructed_image]=Function_Reconstruction_MLE(bitplane,alpha,q)
number_frame=size(bitplane,3);
[non,bitcount]=Function_Reconstruction_SUM(bitplane);
D = bitcount/(number_frame);

% ç≈ñﬁêÑíË
reconstructed_image = round(255/alpha*gammaincinv(1-D,q,'upper'));