function z = mr3(im, im2, im3, w)
%function ct3(im,w) %http://www.mathworks.com/matlabcentral/fileexchange/32173-ct3-a-simple-mousewheel-based-3d-image-browser-for-medical-images
%
%Allows simple browsing of a CT scan using the mousewheel.  Assumes a grid
%spacing ratio of 3:1 axial thickness:radial thickness for display purposes
%
%Usage: ct3(im) will open Figures 1,2, and 3 and use imshow() to display the
%       CT dataset contained in "im" in all 3 orthogonal planes (sagittal,
%       coronal, axial).  Scrolling the mousewheel will move to the
%       next/previous slice in the active figure window.  Clicking the mouse
%       will print the current slice number of all 3 figure windows in
%       the console.
%
%input:
%   -im: 3D array of grayscale values.  This function assumes that the
%        1st and 2nd dimensions of the array contain the radial (or
%        sagittal/coronal) data, and the 3rd dimension of "im" contains
%        axial data.  This function also assumes a voxel size ratio of
%        1:1:3.
%
%   -w : (optional) window to use for display.  Default=[-140 160]
%        1x2 numerical array that contains the range of values of interest
%        to be displayed using ct3
%        note - use Matlab built-in function "imcontrast" (Image Proc Toolbox)
%        or plot the image data using hist() to easily determine the proper
%        window for your dataset
%
%output:
%        none
%
%ex:
%     ct3(im)
%     ct3(im, [-140 160])


%reverse the z direction
im=im(:,:,end:-1:1);
im2=im2(:,:,end:-1:1);
im3=im3(:,:,end:-1:1);



slice1=floor(size(im,1)/2);
slice2=floor(size(im,2)/2);
slice3=floor(size(im,3)/2);

mn=1;

mx1=size(im,1);
mx2=size(im,2);
mx3=size(im,3);

if nargin < 4
    w=[-140 160];
end

w = [];

%% INITALIZE THE FIGURE WINDOWS
get(0,'ScreenSize');
set(0,'Units','normalized');
f1=figure(1); clf;set(gcf,'Units','normalized');datacursormode off; rotate3d off; zoom off;
f2=figure(2); clf;set(gcf,'Units','normalized');datacursormode off; rotate3d off; zoom off;
f3=figure(3); clf;set(gcf,'Units','normalized');datacursormode off; rotate3d off; zoom off;
set(gcf,'position',[ 0.0050    0.0400    0.3025    0.3383]);

i3=imshow(cat(3, im(:,:,slice3), im2(:,:,slice3), im3(:,:,slice3)),w, 'parent',gca);
set(gca,'position',[0 0 1 1]);

hold on
p311=plot([0 mx2/10],[slice1 slice1],'g', 'linewidth',1);
p312=plot([mx2*9/10 mx2],[slice1 slice1],'g', 'linewidth',1);
p321=plot([slice2 slice2],[0 mx1/10],'g', 'linewidth',1);
p322=plot([slice2 slice2],[mx1*9/10 mx1],'g', 'linewidth',1);
hold off

figure(1);
set(gcf,'position',[ 0.3169    0.0400    0.3025    0.3383]);

i1=imshow(permute(cat(1, im(slice1,:,:), im2(slice1,:,:), im3(slice1,:,:)),[3 2 1]),w,'parent',gca);
set(gca,'position',[0 0 1 1]);

hold on
p131=plot([0 mx2/10],[slice3 slice3],'g', 'linewidth',1);
p132=plot([mx2*9/10 mx2],[slice3 slice3],'g', 'linewidth',1);
p121=plot([slice2 slice2],[0 mx3/10],'g', 'linewidth',1);
p122=plot([slice2 slice2],[mx3*9/10 mx3],'g', 'linewidth',1);
hold off

figure(2); set(gcf,'Units','normalized');
set(gcf,'position',[ 0.0044    0.4558    0.3025    0.3383]);

i2=imshow(permute(cat(2, im(:,slice2,:), im2(:,slice2,:), im3(:,slice2,:)),[3 1 2]),w,'parent',gca);
set(gca,'position',[0 0 1 1]);

hold on
p231=plot([0 mx1/10],[slice3 slice3],'g', 'linewidth',1);
p232=plot([mx1*9/10 mx1],[slice3 slice3],'g', 'linewidth',1);
p211=plot([slice1 slice1],[0 mx3/10],'g', 'linewidth',1);
p212=plot([slice1 slice1],[mx3*9/10 mx3],'g', 'linewidth',1);
hold off



