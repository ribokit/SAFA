function varargout = SecondaryStructure(varargin)
% SECONDARYSTRUCTURE M-file for SecondaryStructure.fig
%      SECONDARYSTRUCTURE, by itself, creates a new SECONDARYSTRUCTURE or raises the existing
%      singleton*.
%
%      H = SECONDARYSTRUCTURE returns the handle to a new SECONDARYSTRUCTURE or the handle to
%      the existing singleton*.
%
%      SECONDARYSTRUCTURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SECONDARYSTRUCTURE.M with the given input arguments.
%
%      SECONDARYSTRUCTURE('Property','Value',...) creates a new SECONDARYSTRUCTURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SecondaryStructure_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SecondaryStructure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SecondaryStructure

% Last Modified by GUIDE v2.5 10-Feb-2005 15:31:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SecondaryStructure_OpeningFcn, ...
    'gui_OutputFcn',  @SecondaryStructure_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SecondaryStructure is made visible.
function SecondaryStructure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SecondaryStructure (see VARARGIN)

% Choose default command line output for SecondaryStructure
handles.output = hObject;

% Set our axes right to start with
axis equal
%axis off

% Set up our data
handles.data = [];
handles.offset = 0;
handles.image = [];
handles.pickpoints = [];
handles.whichres = [];
handles.maxvalue = 0;
handles.zerovalue = 0;
handles.minvalue = 0;
handles.squarewidth = 24;

%User is calling from SAFA with data.
if (size(varargin)>0)
    tmpdata = varargin{1};
    handles.whichres = varargin{2};
    
    colorplotfig = figure;
    pickLane=colorplotChooseLane(tmpdata,handles.whichres); %,handles <-- If want to plot to the main window);
    %     pause(2);
    close(colorplotfig);
    
    % Lets grab the appropriate data column
    handles.data = tmpdata(:,pickLane);
    handles.maxvalue = max(handles.data);
    handles.minvalue = min(handles.data);
    handles.zerovalue = mean([handles.maxvalue handles.minvalue]);
    
    [maxString, unused] = sprintf('%.1f', handles.maxvalue);
    [zeroString, unused] = sprintf('%.1f', handles.zerovalue);
    [minString, unused] = sprintf('%.1f', handles.minvalue);
    set(handles.textMaxValue, 'String', maxString);
    set(handles.textZeroValue, 'String', zeroString);
    set(handles.textMinValue, 'String', minString);
    
    set(handles.textDataLoaded, 'String', 'Loaded');
    
    redrawPreview(handles);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SecondaryStructure wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SecondaryStructure_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonLoadStructureImage.
function pushbuttonLoadStructureImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadStructureImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,pathname] = uigetfile({'*.tiff;*.tif;*.jpg;*.jpeg;*.gif;*.mat'});
fullpath=[pathname file];
% isempty(handles.pickpoints)
% file
% pathname
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    if( ~isempty(strfind(file, '.mat')) ) % Chose a .mat file, load the image element
        load(fullpath);
        if(isempty(datatosave.image))
            uiwait(errordlg('No image found in .MAT file!!'));
            return;
        else
            handles.image = datatosave.image;
        end
    else % Was a plain image file
        handles.image = imread(fullpath);
    end
    
    set(handles.pushbuttonPickPoints, 'Enable', 'on');
    set(handles.textImageLoaded, 'String', 'Loaded');
    
    % Update handles structure
    guidata(hObject, handles);
    
    redrawPreview(handles);
end
% isempty(handles.pickpoints)


% --- Executes on button press in pushbuttonLoadData.
function pushbuttonLoadData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

loaddata = questdlg('Warning: This will discard all current data. Continue?',...
    'Load Data','Yes','No','No');
if (0==strcmp(loaddata,'Yes'))
    return;
end

