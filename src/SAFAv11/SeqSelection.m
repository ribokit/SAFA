function varargout = SeqSelection(varargin)
% SEQSELECTION M-file for SeqSelection.fig
%      SEQSELECTION, by itself, creates a new SEQSELECTION or raises the existing
%      singleton*.
%
%      H = SEQSELECTION returns the handle to a new SEQSELECTION or the handle to
%      the existing singleton*.
%
%      SEQSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEQSELECTION.M with the given input arguments.
%
%      SEQSELECTION('Property','Value',...) creates a new SEQSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SeqSelection_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SeqSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SeqSelection

% Last Modified by GUIDE v2.5 17-Jun-2004 16:13:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SeqSelection_OpeningFcn, ...
    'gui_OutputFcn',  @SeqSelection_OutputFcn, ...
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


% --- Executes just before SeqSelection is made visible.
function SeqSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SeqSelection (see VARARGIN)

% Choose default command line output for SeqSelection
handles.output = hObject;
if size(varargin,2) < 2
    cleavage_sites=zeros(5,1);
else
    cleavage_sites=varargin{2};
end
%U C G A T
handles.cleavage_sites=cleavage_sites;
if isfield(handles,'Offset')==0
    handles.Offset=0;
end

% If we've passed in the Offset, set it in handles
if size(varargin,2) >=3
    handles.Offset=varargin{3};
end


% Update handles structure
sequence=varargin{1};
handles.sequence=sequence;
plot_sequence(sequence,handles.Offset,handles.axes2);

% If we passed in the cleavage_sites, we should set the buttons to the
% appropriate states, and then disable everything.
%fprintf('nargin(SeqSelection) == %d,%d,%d\n', size(varargin,1),size(varargin,2), nargin('SeqSelection'));
if size(varargin,2) >= 2
    if cleavage_sites(1) ~= 0
        set(handles.checkboxU, 'Value', get(handles.checkboxU, 'Max'));
    end
    if cleavage_sites(2) ~= 0
        set(handles.checkboxC, 'Value', get(handles.checkboxC, 'Max'));
    end
    if cleavage_sites(3) ~= 0
        set(handles.checkboxG, 'Value', get(handles.checkboxG, 'Max'));
    end
    if cleavage_sites(4) ~= 0
        set(handles.checkboxA, 'Value', get(handles.checkboxA, 'Max'));
    end
    if cleavage_sites(5) ~= 0
        set(handles.checkboxT, 'Value', get(handles.checkboxT, 'Max'));
    end
    
    if size(varargin,2) >=3
        if varargin{3} ~= 0
            set(handles.editOffset, 'string', varargin{3});
        end
        
        if size(varargin,2) >= 4
            if varargin{4} ~= 0
                set(handles.checkbox3Prime, 'Value', get(handles.checkbox3Prime, 'Max'));
            end
        end
    end

    disableAllControls(handles);
    % This will ensure a handle to this window is passed back to SAFA
    handles.hitOK = 1;
    replot(handles);
    guidata(hObject, handles);
else
    guidata(hObject, handles);
    % UIWAIT makes SeqSelection wait for user response (see UIRESUME)
    % We only wait if we DID NOT pass in the cleavage sites from a dump
    uiwait(handles.figure1);
end



% --- Outputs from this function are returned to the command line.
function varargout = SeqSelection_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = [];
varargout{2} = [];
varargout{3} = [];
varargout{4} = [];
if isfield(handles,'hitOK') == 1
    if(handles.hitOK == 1)
        if isfield(handles,'threeprime')==0
            handles.threeprime=0;
        end
        
        if isfield(handles,'Offset')==0
            handles.Offset=0;
        end
        
        if isfield(handles, 'cleavage_sites') == 1
            varargout{1} = handles.cleavage_sites;
        end
        if isfield(handles, 'threeprime') == 1
            varargout{2} = handles.threeprime;
        end
        if isfield(handles, 'Offset') == 1
            varargout{3} = handles.Offset;
        end
        if isfield(handles, 'figure1') == 1
            varargout{4} = handles.figure1;
        end
        %delete(handles.figure1);
    end
end


