function [bitplane_Downsampling]=Function_DownSampling_Bitplane(bitplane)
if(rem(size(bitplane,1),2)==1)
    bitplane_Downsampling_width=bitplane(1:2:end-1,:,:)+bitplane(2:2:end,:,:);
else
    bitplane_Downsampling_width=bitplane(1:2:end,:,:)+bitplane(2:2:end,:,:);
end

if(rem(size(bitplane,2),2)==1)
    bitplane_Downsampling=bitplane_Downsampling_width(:,1:2:end-1,:)+bitplane_Downsampling_width(:,2:2:end,:);
else
    bitplane_Downsampling=bitplane_Downsampling_width(:,1:2:end,:)+bitplane_Downsampling_width(:,2:2:end,:);
end

end