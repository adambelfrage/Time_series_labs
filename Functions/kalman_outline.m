% Example of Kalman filter

% Simulate process
y = ?;

% Length of process
N = length(y);

% Set parameters
A = [? ?;
     ? ?];
V1 = [? ?;
      ? ?]; % State noise variance
V2 = ?; % Measure variance
%usually C should be set here to, but in this case C is a function of
%time.

% Set initial values
Vtt = ?*eye(2); % Initial variance
Ztt = [? ?]'; % Initial state

% Vector to store values in
Zsave=zeros(2,N);

% Kalman filter. Start from k=3, since we need old values of y.
for k=3:N,
  % C is a function of time.
  C = [? ?];

  % Time update
  Ztt_1 = ?;
  Vtt_1 = ?;

  % Measure update
  Vtt = ?;
  Kt = ?;
  Ztt = ?;

  % Save the state
  Zsave(:,k)=Ztt;
end;


