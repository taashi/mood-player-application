function mp3write(D,SR,NBITS,FILE,OPTIONS)


% find our baseline directory
[path] = fileparts(which('mp3write'));

% %%%%% Directory for temporary file (if needed)
% % Try to read from environment, or use /tmp if it exists, or use CWD
tmpdir = getenv('TMPDIR');
if isempty(tmpdir) || exist(tmpdir,'file')==0
  tmpdir = '/tmp';
end
if exist(tmpdir,'file')==0
  tmpdir = '';
end
% ensure it exists
%if length(tmpdir) > 0 && exist(tmpdir,'file')==0
%  mkdir(tmpdir);
%end

%%%%%% Command to delete temporary file (if needed)
rmcmd = 'rm';

%%%%%% Location of the binary - attempt to choose automatically
%%%%%% (or edit to be hard-coded for your installation)
ext = lower(computer);
if ispc
  ext = 'exe';
  rmcmd = 'del';
end
lame = fullfile(path,['lame.',ext]);

%%%% Process input arguments
% Do we have NBITS?
mynargin = nargin;
if ischar(NBITS)
  % NBITS is a string i.e. it's actually the filename
  if mynargin > 3
    OPTIONS = FILE;
  end
  FILE = NBITS;
  NBITS = 16;
  % it's as if NBITS had been specified...
  mynargin = mynargin + 1;
end

if mynargin < 5
  OPTIONS = '--quiet -h';  % -h means high-quality psych model
end

[nr, nc] = size(D);
if nc < nr
  D = D';
  [nr, nc] = size(D);
end
% Now rows are channels, cols are time frames (so interleaving is right)

%%%%% add extension if none (like wavread)
[path,file,ext] = fileparts(FILE);
if isempty(ext)
  FILE = [FILE, '.mp3'];
end

nchan = nr;
nfrm = nc;

if nchan == 1
  monostring = ' -m m';
else
  monostring = '';
end

lameopts = [' ', OPTIONS, monostring, ' '];

%if exist('popenw') == 3
if length(which('popenw')) > 0

  % We have the writable stream process extensions
  cmd = ['"',lame,'"', lameopts, '-r -s ',num2str(SR),' - "',FILE,'"'];

  p = popenw(cmd);
  if p < 0
    error(['Error running popen(',cmd,')']);
  end

  % We feed the audio to the encoder in blocks of <blksize> frames.
  % By adapting this loop, you can create your own code to 
  % write a single, large, MP3 file one part at a time.
  
  blksiz = 10000;

  nrem = nfrm;
  base = 0;

  while nrem > 0
    thistime = min(nrem, blksiz);
    done = popenw(p,32767*D(:,base+(1:thistime)),'int16be');
    nrem = nrem - thistime;
    base = base + thistime;
    %disp(['done=',num2str(done)]);
  end

  % Close pipe
  popenw(p,[]);

else 
  disp('Warning: popenw not available, writing temporary file');
  
  tmpfile = fullfile(tmpdir,['tmp',num2str(round(1000*rand(1))),'.wav']);

  wavwrite(D',SR,tmpfile);
  
  cmd = ['"',lame,'"', lameopts, '"',tmpfile, '" "', FILE, '"'];

  mysystem(cmd);

  % Delete tmp file
  mysystem([rmcmd, ' "', tmpfile,'"']);

end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w = mysystem(cmd)
% Run system command; report error; strip all but last line
[s,w] = system(cmd);
if s ~= 0 
  error(['unable to execute ',cmd,' (',w,')']);
end
% Keep just final line
w = w((1+max([0,findstr(w,10)])):end);
% Debug
%disp([cmd,' -> ','*',w,'*']);
