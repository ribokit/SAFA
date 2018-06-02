function varargout = SAFA(varargin)
% SAFA M-file for SAFA.fig
%      SAFA, by itself, creates a new SAFA or raises the existing
%      singleton*.
%
%      H = SAFA returns the handle to a new SAFA or the handle to
%      the existing singleton*.
%
%      SAFA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAFA.M with the given input arguments.
%
%      SAFA('Property','Value',...) creates a new SAFA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAFA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAFA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAFA

% Last Modified by GUIDE v2.5 26-Jan-2005 18:00:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SAFA_OpeningFcn, ...
    'gui_OutputFcn',  @SAFA_OutputFcn, ...
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


% --- Executes just before SAFA is made visible.
function SAFA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAFA (see VARARGIN)

% Choose default command line output for SAFA
handles.output = hObject;

% Save the original axes for reset
handles.originalaxes = handles.axes1;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SAFA wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global verbose; verbose = [0 1];

% This is our original start directory. This is needed to find Open.tif in
% the compiled version!
global original_dir;
original_dir = cd;

% This is a list of all the User-defined fields that need
% to be reset when loading a new dump, or resetting SAFA
global datafieldnames;
datafieldnames = cell(0);
datafieldnames{size(datafieldnames,1)+1,1} = 'anchorlines';
datafieldnames{size(datafieldnames,1)+1,1} = 'cleavage_sites';
datafieldnames{size(datafieldnames,1)+1,1} = 'gelbounds';
datafieldnames{size(datafieldnames,1)+1,1} = 'imagey';
datafieldnames{size(datafieldnames,1)+1,1} = 'laneboundaries';
datafieldnames{size(datafieldnames,1)+1,1} = 'numfinebins';
datafieldnames{size(datafieldnames,1)+1,1} = 'Offset';
datafieldnames{size(datafieldnames,1)+1,1} = 'peakarea_lin';
datafieldnames{size(datafieldnames,1)+1,1} = 'POS_Array';
datafieldnames{size(datafieldnames,1)+1,1} = 'profiles';
datafieldnames{size(datafieldnames,1)+1,1} = 'profiles_align';
datafieldnames{size(datafieldnames,1)+1,1} = 'profiles_combine';
datafieldnames{size(datafieldnames,1)+1,1} = 'profiles_pred';
datafieldnames{size(datafieldnames,1)+1,1} = 'profiles_pred_fine';
datafieldnames{size(datafieldnames,1)+1,1} = 'sequence';
datafieldnames{size(datafieldnames,1)+1,1} = 'startnum';
datafieldnames{size(datafieldnames,1)+1,1} = 't1num';
datafieldnames{size(datafieldnames,1)+1,1} = 'threeprime';
datafieldnames{size(datafieldnames,1)+1,1} = 'whichpeaks';
datafieldnames{size(datafieldnames,1)+1,1} = 'widthpeak_all';
datafieldnames{size(datafieldnames,1)+1,1} = 'xsel';
datafieldnames{size(datafieldnames,1)+1,1} = 'xsel_all';
datafieldnames{size(datafieldnames,1)+1,1} = 'xsel_T1';
datafieldnames{size(datafieldnames,1)+1,1} = 'xsel_bound_fine';
datafieldnames{size(datafieldnames,1)+1,1} = 'xsel_center';

% Set whether or not we render with the SQRT(image) by default
global renderSqrt;
renderSqrtMenuHandle = findobj('Tag', 'RenderSqrt');
if(ispc)
    renderSqrt = 1;
    set(renderSqrtMenuHandle, 'Checked', 'on');
else
    renderSqrt = 0;
    set(renderSqrtMenuHandle, 'Checked', 'off');
end

axes(handles.axes1);
openimage=imread('Open.tif');
image(openimage);
set(gca,'XTickMode','manual');
set(gca,'YTickMode','manual');


