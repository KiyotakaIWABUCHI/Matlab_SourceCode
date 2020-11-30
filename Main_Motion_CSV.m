clear
close all
Motion_True_Map=imread('../Images/Output/IEEE_traffic_Z_chi16/TrueMotion.png');
Motion_True_Map=imresize(Motion_True_Map,0.5);
car=-(283-197)/2;
bus=-(92-75)/2;
heri=-(160-184)/2;
%EstimationX=zeros(256,256);
EstimationY=zeros(256,256);

EstimationX=double(Motion_True_Map(:,:,1)>10)*car+double(Motion_True_Map(:,:,2)>10)*bus+double(Motion_True_Map(:,:,3)>10)*heri;
csvwrite(['../Images/Output/test/X_MotionMap_true.csv'],int8(EstimationX));
csvwrite(['../Images/Output/test/Y_MotionMap_true.csv'],int8(EstimationY));