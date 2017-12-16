function varargout = faceemotion(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @faceemotion_OpeningFcn, ...
                   'gui_OutputFcn',  @faceemotion_OutputFcn, ...
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


% --- Executes just before faceemotion is made visible.
function faceemotion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to faceemotion (see VARARGIN)

% Choose default command line output for faceemotion
handles.output = hObject;
handles.image = imread('test.png'); %Read test image 
handles.rgbimage = handles.image; %Preserve RGB image for detection using boosted classifier
handles.image = rgb2gray(handles.image); %Convert to grayscale
imshow(handles.image,'Parent', handles.axes1);
set(handles.cutFace, 'Enable','off');
set(handles.cutEyes, 'Enable','off');
set(handles.cutMouth, 'Enable','off');
set(handles.personAndEmotion, 'Enable','off');
axis off;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes faceemotion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = faceemotion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in detectFace.
function detectFace_Callback(hObject, eventdata, handles)
% hObject    handle to detectFace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
faceDetector = vision.CascadeObjectDetector;
handles.face = step(faceDetector,handles.image);%Get the bounding box of the face in the image by moving a rectangular window along the face
if(size(handles.face,1)==0) msgbox('No face Detected','','error');
else
Ifaces = insertObjectAnnotation(handles.image,'rectangle',handles.face,'Face');
imshow(Ifaces,'parent',handles.axes1);
set(handles.cutFace, 'Enable','on');
set(handles.cutEyes, 'Enable','on');
set(handles.cutMouth, 'Enable','on');
end
guidata(hObject, handles);


% --- Executes on button press in cutFace.
function cutFace_Callback(hObject, eventdata, handles)
% hObject    handle to cutFace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.faceIm = imcrop(handles.image,handles.face); %Cut the face out of the image
imshow(handles.faceIm,'parent',handles.axes1);

guidata(hObject, handles);


% --- Executes on button press in cutEyes.
function cutEyes_Callback(hObject, eventdata, handles)
% hObject    handle to cutEyes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

eyeDetector = vision.CascadeObjectDetector('EyePairBig'); %Use the viola jones classifier to detect both the eyes
handles.eyes = step(eyeDetector,handles.faceIm);
if(size(handles.eyes,1)>0) %If the eyes are not detected
handles.eye = imcrop(handles.faceIm,handles.eyes(1,:)); %Crop the image of the eyes out of the image of the face
width = size(handles.eye,2)/2;
widthlef = width -width/4;
widthrig = width +width/4;
height = size(handles.eye,1);
handles.lefteye = imcrop(handles.eye,[0 0 widthlef height]); %Crop left eye and right eye out of the image of the eyes
handles.righteye = imcrop(handles.eye,[widthrig 0 widthlef height]);
imshow(handles.lefteye,'parent',handles.axes2);
imshow(handles.righteye,'parent',handles.axes3);
else
    msgbox('Please take another image without glasses or glare around the eyes','','error');
end
    
guidata(hObject, handles);



% --- Executes on button press in cutMouth.
function cutMouth_Callback(hObject, eventdata, handles)
% hObject    handle to cutMouth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%{
The face detector is boosted for detecting the mouth, therefore you can
either use location or the boosted classifier to detect the mouth. Just
uncomment this code for the boosted classifier. 

detector = buildDetector();
[bbox bbimg] = detectFaceParts(detector,handles.rgbimage);
handles.mouth = imcrop(handles.rgbimage,bbox(:,13:16));
handles.mouth = rgb2gray(handles.mouth);
imshow(handles.mouth,'parent',handles.axes4);
%}

%Mouth detected via facial location
width = size(handles.faceIm,2)/2;
height = size(handles.faceIm,1);
handles.mouth = imcrop(handles.faceIm,[4.5*width/8 height-height/3 width-width/5 height/4]);
imshow(handles.mouth,'parent',handles.axes4);
set(handles.personAndEmotion, 'Enable','on');
guidata(hObject, handles);


% --- Executes on button press in personAndEmotion.
function personAndEmotion_Callback(hObject, eventdata, handles)
% hObject    handle to personAndEmotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.faceIm = imresize(handles.faceIm,[64 64]);%Save all the features as images
handles.mouth = imresize(handles.mouth,[24 24]);
handles.lefteye = imresize(handles.lefteye,[24 24]);
imwrite(handles.lefteye,'lefteye.png');
handles.lefteye = imresize(handles.righteye,[24 24]);
imwrite(handles.lefteye,'righteye.png');
imwrite(handles.mouth,'mouth.png');
imwrite(handles.faceIm,'test.png');
personandemotion();
