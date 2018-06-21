#!/usr/bin/env python

###############################################################
# < next few lines under version control, D O  N O T  E D I T >
# $Date: 2018-03-29 10:12:00 -0400 (Thu, 29 Mar 2018) $
# $Revision: 100014 $
# $Author: rahul.mahajan@noaa.gov $
# $Id: nemsio2nc4.py 100014 2018-03-29 14:12:00Z rahul.mahajan@noaa.gov $
###############################################################

__author__  = 'Rahul Mahajan'
__email__   = 'rahul.mahajan@noaa.gov'
__license__ = 'GPL'

'''
Simple utility to convert nemsio file into a netCDF4 file
Utilizes mkgfsnemsioctl utility from NWPROD and CDO
'''

import os
import sys
import subprocess
from distutils.spawn import find_executable
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

def execute_subprocess(cmd, verbose=False):
    '''
    call the subprocess command
    :param cmd: command to execute
    :param type: str
    '''
    if verbose:
        print 'Executing: %s' % cmd

    try:
        out = subprocess.check_output(cmd,shell=True)
    except subprocess.CalledProcessError as e:
        raise subprocess.CalledProcessError('',cmd,output=e.output)
    return


def get_exec_path(exec_name, verbose=False):
    '''
    get the full path to a given executable name
    :param exec_name: executable to fine
    :param type: str
    '''

    exec_path_def = '/home/Rahul.Mahajan/bin/%s' % exec_name

    exec_path = find_executable(exec_name)
    if exec_path is None:
        msg = '%s is needed to run this utility, and is not in your path.\n' % exec_name
        msg += 'Using:\n'
        msg += '%s\n' % exec_path_def
        msg += 'If you wish to use another version, Enter full path or return to continue: \n'
        input_str = raw_input(msg)
        if input_str in ['']:
            exec_path = exec_path_def
        else:
            exec_path = input_str
            if ( not os.path.exists(exec_path) ):
                print '%s does not exist, EXITING!' % exec_path
                sys.exit(2)

    if verbose:
        print '%s: %s' % (exec_name, exec_path)

    return exec_path


if __name__ == '__main__':

    parser = ArgumentParser(description='convert nemsio file to netCDF4 file', formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument('-n', '--nemsio', help='input nemsio file name', type=str, required=True)
    parser.add_argument('-v', '--verbose', help='print debugging information', action='store_true', required=False)
    args = parser.parse_args()

    finput = args.nemsio
    verbose = args.verbose

    fname = finput.strip('.nemsio') if finput.endswith('.nemsio') else finput

    mkgfsnemsioctl = get_exec_path('mkgfsnemsioctl', verbose=verbose)
    cdo = get_exec_path('cdo', verbose=verbose)

    cmd = '%s %s' % (mkgfsnemsioctl, finput)
    execute_subprocess(cmd, verbose=verbose)

    cmd = '%s -f nc4 import_binary %s.ctl %s.nc4' % (cdo, finput, fname)
    execute_subprocess(cmd, verbose=verbose)

    #cmd = '%s setgatt,source,GSI %s.nctmp %s.nc4' % (cdo, fname, fname)
    #execute_subprocess(cmd)

    cmd = 'rm -f %s.ctl' % (finput)
    execute_subprocess(cmd, verbose=verbose)

    sys.exit(0)
