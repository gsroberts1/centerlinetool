function varargout = paramMap(varargin)
% PARAMMAP MATLAB code for paramMap.fig
%      PARAMMAP, by itself, creates a new PARAMMAP or raises the existing
%      singleton*.
%
%      H = PARAMMAP returns the handle to a new PARAMMAP or the handle to
%      the existing singleton*.
%
%      PARAMMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMMAP.M with the given input arguments.
%
%      PARAMMAP('Property','Value',...) creates a new PARAMMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before paramMap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to paramMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help paramMap

% Last Modified by GUIDE v2.5 06-Mar-2017 14:10:36

% Copyright Eric Schrauben; University of Wisconsin - Madison, 2015
% updated Eric Schrauben; The Hospital for Sick Children, Toronto, 2017

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @paramMap_OpeningFcn, ...
    'gui_OutputFcn',  @paramMap_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before paramMap is made visible.
function paramMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to paramMap (see VARARGIN)

% Choose default command line output for paramMap
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes paramMap wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global nframes timeres fov res directory timeMIP v 
global branchList branchTextList branchMat
global segment area_vol flowPerHeartCycle_vol PI_vol diam_vol maxVel_vol RI_vol flowPulsatile_vol
% flow parameter calculation, bulk of code is in paramMap_parameters.m
[area_vol, diam_vol, flowPerHeartCycle_vol, maxVel_vol, PI_vol, RI_vol, flowPulsatile_vol] = paramMap_params(...
    branchTextList, branchList, res, timeMIP, v,branchMat, nframes, fov);

% --- Outputs from this function are returned to the command line.
function varargout = paramMap_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in parameter_choice.
function parameter_choice_Callback(hObject, eventdata, handles)
% hObject    handle to parameter_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameter_choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameter_choice


% --- Executes during object creation, after setting all properties.
function parameter_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in view_map.
function view_map_Callback(hObject, eventdata, handles)
% hObject    handle to view_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Yhis function allows for the 3D plotting of the values calculated from
% paramMap_params.m, with the option of visualizing individual waveforms

global  area_vol flowPerHeartCycle_vol PI_vol  diam_vol maxVel_vol RI_vol ...
    plot_flowWaveform

% Get parameter option and whether plotting flow waveform is turned on
val = get(handles.parameter_choice, 'Value');
str = get(handles.parameter_choice, 'String');
plot_flowWaveform = get(handles.plot_flowWaveform,'Value');

% Initialize figure
fig = figure(1);
clf
set(fig,'Name',[str{val} ' Map'], 'NumberTitle','off')

% turn on data cursormode within the figure
dcm_obj = datacursormode(fig);
datacursormode on;

switch str{val}
    case 'Area'
        [x y z] = ind2sub(size(area_vol),find(area_vol));
        cdata = area_vol(find(area_vol));
        
        if plot_flowWaveform ==1;
            subplot(2,1,1)
            scatter3(y,x,z,45,cdata,'filled')
        else
            scatter3(y,x,z,45,cdata,'filled')
        end
        
        % make it look good
        caxis([min(cdata) 0.7*max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([0 1.5*mean(area_vol(find(area_vol(:))))])
        set(get(cbar,'xlabel'),'string','Area (cm^2)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        
        % update string
        set(dcm_obj,'UpdateFcn',@myupdatefcn_area)
        
    case 'Diameter'
        [x y z] = ind2sub(size(diam_vol),find(diam_vol));
        cdata = diam_vol(find(diam_vol));
        
        if plot_flowWaveform ==1;
            subplot(2,1,1)
            scatter3(y,x,z,45,cdata,'filled')
        else
            scatter3(y,x,z,45,cdata,'filled')
        end
        
        % make it look good
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-0.25 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        set(get(cbar,'xlabel'),'string','Diameter (cm)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        
        % update string
        set(dcm_obj,'UpdateFcn',@myupdatefcn_diam)
        
    case 'Total Flow'
        [x y z] = ind2sub(size(flowPerHeartCycle_vol),find(flowPerHeartCycle_vol));
        cdata = flowPerHeartCycle_vol(find(flowPerHeartCycle_vol));
        
        if plot_flowWaveform ==1;
            subplot(2,1,1)
            scatter3(y,x,z,45,cdata,'filled')
        else
            scatter3(y,x,z,45,cdata,'filled')
        end
        
        % make it look good
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([0 0.8*max(flowPerHeartCycle_vol(:))])
        set(get(cbar,'xlabel'),'string','Flow (mL/cycle)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        
        % update string
        set(dcm_obj,'UpdateFcn',@myupdatefcn_flow)
        
    case 'Maximum Velocity '
        [x y z] = ind2sub(size(maxVel_vol),find(maxVel_vol));
        cdata = maxVel_vol(find(maxVel_vol));
        
        if plot_flowWaveform ==1;
            subplot(2,1,1)
            scatter3(y,x,z,45,cdata,'filled')
        else
            scatter3(y,x,z,45,cdata,'filled')
        end
        
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([min(maxVel_vol(:)) 110])
        set(get(cbar,'xlabel'),'string','Max Velocity (cm/s)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        set(dcm_obj,'UpdateFcn',@myupdatefcn_maxVel)
        
        case 'Resistance Index'
        
        [x y z] = ind2sub(size(RI_vol),find(RI_vol));
        cdata = RI_vol(find(RI_vol));
        
        if plot_flowWaveform ==1;
            subplot(2,1,1)
            scatter3(y,x,z,45,cdata,'filled')
        else
            scatter3(y,x,z,45,cdata,'filled')
        end
        
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([-0.5 1])
        set(get(cbar,'xlabel'),'string','Resistance Index','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        
        set(dcm_obj,'UpdateFcn',@myupdatefcn_RI)
    case str{val}
        
        [x y z] = ind2sub(size(PI_vol),find(PI_vol));
        cdata = PI_vol(find(PI_vol));
        
        if plot_flowWaveform ==1;
            subplot(2,1,1)
            scatter3(y,x,z,45,cdata,'filled')
        else
            scatter3(y,x,z,45,cdata,'filled')
        end
        
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([0 2])
        set(get(cbar,'xlabel'),'string','Pulsatility Index','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        
        set(dcm_obj,'UpdateFcn',@myupdatefcn_PI)
  
end


% --- Executes on button press in plot_flowwaveform.
function plot_flowWaveform_Callback(hObject, eventdata, handles)
% hObject    handle to plot_flowwaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_flowwaveform


% --- Executes during object creation, after setting all properties.
function plot_flowWaveform_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_flowwaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