% --- Outputs from this function are returned to the command line.
function varargout = SAFA_OutputFcn(hObject, eventdata, handles)
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
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

if isfield(handles,'SeqSelectionWindow')==1
    if ishandle(handles.SeqSelectionWindow) == 1
        delete(handles.SeqSelectionWindow);
    end
    handles = rmfield(handles, 'SeqSelectionWindow');
end
delete(handles.figure1)


% --- Executes on button press in AlignGel.
function AlignGel_Callback(hObject, eventdata, handles)
% hObject    handle to AlignGel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'imagey')==0
    errordlg('You cannot align a gel you have not yet loaded, please load a gel from the file menu','Error');
    return;
end
if isfield(handles,'xsel_bound_fine')==0
    errordlg('You first need to define the lanes before you can align a gel, please click on define lanes first','Error');
    return;
end
if isfield(handles,'t1num')==0
    errordlg('You first need to define a anchor lane before you can align a gel, please click on Anchor Lane','t1num missing');
    return;
end


if isfield(handles,'profiles')==0 && isfield(handles,'xsel_bound_fine')==1
    [handles.profiles] = calculateprofiles(handles.xsel_bound_fine,handles.imagey,handles.numfinebins);
end
if isfield(handles,'anchorlines')==0  %No alignment has been carried out yet.
    handles.anchorlines = [];
end
if ~isfield(handles,'profiles_align') handles.profiles_align = [];end;
profilesinput = handles.profiles; saveanchorlines = 1;

%For backwards compatibility only ...
% previous versions did not save "anchorline information".
if isempty(handles.anchorlines) & ~isempty(handles.profiles_align) 
    handles.anchorlines = [];   saveanchorlines = 0;
    profilesinput = handles.profiles_align;
end

[handles.profiles_align,handles.profiles_combine,handles.anchorlines] = ...
    align_userinput_saveanchorlines(profilesinput,handles.numfinebins,handles.t1num,handles.anchorlines,handles.axes1);

if (saveanchorlines == 0) handles.anchorlines = []; end;

guidata(hObject,handles);

% --- Executes on button press in DefineLanes.
function DefineLanes_Callback(hObject, eventdata, handles)
% hObject    handle to DefineLanes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'imagey')==0
    errordlg('You cannot define lanes on a gel you have not yet loaded, please load a gel from the file menu','Error');
    return;
end

% First get the number of bins per lane
prompt={'Number of bins per lane:' };
def={'10'};
dlgTitle='Bins per lane';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
if size(answer,1) == 0
    errordlg('You must choose the number of divisions per lane to define your lanes.');
    return;
end

handles.numfinebins=str2num(answer{1});

imagey=handles.imagey;
% max(max(handles.imagey))
% max(max(handles.profiles))
% sum(sum(handles.imagey))
% sum(sum(handles.profiles))
axes(handles.axes1);
numfinebins=handles.numfinebins;

if isfield(handles,'laneboundaries')==0
    handles.laneboundaries =[];
end

[xsel_bound_fine,xsel_center,handles.laneboundaries] = definelanes(imagey,numfinebins,handles.laneboundaries,handles.axes1);

handles.xsel_bound_fine = xsel_bound_fine;
handles.xsel_center = xsel_center;

% Use this if not using the precompiled c-routine below
[handles.profiles] = calculateprofiles(handles.xsel_bound_fine,handles.imagey,handles.numfinebins);

% This uses the c-compiled routine that is only available on the Mac
%profiles = calculateprofiles_call_comp(handles.xsel_bound_fine,handles.imagey,handles.numfinebins);
%profiles = profiles';
%handles.profiles = profiles(:, 1 :  size(handles.xsel_bound_fine,1) - 1);

guidata(hObject,handles); % stores data



% --- Executes on button press in AssignBands.
function AssignBands_Callback(hObject, eventdata, handles)
% hObject    handle to AssignBands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'imagey')==0
    errordlg('You cannot assign a gel you have not yet loaded, please load a gel from the file menu','Error');
    return;
