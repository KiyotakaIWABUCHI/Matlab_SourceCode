function [bitplane_Downsampling]=Function_DownSampling_Bitplane(bitplane)

bitplane_Downsampling_width=bitplane(1:2:end,:)+bitplane(2:2:end,:);
bitplane_Downsampling=bitplane_Downsampling_width(:,1:2:end)+bitplane_Downsampling_width(:,2:2:end);

end