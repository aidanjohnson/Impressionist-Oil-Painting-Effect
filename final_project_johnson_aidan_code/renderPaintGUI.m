function varargout = renderPaintGUI(varargin)
% RENDERPAINTGUI MATLAB code for renderPaintGUI.fig
%      RENDERPAINTGUI, by itself, creates a new RENDERPAINTGUI or raises the existing
%      singleton*.
%
%      H = RENDERPAINTGUI returns the handle to a new RENDERPAINTGUI or the handle to
%      the existing singleton*.
%
%      RENDERPAINTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RENDERPAINTGUI.M with the given input arguments.
%
%      RENDERPAINTGUI('Property','Value',...) creates a new RENDERPAINTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before renderPaintGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to renderPaintGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help renderPaintGUI

% Last Modified by GUIDE v2.5 09-Dec-2017 15:40:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @renderPaintGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @renderPaintGUI_OutputFcn, ...
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


% --- Executes just before renderPaintGUI is made visible.
function renderPaintGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to renderPaintGUI (see VARARGIN)

% Choose default command line output for renderPaintGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes renderPaintGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

clear all;
reset;

function reset
global hAxes1;
global hAxes2;

if (isempty(hAxes1))
    hAxes1 = findobj(gcf,'Tag', 'original');
end
if (isempty(hAxes2))
    hAxes2 = findobj(gcf,'Tag', 'painting');
end

set(gcf, 'CurrentAxes', hAxes1);
imshow(1);
set(gcf, 'CurrentAxes', hAxes2);
imshow(1);
return;

% --- Outputs from this function are returned to the command line.
function varargout = renderPaintGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global X; % original image
global hAxes1;
global name;
global path;

% open an image
[FileName,PathName] = uigetfile('*.bmp;*.tif;*.jpg;*.png','Select the image file');
if ispc
    FullPathName = [PathName,'\',FileName];
elseif ismac
    FullPathName = [PathName,'/',FileName];
elseif isunix
    FullPathName = [PathName,'/',FileName];
else
    FullPathName = [PathName,'\',FileName];
end
X = imread(FullPathName);
path = char(PathName);
name = char(FileName);
% display the original image
set(gcf, 'CurrentAxes', hAxes1);
imshow(X);

% --- Executes on button press in Paint.
function Paint_Callback(hObject, eventdata, handles)
% hObject    handle to Paint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global C;
global CR;
global CG;
global CB;
global brushR;
global R1;
global R2;
global R3;

brushR = [R1,R2,R3];
C = [CR,CG,CB];
displayResult;


function displayResult

global Y;
global hAxes2;
global T;
global fg;
global fs;
global fc;
global C;
global minLen;
global maxLen;
global brushR;
global name;
global path;

Y = renderPaint([path,'\',name],T,fg,fs,fc,maxLen,minLen,brushR,C);

% shows the resulting painted image
set(gcf, 'CurrentAxes', hAxes2);
imshow(Y);
return;

% --- Executes on button press in Impressionist.
function Impressionist_Callback(hObject, eventdata, handles)
% hObject    handle to Impressionist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disables custom parameters
set(findall(handles.CustomParameters,'-property','Enable'),'Enable','off');

global T;
global fg;
global fs;
global fc;
global CR;
global CG;
global CB;
global minLen;
global maxLen;
global R1;
global R2;
global R3;

% impressionist style parameters
T = 50;
fg = 1;
fs = 0.5;
fc = 1;
R1 = 8;
R2 = 4;
R3 = 2;
minLen = 4;
maxLen = 16;
CR = 128;
CG = 128;
CB = 128;


function Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global T;
T = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BlurFactor_Callback(hObject, eventdata, handles)
% hObject    handle to BlurFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fs;
fs = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function BlurFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlurFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GridSize_Callback(hObject, eventdata, handles)
% hObject    handle to GridSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fg;
fg = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function GridSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GridSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CurvatureFilter_Callback(hObject, eventdata, handles)
% hObject    handle to CurvatureFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global fc;
fc = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function CurvatureFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurvatureFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinLength_Callback(hObject, eventdata, handles)
% hObject    handle to MinLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global minLen;
minLen = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function MinLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MaxLength_Callback(hObject, eventdata, handles)
% hObject    handle to MaxLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maxLen;
maxLen = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function MaxLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CanvasR_Callback(hObject, eventdata, handles)
% hObject    handle to CanvasR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CR;
CR = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function CanvasR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CanvasR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CanvasG_Callback(hObject, eventdata, handles)
% hObject    handle to CanvasG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CG;
CG = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function CanvasG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CanvasG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CanvasB_Callback(hObject, eventdata, handles)
% hObject    handle to CanvasB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global CB;
CB = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function CanvasB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CanvasB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BrushR1_Callback(hObject, eventdata, handles)
% hObject    handle to BrushR1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global R1;
R1 = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function BrushR1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrushR1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BrushR2_Callback(hObject, eventdata, handles)
% hObject    handle to BrushR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global R2;
R2 = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function BrushR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrushR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BrushR3_Callback(hObject, eventdata, handles)
% hObject    handle to BrushR3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global R3;
R3 = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function BrushR3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BrushR3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Custom.
function Custom_Callback(hObject, eventdata, handles)
% hObject    handle to Custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% enables custom parameters
set(findall(handles.CustomParameters,'-property','Enable'),'Enable','on');

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global name;
global path;
global Y;
paintingName = [path, '\','painted_',name];
imwrite(Y,paintingName);