end
if isfield(handles,'xsel_bound_fine')==0
    errordlg('You first need to define the lanes before you can assign a gel, please click on define lanes first','Error');
    return;
end
if isfield(handles,'t1num')==0
    errordlg('You first need to define an anchor lane, please click on anchor lane','t1num missing');
    return;
end
if isfield(handles,'profiles_align')==0
    errordlg('You first need to align the gel before you can assign a gel, please click on align gel','Error');
    return;
end
if isfield(handles,'POS_Array')==0
    errordlg('You first need to read in a sequence file before you can assign the gel, please load a sequence file','POS_Array missing');
    return;
end

if isfield(handles,'startnum')==1
    tmpdef=num2str(handles.startnum);
    def={tmpdef};
else
    def={'132'};
end

%Ask user for starting band, if no band assignments have been made yet.
if isfield(handles,'xsel')==0
    handles.xsel=[];
    handles.xsel_T1=[];
end
if isempty(handles.xsel)
    prompt={'Starting Band number'};
    dlgTitle='Input for Starting Band';
    lineNo=1;
    answer=inputdlg(prompt,dlgTitle,lineNo,def);
    handles.startnum=str2num(answer{1});
end

[handles.xsel,handles.xsel_T1] = defineT1user(handles.profiles_align,handles.POS_Array,handles.numfinebins,handles.t1num,handles.startnum,handles.xsel,handles.xsel_T1,handles.sequence,handles.Offset,handles.axes1);

guidata(hObject,handles); % stores data


% --- Executes on button press in Quantify.
function Quantify_Callback(hObject, eventdata, handles)
% hObject    handle to Quantify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'imagey')==0
    errordlg('You cannot fit data you have not yet loaded, please load a gel from the file menu','imagey missing');
    return;
end
if isfield(handles,'xsel_bound_fine')==0
    errordlg('You first need to define the lanes before you can fit data, please click on define lanes first','xsel_bound_fine missing');
    return;
end
if isfield(handles,'t1num')==0
    errordlg('You first need to define an anchor lane, please click on Anchor Lane','t1num missing');
    return;
end
if isfield(handles,'profiles_align')==0
    errordlg('You first need to align the gel before you can fit data, please click on align gel','profiles_align missing');
    return;
end
if isfield(handles,'xsel')==0
    errordlg('You first need to Assign Bands before you can fit data, please click on Assign Bands','xsel missing');
    return;
end
if isfield(handles,'xsel_T1')==0
    errordlg('You first need to Assign Bands before you can fit data, please click on Assign Bands','xsel_T1 missing');
    return;
end

numpeaks_defined = length(find(handles.xsel>0));
prompt={'Number of Bands to fit'};
def={num2str(numpeaks_defined)};
dlgTitle='Fitting Parameters';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
num_bands=str2num(answer{1});
if (num_bands>numpeaks_defined)
    errordlg(['Number of bands should be less than number guessed, ' num2str(numpeaks_defined),'.'],...
        'num_bands too big');
    return;
end;
numres_refine = handles.startnum:handles.startnum+num_bands-1;
alpha=0.1;

if handles.POS_Array(2)<handles.POS_Array(1) %It's a 3prime gel.
    numres_refine = handles.startnum-num_bands+1:handles.startnum;
end

%ButtonName=questdlg('Enforce positive peak areas? Selecting yes will fit slower, but you may obtain more accurate results.', ...
%    'Peak Width Model', ...
%    'Yes','No','Cancel','Yes');

[handles.peakarea_lin,handles.profiles_pred,handles.xsel_all,handles.widthpeak_all,handles.whichpeaks,handles.dwhichpeaks,handles.profiles_pred_fine] = ...
    peakfitlinear_refineboot(handles.profiles_combine,handles.numfinebins,handles.xsel,alpha,numres_refine,handles.profiles);

