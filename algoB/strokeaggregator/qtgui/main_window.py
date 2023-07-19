#!/usr/bin/env python3

# https://stackoverflow.com/questions/19966056/pyqt5-how-can-i-connect-a-qpushbutton-to-a-slot

import sys

from core.manager import Manager
from core.defs import *

from PyQt4 import QtGui, QtCore

from qtgui.canvas_widget import CanvasWidget
from qtgui.button_list_widget import ButtonListWidget


BUTTON_READ_VECTOR      = "BUTTON_READ_VECTOR"
BUTTON_RESET             = "BUTTON_RESET"
BUTTON_CLEANUP      = "BUTTON_CLEANUP"

BUTTON_SINGLE    = "BUTTON_SINGLE"
BUTTON_FOUR      = "BUTTON_FOUR"
BUTTON_EIGHT      = "BUTTON_EIGHT"

BUTTON_PRECOMPUTE    = "BUTTON_PRECOMPUTE"
BUTTON_JOINT      = "BUTTON_JOINT"

BUTTON_ACCEPT          = "BUTTON_ACCEPT"
BUTTON_REFUSE          = "BUTTON_REFUSE"

class MainWindow(QtGui.QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle('StrokeAggregator')
        self._is_gui_setup = False
        ##
        self.manager = Manager()
        self.manager.add_observer(self)
        self.setup_gui()
        ##
        self.setMinimumSize(1200, 900)
        self.setMinimumSize(600, 450)
        # self.canvas.resize(1100, 900);
        
    def setup_gui(self):
        if(self._is_gui_setup): return
        ## Layout
        self.setLayout( QtGui.QHBoxLayout(self) )
        ## Control panel and canvas
        self.control_panel = ButtonListWidget(self, is_vertical=True)
        self.canvas        = CanvasWidget(self)
        self.layout().addWidget( self.canvas, 5 )
        self.layout().addWidget( self.control_panel, 1 )

        ## Add buttons
        self.control_panel.add_button(BUTTON_READ_VECTOR,  "Read Vector Input")
        self.control_panel.add_button(BUTTON_RESET,         "Reset Preview")
        self.control_panel.add_button(BUTTON_CLEANUP,  "Consolidate")

        self.control_panel.add_radio(BUTTON_SINGLE,  "1 thread")
        self.control_panel.add_radio(BUTTON_FOUR,  "4 threads")
        self.control_panel.add_radio(BUTTON_EIGHT,  "8 threads")

        self.control_panel.add_checkbox(BUTTON_PRECOMPUTE,  "Preprocessing")
        self.control_panel.add_checkbox(BUTTON_JOINT,  "Connection Enforcement")

        b = self.control_panel.get_button(BUTTON_READ_VECTOR)
        b.clicked.connect(self.read_image_clicked)
        # ##
        b = self.control_panel.get_button(BUTTON_RESET)
        b.clicked.connect(self.reset_preview)

        b = self.control_panel.get_button(BUTTON_CLEANUP)
        b.clicked.connect(self.cleanup)

        ##
        b1 = self.control_panel.get_checkbox(BUTTON_PRECOMPUTE)
        b2 = self.control_panel.get_checkbox(BUTTON_JOINT)
        b1.clicked.connect(lambda: self.set_manager_launch_flags(b1.isChecked(), b2.isChecked()))
        b2.clicked.connect(lambda: self.set_manager_launch_flags(b1.isChecked(), b2.isChecked()))

        b1 = self.control_panel.get_radio(BUTTON_SINGLE)
        b1.setChecked(True)
        b2 = self.control_panel.get_radio(BUTTON_FOUR)
        b3 = self.control_panel.get_radio(BUTTON_EIGHT)
        b1.clicked.connect(self.set_single_threads)
        b2.clicked.connect(self.set_four_threads)
        b3.clicked.connect(self.set_eight_threads)

        self.set_manager_launch_flags()
        
    ### =================================================
    ###  CLICKS FROM THE BUTTONS
    ### =================================================
    def read_image_clicked(self):
        filename = QtGui.QFileDialog.getOpenFileName(self, 'OpenFile', '','Scap files (*.scap);;SVG files (*.svg)')
        if len(filename) > 0:
            self.manager.read_image(filename)

    def cleanup(self):
        self.manager.cleanup_sketch()

    def reset_preview(self):
        if not self.canvas.is_active:
            return
        
        widget = self.canvas._svg_widget
        widget.reset()
        svg_height = widget.svg_height
        svg_width = widget.svg_width

        self.resize(QtCore.QSize(svg_width + 165 + 40 * 2,\
                                 svg_height + 40 * 2))

    def set_manager_launch_flags(self, to_preprocessing = True, with_joint = True):
        self.manager.set_launch_flags(to_preprocessing, with_joint)

    def set_single_threads(self):
        self.manager.set_num_threads(1)
    def set_four_threads(self):
        self.manager.set_num_threads(4)
    def set_eight_threads(self):
        self.manager.set_num_threads(8)

    ### =================================================
    ###  THINGS TO OBSERVE FROM MANAGER
    ### =================================================
    def observe_image_changed(self, manager):
        if( manager.to_view == VIEW_NONE ):
            self.canvas.clear_figure()           
        elif( manager.to_view == VIEW_SVG  ):
            self.canvas.show_svg( manager.svg_address )

            # Set to 100% when open
            self.reset_preview()
        elif( manager.to_view == VIEW_OUT  ):
            self.canvas.show_svg( manager.svg_out_address )

            # Set to 100% when open
            self.reset_preview()
        else:
            self.canvas.clear_figure()    

        
class DisclaimerWindow(QtGui.QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle('Disclaimer')
        self.accepted = False
        self.setMinimumSize(600, 450)

        self.setLayout( QtGui.QVBoxLayout(self) )

        self.disclaimer = QtGui.QTextEdit()
        self.control_panel = ButtonListWidget(self, is_vertical=False)

        self.layout().addWidget(self.disclaimer, 6)
        self.layout().addWidget( self.control_panel, 1 )

        self.control_panel.add_button(BUTTON_ACCEPT,  "Accept")
        self.control_panel.add_button(BUTTON_REFUSE,  "Decline")

        b = self.control_panel.get_button(BUTTON_ACCEPT)
        b.clicked.connect(self.accept_clicked)
        
        b = self.control_panel.get_button(BUTTON_REFUSE)
        b.clicked.connect(self.refuse_clicked)

        with open(EULA_DIR, 'rb') as ff:
            eula = ff.read()
            eula = eula.decode('windows-1252')

        self.disclaimer.insertHtml(eula)
        self.disclaimer.moveCursor(QtGui.QTextCursor.Start)
        self.disclaimer.setReadOnly(True)

    def accept_clicked(self):
        self.accepted = True
        self.close()

    def refuse_clicked(self):
        self.close()


## ====================================================
##                     Test code
## ====================================================
# Create an instance of the application window and run it
def main():
    qt_app = QtGui.QApplication(sys.argv)
    qt_app.setApplicationName('StrokeAggregator')

    dw = DisclaimerWindow()
    dw.exec_()

    if not dw.accepted:
        print('Disclaimer not accepted')
        sys.exit(1)

    m = MainWindow()
    m.show()

    print("Starting the GUI")
    sys.exit(qt_app.exec_())

if __name__ == '__main__':
    main()