set(f1, 'WindowScrollWheelFcn', @wheel); 
set(f1, 'WindowButtonDownFcn', @click);
set(f2, 'WindowScrollWheelFcn', @wheel);
set(f2, 'WindowButtonDownFcn', @click);
set(f3, 'WindowScrollWheelFcn', @wheel);
set(f3, 'WindowButtonDownFcn', @click);

disp('Find vessel in axial image, then press Return.')

pause
z = slice3;

%% CAPTURE MOUSEWHEEL EVENTS
    function wheel(src, evnt)
        cur=gcf;
        switch cur
            case 1
                if evnt.VerticalScrollCount > 0
                    slice1=slice1+1;
                else
                    slice1=slice1-1;
                end
                slice1=re_eval1(slice1);
                
            case 2
                if evnt.VerticalScrollCount > 0
                    slice2=slice2-1;
                else
                    slice2=slice2+1;
                end
                slice2=re_eval2(slice2);
            case 3
                if evnt.VerticalScrollCount > 0
                    slice3=slice3+1;
                else
                    slice3=slice3-1;
                end
                slice3=re_eval3(slice3);
            otherwise
                %do nothing
        end
    end

%% REDRAW FIGURES
    function slice1=re_eval1(slice1)
        if slice1>mx1
            slice1=mx1;
        elseif slice1<mn
            slice1=mn;
        else
            set(i1,'CData',permute(cat(1, im(slice1,:,:), im2(slice1,:,:), im3(slice1,:,:)),[3 2 1]));
        end
        do_lines;
    end
    function slice2=re_eval2(slice2)
        if slice2>mx2
            slice2=mx2;
        elseif slice2<mn
            slice2=mn;
        else
            set(i2,'CData',permute(cat(2, im(:,slice2,:), im2(:,slice2,:), im3(:,slice2,:)),[3 1 2]));
        end
        do_lines;
    end
    function slice3=re_eval3(slice3)
        if slice3>mx3
            slice3=mx3;
        elseif slice3<mn
            slice3=mn;
        else
            set(i3,'CData',cat(3, im(:,:,slice3), im2(:,:,slice3), im3(:,:,slice3)));
        end
        do_lines;
    end
%% CAPTURE MOUSE CLICKS
    function click(src,evnt)
        %account for reversal of z dimension
%         disp(num2str([slice1 slice2 (mx3+1-slice3)]))
        cur=gcf;
        
        switch cur
            case 1
                pos_axes_unitfig        = get(f1,'position');
                left_origin_unitfig     = pos_axes_unitfig(1);
                bottom_origin_unitfig   = pos_axes_unitfig(2);
                width_axes_unitfig      = pos_axes_unitfig(3);
                height_axes_unitfig     = pos_axes_unitfig(4);
            
                pos_cursor_unitfig      = get( f1, 'currentpoint');
                xlim_axes=get(f1,'XLim');
                
            case 2
                 pos_axes_unitfig        = get(f2,'position');
                left_origin_unitfig     = pos_axes_unitfig(1);
                bottom_origin_unitfig   = pos_axes_unitfig(2);
                width_axes_unitfig      = pos_axes_unitfig(3);
                height_axes_unitfig     = pos_axes_unitfig(4);
            
                pos_cursor_unitfig      = get( f2, 'currentpoint');
                xlim_axes=get(f2,'XLim');
                
            case 3
                 pos_axes_unitfig        = get(f3,'position');
                left_origin_unitfig     = pos_axes_unitfig(1);
                bottom_origin_unitfig   = pos_axes_unitfig(2);
                width_axes_unitfig      = pos_axes_unitfig(3);
                height_axes_unitfig     = pos_axes_unitfig(4);
            
                pos_cursor_unitfig      = get( f3, 'currentpoint');
                xlim_axes=get(f3,'XLim');
            otherwise
                %
        end
    end

%% REDRAW MARKER LINES
    function do_lines
        set(p131,'YData',[slice3 slice3]);
        set(p121,'XData',[slice2 slice2]);
        set(p132,'YData',[slice3 slice3]);
        set(p122,'XData',[slice2 slice2]);
        
        set(p231,'YData',[slice3 slice3]);
        set(p211,'XData',[slice1 slice1]);
        set(p232,'YData',[slice3 slice3]);
        set(p212,'XData',[slice1 slice1]);
        
        set(p311,'YData',[slice1 slice1]);
        set(p321,'XData',[slice2 slice2]);
        set(p312,'YData',[slice1 slice1]);
        set(p322,'XData',[slice2 slice2]);
    end

end