% Save a copy of the data in .txt format?
Click=questdlg('Finished fitting the data, would you like to save a copy?','Save areas','Yes','No','Yes');
if strcmp(Click,'Yes') == 1
    whichpeaks=handles.whichpeaks;
    areas=handles.peakarea_lin;
    size(areas);
    size(whichpeaks);
    datamatrix = [whichpeaks' areas];
    [file,pathname] = uiputfile('*.txt','Save Fitted Areas');
    fullpath=[pathname file];
    if ~isequal(file, 0)
        % Make this our current dir
        cd(pathname);
        
        save(fullpath,'-ASCII','-TABS','datamatrix');
    end
    handles.pathname_out = pathname;
    handles.file_out     = file;
    % Call the Plot-Fit Visualization Routine
    PlotFits_Callback(hObject, eventdata, handles);
end


guidata(hObject,handles); % stores data


% --------------------------------------------------------------------
function SaveDump_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Save a Dump of all the memory

[file,pathname] = uiputfile('*.mat','Save Dump of current work');
fullpath=[pathname file];

if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);

    % Get access to the global variable of user-defined field names
    global datafieldnames;
    datatosave = [];
    for i=1:size(datafieldnames,1)
        s = datafieldnames{i,1};
        if isfield(handles, s)==1
            datatosave = setfield(datatosave, s, getfield(handles, s));
        end
    end
    theVersion = version;
    if(theVersion(1) == '7')
        save(fullpath,'datatosave', '-V6');
    else
        save(fullpath,'datatosave');
    end
end



% --------------------------------------------------------------------
function LoadDump_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Read a Dumped file
[file,pathname] = uigetfile('*.mat');
fullpath=[pathname file];
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);

    load(fullpath);
    
    ResetSAFA_Callback(hObject, eventdata, handles);
    
    % Get access to the global variable of user-defined field names
    global datafieldnames;
    for i=1:size(datafieldnames,1)
        s = datafieldnames{i,1};
        if isfield(datatosave, s)==1
            handles = setfield(handles, s, getfield(datatosave, s));
        end
    end
    
    
    % If there is a gel image, display it
    if isfield(datatosave,'profiles_align') == 1
        imagetoplot = handles.profiles_align;
    elseif isfield(datatosave,'profiles') == 1
        imagetoplot = handles.profiles;
    elseif isfield(datatosave,'imagey') == 1
        imagetoplot = handles.imagey;    
    end
    
    axes(handles.axes1); 
    imagesize=size(imagetoplot);
    
    % Make maxprof and grayscaleon global so that
    % they stay the same in between functions
    global maxprof;
    global grayscaleon;
    global renderSqrt;
    
    maxprof = max(max(imagetoplot))/80;
    grayscaleon = 1;
    setcolormap(grayscaleon, maxprof);
    axis([1 imagesize(2) 1 imagesize(1)]);
    if(renderSqrt == 1)
        image(sqrt(imagetoplot));
    else
        image(imagetoplot);
    end
    
    % If there was a sequence read in, display the sequence cleavage window
%  **NOT** bringing up the SeqSelection window automatically anymore!!!
%     if isfield(datatosave,'cleavage_sites')==1
%         [blank1,blank2,blank3,handles.SeqSelectionWindow]=SeqSelection(handles.sequence, handles.cleavage_sites, handles.Offset, handles.threeprime);
%     end
    
    guidata(hObject,handles); % stores data
end

% --- Executes on button press in AnchorLane.
function AnchorLane_Callback(hObject, eventdata, handles)
% hObject    handle to AnchorLane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles,'profiles')==0 && isfield(handles,'xsel_bound_fine')==1
    [handles.profiles] = calculateprofiles(handles.xsel_bound_fine,handles.imagey,handles.numfinebins);
end
if isfield(handles,'profiles')==0
    errordlg('You first need to define lanes before selecting a lane as a reference, please click on define lanes','profiles missing');
    return;
end


