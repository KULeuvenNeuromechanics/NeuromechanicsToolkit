function [] = MatlabDefault()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

startpath = pwd;
cd('C:\Users\u0088756\Documents\Software\MatlabToolBox\matlab-schemer')
schemer_import('C:\Users\u0088756\Documents\Software\MatlabToolBox\matlab-schemer\schemes\default.prf');
cd(startpath);
end

