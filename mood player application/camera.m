function varargout = camera(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @camera_OpeningFcn, ...
                   'gui_OutputFcn',  @camera_OutputFcn, ...
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


% --- Executes just before camera is made visible.
function camera_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to camera (see VARARGIN)

% Choose default command line output for camera
handles.output = hObject;
axis off;
set(handles.reCapture, 'Enable', 'off'); %Disable recapture button until one image has been captured
set(handles.detEmotion, 'Enable', 'off');%Disable detect emotion button until one image has been captured 


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes camera wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = camera_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pbCapture.
function pbCapture_Callback(hObject, eventdata, handles)
% hObject    handle to pbCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vid = videoinput('winvideo', 1, 'YUY2_320x240');
vid.FramesPerTrigger = 1;
vid.ReturnedColorspace = 'rgb';
triggerconfig(vid,'manual');
vidRes = get(vid,'videoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);

nBands = get(vid, 'NumberOfBands');
hImage = image(zeros(imHeight, imWidth, nBands), 'parent', handles.axPreview);
preview(vid,hImage);

start(vid);
h = waitbar(0,'Please wait while camera loads');
pause(3);
close(h);
pause(1);
trigger(vid);
stoppreview(vid);
capt1 = getdata(vid);
imwrite(capt1,'test.png');
set(handles.pbCapture, 'Enable', 'off');
set(handles.reCapture, 'Enable', 'on');
set(handles.detEmotion, 'Enable', 'on');


% --- Executes on button press in reCapture.
function reCapture_Callback(hObject, eventdata, handles)
% hObject    handle to reCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vid = videoinput('winvideo', 1, 'YUY2_320x240'); %Access video camera and produce an output of resolution 320x240
vid.FramesPerTrigger = 1; %Number of photos/frames shot per trigger/click
vid.ReturnedColorspace = 'rgb'; %Changed returned colour space to rgb
triggerconfig(vid,'manual'); %Click photos only manually
vidRes = get(vid,'videoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);

nBands = get(vid, 'NumberOfBands');
hImage = image(zeros(imHeight, imWidth, nBands), 'parent', handles.axPreview);
preview(vid,hImage); % Open the camera preview in the axis on the GUI
start(vid);
h = waitbar(0,'Please wait while camera loads');
pause(3);
close(h);
pause(1);
trigger(vid);
stoppreview(vid);
capt1 = getdata(vid);
imwrite(capt1,'test.png');


% --- Executes on button press in detEmotion.
function detEmotion_Callback(hObject, eventdata, handles)
% hObject    handle to detEmotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

faceemotion();
