function plotbyfactor(x,y,g,xdiscrete,ydiscrete,disp,xlab,ylab,clab,titlab)
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
% Fits gain effect correction model.
%
% INPUTS
%
% x: vector with values in the horizontal axis.
% y: vector with values in the vertical axis.
% g: vector with group of each observation.
% xdiscrete: optional argument indicating if the x variable is discrete. If
% it is (value set to 1), jitter will be added to the plot in this axis. 
% Default value is set to 0.
% ydiscrete: optional argument indicating if the y variable is discrete. If
% it is (value set to 1), jitter will be added to the plot in this axis. 
% Default value is set to 0.
% disp: optional argument indicating the dispersion to be considered when
% adding the jitter to the points. Default value set to 0.01*min(abs(x)).
% xlab: optional string with the horizontal label. Default value set to "".
% ylab: optional string with the vertical label. Default value set to "".
% titlab: optional string with the title. Default value set to "".
%
% OUTPUTS
%
% (none) displays the plot.
switch nargin
    case 3
        xdiscrete = 0;
        ydiscrete = 0;
        disp = 0.01*min(abs(x));
        xlab = "";
        ylab = "";
        clab = "";
        titlab = "";
    case 4
        ydiscrete = 0;
        disp = 0.01*min(abs(x));
        xlab = "";
        ylab = "";
        clab = "";
        titlab = "";
    case 5
        disp = 0.01*min(abs(x));
        xlab = "";
        ylab = "";
        clab = "";
        titlab = "";
    case 6
        xlab = "";
        ylab = "";
        clab = "";
        titlab = "";
    case 7
        ylab = "";
        clab = "";
        titlab = "";
    case 8
        clab = "";
        titlab = "";
    case 9
        titlab = "";
    case 10
    otherwise
        error('Unexpected inputs')
end
ug = unique(g);
symbs = {'o' '+' 'd' '^' 'p'  '*' 'v' '<' '>'};
symbs = symbs(1:length(ug));
colscale = linspecer(length(symbs),'sequential');
edcol = {'none','none','none','none','none','none','none',...
    'none','none','none'};
if length(ug) >= 2
    edcol{2} = colscale(2,:);
end
if length(ug) >= 6
    edcol{6} = colscale(6,:);
end
edcol = edcol(1:length(ug));

sx = x;
if iscell(x)
    [~,~,x] = unique(x);
end
if iscell(g)
    [uug,~,g] = unique(g);
    ug = unique(g);
else 
    uug = ug;
end
for i = 1:length(ug)
    xg = x(g==ug(i));
    yg = y(g==ug(i));
    if xdiscrete==1
        ux = unique(xg);
        xnoisy = [];
        ynoisy = [];
        for j = 1:length(ux)
            ygx = yg(xg==ux(j));
            xnoisy = [xnoisy;normrnd(ux(j),disp,sum(xg==ux(j)),1)];
            if ydiscrete==1
                uy = unique(ygx);
                ynoisy = [];
                for k = 1:length(uy)
                    ynoisy = [ynoisy;normrnd(uy(k),disp,sum(ygx==uy(k)),1)];
                end
            else
                ynoisy = [ynoisy;ygx];
            end
        end
    else
        xnoisy = [xnoisy;xg];
        if ydiscrete==1
            uy = unique(yg);
            xnoisy = [];
            ynoisy = [];
            for k = 1:length(uy)
                xnoisy = [xnoisy;xg(yg==uy(k))];
                ynoisy = [ynoisy;normrnd(uy(k),disp,sum(yg==uy(k)),1)];
            end
        else
            ynoisy = [ynoisy;yg];
        end
    end
    scatter(xnoisy,ynoisy,20,'Marker','o','MarkerFaceColor',...
        colscale(i,:),'MarkerFaceAlpha',0.6,'MarkerEdgeColor',edcol{i},...
        'HandleVisibility','on','DisplayName',strcat(string(uug(i)))),
    hold on
end
grid on
leg = legend('Orientation','Horizontal','Location','southoutside');
title(leg,clab);
xlabel(xlab),ylabel(ylab),title(titlab)
if xdiscrete==1
    xticks(unique(x))
    xticklabels(unique(sx))
end
if ydiscrete==1
    yticks(unique(y))
end
end