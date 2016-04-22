function varargout = sdGUI(varargin)
% SDGUI MATLAB code for sdGUI.fig
%      SDGUI, by itself, creates a new SDGUI or raises the existing
%      singleton*.
%
%      H = SDGUI returns the handle to a new SDGUI or the handle to
%      the existing singleton*.
%
%      SDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SDGUI.M with the given input arguments.
%
%      SDGUI('Property','Value',...) creates a new SDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sdGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sdGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sdGUI

% Last Modified by GUIDE v2.5 17-Jun-2015 10:13:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sdGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @sdGUI_OutputFcn, ...
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


% --- Executes just before sdGUI is made visible.
function sdGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sdGUI (see VARARGIN)

% Define variables
handles.raw      = {};          % cell array to store timestamps for session events
handles.names    = {};          % cell array to store names for session events
handles.binnedIX = false(0);    % logical index of data to be binned
handles.data     = [];          % matrix of data binned by imgTS

% Choose default command line output for sdGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sdGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sdGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushSD_Callback(hObject, eventdata, handles)
% Loads SD values for each cell from exported Mosaic text file.
% Prompts user to locate file and imports data.

[fName,pName] = uigetfile('*.txt','Select file with cell responses');
if fName == 0,return,end                        % Return if no file chosen

% Load data
set(handles.editSDfile,'string','LOADING...', ....
                       'foregroundColor','r')
drawnow
data          = importdata([pName fName]);      % Load data
handles.imgTS = data(:,1);                      % First column corresponds to timestamps
handles.sd    = data(:,2:end);                  % Remaining columns correspond to SD values

% Reset binned data and data to be binned - all need to be re-binned.
handles.binnedIX(:) = false;
handles.data        = [];

% Update GUI
set(handles.editSDfile,'string',fName, ....
                       'foregroundColor','k')
set(handles.pushLoad,'enable','on')
set(handles.pushAdd,'enable','on')
set(handles.pushDelete,'enable','on')
set(handles.pushRename,'enable','on')
set(handles.pushView,'enable','on')
guidata(hObject,handles)


function pushLoad_Callback(hObject, eventdata, handles)
% Load data from .mat file into GUI. .mat file should contain variables
% with timestamp data of session events. Events will be named according to
% variable name.

% Request file from user
[fName,pathName] = uigetfile('*.mat');                  % Request user for .mat file with data to load
if fName == 0,return,end                                % Return if no file chosen

