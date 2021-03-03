#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: FM Sender
# Author: Michael Wurm <wurm.michael95@gmail.com>
# Description: FM Sender, using USRP.
# GNU Radio version: 3.8.2.0

from distutils.version import StrictVersion

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print("Warning: failed to XInitThreads()")

from PyQt5 import Qt
from gnuradio import qtgui
from gnuradio.filter import firdes
import sip
from gnuradio import analog
from gnuradio import blocks
from gnuradio import filter
from gnuradio import gr
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import uhd
import time
from gnuradio.qtgui import Range, RangeWidget

from gnuradio import qtgui

class fm_sender(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "FM Sender")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("FM Sender")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "fm_sender")

        try:
            if StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
                self.restoreGeometry(self.settings.value("geometry").toByteArray())
            else:
                self.restoreGeometry(self.settings.value("geometry"))
        except:
            pass

        ##################################################
        # Variables
        ##################################################
        self.osr_rf = osr_rf = 10
        self.osr_mod = osr_mod = 5
        self.fs_file = fs_file = 44100
        self.tx_gain_db = tx_gain_db = 0.8
        self.n_filter_delay = n_filter_delay = 265//2
        self.gain_pilot = gain_pilot = 0.05
        self.gain_mono = gain_mono = 0.3
        self.gain_lrdiff = gain_lrdiff = 0.5
        self.fs_rf = fs_rf = fs_file*osr_mod*osr_rf
        self.fs_mod = fs_mod = fs_file*osr_mod
        self.fc_pirate = fc_pirate = 99e6

        ##################################################
        # Blocks
        ##################################################
        self._tx_gain_db_range = Range(0, 1, 0.01, 0.8, 200)
        self._tx_gain_db_win = RangeWidget(self._tx_gain_db_range, self.set_tx_gain_db, 'tx_gain_db', "counter_slider", float)
        self.top_grid_layout.addWidget(self._tx_gain_db_win, 0, 0, 1, 1)
        for r in range(0, 1):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.qtgui_tab_widget_0 = Qt.QTabWidget()
        self.qtgui_tab_widget_0_widget_0 = Qt.QWidget()
        self.qtgui_tab_widget_0_layout_0 = Qt.QBoxLayout(Qt.QBoxLayout.TopToBottom, self.qtgui_tab_widget_0_widget_0)
        self.qtgui_tab_widget_0_grid_layout_0 = Qt.QGridLayout()
        self.qtgui_tab_widget_0_layout_0.addLayout(self.qtgui_tab_widget_0_grid_layout_0)
        self.qtgui_tab_widget_0.addTab(self.qtgui_tab_widget_0_widget_0, 'Tab 0')
        self.qtgui_tab_widget_0_widget_1 = Qt.QWidget()
        self.qtgui_tab_widget_0_layout_1 = Qt.QBoxLayout(Qt.QBoxLayout.TopToBottom, self.qtgui_tab_widget_0_widget_1)
        self.qtgui_tab_widget_0_grid_layout_1 = Qt.QGridLayout()
        self.qtgui_tab_widget_0_layout_1.addLayout(self.qtgui_tab_widget_0_grid_layout_1)
        self.qtgui_tab_widget_0.addTab(self.qtgui_tab_widget_0_widget_1, 'Tab 1')
        self.qtgui_tab_widget_0_widget_2 = Qt.QWidget()
        self.qtgui_tab_widget_0_layout_2 = Qt.QBoxLayout(Qt.QBoxLayout.TopToBottom, self.qtgui_tab_widget_0_widget_2)
        self.qtgui_tab_widget_0_grid_layout_2 = Qt.QGridLayout()
        self.qtgui_tab_widget_0_layout_2.addLayout(self.qtgui_tab_widget_0_grid_layout_2)
        self.qtgui_tab_widget_0.addTab(self.qtgui_tab_widget_0_widget_2, 'Tab 2')
        self.top_grid_layout.addWidget(self.qtgui_tab_widget_0, 4, 0, 1, 1)
        for r in range(4, 5):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._n_filter_delay_range = Range(0, 400, 1, 265//2, 200)
        self._n_filter_delay_win = RangeWidget(self._n_filter_delay_range, self.set_n_filter_delay, 'n_filter_delay', "counter_slider", int)
        self.top_grid_layout.addWidget(self._n_filter_delay_win, 5, 0, 1, 1)
        for r in range(5, 6):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._gain_pilot_range = Range(0, 1, 0.05, 0.05, 200)
        self._gain_pilot_win = RangeWidget(self._gain_pilot_range, self.set_gain_pilot, 'gain_pilot', "counter_slider", float)
        self.top_grid_layout.addWidget(self._gain_pilot_win, 3, 0, 1, 1)
        for r in range(3, 4):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._gain_mono_range = Range(0, 1, 0.05, 0.3, 200)
        self._gain_mono_win = RangeWidget(self._gain_mono_range, self.set_gain_mono, 'gain_mono', "counter_slider", float)
        self.top_grid_layout.addWidget(self._gain_mono_win, 1, 0, 1, 1)
        for r in range(1, 2):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self._gain_lrdiff_range = Range(0, 1, 0.05, 0.5, 200)
        self._gain_lrdiff_win = RangeWidget(self._gain_lrdiff_range, self.set_gain_lrdiff, 'gain_lrdiff', "counter_slider", float)
        self.top_grid_layout.addWidget(self._gain_lrdiff_win, 2, 0, 1, 1)
        for r in range(2, 3):
            self.top_grid_layout.setRowStretch(r, 1)
        for c in range(0, 1):
            self.top_grid_layout.setColumnStretch(c, 1)
        self.uhd_usrp_sink_1 = uhd.usrp_sink(
            ",".join(("", "")),
            uhd.stream_args(
                cpu_format="fc32",
                args='',
                channels=list(range(0,1)),
            ),
            '',
        )
        self.uhd_usrp_sink_1.set_center_freq(fc_pirate, 0)
        self.uhd_usrp_sink_1.set_normalized_gain(tx_gain_db, 0)
        self.uhd_usrp_sink_1.set_antenna('TX/RX', 0)
        self.uhd_usrp_sink_1.set_bandwidth(200e3, 0)
        self.uhd_usrp_sink_1.set_samp_rate(fs_rf)
        self.uhd_usrp_sink_1.set_time_unknown_pps(uhd.time_spec())
        self.rational_resampler_xxx_0_0_0 = filter.rational_resampler_fff(
                interpolation=osr_mod,
                decimation=1,
                taps=None,
                fractional_bw=None)
        self.rational_resampler_xxx_0_0 = filter.rational_resampler_fff(
                interpolation=osr_mod,
                decimation=1,
                taps=None,
                fractional_bw=None)
        self.rational_resampler_xxx_0 = filter.rational_resampler_ccc(
                interpolation=osr_rf,
                decimation=1,
                taps=None,
                fractional_bw=None)
        self.qtgui_freq_sink_x_0_0_0 = qtgui.freq_sink_c(
            8092, #size
            firdes.WIN_BLACKMAN_hARRIS, #wintype
            fc_pirate, #fc
            fs_rf, #bw
            "tx_fm_mod", #name
            1
        )
        self.qtgui_freq_sink_x_0_0_0.set_update_time(0.10)
        self.qtgui_freq_sink_x_0_0_0.set_y_axis(-140, 10)
        self.qtgui_freq_sink_x_0_0_0.set_y_label('Relative Gain', 'dB')
        self.qtgui_freq_sink_x_0_0_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_0_0_0.enable_autoscale(False)
        self.qtgui_freq_sink_x_0_0_0.enable_grid(True)
        self.qtgui_freq_sink_x_0_0_0.set_fft_average(0.2)
        self.qtgui_freq_sink_x_0_0_0.enable_axis_labels(True)
        self.qtgui_freq_sink_x_0_0_0.enable_control_panel(False)



        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_0_0_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_0_0_0.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_0_0_0.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_0_0_0.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_0_0_0.set_line_alpha(i, alphas[i])

        self._qtgui_freq_sink_x_0_0_0_win = sip.wrapinstance(self.qtgui_freq_sink_x_0_0_0.pyqwidget(), Qt.QWidget)
        self.qtgui_tab_widget_0_layout_2.addWidget(self._qtgui_freq_sink_x_0_0_0_win)
        self.qtgui_freq_sink_x_0_0 = qtgui.freq_sink_c(
            4096, #size
            firdes.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            fs_mod, #bw
            "tx_fm_bb", #name
            1
        )
        self.qtgui_freq_sink_x_0_0.set_update_time(0.10)
        self.qtgui_freq_sink_x_0_0.set_y_axis(-140, 10)
        self.qtgui_freq_sink_x_0_0.set_y_label('Relative Gain', 'dB')
        self.qtgui_freq_sink_x_0_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_0_0.enable_autoscale(False)
        self.qtgui_freq_sink_x_0_0.enable_grid(True)
        self.qtgui_freq_sink_x_0_0.set_fft_average(0.2)
        self.qtgui_freq_sink_x_0_0.enable_axis_labels(True)
        self.qtgui_freq_sink_x_0_0.enable_control_panel(False)



        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_0_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_0_0.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_0_0.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_0_0.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_0_0.set_line_alpha(i, alphas[i])

        self._qtgui_freq_sink_x_0_0_win = sip.wrapinstance(self.qtgui_freq_sink_x_0_0.pyqwidget(), Qt.QWidget)
        self.qtgui_tab_widget_0_layout_1.addWidget(self._qtgui_freq_sink_x_0_0_win)
        self.qtgui_freq_sink_x_0 = qtgui.freq_sink_f(
            4096*2, #size
            firdes.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            fs_mod, #bw
            "fmChannelData", #name
            1
        )
        self.qtgui_freq_sink_x_0.set_update_time(0.10)
        self.qtgui_freq_sink_x_0.set_y_axis(-140, 10)
        self.qtgui_freq_sink_x_0.set_y_label('Relative Gain', 'dB')
        self.qtgui_freq_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_0.enable_autoscale(False)
        self.qtgui_freq_sink_x_0.enable_grid(True)
        self.qtgui_freq_sink_x_0.set_fft_average(0.1)
        self.qtgui_freq_sink_x_0.enable_axis_labels(True)
        self.qtgui_freq_sink_x_0.enable_control_panel(False)


        self.qtgui_freq_sink_x_0.set_plot_pos_half(not False)

        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_0.set_line_alpha(i, alphas[i])

        self._qtgui_freq_sink_x_0_win = sip.wrapinstance(self.qtgui_freq_sink_x_0.pyqwidget(), Qt.QWidget)
        self.qtgui_tab_widget_0_layout_0.addWidget(self._qtgui_freq_sink_x_0_win)
        self.blocks_wavfile_source_0 = blocks.wavfile_source('/home/mike/work/fm-radio/sim/matlab/recordings/viera-blech-ehrenwert-polka.wav', True)
        self.blocks_sub_xx_0 = blocks.sub_ff(1)
        self.blocks_multiply_xx_0 = blocks.multiply_vff(1)
        self.blocks_multiply_const_xx_1 = blocks.multiply_const_ff(1, 1)
        self.blocks_multiply_const_xx_0_1_0 = blocks.multiply_const_ff(1, 1)
        self.blocks_multiply_const_xx_0_1 = blocks.multiply_const_ff(1, 1)
        self.blocks_multiply_const_xx_0_0_1 = blocks.multiply_const_cc(1, 1)
        self.blocks_multiply_const_xx_0_0_0 = blocks.multiply_const_ff(gain_pilot, 1)
        self.blocks_multiply_const_xx_0_0 = blocks.multiply_const_ff(gain_lrdiff, 1)
        self.blocks_multiply_const_xx_0 = blocks.multiply_const_ff(gain_mono, 1)
        self.blocks_delay_0_0 = blocks.delay(gr.sizeof_float*1, n_filter_delay)
        self.blocks_delay_0 = blocks.delay(gr.sizeof_float*1, n_filter_delay)
        self.blocks_add_xx_0_0 = blocks.add_vff(1)
        self.blocks_add_xx_0 = blocks.add_vff(1)
        self.band_pass_filter_1_0 = filter.fir_filter_fff(
            1,
            firdes.band_pass(
                1,
                fs_mod,
                30,
                15e3,
                100,
                firdes.WIN_HAMMING,
                6.76))
        self.band_pass_filter_1 = filter.fir_filter_fff(
            1,
            firdes.band_pass(
                1,
                fs_mod,
                30,
                15e3,
                100,
                firdes.WIN_HAMMING,
                6.76))
        self.band_pass_filter_0 = filter.fir_filter_fff(
            1,
            firdes.band_pass(
                1,
                fs_mod,
                23e3,
                53e3,
                2e3,
                firdes.WIN_HAMMING,
                6.76))
        self.analog_sig_source_x_0_0 = analog.sig_source_f(fs_mod, analog.GR_COS_WAVE, 19e3, 1, 0, 0)
        self.analog_sig_source_x_0 = analog.sig_source_f(fs_mod, analog.GR_COS_WAVE, 38e3, 1, 0, 0)
        self.analog_frequency_modulator_fc_0 = analog.frequency_modulator_fc(75e3/fs_mod*2*3.1415926)
        self.analog_fm_preemph_0_0 = analog.fm_preemph(fs=fs_file, tau=50e-6, fh=-1.0)
        self.analog_fm_preemph_0 = analog.fm_preemph(fs=fs_file, tau=50e-6, fh=-1.0)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_fm_preemph_0, 0), (self.blocks_add_xx_0, 0))
        self.connect((self.analog_fm_preemph_0, 0), (self.blocks_sub_xx_0, 0))
        self.connect((self.analog_fm_preemph_0_0, 0), (self.blocks_add_xx_0, 1))
        self.connect((self.analog_fm_preemph_0_0, 0), (self.blocks_sub_xx_0, 1))
        self.connect((self.analog_frequency_modulator_fc_0, 0), (self.qtgui_freq_sink_x_0_0, 0))
        self.connect((self.analog_frequency_modulator_fc_0, 0), (self.rational_resampler_xxx_0, 0))
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_multiply_xx_0, 1))
        self.connect((self.analog_sig_source_x_0_0, 0), (self.blocks_delay_0, 0))
        self.connect((self.band_pass_filter_0, 0), (self.blocks_multiply_const_xx_0_0, 0))
        self.connect((self.band_pass_filter_1, 0), (self.blocks_delay_0_0, 0))
        self.connect((self.band_pass_filter_1_0, 0), (self.blocks_multiply_xx_0, 0))
        self.connect((self.blocks_add_xx_0, 0), (self.rational_resampler_xxx_0_0, 0))
        self.connect((self.blocks_add_xx_0_0, 0), (self.blocks_multiply_const_xx_1, 0))
        self.connect((self.blocks_delay_0, 0), (self.blocks_multiply_const_xx_0_0_0, 0))
        self.connect((self.blocks_delay_0_0, 0), (self.blocks_multiply_const_xx_0, 0))
        self.connect((self.blocks_multiply_const_xx_0, 0), (self.blocks_add_xx_0_0, 0))
        self.connect((self.blocks_multiply_const_xx_0_0, 0), (self.blocks_add_xx_0_0, 1))
        self.connect((self.blocks_multiply_const_xx_0_0_0, 0), (self.blocks_add_xx_0_0, 2))
        self.connect((self.blocks_multiply_const_xx_0_0_1, 0), (self.qtgui_freq_sink_x_0_0_0, 0))
        self.connect((self.blocks_multiply_const_xx_0_0_1, 0), (self.uhd_usrp_sink_1, 0))
        self.connect((self.blocks_multiply_const_xx_0_1, 0), (self.analog_fm_preemph_0, 0))
        self.connect((self.blocks_multiply_const_xx_0_1_0, 0), (self.analog_fm_preemph_0_0, 0))
        self.connect((self.blocks_multiply_const_xx_1, 0), (self.analog_frequency_modulator_fc_0, 0))
        self.connect((self.blocks_multiply_const_xx_1, 0), (self.qtgui_freq_sink_x_0, 0))
        self.connect((self.blocks_multiply_xx_0, 0), (self.band_pass_filter_0, 0))
        self.connect((self.blocks_sub_xx_0, 0), (self.rational_resampler_xxx_0_0_0, 0))
        self.connect((self.blocks_wavfile_source_0, 0), (self.blocks_multiply_const_xx_0_1, 0))
        self.connect((self.blocks_wavfile_source_0, 1), (self.blocks_multiply_const_xx_0_1_0, 0))
        self.connect((self.rational_resampler_xxx_0, 0), (self.blocks_multiply_const_xx_0_0_1, 0))
        self.connect((self.rational_resampler_xxx_0_0, 0), (self.band_pass_filter_1, 0))
        self.connect((self.rational_resampler_xxx_0_0_0, 0), (self.band_pass_filter_1_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "fm_sender")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_osr_rf(self):
        return self.osr_rf

    def set_osr_rf(self, osr_rf):
        self.osr_rf = osr_rf
        self.set_fs_rf(self.fs_file*self.osr_mod*self.osr_rf)

    def get_osr_mod(self):
        return self.osr_mod

    def set_osr_mod(self, osr_mod):
        self.osr_mod = osr_mod
        self.set_fs_mod(self.fs_file*self.osr_mod)
        self.set_fs_rf(self.fs_file*self.osr_mod*self.osr_rf)

    def get_fs_file(self):
        return self.fs_file

    def set_fs_file(self, fs_file):
        self.fs_file = fs_file
        self.set_fs_mod(self.fs_file*self.osr_mod)
        self.set_fs_rf(self.fs_file*self.osr_mod*self.osr_rf)

    def get_tx_gain_db(self):
        return self.tx_gain_db

    def set_tx_gain_db(self, tx_gain_db):
        self.tx_gain_db = tx_gain_db
        self.uhd_usrp_sink_1.set_normalized_gain(self.tx_gain_db, 0)

    def get_n_filter_delay(self):
        return self.n_filter_delay

    def set_n_filter_delay(self, n_filter_delay):
        self.n_filter_delay = n_filter_delay
        self.blocks_delay_0.set_dly(self.n_filter_delay)
        self.blocks_delay_0_0.set_dly(self.n_filter_delay)

    def get_gain_pilot(self):
        return self.gain_pilot

    def set_gain_pilot(self, gain_pilot):
        self.gain_pilot = gain_pilot
        self.blocks_multiply_const_xx_0_0_0.set_k(self.gain_pilot)

    def get_gain_mono(self):
        return self.gain_mono

    def set_gain_mono(self, gain_mono):
        self.gain_mono = gain_mono
        self.blocks_multiply_const_xx_0.set_k(self.gain_mono)

    def get_gain_lrdiff(self):
        return self.gain_lrdiff

    def set_gain_lrdiff(self, gain_lrdiff):
        self.gain_lrdiff = gain_lrdiff
        self.blocks_multiply_const_xx_0_0.set_k(self.gain_lrdiff)

    def get_fs_rf(self):
        return self.fs_rf

    def set_fs_rf(self, fs_rf):
        self.fs_rf = fs_rf
        self.qtgui_freq_sink_x_0_0_0.set_frequency_range(self.fc_pirate, self.fs_rf)
        self.uhd_usrp_sink_1.set_samp_rate(self.fs_rf)

    def get_fs_mod(self):
        return self.fs_mod

    def set_fs_mod(self, fs_mod):
        self.fs_mod = fs_mod
        self.analog_frequency_modulator_fc_0.set_sensitivity(75e3/self.fs_mod*2*3.1415926)
        self.analog_sig_source_x_0.set_sampling_freq(self.fs_mod)
        self.analog_sig_source_x_0_0.set_sampling_freq(self.fs_mod)
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.fs_mod, 23e3, 53e3, 2e3, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_1.set_taps(firdes.band_pass(1, self.fs_mod, 30, 15e3, 100, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_1_0.set_taps(firdes.band_pass(1, self.fs_mod, 30, 15e3, 100, firdes.WIN_HAMMING, 6.76))
        self.qtgui_freq_sink_x_0.set_frequency_range(0, self.fs_mod)
        self.qtgui_freq_sink_x_0_0.set_frequency_range(0, self.fs_mod)

    def get_fc_pirate(self):
        return self.fc_pirate

    def set_fc_pirate(self, fc_pirate):
        self.fc_pirate = fc_pirate
        self.qtgui_freq_sink_x_0_0_0.set_frequency_range(self.fc_pirate, self.fs_rf)
        self.uhd_usrp_sink_1.set_center_freq(self.fc_pirate, 0)





def main(top_block_cls=fm_sender, options=None):

    if StrictVersion("4.5.0") <= StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    def quitting():
        tb.stop()
        tb.wait()

    qapp.aboutToQuit.connect(quitting)
    qapp.exec_()

if __name__ == '__main__':
    main()
