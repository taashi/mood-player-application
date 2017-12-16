function varargout = personandemotion(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @personandemotion_OpeningFcn, ...
                   'gui_OutputFcn',  @personandemotion_OutputFcn, ...
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


% --- Executes just before personandemotion is made visible.
function personandemotion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to personandemotion (see VARARGIN)

% Choose default command line output for personandemotion
handles.output = hObject;
input_dir = 'training'; % Access the training images
files = dir(fullfile(input_dir,'*.jpg')); % Get the names of all the jpg files
image_num = numel(files);
image_dimensions = [64,64]; %Change image_dimensions if you want a larger test image
images = [];
for n=1:image_num
    file = fullfile(input_dir,files(n).name);
    image = imread(file); %Read each file and convert them to grayscale if they are rgb
    if(ndims(image)>2)
        image = rgb2gray(image);
    end
    image = imresize(image,[image_dimensions]);
    if(n==1)
        images = zeros(prod(image_dimensions),image_num);
    end
    images(:,n) = image(:);
end
mean_faces = mean(images,2); % Calculate the mean face and shift all the images so that they are around the mean
mean_shifted_images = images - repmat(mean_faces,1,image_num);
[coefs,scores, variances] = princomp(images'); % Coefs refer to the principal component vectors, scores refer to the values and variances provide the variances contained by each vector
eigenfaces = 30;
coefs = coefs(:,1:eigenfaces);

features = coefs' * mean_shifted_images; % convert all the mean shifted images to the new principal component space or eigenspaces

testimg = imread('test.png'); % Do the same for the test image
testimg = imresize(testimg,[image_dimensions]);
mean_test = double(testimg(:)) - mean_faces;
test_featurevector = coefs' * mean_test;
similarity_score = arrayfun(@(n) 1/(1+norm(features(:,n)-test_featurevector)),1:image_num); % Calculate the inverse of the square of the distance between the test image and each image in the database in the eigenspaces

[score,img] = max(similarity_score); % Get the maximum score, less the distance

imshow(testimg,'parent',handles.axes1);
if(score<=0.0009)
    set(handles.text1,'String', 'This is the way how you look....');
else
    img1 = imread(files(img).name);
    if(ndims(img1)>2)
        img1 = rgb2gray(img1);
    end
    imshow(img1,'parent',handles.axes2);
    set(handles.text1,'String', sprintf('Matches with %s with a score %f', files(img).name,score)); % Display the image it matches along with the score
end
%[handles.emotions,scores1,face] = detectemotion(); %Calculate emotion using eigenfaces
[handles.emotions1,scores2,lefteye,righteye,mouth,leftscore,rightscore, mouthscore] = detectfeaturesemotion(); %Calculate emotion using eigenfeatures

[emotion_score,emotion] = max(scores2); %Take the sum of the two scores to calculate emotion

righttest = imread('righteye.png');
lefttest = imread('lefteye.png');
mouthtest = imread('mouth.png');

imshow(lefttest,'parent',handles.axes6);
set(handles.text5,'String', sprintf('Matches with left eye with a score %f', leftscore));
imshow(lefteye,'parent',handles.axes7);

imshow(righttest,'parent',handles.axes8);
set(handles.text6,'String', sprintf('Matches with right eye with a score %f', rightscore));
imshow(righteye,'parent',handles.axes9);

imshow(mouthtest,'parent',handles.axes10);
set(handles.text7,'String', sprintf('Matches with mouth with a score %f', mouthscore));
imshow(mouth,'parent',handles.axes11);

if(emotion ==1)
    handles.finalemotion = 'Neutral';
    msgbox('seems like there is nothing great happening today you may not be the best but you are definitely not like the rest.');
elseif (emotion==2)
    handles.finalemotion = 'Happy';
    msgbox('Hey, it seems you are happy today beuatiful quotation  for you /n The Secret of being happy is accepting where you are in life and making most oout of everyday');
elseif (emotion ==3)
    handles.finalemotion = 'Sad';
    msgbox('Life is short, Smile till you have teeth /n moreover, no one is born happy but everyone is born with with ability to create happiness');
else
    handles.finalemotion = 'Surprised';
    msgbox('Hey, Why you so surprised : was it nothing that you expected, that you look so surprised *wink* ');
end

set(handles.text8,'String',sprintf('Mood is %s',handles.finalemotion)); 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes personandemotion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = personandemotion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MP3_Player(handles.finalemotion); % Play music based on the final emotion detected 