laneNo=get_lane_number(handles.profiles,handles.axes1,handles.numfinebins);
handles.t1num=laneNo;
title(['You selected lane ',num2str(laneNo), ' as your reference.']);

guidata(hObject,handles); % stores data




% --- Executes on button press in ResetAlign.
function ResetAlign_Callback(hObject, eventdata, handles)
% hObject    handle to ResetAlign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'profiles')==0
    errordlg('You cannot reset a gel you have not yet aligned, please load a gel from the file menu and align','no profiles');
    return;
end

handles.anchorlines = [];
handles.profiles_align = [];

guidata(hObject,handles); % stores data

%AlignGel_Callback(hObject, eventdata, handles);


% --- Executes on button press in ResetAssign.
function ResetAssign_Callback(hObject, eventdata, handles)
% hObject    handle to ResetAssign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.xsel=[]; 
handles.xsel_T1 = [];


guidata(hObject,handles); % stores data


% --------------------------------------------------------------------
% Executes on choosing 'Export Gel' in the file menu
function ExportGel_Callback(hObject, eventdata, handles)
% hObject    handle to ExportGel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'profiles') == 0
    uiwait(errordlg('You must have loaded a gel in order to export'));
    return;
end

if isfield(handles, 'profiles_align')   
    exportgel(handles.profiles_align,handles.axes1);
else
    exportgel(handles.profiles,handles.axes1);
end    
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function ResetSAFA_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSAFA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global datafieldnames;

if isfield(handles,'SeqSelectionWindow')==1
    if ishandle(handles.SeqSelectionWindow) == 1
        delete(handles.SeqSelectionWindow);
        handles = rmfield(handles, 'SeqSelectionWindow');
    end
end

for i=1:size(datafieldnames,1)
    s = datafieldnames{i,1};
    if isfield(handles, s)==1
        handles = rmfield(handles, s);
    end
end

guidata(hObject,handles); % stores data

axes(handles.originalaxes);
%axes(handles.axes1);

currentDir = cd;

% Lets go to the original Dir to load Open.tif
global original_dir;
cd(original_dir);

hold off
openimage=imread('Open.tif');
image(openimage);
set(gca,'XTickMode','manual');
set(gca,'YTickMode','manual');

% Change back to the dir we were in
cd(currentDir);

% --- Executes on button press in ResetLanes.
function ResetLanes_Callback(hObject, eventdata, handles)
% hObject    handle to ResetLanes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'laneboundaries')==1
    handles.laneboundaries =[];
    rmfield(handles, 'laneboundaries');
    rmfield(handles, 'xsel_bound_fine');
    rmfield(handles, 'xsel_center');
    hold off;
    
    global renderSqrt;
    if(renderSqrt == 1)
        image(sqrt(abs(handles.imagey)));
    else
        image(abs(handles.imagey));
    end

    guidata(hObject,handles); % stores data
end


% --- Executes on button press in LoadGelFile.
function LoadGelFile_Callback(hObject, eventdata, handles)
% hObject    handle to LoadGelFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,pathname] = uigetfile('*.gel');
fullpath=[pathname file];
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);

    axes(handles.axes1);
    cla;
    %     prompt={'Number of bins per lane:' };
    %     def={'10'};
    %     dlgTitle='Bins per lane';
    %     lineNo=1;
    %     answer=inputdlg(prompt,dlgTitle,lineNo,def);
    %     handles.numfinebins=str2num(answer{1});
    [handles.imagey,handles.gelbounds] = readingel(fullpath,handles.axes1);
end

guidata(hObject,handles); % stores data

% --- Executes on button press in LoadSequence.
function LoadSequence_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Need to add UCGAT state 'cleavage_sites' to handles, then save in a
% dump, and move back into handles on load. And also send to SeqSelection for display 

