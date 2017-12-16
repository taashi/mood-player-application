function [Y,FS,NBITS,OPTS] = mp3read(FILE,N,MONO,DOWNSAMP,DELAY)

% find our baseline directory
path = fileparts(which('mp3read'));

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

%%%%%% Location of the binaries - attempt to choose automatically
%%%%%% (or edit to be hard-coded for your installation)
ext = lower(computer);
if ispc
  ext = 'exe';
  rmcmd = 'del';
end
% mpg123-0.59 inserts silence at the start of decoded files, which
% we compensate.  However, this is fixed in mpg123-1.9.0, so 
% make this flag 1 only if you have mpg123-0.5.9
MPG123059 = 0;
mpg123 = fullfile(path,['mpg123.',ext]);
mp3info = fullfile(path,['mp3info.',ext]);

%%%%% Check for network mode
if length(FILE) > 6 && (strcmp(lower(FILE(1:7)),'http://') == 1 ...
      || strcmp(lower(FILE(1:6)),'ftp://'))
  % mp3info not available over network
  OVERNET = 1;
else
  OVERNET = 0;
end


%%%%% Process input arguments
if nargin < 2
  N = 0;
end

% Check for FMT spec (per wavread)
FMT = 'double';
if ischar(N)
  FMT = lower(N);
  N = 0;
end

if length(N) == 1
  % Specified N was upper limit
  N = [1 N];
end
if nargin < 3
  forcemono = 0;
else
  % Check for 3rd arg as FMT
  if ischar(MONO)
    FMT = lower(MONO);
    MONO = 0;
  end
  forcemono = (MONO ~= 0);
end
if nargin < 4
  downsamp = 1;
else
  downsamp = DOWNSAMP;
end
if downsamp ~= 1 && downsamp ~= 2 && downsamp ~= 4
  error('DOWNSAMP can only be 1, 2, or 4');
end

% process DELAY option (nargin 5) after we've read the SR