[file,pathname] = uigetfile('*.mat');
fullpath=[pathname file];
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    load(fullpath);
    
    handles = setfield(handles, 'image', getfield(datatosave, 'image'));
    handles = setfield(handles, 'offset', getfield(datatosave, 'offset'));
    handles = setfield(handles, 'pickpoints', getfield(datatosave, 'pickpoints'));
    handles = setfield(handles, 'data', getfield(datatosave, 'data'));
    handles = setfield(handles, 'whichres', getfield(datatosave, 'whichres'));
    handles = setfield(handles, 'maxvalue', getfield(datatosave, 'maxvalue'));
    handles = setfield(handles, 'zerovalue', getfield(datatosave, 'zerovalue'));
    handles = setfield(handles, 'minvalue', getfield(datatosave, 'minvalue'));
    handles = setfield(handles, 'squarewidth', getfield(datatosave, 'squarewidth'));
    
    set(handles.textOffsetDisplay, 'String', handles.offset);
    
    [pickpointsString, unused] = sprintf('%d Picked', length(handles.pickpoints));
    set(handles.textNumPoints, 'String', pickpointsString);
    
    [maxString, unused] = sprintf('%.1f', handles.maxvalue);
    [zeroString, unused] = sprintf('%.1f', handles.zerovalue);
    [minString, unused] = sprintf('%.1f', handles.minvalue);
    set(handles.textMaxValue, 'String', maxString);
    set(handles.textZeroValue, 'String', zeroString);
    set(handles.textMinValue, 'String', minString);
    set(handles.textSquareWidth, 'String', handles.squarewidth);
    
    if(size(handles.image,1) == 0)
        set(handles.pushbuttonPickPoints, 'Enable', 'off');
        set(handles.textImageLoaded, 'String', 'Not Loaded');
    else
        set(handles.pushbuttonPickPoints, 'Enable', 'on');
        set(handles.textImageLoaded, 'String', 'Loaded');
    end
    
    if(~isempty(handles.data))
        set(handles.textDataLoaded, 'String', 'Loaded');
    else
        set(handles.textDataLoaded, 'String', 'Not Loaded');
    end
    
    % Redraw our Sec Struct preview
    redrawPreview(handles);
    
    guidata(hObject,handles); % stores data
end


% --- Executes on button press in pushbuttonSaveData.
function pushbuttonSaveData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,pathname] = uiputfile('*.mat','Save current Secondary Structure data');
fullpath=[pathname file];

if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    datatosave = [];
    datatosave = setfield(datatosave, 'image', getfield(handles, 'image'));
    datatosave = setfield(datatosave, 'offset', getfield(handles, 'offset'));
    datatosave = setfield(datatosave, 'pickpoints', getfield(handles, 'pickpoints'));
    datatosave = setfield(datatosave, 'data', getfield(handles, 'data'));
    datatosave = setfield(datatosave, 'whichres', getfield(handles, 'whichres'));
    datatosave = setfield(datatosave, 'maxvalue', getfield(handles, 'maxvalue'));
    datatosave = setfield(datatosave, 'zerovalue', getfield(handles, 'zerovalue'));
    datatosave = setfield(datatosave, 'minvalue', getfield(handles, 'minvalue'));
    datatosave = setfield(datatosave, 'squarewidth', getfield(handles, 'squarewidth'));
    
    % Get access to the global variable of user-defined field names
    theVersion = version;
    if(theVersion(1) == '7')
        save(fullpath,'datatosave', '-V6');
    else
        save(fullpath,'datatosave');
    end
end

% --- Executes on button press in pushbuttonPickPoints.
function pushbuttonPickPoints_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPickPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'pickpoints')
    handles.pickpoints = [];
end
if ~isfield(handles, 'offset')
    handles.offset = 0;
end

handles.pickpoints = pickpoints(handles.image, handles.offset, handles.pickpoints, handles.squarewidth);
[pickpointsString, unused] = sprintf('%d Picked', length(handles.pickpoints));
set(handles.textNumPoints, 'String', pickpointsString);

if(size(handles.pickpoints, 2) < length(handles.data))
    uiwait(errordlg('Note: You have not defined enough points for your entire dataset'));
end

