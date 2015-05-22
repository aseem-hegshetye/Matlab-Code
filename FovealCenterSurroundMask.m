function [fovea_cent_suround_mask] = FovealCenterSurroundMask(rows,columns)


%ROWS IS ALWAYS GOING TO BE AN ODD NUMBER WHICH FACILITATES LOCATING EXACT %CENTER OF A FOVEA.
fovea_center=ceil(rows/2);
fovea_cent_suround_mask= zeros(rows,columns,2,rows*columns);% 1st DIM- ON CENTER. 2ND DIM- OFF SURROUND. 3RD DIM- INDX OF BP_CODE MATRIX.EVERY PIXEL HAS CENTER SURROUND ARRANGEMENT

%GOING THROUGH EACH PIXEL IN FOVEA
    for y=1:(rows);
        for x=1:columns;
            %dist_frm_center=min(abs(x-fovea_center),abs(y-fovea_center));
            dist_frm_center=ceil(sqrt(((x-fovea_center).^2)+((y-fovea_center).^2)));
            index=x+((y-1)*columns);%CONVERTING X Y CO.ORD TO INDEX


            %bipolar_mask(:,:,1,index);
            count=1; %COUNT OF ON PIXELS. WE NEED TO TURN ON "dist_frm_center" NUMBER OF PIXELS IN CENTER AND SURROUND EACH. NOT MORE. 
            %WE MAKE count=1 COZ BELOW WE SET THE (y,x) PIXEL IN THE CENTER OF THE BIPOLAR CELL MASK TO 1
            
            %{
            if x==2&& y==4 && index==65;  %FOR DEBUGGING VALUES
                disp('debuging');
            end
            %}
            fovea_cent_suround_mask(y,x,1,index)=1;
            
            center_surround=1; % 1 MEANS PREPARING MASK FOR CENTER. 2 MEANS FOR SURROUNDING !!!!!!
            for dist= 1:rows; %dist- DISTANCE FROM THE CENTER OF BP (PIXEL) IN CONSIDERATION. ONCE WE FIND NUMBER OF PIXELS REQUIRE WE BREAK

                 if center_surround==3; %BOTH CENTER AND SURROUN PIXELS ARE SET. WE ARE DONE !!!
                     break;
                 end
                        % TAKING CARE OF NOT GOING OUT OF BOUNDS FOR THE FOVEA
                            if x-dist <=0;% IN MATLAB 1ST INDEX IS NOT 0. ITS 1 LOL
                                k1=1;
                            else
                                k1=x-dist;
                            end
                            if x+dist >columns;
                                k2=columns;
                            else 
                                k2=x+dist;
                            end
                            if y-dist <=0;
                                k3=1;
                            else 
                                k3=y-dist;
                            end
                            if y+dist>rows;
                                k4=rows;
                            else
                                k4=y+dist;
                            end

                %CENTER ON. PREPARING A MASK FOR CENTER OF A BP



                    for cen_on_col= k1:k2;%CENTER ON BP COLUMNS IN SURROUNDING FOR ROW y-dist.. ABOVE ROW ALL COLUMNS
                        if count > dist_frm_center ;%&& center_surround ==1;
                            break;
                        end
                        if fovea_cent_suround_mask(k3,cen_on_col,center_surround,index)==0; %ONLY COUNT NON ZERO PIXELS AND MAKE THEM ONE. DONT TOUCH THOSE WHO ARE ALREADY 1
                            fovea_cent_suround_mask(k3,cen_on_col,center_surround,index)=1; % MAKING dist_frm_center NUMBER OF PIXELS IN THE CENTER OF A BP =1
                            count=count+1;
                        end

                    end
                    for cen_on_col= k1:k2;%CENTER ON BP COLUMNS IN SURROUNDING FOR ROW y+dist.. BELOW ROW ALL COLUMNS
                        if count > dist_frm_center ;%&& center_surround ==1;
                            break;
                        end
                        if fovea_cent_suround_mask(k4,cen_on_col,center_surround,index)==0;%ONLY COUNT NON ZERO PIXELS AND MAKE THEM ONE. DONT TOUCH THOSE WHO ARE ALREADY 1
                            fovea_cent_suround_mask(k4,cen_on_col,center_surround,index)=1; % MAKING dist_frm_center NUMBER OF PIXELS IN THE CENTER OF A BP =1
                            count=count+1;
                        end

                    end

                    for cen_on_row= k3:k4;%CENTER ON BP COLUMNS IN SURROUNDING FOR COL x-dist.. LEFT COLUMN ALL ROWS
                         if count > dist_frm_center ;%&& center_surround ==1;
                            break;
                         end
                         if fovea_cent_suround_mask(cen_on_row,k1,center_surround,index)==0; %IF THAT PIXEL IS ALREADY 1 DONT INCREMENT THE COUNT UNNECESSARILY.
                            fovea_cent_suround_mask(cen_on_row,k1,center_surround,index)=1; % MAKING dist_frm_center NUMBER OF PIXELS IN THE CENTER OF A BP =1
                            count=count+1;
                         end

                    end
                    for cen_on_row= k3:k4;%CENTER ON BP COLUMNS IN SURROUNDING FOR ROW x+dist.. RIGHT COLUMN ALL ROWS !!
                         if count > dist_frm_center && center_surround ==1;
                            center_surround=2;
                            count=0; %CENTER PIXELS ARE FIXED.NOW RESETTING THE COUNT FOR SURROUND PIXELS
                            break;
                        elseif count > dist_frm_center && center_surround ==2;
                            center_surround=3; % MEANS BOTH CENTER AND SURROUND ARE SET. NOW STOP THIS FUNCTION
                            break;
                         end
                        if fovea_cent_suround_mask(cen_on_row,k2,center_surround,index)==0; %IF THAT PIXEL IS ALREADY 1 DONT INCREMENT THE COUNT UNNECESSARILY.
                            fovea_cent_suround_mask(cen_on_row,k2,center_surround,index)=1; % MAKING dist_frm_center NUMBER OF PIXELS IN THE CENTER OF A BP =1
                            count=count+1;
                        end

                    end




            end
        end
    end
end