if strcmp(FMT,'native') == 0 && strcmp(FMT,'double') == 0 && ...
      strcmp(FMT,'size') == 0
  error(['FMT must be ''native'' or ''double'' (or ''size''), not ''',FMT,'''']);
end


%%%%%% Constants
NBITS=16;

%%%%% add extension if none (like wavread)
[path,file,ext] = fileparts(FILE);
if isempty(ext)
  FILE = [FILE, '.mp3'];
end

%%%%% maybe expand ~ %%%%%%
if FILE(1) == '~'
  FILE = [getenv('HOME'),FILE(2:end)];
end


if ~OVERNET
  %%%%%% Probe file to find format, size, etc. using "mp3info" utility
  cmd = ['"',mp3info, '" -r m -p "%Q %u %b %r %v * %C %e %E %L %O %o %p" "', FILE,'"'];
  % Q = samprate, u = #frames, b = #badframes (needed to get right answer from %u) 
  % r = bitrate, v = mpeg version (1/2/2.5)
  % C = Copyright, e = emph, E = CRC, L = layer, O = orig, o = mono, p = pad
  w = mysystem(cmd);
  % Break into numerical and ascii parts by finding the delimiter we put in
  starpos = findstr(w,'*');
  nums = str2num(w(1:(starpos - 2)));
  strs = tokenize(w((starpos+2):end));

  SR = nums(1);
  nframes = nums(2);
  nchans = 2 - strcmp(strs{6}, 'mono');
  layer = length(strs{4});
  bitrate = nums(4)*1000;
  mpgv = nums(5);
  % Figure samples per frame, after
  % http://board.mp3-tech.org/view.php3?bn=agora_mp3techorg&key=1019510889
  if layer == 1
    smpspfrm = 384;
  elseif SR < 32000 && layer ==3
    smpspfrm = 576;
    if mpgv == 1
      error('SR < 32000 but mpeg version = 1');
    end
  else
    smpspfrm = 1152;
  end

  OPTS.fmt.mpgBitrate = bitrate;
  OPTS.fmt.mpgVersion = mpgv;
  % fields from wavread's OPTS
  OPTS.fmt.nAvgBytesPerSec = bitrate/8;
  OPTS.fmt.nSamplesPerSec = SR;
  OPTS.fmt.nChannels = nchans;
  OPTS.fmt.nBlockAlign = smpspfrm/SR*bitrate/8;
  OPTS.fmt.nBitsPerSample = NBITS;
  OPTS.fmt.mpgNFrames = nframes;
  OPTS.fmt.mpgCopyright = strs{1};
  OPTS.fmt.mpgEmphasis = strs{2};
  OPTS.fmt.mpgCRC = strs{3};
  OPTS.fmt.mpgLayer = strs{4};
  OPTS.fmt.mpgOriginal = strs{5};
  OPTS.fmt.mpgChanmode = strs{6};
  OPTS.fmt.mpgPad = strs{7};
  OPTS.fmt.mpgSampsPerFrame = smpspfrm;
else
  % OVERNET mode
  OPTS = [];
  % guesses
  smpspfrm = 1152;
  SR = 44100;
  nframes = 0;
end
  
if SR == 16000 && downsamp == 4
  error('mpg123 will not downsample 16 kHz files by 4 (only 2)');
end

% from libmpg123/frame.h
GAPLESS_DELAY = 529;

% process or set delay
if nargin < 5

  if MPG123059
    mpg123delay44kHz = 2257;  % empirical delay of lame/mpg123 loop
    mpg123delay16kHz = 1105;  % empirical delay of lame/mpg123 loop
                              % for 16 kHz sampling - one 1152
                              % sample frame less??
    if SR == 16000
      rawdelay = mpg123delay16kHz;
    else
      rawdelay = mpg123delay44kHz;  % until we know better
    end
    delay = round(rawdelay/downsamp);
  else
    % seems like predelay is fixed in mpg123-1.9.0
    delay = 0;
  end
else
  delay = DELAY;
end

if downsamp == 1
  downsampstr = '';
else
  downsampstr = [' -',num2str(downsamp)];
end
FS = SR/downsamp;

if forcemono == 1
  nchans = 1;
  chansstr = ' -m';
else
  chansstr = '';
end

% Size-reading version
if strcmp(FMT,'size') == 1
  if MPG123059
    Y = [floor(smpspfrm*nframes/downsamp)-delay, nchans];
  else
    Y = [floor(smpspfrm*nframes/downsamp)-GAPLESS_DELAY, nchans];
  end    
else

  % Temporary file to use
  tmpfile = fullfile(tmpdir, ['tmp',num2str(round(1000*rand(1))),'.wav']);

  skipx = 0;
  skipblks = 0;
  skipstr = '';
  sttfrm = N(1)-1;

  % chop off transcoding delay?
  %sttfrm = sttfrm + delay;  % empirically measured
  % no, we want to *decode* those samples, then drop them
  % so delay gets added to skipx instead
  
  if sttfrm > 0
    skipblks = floor(sttfrm*downsamp/smpspfrm);
    skipx = sttfrm - (skipblks*smpspfrm/downsamp);
    skipstr = [' -k ', num2str(skipblks)];
  end
  skipx = skipx + delay;
  
  lenstr = '';
  endfrm = -1;
  decblk = 0;
  if length(N) > 1
    endfrm = N(2);
    if endfrm > sttfrm
      decblk = ceil((endfrm+delay)*downsamp/smpspfrm) - skipblks + 10;   
      % we read 10 extra blks (+10) to cover the case where up to 10 bad 
      % blocks are included in the part we are trying to read (it happened)
      lenstr = [' -n ', num2str(decblk)];
      % This generates a spurious "Warn: requested..." if reading right 
      % to the last sample by index (or bad blks), but no matter.
    end
 end

  % Run the decode
  cmd=['"',mpg123,'"', downsampstr, chansstr, skipstr, lenstr, ...
       ' -q -w "', tmpfile,'"  "',FILE,'"'];
  %w = 
  mysystem(cmd);

  % Load the data (may update FS if it was based on a guess previously)
  [Y,FS] = wavread(tmpfile);

%  % pad delay on to end, just in case
%  Y = [Y; zeros(delay,size(Y,2))];
%  % no, the saved file is just longer
  
  if decblk > 0 && length(Y) < decblk*smpspfrm/downsamp
    % This will happen if the selected block range includes >1 bad block
    disp(['Warn: requested ', num2str(decblk*smpspfrm/downsamp),' frames, returned ',num2str(length(Y))]);
  end
  
  % Delete tmp file
  mysystem([rmcmd,' "', tmpfile,'"']);
  
  % debug
%  disp(['sttfrm=',num2str(sttfrm),' endfrm=',num2str(endfrm),' skipx=',num2str(skipx),' delay=',num2str(delay),' len=',num2str(length(Y))]);
  
  % Select the desired part
  if skipx+endfrm-sttfrm > length(Y)
      endfrm = length(Y)+sttfrm-skipx;
  end
  
  if endfrm > sttfrm
    Y = Y(skipx+(1:(endfrm-sttfrm)),:);
  elseif skipx > 0
    Y = Y((skipx+1):end,:);
  end
  
  % Convert to int if format = 'native'
  if strcmp(FMT,'native')
    Y = int16((2^15)*Y);
  end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = tokenize(s,t)
% Break space-separated string into cell array of strings.
% Optional second arg gives alternate separator (default ' ')
% 2004-09-18 dpwe@ee.columbia.edu
if nargin < 2;  t = ' '; end
a = [];
p = 1;
n = 1;
l = length(s);
nss = findstr([s(p:end),t],t);
for ns = nss
  % Skip initial spaces (separators)
  if ns == p
    p = p+1;
  else
    if p <= l
      a{n} = s(p:(ns-1));
      n = n+1;
      p = ns+1;
    end
  end
end
    
