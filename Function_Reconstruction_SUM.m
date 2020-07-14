function[sum_image_norm,sum_only_imgae]=Function_Reconstruction_SUM(bitplane)
%%% Sum %%%%%%%%%%%%%%%%%%
summation=sum(bitplane,3);

%%% Normalize SumImage %%%%%%%%%%%%%%%%%%
max_number_photon=max(max(summation));
min_number_photon=min(min(summation));
sum_image=(summation-min_number_photon)/(max_number_photon-min_number_photon)*255;

sum_image_norm=sum_image;
sum_only_imgae=summation;
