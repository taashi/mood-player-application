function varargout = MP3_Player(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MP3_Player_OpeningFcn, ...
                   'gui_OutputFcn',  @MP3_Player_OutputFcn, ...
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


% --- Executes just before MP3_Player is made visible.
function MP3_Player_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MP3_Player (see VARARGIN)

% Choose default command line output for MP3_Player

handles.output = hObject;
handles.playfiles = [];
size(varargin)

% Choose the playlist folder according to the emotion detected

if(strcmp(varargin{1}, 'Happy')) 
    input_dir = 'C:/playlists/happy/';
elseif(strcmp(varargin{1}, 'Sad'))
    input_dir = 'c:/playlists/sad/';
elseif(strcmp(varargin{1}, 'Neutral'))
    input_dir = 'c:/playlists/neutral/';
else
    input_dir = 'c:/playlists/surprised/';
end

files = dir(fullfile(input_dir,'*.mp3'));% Playlist files in the directory
file_num = numel(files);
for n=1:file_num
    handles.playfiles{length(handles.playfiles)+1}=[input_dir files(n).name]; % Add each mp3 to the playlist file
    p=get(handles.playlist,'String'); % Get the present playlist
    p{length(p)+1}=[files(n).name]; % Add the present file to the end of the playlist
    set(handles.playlist,'String',p); %Update the playlist
end
image = imread('test.png');
imshow(image,'parent',handles.axes);
set(handles.text21,'String',sprintf('Mood is %s',varargin{1})); % Display the detected mood 
% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = MP3_Player_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pl stop_pl;
stop_pl = 1;
v = get (handles.playlist, 'Value');    % Get current playlist position
pause(0.1);
cfile = handles.playfiles{v};           % Get selected files's path

[Y, FS] = mp3read (cfile);              % Decode selected mp3 file.

pl = audioplayer (Y, FS);               % start playback.
play (pl);

t=get(pl,'TotalSamples');
total_time = t / FS;
mins = total_time / 60;
secs = mod (total_time, 60);
set(handles.timeupdate_ttltmsc,'String',(round(secs)));
set(handles.timeupdate_ttltmmn,'String',(round(mins))); 

% Loop to find the time update
while (stop_pl == 1)
    c=get(pl,'CurrentSample');
    sliderval = c/t;
    current_tm = c / FS;
    current_tm_mins = current_tm / 60;
    current_tm_secs = mod(current_tm, 60);
    set(handles.playslider,'Value',sliderval);
    set(handles.timeupdate_ttltmsec,'String',(round(current_tm_secs)));
    set(handles.timeupdate_ttltmmin,'String',(round(current_tm_mins))); 
    guidata(hObject, handles);
    pause(.1);
end

% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pl stop_pl;
stop_pl = 0;
stop (pl); % Stop mp3 playback

% --- Executes on selection change in playlist.
function playlist_Callback(hObject, eventdata, handles)
% hObject    handle to playlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns playlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from playlist


% --- Executes during object creation, after setting all properties.
function playlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pladd.
function pladd_Callback(hObject, eventdata, handles)
% hObject    handle to pladd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%persistent i;
[f g]=uigetfile ('*.mp3','Choose a MP3 File','MultiSelect', 'on');  % Choose mp3 file to add to play list
p=get(handles.playlist,'String');             
p{length(p)+1}=[f];
set(handles.playlist,'String',p);               % Update the playlist display
handles.playfiles{length(handles.playfiles)+1}=[g f];
s = which('mp3read.m');
ww = strfind('mp3read.m',s);
location = s(1:ww-2);

guidata(hObject,handles);


% --- Executes on slider movement.
function playslider_Callback(hObject, eventdata, handles)
% hObject    handle to playslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function playslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global pl stop_pl;
stop_pl = 0;
stop (pl);
v = get (handles.playlist, 'Value'); 
if(v>1)
    v = v-1;
end
set(handles.playlist,'Value',v);
play_Callback(hObject,eventdata,handles);


% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global pl stop_pl;
stop_pl = 0;
stop (pl);
v = get (handles.playlist, 'Value'); 
if(v<length(handles.playfiles))
    v = v+1;
end
set(handles.playlist,'Value',v);
play_Callback(hObject,eventdata,handles);