% --- Executes on button press in checkboxU.
function checkboxU_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxU
%U C G A T
%'U'
handles.cleavage_sites(1)=get(hObject,'Value');
replot(handles);
guidata(hObject,handles); % stores data

% --- Executes on button press in checkboxC.
function checkboxC_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxC
%U C G A T
%'C'
handles.cleavage_sites(2)=get(hObject,'Value');
replot(handles);
guidata(hObject,handles); % stores data

% --- Executes on button press in checkboxG.
function checkboxG_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxG
%U C G A T
%'G'
handles.cleavage_sites(3)=get(hObject,'Value');
replot(handles);
guidata(hObject,handles); % stores data

% --- Executes on button press in checkboxA.
function checkboxA_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxA
%U C G A T
%'A'
handles.cleavage_sites(4)=get(hObject,'Value');
replot(handles);
guidata(hObject,handles); % stores data

% --- Executes on button press in checkboxT.
function checkboxT_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxT

%U C G A T
%'T'
handles.cleavage_sites(5)=get(hObject,'Value');
replot(handles);
guidata(hObject,handles); % stores data

% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If no nucleotides were selected, make them choose one.
if size(find(handles.cleavage_sites), 1) == 0
    errordlg('You must choose at least one nucleotide for cleavage.');
    return;
end

disableAllControls(handles);
handles.hitOK = 1;
guidata(hObject,handles); % stores data

uiresume(handles.figure1);


% --- Executes during object creation, after setting all properties.
function editOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editOffset_Callback(hObject, eventdata, handles)
% hObject    handle to editOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOffset as text
%        str2double(get(hObject,'String')) returns contents of editOffset as a double

string_Offset=get(hObject,'String');
num_Offset=str2double(string_Offset);
if isnan(num_Offset)
    errordlg('You must enter a numeric value','Bad Input','modal')
else
    handles.Offset=str2num(string_Offset);
    replot(handles);
    
    guidata(hObject,handles); % stores data
end



% --- Executes on button press in checkbox3Prime.
function checkbox3Prime_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3Prime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3Prime
handles.threeprime=get(hObject,'Value');
guidata(hObject,handles); % stores data

function replot(handles);
pointertoaxes = handles.axes2;
sequence = handles.sequence;
cleavage_sites = handles.cleavage_sites;
axes(pointertoaxes);
cla;
plot_sequence(sequence,handles.Offset,handles.axes2);
sites=find(cleavage_sites);
if isempty(sites)==1
    return;
end
hold on; 
site_colors = [0 1 0; 0 0 1;1 0.5 0.2;1 0 0; 0 1 0];
num_sites=max(size(sites));
for m=1:num_sites
    num_letters=max(size(sequence));
    blocksize=50;
    numblocks=ceil(num_letters/blocksize);
    
    char_string='UCGAT';
    cleavage_string=char_string(sites);
    
    set(gca,'XLim',[-0.1 1.1],'YLim',[-0.1 1.1]);
    set(gca,'XTick',[],'YTick',[]);
    set(gca,'Visible','off');
    for k=1:num_letters;
        i = mod((k-1),blocksize);
        j = floor((k-1)/blocksize);
        if sequence(k)==cleavage_string(m)
            h=text(i/blocksize,0.9-0.1*j,sequence(k));
            set(h,'Color',site_colors(sites(m),:),'fontweight','bold');
            
        end
    end
end
hold off;

function POS_array=find_positions(sequence,cleave_pattern)
num_letters=max(size(cleave_pattern));
POS_array=[];
for i=1:num_letters
    POS_array = cat(2,POS_array,find(sequence==cleave_pattern(i)));
end
POS_array=sort(POS_array);

% 
% This disables all controls in the window. Is used once the user
% hits 'OK' or if they load a dump that already has a sequence loaded in
% 
function disableAllControls(handles)
set(handles.pushbuttonOK, 'enable', 'off');
set(handles.checkboxU, 'enable', 'off');
set(handles.checkboxC, 'enable', 'off');
set(handles.checkboxG, 'enable', 'off');
set(handles.checkboxA, 'enable', 'off');
set(handles.checkboxT, 'enable', 'off');
set(handles.checkbox3Prime, 'enable', 'off');
set(handles.editOffset, 'enable', 'off');
