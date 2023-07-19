#!/usr/bin/env python3

from core.defs import *
import core.scap_to_svg as scap_to_svg
import core.svg_to_scap as svg_to_scap

import sys, os, subprocess, time

class Manager:
    """All the flow of the application is managed by this guy.  It is
completely decoupled from the GUI, and can be used on its own. The GUI
will call the appropriate functions from the Manager.

    """

    def __init__(self):
        self.svg_address = None
        self.scap_address = None
        self.scap_out_address = None
        self.svg_out_address = None

        self.intermediate_files = []
        ###
        self.observers = []
        ###
        self.to_view = None
        ###
        self.to_preprocessing = True
        self.with_joint = True
        ###
        self.num_threads = 1

    def add_observer(self, obs):
        self.observers.append(obs)

    def call_observers(self, method):
        for obs in self.observers:
            func = getattr(obs, method)
            func(self)

    ## ======================================
    ##   CHANGING THE STATE OF PREVIEW OR LAUNCHING
    ## ======================================
    def change_view_mode(self, mode):
        self.to_view = mode
        self.call_observers('observe_image_changed')

    def set_launch_flags(self, to_preprocessing = True, with_joint = True):
        self.to_preprocessing = to_preprocessing
        self.with_joint = with_joint

    def set_num_threads(self, num_threads = 1):
        self.num_threads = num_threads

    ## ======================================
    ##   PROCESS LAUNCHING
    ## ======================================
    def call_process(self, argv, to_wait = False, pipe_out = False):
        if pipe_out:
            process = subprocess.Popen(argv, stdout=subprocess.PIPE, shell=(sys.platform != 'darwin'))
        else:
            process = subprocess.Popen(argv, shell=(sys.platform != 'darwin'))

        if to_wait:
            process.wait()

        if pipe_out:
            process.stdout.flush()

        return process

    def monitor_process(self, process):
        file_dir = os.path.dirname(self.scap_out_address)
        input_name = os.path.basename(self.scap_address)
        output_name = os.path.basename(self.scap_out_address)
        process_flags = [False] * (len(PROC_FILE_NAMES))
        file_ind_offset = len(self.intermediate_files) - len(PROC_FILE_NAMES)
        while 1:
            file_names = [f for f in os.listdir(file_dir) if os.path.isfile(os.path.join(file_dir, f))]

            for i, flag in enumerate(process_flags):
                if not flag:
                    step_out_name = os.path.basename(self.intermediate_files[file_ind_offset + i])
                    
                    filtered_name = [f for f in file_names if step_out_name in file_names]
                    if len(filtered_name) > 0:
                        process_flags[i] = True
                        #print('  * ' + ('%d/%d ' % (i + 1, len(process_flags))) + #PROC_PRINT[i] + \
                        #    ' done...')

                    if not process_flags[i]:
                        break

            # Terminate the loop is either all steps are done or the process quits
            #if process_flags[-1] or process.poll() is not None:
            if process.poll() is not None:
                break
            time.sleep(SLEEP_INTERVAL_SEC)

        self.delete_intermediate_files()

    ## ======================================
    ##   IMAGE MODIFICATION ROUTINES
    ## ======================================
    def read_image(self, address):
        self.intermediate_files = []
        self.scap_address = None
        self.scap_out_address = None
        self.svg_out_address = None

        self.svg_address = address
        print( "Opening {}...".format(address) )

        if '.scap' in address:
            self.scap_address = address
            self.svg_address = self.svg_address.replace('.scap', '.svg')
            print( "  Converting to {}...".format(self.svg_address) )

            with open(address) as f:
                scap_to_svg.to_svg(f, self.svg_address)

        if not self.scap_address:
            self.scap_address = self.svg_address.replace('.svg', '_temp.scap')

        self.scap_out_address = self.svg_address.replace('.svg', '_out.scap')

        # Delete intermediate files before the new launching
        self.create_intermediate_file_list()
        self.delete_intermediate_files()

        self.change_view_mode( VIEW_SVG )

    def create_intermediate_file_list(self):
        if '_temp' in self.scap_address:
            self.intermediate_files.append(self.scap_address)
        file_dir = os.path.dirname(self.scap_out_address)
        input_name = os.path.basename(self.scap_address)
        output_name = os.path.basename(self.scap_out_address)
        process_flags = [False] * (1 + len(PROC_FILE_NAMES))

        for i, flag in enumerate(process_flags):
            step_out_name = None
            if i == 0:
                step_out_name = input_name.replace('.scap', '+')
            else:
                step_out_name = output_name.replace('.scap', PROC_FILE_NAMES[i-1])

            if i < len(process_flags) - 1:
                self.intermediate_files.append(os.path.join(file_dir, step_out_name))


    def delete_intermediate_files(self):
        for name in self.intermediate_files:
            if os.path.exists(name):
                print( "Deleting {}...".format(name) )
                os.remove(name)

    def cleanup_sketch(self):
        if not self.svg_address:
            print("Please select the input file.")
            return

        if not os.path.exists(self.scap_address):
            print( "  Converting to {}...".format(self.scap_address) )

            with open(self.scap_address, 'w') as fout:
                svg_to_scap.to_scap(self.svg_address, fout)

        if os.path.exists(self.scap_out_address):
            print( "Deleting {}...".format(self.scap_out_address) )
            os.remove(self.scap_out_address)

        # Launch the binary
        options = [] #['-c']

        if not self.to_preprocessing:
            options.append('-p')
        if not self.with_joint:
            options.append('-t')

        commandline = [EXE_DIR_WINS[self.num_threads]] + options + \
            [self.scap_address, '-o', self.scap_out_address]
        process = self.call_process(commandline)
        #print(commandline)
        print('=' * 80)
        print( "  Processing {}...".format(self.scap_address) )

        # Monitoring the process by checking the output files busily
        self.monitor_process(process)

        # Convert and inform about displaying result
        if os.path.exists(self.scap_out_address):
            self.svg_out_address = self.scap_out_address.replace('.scap', '.svg')
            print( "  Converting to {}...".format(self.svg_out_address) )

            with open(self.scap_out_address) as f:
                scap_to_svg.to_svg(f, self.svg_out_address)

            print( "  Consolidation done.")
            self.change_view_mode(VIEW_OUT)
        else:
            print('Error generating %s ...' % self.scap_out_address)
