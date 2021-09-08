function foupow=Mo_FFT(data,N)
foucoe=fft(data,N,2) /N;
foupow=abs(foucoe.^2)*4;
end