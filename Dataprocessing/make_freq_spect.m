function [data_ft,frequency_out,magnitude_out] = make_freq_spect( data,fs,bool_plot,varargin)
%Make_freq_spect performs a fourier analysis with the matlab function fft
%and plots the frequency spectrum of the signal
%
%   Input Arguments:
%           - Data= A Vector with input signal
%           - fs= sampling frequency of the input signal
%           - bool_plot= A Boolean, when 1= figure of the freq. spectrum
%                                   when 0= no figure
%
%   Output Arguments:
%           - data_ft= output from the fourier analysis
%           - frequency_out= x-axis of the freq. plot.(freq. harmonics)
%           - magnitude_out= y-axis of the freq. plot (amplitude harmonics)
%
if ~isempty(varargin)
    col_sel=varargin{1};
else
    col_sel='b';
end

data_ft=fft(data);
sze = length(data);
ff= fix(sze/2) + 1;
f = [0:ff-1]*fs/sze;
if bool_plot
    plot(f(1:ff), abs(data_ft(1:ff)/sze*2),col_sel);
    xlabel('Frequency in Hz');
    ylabel('Magnitude');
    title('Frequency spectrum');
    axis tight;
end
frequency_out=f(1:ff)';
magnitude_out=abs(data_ft(1:ff)/sze*2);
end