redrawPreview(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbuttonResetPicks.
function pushbuttonResetPicks_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonResetPicks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

resetpicks = questdlg('Are you sure you wish to Reset the residue location picks?',...
    'Reset','Yes',' No',' No');
switch resetpicks
    case 'Yes'
        handles.pickpoints = [];
        set(handles.pushbuttonGenerateFigure, 'Enable', 'off');
        [pickpointsString, unused] = sprintf('%d Picked', length(handles.pickpoints));
        set(handles.textNumPoints, 'String', pickpointsString);
        
        redrawPreview(handles);
        
        % Update handles structure
        guidata(hObject, handles);
end



% --- Redraws the preview axes based on the underlying data in handles.
function redrawPreview(handles)
% handles object with the axes to draw to

axes(handles.axes1);
if isfield(handles,'image')==1
    image(handles.image)
    axis equal
    axis off
end

if ~isempty(handles.pickpoints)
    if ~isempty(handles.data)
        
        set(handles.pushbuttonGenerateFigure, 'Enable', 'on');
        set(handles.textPreviewStatus, 'String', 'GENERATING PREVIEW...');
        pause(0.1);
        
        % imagex_color = colorsecstruct(handles.image,handles.offset,handles.pickpoints, 1:98,handles.data(:,2),max(handles.data(:,2)),min(handles.data(:,2)), 0, 1);
        imagex_color = colorsecstruct(handles.image, ...
            handles.offset, ...
            handles.pickpoints, ...
            handles.whichres, ...
            handles.data, ...
            handles.maxvalue, ...
            handles.minvalue, ...
            handles.zerovalue, ...
            1, ...
            get(handles.checkboxPlotLegend, 'Value'), ...
            handles.squarewidth);
        %figure(6);
        %hold off; image(imagex_color/256); hold on; axis equal;
        
    else
        set(handles.pushbuttonGenerateFigure, 'Enable', 'off');
        count = length(handles.pickpoints);
        for k=1:count
            xpick = handles.pickpoints(1,k);
            ypick = handles.pickpoints(2,k);
            h(count) = rectangle('Position',...
                [xpick - handles.squarewidth/2, ypick-handles.squarewidth/2,...
                    handles.squarewidth,handles.squarewidth]);
            set(h(count),'edgecolor','b');
        end
    end
    
    set(handles.textPreviewStatus, 'String', 'PLOT PREVIEW:');
end

% --- Executes on button press in pushbuttonLoadProtectionData.
function pushbuttonLoadProtectionData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadProtectionData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,pathname] = uigetfile('*.txt');
fullpath=[pathname file];
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    tmpdata = load(fullpath);
    numLanes = size(tmpdata,2) - 1;
    
    colorplotfig = figure;
    pickLane=colorplotChooseLane(tmpdata(:,2:numLanes+1),tmpdata(:,1)); %,handles <-- If want to plot to the main window);
    close(colorplotfig);
    
    % Lets grab the appropriate data column
    handles.data = tmpdata(:,pickLane+1);
    handles.whichres = tmpdata(:,1);
    handles.maxvalue = max(handles.data);
    handles.minvalue = min(handles.data);
    handles.zerovalue = mean([handles.maxvalue handles.minvalue]);
    
    [maxString, unused] = sprintf('%.1f', handles.maxvalue);
    [zeroString, unused] = sprintf('%.1f', handles.zerovalue);
    [minString, unused] = sprintf('%.1f', handles.minvalue);
    set(handles.textMaxValue, 'String', maxString);
    set(handles.textZeroValue, 'String', zeroString);
    set(handles.textMinValue, 'String', minString);
    
    set(handles.textDataLoaded, 'String', 'Loaded');
    
    redrawPreview(handles);
    
    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on button press in pushbuttonGenerateFigure.
