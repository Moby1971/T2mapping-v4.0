function x=ifft3reco(X)

x=fftshift(fft(fftshift(X,1),[],1),1)/sqrt(size(X,1));
x=fftshift(fft(fftshift(x,2),[],2),2)/sqrt(size(X,2));
x=fftshift(fft(fftshift(x,3),[],3),3)/sqrt(size(X,3));

x = abs(x);

x = circshift(x,1,3);
x = flip(x,2);
x = flip(x,3);

