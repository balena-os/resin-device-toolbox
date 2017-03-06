###
Copyright 2016 Resin.io

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

module.exports =
	signature: 'promote [deviceIp]'
	description: 'Promote a resinOS device'
	help: '''
		If you're running Windows, this command only supports `cmd.exe`.

		Use this command to promote your device.

		Examples:

			$ rdt promote
			$ rdt promote --port 22222
			$ rdt promote --verbose
	'''
	primary: true
	options: [
				signature: 'verbose'
				boolean: true
				description: 'increase verbosity'
				alias: 'v'
		,
				signature: 'port'
				parameter: 'port'
				description: 'ssh port number (default: 22222)'
				alias: 'p'
		]
	action: (params, options, done) ->
		child_process = require('child_process')
		Promise = require 'bluebird'
		_ = require('lodash')
		{ forms } = require('resin-sync')
		{ common } = require('../utils')

		if not options.port?
			options.port = 22222

		verbose = if options.verbose then '-vvv' else ''

		Promise.try ->
			if not params.deviceIp?
				return forms.selectLocalResinOsDevice()
			return params.deviceIp
		.then (deviceIp) ->
			_.assign(options, { deviceIp })

			command = "ssh \
				#{verbose} \
				-t \
				-p #{options.port} \
				-o LogLevel=ERROR \
				-o StrictHostKeyChecking=no \
				-o UserKnownHostsFile=/dev/null \
				-o ControlMaster=no \
				root@#{options.deviceIp} \
				-- \"resin-provision\""

			subShellCommand = common.getSubShellCommand(command)
			child_process.spawn subShellCommand.program, subShellCommand.args,
				stdio: 'inherit'
		.nodeify(done)
