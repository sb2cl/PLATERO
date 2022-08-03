function plotcalib(x,y,c0,c1,scalex,scaley)
% Copyright (C) 2020 A. Gonzalez Cebrian, J. Borràs Ferris
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% DESCRIPTION
%
% Returns a plot with the calibration model obtained between variables in
% the horizontal and vertical axis.
%
% INPUTS
%
% x: vector with variable in the horizontal axis.
% y: vector with variable in the vertical axis.
% c0: intercept term of the calibration model.
% c1: linear term of the calibration model.
% scalex: optional input indicaint the scale in the horizontal axis.
% Possible values are ""(default)|"log".
% scaley: optional input indicaint the scale in the vertical axis.
% Possible values are ""(default)|"log".
%
% OUTPUTS
%
% (none) displays plot with the points from x and y and the calibration
% curve.
arguments
    x double
    y double
    c0 (1,1)double
    c1 (1,1)double
    scalex {string,char}=""
    scaley {string,char}=""
end
if strcmp(scalex,"log")
    x=log(x);
end
if strcmp(scaley,"log")
    y=log(y);
end
if min(x)>0
    lineval_xrng = [0,max(x)];
else
    lineval_xrng = [min(x),max(x)];
end
lineval_yrng = c0*ones(1,2) + lineval_xrng*c1;
scatter(x,y,25,'filled','Marker','o',...
    'MarkerFaceAlpha',0.5,'MarkerEdgeColor','none',...
    'HandleVisibility','off'),grid on
hold on
plot(lineval_xrng,lineval_yrng,'r--',...
    'linewidth',1.2)
xlabstr = "F_{reporter} (A.U.)";
ylabstr = "Concentration (uM)";
if strcmp(scalex,"log")
    xlabstr = strcat(xlabstr,"-log scale");
end
if strcmp(scaley,"log")
    xlabstr = strcat(ylabstr,"-log scale");
end
eqexpr = strcat("y = ",string(c0)," + ",string(c1),"x");
xlabel(xlabstr),ylabel(ylabstr),title(eqexpr)
end