[file,pathname] = uigetfile('*.fas');
if ~isequal(file, 0)
    % Make this our current dir
    cd(pathname);

    % If open, close the Sequence Selection window and clear the sequence
    % data in the handles structure.
    if isfield(handles,'SeqSelectionWindow') == 1
        if ishandle(handles.SeqSelectionWindow) == 1
            delete(handles.SeqSelectionWindow);
        end
        handles = rmfield(handles, 'SeqSelectionWindow');
    end
    if isfield(handles, 'Offset')==1
        handles = rmfield(handles,'Offset');
    end
    if isfield(handles, 'sequence')==1
        handles = rmfield(handles,'sequence');
    end
    if isfield(handles, 'cleavage_sites')==1
        handles = rmfield(handles,'cleavage_sites');    
    end
    if isfield(handles, 'threeprime')==1
        handles = rmfield(handles,'threeprime');
    end
    
    [POS_Array,sequence,Offset,cleavage_sites,threeprime,SeqSelectionWindow]=Fasta2Cleave(file, pathname);
    if (size(cleavage_sites,1) > 1)
        handles.POS_Array = POS_Array;
        handles.sequence = sequence;
        handles.Offset = Offset;
        handles.cleavage_sites = cleavage_sites;
        handles.threeprime = threeprime;
        handles.SeqSelectionWindow = SeqSelectionWindow;
    end
    
    guidata(hObject,handles);
end


% --------------------------------------------------------------------
function VisualizeData_Callback(hObject, eventdata, handles)
% hObject    handle to VisualizeData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PlotFits_Callback(hObject, eventdata, handles)
% hObject    handle to PlotFits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'peakarea_lin') == 0 || ...
        isfield(handles, 'profiles_pred') == 0 || ...
        isfield(handles, 'xsel_all') == 0 || ...
        isfield(handles, 'widthpeak_all') == 0 || ...
        isfield(handles, 'whichpeaks') == 0
    errordlg('You cannot plot the fits: You must first fit your data using Quantify.','Error');
    return;
end


% First get the number of bins per lane
prompt={'Number of Lane Plots per page:' };
def={'5'};
dlgTitle='Bins per lane';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
num_answer=0;
goodnum = 0;
while goodnum==0
    goodnum = 1;
    if size(answer,1) == 0
        % They don't want to plot, then no get plot!
        return;
    else
        num_answer = str2double(answer);
        if isnan(num_answer)
            uiwait(errordlg('You must enter a numeric value'));
            goodnum = 0;
        end
    end
    
    if goodnum == 0
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
    end
end

% Now lets actually plot all the lanes that were fit
numplots = num_answer;
plotfitsforuser(handles.profiles_combine,handles.profiles_pred,handles.peakarea_lin,handles.xsel_all(handles.whichpeaks,:),handles.widthpeak_all(handles.whichpeaks,:),numplots);


% --------------------------------------------------------------------
function Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function RenderSqrt_Callback(hObject, eventdata, handles)
% hObject    handle to RenderSqrt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global renderSqrt;
renderSqrtMenuHandle = findobj('Tag', 'RenderSqrt');
if(renderSqrt == 0)
    renderSqrt = 1;
    set(renderSqrtMenuHandle, 'Checked', 'on');
else
    renderSqrt = 0;
    set(renderSqrtMenuHandle, 'Checked', 'off');
end


% --------------------------------------------------------------------
function norm_colorplot_Callback(hObject, eventdata, handles)
% hObject    handle to norm_colorplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles,'peakarea_lin')
    if ~isfield(handles,'pathname_out')
        handles.pathname_out = '';
        handles.file_out     = 'untitled.txt';
    end
    NormPlot(handles.peakarea_lin,handles.whichpeaks,handles.pathname_out,handles.file_out);
else
    NormPlot;
end




% --------------------------------------------------------------------
function secStructurePlot_Callback(hObject, eventdata, handles)
% hObject    handle to secStructurePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles, 'peakarea_lin')
    SecondaryStructure(handles.peakarea_lin, handles.whichpeaks);
else
    SecondaryStructure;
end
