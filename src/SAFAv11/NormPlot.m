function varargout = NormPlot(varargin)
% NORMPLOT M-file for NormPlot.fig
%      NORMPLOT, by itself, creates a new NORMPLOT or raises the existing
%      singleton*.
%
%      H = NORMPLOT returns the handle to a new NORMPLOT or the handle to
%      the existing singleton*.
%
%      NORMPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NORMPLOT.M with the given input arguments.
%
%      NORMPLOT('Property','Value',...) creates a new NORMPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NormPlot_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NormPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NormPlot

% Last Modified by GUIDE v2.5 05-Dec-2004 14:35:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NormPlot_OpeningFcn, ...
    'gui_OutputFcn',  @NormPlot_OutputFcn, ...
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


% --- Executes just before NormPlot is made visible.
function NormPlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NormPlot (see VARARGIN)

% Choose default command line output for NormPlot
handles.output = hObject;
axis off

% Update handles structure
guidata(hObject, handles);

set(gcf,'color',[1 1 1]);
%User is calling from SAFA.
if (size(varargin)>0)
    handles.data = varargin{1};
    handles.whichpeaks = varargin{2}';
    handles.pathname = varargin{3};
    handles.filename = varargin{4};
    set(handles.text_filename,'string',handles.filename);    
    data_norm=colorplot(handles.data,handles.whichpeaks,hObject,handles);
    handles.data_norm=data_norm;
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NormPlot wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = NormPlot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Read_data_Callback(hObject, eventdata, handles)
% hObject    handle to Read_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,pathname] = uigetfile('*.txt');
data= [pathname file];
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    titleplot = file;
    
    data = load(data);
    numlanes = size(data,2)-1;
    
    %Basic set up.
    handles.whichpeaks = data(:,1);
    handles.data       = data(:,[1:numlanes]+1);
    handles.pathname  = pathname;
    handles.filename  = file;
    
    set(handles.text_filename,'string',handles.filename);
    
    guidata(hObject, handles);
    
    data_norm = colorplot(handles.data,handles.whichpeaks,hObject,handles);
end

% --------------------------------------------------------------------
function Save_data_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Do you wish to switch the rows and columns in your text (useful for Excel or Kaleidagraph)'],...
    'Save data','Yes','No','No');

datamatrix = [handles.whichpeaks handles.data_norm];
if strcmp(selection,'Yes') datamatrix = datamatrix';end;

[file,pathname] = uiputfile([handles.filename,'.norm.txt'],'Save Normalized data');
fullpath=[pathname file];
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    save(fullpath,'-ASCII','-TABS','datamatrix');
end


% --------------------------------------------------------------------
function Save_image_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


selection = questdlg('Select file format',...
    'Save image','eps','pdf','eps');

[file,pathname] = uiputfile([handles.filename,'.',selection],'Save PDF image');
fullpath=[pathname file];

%Center the figure on the page...
% papersize=get(gcf,'PaperSize')
% set(gcf,'Units','inches')
% paperposition = get(gcf,'Position');
% left=    (papersize(1)-paperposition(3))/2
% bottom=  (papersize(2)-paperposition(4))/2
% set(gcf,'Paperpositionmode','auto',...
%     'Paperposition',[left,bottom+1000,paperposition(3),paperposition(4)])
set(gcf,'Paperpositionmode','auto');
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);
    
    switch selection
        case 'eps'
            print(handles.figure1,'-depsc',fullpath)
        case 'pdf'
            print(handles.figure1,'-dpdf',fullpath)
    end
end

% --------------------------------------------------------------------
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1)

% --------------------------------------------------------------------
function Latest_SAFA_data_Callback(hObject, eventdata, handles)
% hObject    handle to Latest_SAFA_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);

if isfield(handles,'data')
    data_norm=colorplot(handles.data,handles.whichpeaks,hObject,handles);
    handles.data_norm=data_norm;
else
    errordlg('No data from SAFA','Error');
end
guidata(hObject, handles);