function pushbuttonGenerateFigure_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGenerateFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 'GENERATE FIGURE!'
% isempty(handles.pickpoints)
% isempty(handles.data)
if ~isempty(handles.pickpoints) && ~isempty(handles.data)
    figure;        
    % imagex_color = colorsecstruct(handles.image,handles.offset,handles.pickpoints, 1:98,handles.data(:,2),max(handles.data(:,2)),min(handles.data(:,2)), 0, 1);
    imagex_color = colorsecstruct(handles.image, ...
        handles.offset, ...
        handles.pickpoints, ...
        handles.whichres, ...
        handles.data, ...
        handles.maxvalue, ...
        handles.minvalue, ...
        handles.zerovalue, ...
        1, ...
        get(handles.checkboxPlotLegend, 'Value'), ...
        handles.squarewidth);
    
    titleString = 'Click to place upper-left of legend, Q/Z to Finish';
    if 1==get(handles.checkboxPlotLegend, 'Value')
        stop_pick = 0;
        while(stop_pick < 1)
            title(titleString);
            [xpick,ypick,button] = ginput(1);
            switch button
                case 1
                    if(ypick < 0 || ypick > size(handles.image, 1) - 8.5*handles.squarewidth || ...
                            xpick < 0 || xpick > size(handles.image, 2) - handles.squarewidth)
                        titleString = 'YOU CLICKED TOO CLOSE TO THE EDGE OF THE IMAGE! \newline Click to place upper-left of legend, Q/Z to Finish';
                    else
                        titleString = 'Click to place upper-left of legend, Q/Z to Finish';
                        title('Drawing...');
                        pause(.1);
                        imagex_color = colorsecstruct(handles.image, ...
                            handles.offset, ...
                            handles.pickpoints, ...
                            handles.whichres, ...
                            handles.data, ...
                            handles.maxvalue, ...
                            handles.minvalue, ...
                            handles.zerovalue, ...
                            1, ...
                            get(handles.checkboxPlotLegend, 'Value'), ...
                            handles.squarewidth, ...
                            ypick, ...
                            xpick);            
                    end
            end
            switch char(button)
                case {'q','z','Q','Z'}
                    stop_pick=1;
            end
        end
        title('Done!');
        pause(1.5);
        title('');
        %hold off; image(imagex_color/256); hold on; axis equal; 
    end
end


% --- Executes during object creation, after setting all properties.
function textMaxValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textMaxValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function textMaxValue_Callback(hObject, eventdata, handles)
% hObject    handle to textMaxValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textMaxValue as text
%        str2double(get(hObject,'String')) returns contents of textMaxValue as a double


% --- Executes on button press in pushbuttonSetMaxValue.
function pushbuttonSetMaxValue_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMaxValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'New maximum data value?';
def={num2str(handles.maxvalue)};
dlgTitle='Set Maximum Value';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
num_answer = str2double(answer);
if ( isnan(num_answer) )
    uiwait(errordlg('You must enter a numeric maximum value'));
    return;
end

handles.maxvalue = num_answer;
[maxString, unused] = sprintf('%.1f', handles.maxvalue);
set(handles.textMaxValue, 'String', maxString);

