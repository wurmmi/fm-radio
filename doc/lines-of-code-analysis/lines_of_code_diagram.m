%-------------------------------------------------------------------------
% File        : lines_of_code_diagram.m
% Author      : Michael Wurm <wurm.michael95@gmail.com>
% Description : Create a diagram to represent the lines of code.
%-------------------------------------------------------------------------

%% Prepare environment
clear;
close all;
clc;

%% Settings
dir_output_doc = "../thesis/img/matlab";


%% Plot

values    = [2730, 2743, 208, 708, 107, 27, 430+489, 224+129, 182, 119, 85];
value_txt = {'Matlab','VHDL IP Design (VHDL)', 'VHDL IP Design (Python)', 'VHDL Tb (Py)','VHDL Tb (make)', 'VHDL Tb (shell)', 'HLS IP Design (C++)', 'HLS Tb (C++)','HLS Tb (Tcl)','HLS Tb (make)','HLS Tb (Py)'};

values    = [2730, 2743+208, 708+107+27, 430+489, 224+129+182+119+85];
value_txt = {'Matlab','VHDL IP Design', 'VHDL Testbench', 'HLS IP Design', 'HLS Testbench'};

values    = [2730, 2743+208+708+107+27, 430+489+224+129+182+119+85];
value_txt = {'Matlab','VHDL', 'HLS'};

set(0,'defaulttextinterpreter','latex');

p = pie(values);
%title('\textbf{Lines Of Code}');

pText = findobj(p,'Type','text');
percentValues = get(pText,'String');
combinedtxt = strcat(strcat(value_txt,'~(~'),percentValues'); 

for i=1:length(value_txt)
    tmp = char(combinedtxt(i));
    pText(i).String = [tmp(1:end-1) '\%~)'];
end

fig = gcf;
fig.Position(3:4) = [700 500];

exportgraphics(fig,sprintf("%s/%s",dir_output_doc, "lines_of_code_pie_chart_matlab.pdf"),'ContentType','vector')
