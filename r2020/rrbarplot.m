function [ff] = rrbarplot(ybar, upieces, colscale, ff, bs, bw)
arguments
    ybar
    upieces
    colscale
    ff = [];
    bs = 0.03;
    bw = 0.2;
end
nconc = size(ybar,1);
if mod(nconc,2) ~= 0
    xb = [fliplr(1-0.5*bw*(1-mod(nconc,2)): -(bs + bw): 1-0.5*bw*(1-mod(nconc,2))-(bs + bw)*floor(nconc/2)),...
        1+0.5*bw*(1-mod(nconc,2)): (bs + bw): 1+0.5*bw*(1-mod(nconc,2))+(bs + bw)*floor(nconc/2)];
else
    xb = [fliplr(1-(bs + bw)*0.5: -(bs + bw): 1-0.5*(bs + bw)*floor(nconc/2)),...
        1+(bs + bw)*0.5: (bs + bw): 1+0.5*(bs + bw)*floor(nconc/2)];
end
xb = unique(xb);
if isempty(ff)
    ff = figure('Position',[405 342  872 338]);
else
    ff = gcf;
end
bar(xb,ybar(:,2:3),'stacked'), grid on
ff.Children.Position(4) = 0.6;
ff.Children.Position(2) = 0.3;
hold on
bar(xb + 2, ybar(:,4))
ylim([0,130])
xticks([xb,xb+2]),xticklabels(strcat(string(repmat(round(upieces,4),2,1)), " \muM")),
xtickangle(45)
gca.XAxis.Fontsize = 6;
annotation('textbox', [0.2,0.05,0.27,0.1], 'String', ...
    "Measurement System",'EdgeColor','none')
annotation('textbox', [0.6,0.05,0.27,0.1], 'String', ...
    "Part-to-Part (Well)",'EdgeColor','none')
title("Sources of variability"), ylabel('Percent (%)')
legend("Repeat. (Repetition)", "Reprod. (Gain)", "Part-to-Part (Well)", ...
    'Orientation','horizontal','Location','north')
ff.Children(2).Children(1).FaceColor = colscale(1,:);
ff.Children(2).Children(2).FaceColor = colscale(2,:);
ff.Children(2).Children(3).FaceColor = colscale(3,:);

text([xb,xb+2] - bw/2.5, 5+[ybar(:,1);ybar(:,4)],  ...
    strcat(string(round([ybar(:,1);ybar(:,4)], 2)), "%"),'FontSize',9)
end