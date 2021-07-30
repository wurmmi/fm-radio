close all

L = {'A','B','C','D','E'};
X = [  1,  3,0.5,2.5,  2];
H = pie(X);
%
T = H(strcmpi(get(H,'Type'),'text'));
P = cell2mat(get(T,'Position'));
set(T,{'Position'},num2cell(P*0.6,2))
text(P(:,1),P(:,2),L(:))