redrawPreview(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function textZeroValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textZeroValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function textZeroValue_Callback(hObject, eventdata, handles)
% hObject    handle to textZeroValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textZeroValue as text
%        str2double(get(hObject,'String')) returns contents of textZeroValue as a double


% --- Executes during object creation, after setting all properties.
function textMinValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function textMinValue_Callback(hObject, eventdata, handles)
% hObject    handle to textMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textMinValue as text
%        str2double(get(hObject,'String')) returns contents of textMinValue as a double


% --- Executes on button press in pushbuttonSetZeroValue.
function pushbuttonSetZeroValue_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetZeroValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'New zero (white) data value?';
def={num2str(handles.zerovalue)};
dlgTitle='Set Zero Value';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
num_answer = str2double(answer);
if ( isnan(num_answer) )
    uiwait(errordlg('You must enter a numeric zero-value'));
    return;
end

handles.zerovalue = num_answer;
[zeroString, unused] = sprintf('%.1f', handles.zerovalue);
set(handles.textZeroValue, 'String', zeroString);

redrawPreview(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbuttonSetMinValue.
function pushbuttonSetMinValue_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetMinValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'New minimum data value?';
def={num2str(handles.minvalue)};
dlgTitle='Set Minimum Value';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
num_answer = str2double(answer);
if ( isnan(num_answer) )
    uiwait(errordlg('You must enter a numeric minimum value'));
    return;
end

handles.minvalue = num_answer;
[minString, unused] = sprintf('%.1f', handles.minvalue);
set(handles.textMinValue, 'String', minString);

redrawPreview(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbuttonSetSquareWidth.
function pushbuttonSetSquareWidth_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSetSquareWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First get the lane of data desired
prompt = 'New point Square Width?';
def={num2str(handles.squarewidth)};
dlgTitle='Set Squre Width';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
num_answer = str2double(answer);
if ( isnan(num_answer) || (num_answer - round(num_answer) ~= 0) || (num_answer <= 0) )
    uiwait(errordlg('You must enter a positive integer value for the pickpoints square width'));
    return;
end

handles.squarewidth = num_answer;
set(handles.textSquareWidth, 'String', answer);

redrawPreview(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function textSquareWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSquareWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function textSquareWidth_Callback(hObject, eventdata, handles)
% hObject    handle to textSquareWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textSquareWidth as text
%        str2double(get(hObject,'String')) returns contents of textSquareWidth as a double


% --- Executes on button press in pushbuttonLoadPickpoints.
function pushbuttonLoadPickpoints_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadPickpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,pathname] = uigetfile('*.mat');
fullpath=[pathname file];
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    load(fullpath);
    
    handles = setfield(handles, 'pickpoints', getfield(datatosave, 'pickpoints'));
    handles = setfield(handles, 'squarewidth', getfield(datatosave, 'squarewidth'));
    
    [pickpointsString, unused] = sprintf('%d Picked', length(handles.pickpoints));
    set(handles.textNumPoints, 'String', pickpointsString);
    
    set(handles.textSquareWidth, 'String', handles.squarewidth);
    
    % Redraw our Sec Struct preview
    redrawPreview(handles);
    
    guidata(hObject,handles); % stores data
end


% --- Executes on button press in pushbuttonOffset.
function pushbuttonOffset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = 'New Offset of first point?';
def={num2str(handles.offset)};
dlgTitle='Set Offset';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
num_answer = str2double(answer);
if ( isnan(num_answer) || (num_answer - round(num_answer) ~= 0) || (num_answer < 0) )
    uiwait(errordlg('You must enter a non-negative integer value for the offset'));
    return;
end

handles.offset = num_answer;
set(handles.textOffsetDisplay, 'String', num2str(num_answer));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkboxPlotLegend.
function checkboxPlotLegend_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPlotLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPlotLegend
redrawPreview(handles);

% titleString = 'Click to place upper-left of legend, Q/Z to Finish';
% if 1==get(handles.checkboxPlotLegend, 'Value')
%     stop_pick = 0;
%     while(stop_pick < 1)
%         set(handles.textPreviewStatus, 'String', titleString);
%         [xpick,ypick,button] = ginput(1);
%         switch button
%             case 1
%                 if(ypick < 0 || ypick > size(handles.image, 1) - 8.5*handles.squarewidth || ...
%                         xpick < 0 || xpick > size(handles.image, 2) - handles.squarewidth)
%                     titleString = 'YOU CLICKED TOO CLOSE TO THE EDGE OF THE IMAGE!';
%                     set(handles.textPreviewStatus, 'String', titleString);
%                     pause(1.5);
%                     titleString = 'Click to place upper-left of legend, Q/Z to Finish';
%                 else
%                     titleString = 'Drawing...';
%                     set(handles.textPreviewStatus, 'String', titleString);
% %                    title('Drawing...');
%                     pause(.1);
%                     imagex_color = colorsecstruct(handles.image, ...
%                         handles.offset, ...
%                         handles.pickpoints, ...
%                         handles.whichres, ...
%                         handles.data, ...
%                         handles.maxvalue, ...
%                         handles.minvalue, ...
%                         handles.zerovalue, ...
%                         1, ...
%                         get(handles.checkboxPlotLegend, 'Value'), ...
%                         handles.squarewidth, ...
%                         ypick, ...
%                         xpick);            
%                     
%                     titleString = 'Click to place upper-left of legend, Q/Z to Finish';
%                 end
%         end
%         switch char(button)
%             case {'q','z','Q','Z'}
%                 stop_pick=1;
%         end
%     end
%     set(handles.textPreviewStatus, 'String', 'Done!');
%     pause(1.5);
%     set(handles.textPreviewStatus, 'String', 'PLOT PREVIEW:');
%     %hold off; image(imagex_color/256); hold on; axis equal; 
% end
