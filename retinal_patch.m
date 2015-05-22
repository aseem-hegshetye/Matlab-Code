function [mask,radius]=retinal_patch(radius)
% i made this with lot of love
%based on the radius it builds a MASK!! A MATRIX THAT WE WILL MULTIPLY ANY IMAGE WITH TO GET A RETINA LIKE IMAGE .ITS  A PLAIN MATRIX WITH 1'S. NUMBER OF
%1'S REDUCE AS DISTANCE FROM CENTER INCREASES.ITS MAKING RECEPTORS SPARSE AS WE GO AWAY FROM CENTER OF RETINA.
%jUST by changing the radius whole mask should change !! thats the beauty
%CHANGE 5 TO 100 OR MORE
%radius=100; % radius of retinal filter -- NOW ITS SET IN MAIN FUNCTION

mask=-ones(radius*2+1);
% RADIUS+1 IS THE CENTER 
%setting the center to 1

%mask(radius+1,radius+1)=1; % its always -mask(rows, columns)

%setting first "10%" distances from the center to 1
%using ceil() to round UP if number is a fraction
%NOW WE DONT HAVE TO AS WE CONVERT ALL -1 TO 1 IN THE END ;)
 %   mask(radius+1-(ceil(radius*0.1)):radius+1+ceil((radius*0.1)),radius+1-ceil((radius*0.1)):radius+1+ceil((radius*0.1)))=1
    
 %setting 11% of pixels at a distance ceil(.11*radius)from center to "0"
  
 previous_radius=ceil(.10*radius);
 %starting with closest radius where all pixels are 1
 for nw_rp=0.101:0.001:1; % as we go far from center,nw_rp = new radius percentage
     
  if ceil(nw_rp * radius)>  previous_radius;
   % as its greater than previous radius we can now calculate total number of pixels that are required to be filled
   %if radius is too big than there will be some boundaries with all "-1".
   %so u should write something to convert all "-1"to "0"
num_of_pix_tobefil=(((2*ceil(nw_rp * radius)) +1)^2) -(((2*previous_radius)+1)^2);
% this radius is stored in previous_radius for further use.
previous_radius=ceil(nw_rp * radius);
%pause;
%(nw_rp*100)% pixels of the matrix should be zero at (nw_rp* radius)distance from the center!!awesome ! 
  count=ceil(num_of_pix_tobefil*nw_rp);
  %count is the total number of pixels that should be assigned "0"
  %this while loop will assign count number of coordinates at particular
  %distance from center to "0" !
  %disp('entering while loop');
  while(count >0)
    %  disp('while loop count=');count
      
      row_col=randi(2); %if random int is 1 then many rows and just two coulmns shd be considered, 
      % else many columns and two rows shd be considered for filling up
      if row_col==1; %detailed row
          %"previous_radius" is currently the current radius, in next
          %iteration it will be old radius
          row=(radius+1-previous_radius)+ceil(((radius+1+previous_radius)-(radius+1-previous_radius))*rand);
         % disp('row='); row
          
          % min+((max-min)*rand) = rand number in range max-min
          % now choosing between two columns
          if randi(2)==1;
              column=(radius+1-previous_radius);
          else
              column=(radius+1+previous_radius);
          end %columns decided randomly
       %  disp('column='); column
         
          
      else %detailed column
           column=(radius+1-previous_radius)+ceil(((radius+1+previous_radius)-(radius+1-previous_radius))*rand);
         %disp('column='); column
         
           if randi(2)==1;
              row=(radius+1-previous_radius);
          else
              row=(radius+1+previous_radius);
          end %row decided randomly
          %disp('row='); row
      end
     % pause;
     
     %checking if this coordinate is already "0" If so then the count
     %should not be decresed !
     if mask(row,column)~=0;
         
       mask(row,column)=0; %that random coordinate assigned "0" yahoo!!
       
       count=count-1; 
      %count decreased by 1
     end
  end
  end
 end

  mask=mask(:,:)<0; %converting all -1s to 1s :D
  
          
          
          
  end

  
  
  