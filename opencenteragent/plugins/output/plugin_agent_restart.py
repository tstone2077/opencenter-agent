#!/usr/bin/env python
#               OpenCenter(TM) is Copyright 2013 by Rackspace US, Inc.
##############################################################################
#
# OpenCenter is licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.  This
# version of OpenCenter includes Rackspace trademarks and logos, and in
# accordance with Section 6 of the License, the provision of commercial
# support services in conjunction with a version of OpenCenter which includes
# Rackspace trademarks and logos is prohibited.  OpenCenter source code and
# details are available at: # https://github.com/rcbops/opencenter or upon
# written request.
#
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0 and a copy, including this
# notice, is available in the LICENSE file accompanying this software.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the # specific language governing permissions and limitations
# under the License.
#
##############################################################################
#

import os
import sys
import time

name = 'agent_restart'


def setup(config={}):
    LOG.debug('Setting up restart_agent plugin')
    register_action('agent_restart', restart_agent)


def restart_agent(input_data):
    pid = os.fork()
    if pid != 0:
        # Parent process, wait for child to finish.. then recycle
        try:
            os.wait()
            time.sleep(15)
            _respawn()
        except OSError:
            return _return(1, 'unable to wait on child process')

    else:
        # Child Process
        return _success()


def _return(result_code, result_str, result_data=None):
    if result_data is None:
        result_data = {}
    return {'result_code': result_code,
            'result_str': result_str,
            'result_data': result_data}


def _success(result_str='success', result_data=None):
    if result_data is None:
        result_data = {}
    return _return(0, result_str, result_data)


def _respawn():
    args = sys.argv[:]
    LOG.info('Re-spawning %s' % ' '.join(args))
    args.insert(0, sys.executable)
    os.execv(sys.executable, args)
