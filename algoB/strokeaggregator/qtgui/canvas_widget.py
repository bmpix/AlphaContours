#!/usr/bin/env python3

from PyQt4 import QtGui, QtSvg, QtCore

import re

class SvgWidget(QtSvg.QSvgWidget):
    def __init__(self, fname, parent=None):
        super().__init__(fname, parent)

        # Find SVG size
        br = QtSvg.QGraphicsSvgItem(fname).boundingRect()
        self.svg_height = br.height()
        self.svg_width = br.width()

        viewbox_groups = None
        pattern = r'viewBox="([\d-]+)[ ,]([\d-]+)[ ,]([\d-]+)[ ,]([\d-]+)"'
        with open(fname) as f:
            for i, line in enumerate(f):
                for match in re.finditer(pattern, line):
                    viewbox_groups = match.groups()

        if viewbox_groups is not None:
            self.svg_width = float(viewbox_groups[2]) 
            self.svg_height = float(viewbox_groups[3]) 

        # Set background color
        self.pen = QtGui.QPen(QtGui.QColor(255,255,255,255))
        self.brush = QtGui.QBrush(QtGui.QColor(255,255,255,255))

        # Transform
        self.scale = 1
        self.prev_translation = [0, 0]
        self.translation = [0, 0]
    
    def reset(self):
        self.scale = 1
        self.prev_translation = [0, 0]
        self.translation = [0, 0]

        self.update()

    def paintEvent(self, paint_event):
        painter = QtGui.QPainter(self)
        # default_width  = self.renderer().defaultSize().width()
        # default_height = self.renderer().defaultSize().height()
        default_width  = self.svg_width
        default_height = self.svg_height
        widget_width  = self.size().width()
        widget_height = self.size().height()
        ratio_x = widget_width / default_width
        ratio_y = widget_height / default_height
        if ratio_x < ratio_y:
            new_width = widget_width
            new_height = widget_width * default_height / default_width
            new_left = 0
            new_top =  (widget_height - new_height) / 2
        else:
            new_width = widget_height * default_width / default_height
            new_height = widget_height
            new_left = (widget_width - new_width) / 2
            new_top = 0

        # Set white bg
        painter.setPen(self.pen)
        painter.setBrush(self.brush)
        painter.drawRect(QtCore.QRect(0, 0, widget_width, widget_height))

        # Transform
        # first translate to align center and the origin
        painter.scale(self.scale, self.scale)
        t2 = [self.translation[0] / self.scale, self.translation[1] / self.scale]
        painter.translate(t2[0], t2[1])

        # Draw
        self.renderer().render(painter, QtCore.QRectF(new_left, new_top, new_width, new_height))


class CanvasWidget(QtGui.QWidget):
    """A place to draw your stuff, either using painter or matplotlib."""
    def __init__(self, parent=None):
        super().__init__(parent)

        self.setLayout( QtGui.QHBoxLayout(self) )
        self._svg_widget = None

        self._mouse_pos = None

        self.setFocusPolicy(QtCore.Qt.ClickFocus)

    def is_active(self):
        if(self._svg_widget is not None):
            return True
        else:
            return False
        
    def clear_figure(self):
        if( self._svg_widget ):
            self.layout().removeWidget( self._svg_widget )
            self._svg_widget.deleteLater()
            self._svg_widget = None
        
    def show_svg(self, fname):
        self.clear_figure()
        self._svg_widget = SvgWidget(fname)
        self.layout().addWidget( self._svg_widget )

    ### =================================================
    ###  TRANSFORM BASED ON MOUSE AND KEYBOARD INPUTS
    ### =================================================
    def mousePressEvent(self, event):  
        self._mouse_pos = event.pos()

    def mouseMoveEvent(self, event):
        widget = self._svg_widget
        if self._mouse_pos:
            diff = event.pos() - self._mouse_pos
            self._svg_widget.translation = [diff.x() + widget.prev_translation[0], \
                                            diff.y() + widget.prev_translation[1]]
            self._svg_widget.update()
    
    def mouseReleaseEvent(self, event):
        self._svg_widget.prev_translation = self._svg_widget.translation
        self._mouse_pos = None

    def wheelEvent(self, event):
        widget = self._svg_widget
        widget.scale += event.delta() / 8. / 15. * 0.05

        self._svg_widget.update()

    def keyPressEvent(self, event):
        widget = self._svg_widget

        if event.text() == '+':
            widget.scale += 0.05
        elif event.text() == '-':
            widget.scale -= 0.05
        else:
            event.ignore()

        self._svg_widget.update()

## ====================================================
##                     Test code
## ====================================================
# Create an instance of the application window and run it
def run_min_example():
    import sys
    import numpy as np
    import matplotlib.pyplot as plt
    
    qt_app = QtGui.QApplication(sys.argv)

    cw = CanvasWidget()
    # cw.show_svg('example/Zeichen_123.svg')
    cw.show_svg('temp/out_result_regularizer_step4_black.svg')
    cw.show()

    sys.exit(qt_app.exec_())

if __name__ == '__main__':
    run_min_example()
