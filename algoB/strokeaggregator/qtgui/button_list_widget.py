#!/usr/bin/env python3

from PyQt4 import QtGui

class ButtonListWidget(QtGui.QWidget):
    """ A panel where you can dump a bunch of buttons dynamically"""
    def __init__(self, parent=None, is_vertical=True):
        super().__init__(parent)
        
        # Add layout
        if(is_vertical): self._layout = QtGui.QVBoxLayout()
        else           : self._layout = QtGui.QHBoxLayout()
        self.setLayout( self._layout )

        # buttons
        self._buttons = {}
        self._radios = {}
        self._checkboxs = {}

    def add_button(self, handle, label):
        assert( not label in self._buttons )
        self._buttons[handle] = b = QtGui.QPushButton(parent=None)
        b.setText(label)
        self._layout.addWidget( b )
        return b
    
    def add_radio(self, handle, label):
        assert( not label in self._radios )
        self._radios[handle] = b = QtGui.QRadioButton(parent=None)
        b.setText(label)
        self._layout.addWidget( b )
        return b

    def add_checkbox(self, handle, label):
        assert( not label in self._checkboxs )
        self._checkboxs[handle] = b = QtGui.QCheckBox(parent=None)
        b.setText(label)
        b.setChecked(True) # Checked by default
        self._layout.addWidget( b )
        return b

    def get_button(self, handle):
        if( handle in self._buttons): return self._buttons[handle]
        else:                         return None
        
    def get_radio(self, handle):
        if( handle in self._radios): return self._radios[handle]
        else:                         return None

    def get_checkbox(self, handle):
        if( handle in self._checkboxs): return self._checkboxs[handle]
        else:                         return None

    def remove_button(self, handle):
        b = self.get_button(handle)
        if( b is not None):
            self._layout.removeWidget(b)
            b.deleteLater()

    def remove_radio(self, handle):
        r = self.get_radio(handle)
        if( r is not None):
            self._layout.removeWidget(r)
            r.deleteLater()

    def remove_checkbox(self, handle):
        r = self.get_checkbox(handle)
        if( r is not None):
            self._layout.removeWidget(r)
            r.deleteLater()

    def clear_radios(self):
        for h in self._radios: self.remove_radio(h)

    def clear_buttons(self):
        for h in self._buttons: self.remove_button(h)

    def clear_checkboxs(self):
        for h in self._checkboxs: self.remove_checkbox(h)

    ## Add custom signals and slots for radios and buttons

## ====================================================
##                     Test code
## ====================================================
# Create an instance of the application window and run it
def run_min_example():
    import sys
    qt_app = QtGui.QApplication(sys.argv)

    bh = ButtonListWidget(is_vertical=True)
    b1 = bh.add_button("shashoo", "press me")
    bh.add_button("shashoo2", "press me 2")
    bh.add_button("shashoo3", "press me 3")
    bh.remove_button("shashoo3")
    b2 = bh.get_button("shashoo")
    b3 = bh.get_button("hello")
    print( b1 is b2 )
    print( b3 )
    
    bh.show()

    r1 = bh.add_radio("z", "shayan")
    r2 = bh.add_radio("w", "shayan2")
    r3 = bh.add_radio("y", "shayan3")
    r4 = bh.get_radio("y")
    print (r3 is r4)
    print (bh.get_radio("adfhjlajldf") )
    bh.remove_radio( "z" )
    
    sys.exit(qt_app.exec_())

if __name__ == '__main__':
    run_min_example()
