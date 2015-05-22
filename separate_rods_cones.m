function [a,nw_rd]= separate_rods_cones(img,radius)
% this function separates rods and cones in an image "img".
%img is already a convoluted image so at center we have lot of pixels and
%as we go away from the center density reduces.
% we 

nw_rd=ceil(0.10*radius )+1; %its the distance from the center where pixels are to be converted to rods
[rows,columns,rgb]=size(img);
a=zeros(rows,columns,rgb);

a(1:(radius+1)-nw_rd,:,1)= img(1:(radius+1)-nw_rd,:,2) ;

a( (radius+1)+nw_rd:rows,:,1)= img( (radius+1)+nw_rd:rows,:,2);

a((radius+1)-nw_rd:(radius+1)+nw_rd,1:(radius+1)-nw_rd,1)=img((radius+1)-nw_rd:(radius+1)+nw_rd,1:(radius+1)-nw_rd,2);
a((radius+1)-nw_rd:(radius+1)+nw_rd,(radius+1)+nw_rd:columns,1)=img((radius+1)-nw_rd:(radius+1)+nw_rd,(radius+1)+nw_rd:columns,2);

%radius+1 is the center !!!!!!!!

% matrix a should have 3 types of cones in the center till the radius and
% then it should just have rods in the surrounding whose magnitude is NOT
% THE MAX  of all three rgb values the original image has but just the
% green value so that it varies with edges. !MAX wont varry i think. It
% would be same for red and green and blue as long as they all have same
% value.
a(radius+1-(0.10*radius):radius+1+(0.10*radius),radius+1-(0.10*radius):radius+1+(0.10*radius),:)=img(radius+1-(0.10*radius):radius+1+(0.10*radius),radius+1-(0.10*radius):radius+1+(0.10*radius),:);

% a is a 3 dimentional matrix with rods in just 1st dimension and cones in
% center in all 3 dimensions with RGB values. hope it works ;)

end