% Load data. Variables are stored as fields in structure.
dataIn = load([pathName fName]);                            % Load data
fields = fieldnames(dataIn);                                % Variables (structure field names)
fNum   = length(fields);                                    % Number of variables (fields in structure)
for ff = 1:fNum
    fData = dataIn.(fields{ff});                            % Load variable/data from each field
    if isempty(fData)
        fprintf('%s is empty\n',fields{ff})
        continue
    elseif isnumeric(fData)
        if isvector(fData)
            newData = {fData(:)};                           % Shape data into column
            names   = fields(ff);                           % Variable name
            col     = 1;
        else
            row     = size(squeeze(fData),1);               % Size of first dimension of data - squeeze in case first dimension is sigular
            fData   = reshape(fData,row,[]);                % Reshape matrix into 2 dimension matrix (probably not needed)
            col     = size(fData,2);                        % Number of "columns" (or new variables)
            newData = mat2cell(fData,row,ones(col,1));      % Convert each column into element in cell array
            names   = strcat(repmat(fields(ff),[col 1]), ...
                             cellstr(num2str((1:col)')))';  % Name data according to field name with column number appended
        end
%     elseif iscell(fData) && ~iscellstr(fData)
        
%     elseif isstruct(fData)
        
    else
        fprinf('%s is not a supported variable type\n',fields(ff))
        continue
    end
    
    handles.raw(end+(1:col))   = newData;                   % Append new data to existing
    handles.names(end+(1:col)) = names;                     % Add new names to existing
end

% Mark new data as not yet binned
handles.binnedIX(length(handles.names)) = false;

% Update GUI
set(handles.listData,'string',handles.names)
set(handles.popData,'string',handles.names)
set(handles.pushDelete,'enable','on')
set(handles.pushRename,'enable','on')
set(handles.pushAlign,'enable','on')
guidata(hObject,handles)


function pushAdd_Callback(hObject, eventdata, handles)
% Adds another variable to data set.

% Prompt for new data
dlgTitle = 'Input one variable/data set at a time';
prompts  = {'New data name:', ...
            'New data:'};
nameIX = 1;                                     % Index in user response for name 
dataIX = 2;                                     % Index in user response for data
inStr  = inputdlg(prompts,dlgTitle);            % Prompt for new data to add
if isempty(inStr), return, end

% Try to evaluate new data
try
    newData = evalin('base',inStr{dataIX});     % Evaluate input in base workspace
    if ~isvector(newData)
        msgbox('Data was converted to column vector')
    end
    newData = newData(:);                       % Convert to column vector
catch ME
    msgbox('Could not evaluate data input')
    return
end

% Update data
handles.raw   = [handles.raw newData];
handles.names = [handles.names inStr{nameIX}];

% Mark new data as not yet binned
handles.binnedIX(end+1) = false;

% Update GUI
set(handles.listData,'string',handles.names)
set(handles.popData,'string',handles.names)
set(handles.pushDelete,'enable','on')
set(handles.pushRename,'enable','on')
set(handles.pushAlign,'enable','on')
guidata(hObject,handles)


function pushRename_Callback(hObject, eventdata, handles)
% Renames a currently-defined variable from dataset.

% Identify variable to rename and prompt for new name
dataIX = get(handles.listData,'value');         % Identify selected variable
inStr  = inputdlg('New name:');                 % Ask user for new name
if isempty(inStr), return, end                  % Return if input is empty

% Update data (rename variable)
handles.names(dataIX) = inStr;                  % Rename variable

% Update GUI
set(handles.listData,'string',handles.names)    % Update list box
set(handles.popData,'string',handles.names)     % Update popup menu
guidata(hObject,handles)


function pushDelete_Callback(hObject, eventdata, handles)
% Removes a currently-defined variable from dataset.
hObject.Enable = 'off';
dataIX = get(handles.listData,'value');         % Identify selected variable
handles.raw(:,dataIX) = [];                     % Remove variable from data
handles.names(dataIX) = [];                     % Remove variable from names
if handles.binnedIX(dataIX)
    handles.data(:,dataIX) = [];                % Remove variable from binned data if it exists
end
handles.binnedIX(dataIX) = [];                  % Remove variable from binned list

% Update GUI
% Adjust selection in list box or popup menu if deleting variable will 
% change index of currently selected item. Otherwise variable selected will
% change or current index will be out of bounds (does not exist).
listIX = get(handles.listData,'value');
if dataIX >= listIX && listIX ~= 1
    set(handles.listData,'value',listIX-1)
end

popIX = get(handles.popData,'value');
if popIX >= dataIX && dataIX ~= 1
    set(handles.popData,'value',popIX-1)
end

if isempty(handles.names)
    set(handles.listData,'string','[no data]')
    set(handles.popData,'string','[no data]')
else
    set(handles.listData,'string',handles.names)
    set(handles.popData,'string',handles.names)
end
hObject.Enable = 'on';
guidata(hObject,handles)


function pushView_Callback(hObject, eventdata, handles)
% Sends variable selected in list box to base workspace and opens variable
% in variable editor.

dataIX = get(handles.listData,'value');             % index of variable selected in list box

figVar = figure('menubar','none', ...
                'name',handles.names{dataIX}, ...
                'numbertitle','off');
uicontrol('parent',figVar, ...
          'style','listbox', ...
          'units','normalized', ...
          'position',[0,0,1,1], ...
          'string',cellstr(num2str(handles.raw{dataIX})))


function checkSmooth_Callback(hObject, eventdata, handles)
toSmooth = hObject.Value;
if toSmooth
    set(handles.editSmooth,'enable','on')
else
    set(handles.editSmooth,'enable','off')
end


function checkSort_Callback(hObject, eventdata, handles)
toSort = hObject.Value;
if toSort
    set(handles.editResp1,'enable','on')
    set(handles.editResp2,'enable','on')
    set(handles.radioMax,'enable','on')
    set(handles.radioAvg,'enable','on')
else
    set(handles.editResp1,'enable','off')
    set(handles.editResp2,'enable','off')
    set(handles.radioMax,'enable','off')
    set(handles.radioAvg,'enable','off')
end


function radioMax_Callback(hObject, eventdata, handles)
set(handles.radioAvg,'value',0)
function radioAvg_Callback(hObject, eventdata, handles)
set(handles.radioMax,'value',0)

function pushMap_Callback(hObject, eventdata, handles)
pName = uigetdir(pwd,'Select directory with cell images');
set(handles.editMapPath,'string',pName)

% Update GUI
guidata(hObject,handles)


function pushAlign_Callback(hObject, eventdata, handles)

% Checkpoint
in.pre  = str2double(get(handles.editPre,'string'));
in.post = str2double(get(handles.editPost,'string'));
if in.pre > in.post
    msgbox('Invalid align window set','Error')
    return
end

in.resp1  = str2double(get(handles.editResp1,'string'));
in.resp2  = str2double(get(handles.editResp2,'string'));
in.toSort = get(handles.checkSort,'value');
in.toMap  = get(handles.checkMap,'value');
if in.toSort || in.toMap
    if in.resp1 > in.resp2
        msgbox('Invalid response window set','Error')
        return
    elseif in.resp1 < in.pre || in.resp2 > in.post
        msgbox('Response window is not within align window','Error')
        return
    end
end
if in.toMap
    in.pMap = get(handles.editMapPath,'string');
    if ~exist(in.pMap,'dir')
        msgbox('Invalid path for cell maps','Error')
        return
    end
end

in.toSmooth = get(handles.checkSmooth,'value');
if in.toSmooth
    in.smoothWin = str2double(get(handles.editSmooth,'string'));
    if in.smoothWin <= 0 || ...
       in.smoothWin ~= fix(in.smoothWin)
        msgbox('Invalid smoothing parameters','Error')
        return
    end
end

% Bins data timestamps into bins corresponding to calcium imaging
% "frames" (imgTS).
IX      = find(~handles.binnedIX);              % numerical index of variables to be binned
newNum  = sum(~handles.binnedIX);
dataBin = zeros(length(handles.imgTS),newNum);  % matrix of new binned data
for nn = 1:newNum
    dataBin(:,nn) = binData(handles.raw{IX(nn)}, ...
                            handles.imgTS);
end
newBins = sdPrep(handles);

handles.binnedIX(:) = true;
handles.data(:,end+(1:newNum)) = newBins;


set(handles.pushAlign,'enable','inactive', ...
                      'string','WORKING...', ...
                      'foregroundColor','r')
drawnow
sdAlign(handles)
set(handles.pushAlign,'enable','on', ...
                      'string','Align', ...
                      'foregroundColor','k')

% Update GUI
guidata(hObject,handles)



function editLabel_Callback(hObject, eventdata, handles)
function editLabel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPre_Callback(hObject, eventdata, handles)
function editPre_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPost_Callback(hObject, eventdata, handles)
function editPost_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSmooth_Callback(hObject, eventdata, handles)
function editSmooth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listData_Callback(hObject, eventdata, handles)
function listData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editResp1_Callback(hObject, eventdata, handles)
function editResp1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popData_Callback(hObject, eventdata, handles)
function popData_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editResp2_Callback(hObject, eventdata, handles)
function editResp2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkMap_Callback(hObject, eventdata, handles)

function editMapPath_Callback(hObject, eventdata, handles)
function editMapPath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSDfile_Callback(hObject, eventdata, handles)
function editSDfile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
