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

# A function to reliably execute a command
# in all supported operating systems, including
# different Windows environments like `cmd.exe`
# and `Cygwin` should be encapsulated in a
# re-usable package.
getSubShellCommand = (command) ->
	os = require('os')

	if os.platform() is 'win32'
		return {
			program: 'cmd.exe'
			args: [ '/s', '/c', command ]
		}
	else
		return {
			program: '/bin/sh'
			args: [ '-c', command ]
		}

module.exports =
	signature: 'ssh [deviceIp]'
	description: 'Get a shell into a resinOS device'
	help: '''
		If you're running Windows, this command only supports `cmd.exe`.

		Use this command to get a shell into the running application container of
		your device.

		The '--host' option will get you a shell into the Host OS of the resinOS device.
		No option will return a list of containers to enter or you can explicitly select
		one by passing its name to the --container option

		Examples:

			$ rdt ssh
			$ rdt ssh --host
			$ rdt ssh --container chaotic_water
			$ rdt ssh --container chaotic_water --port 22222
			$ rdt ssh --verbose
	'''
	primary: true
	options: [
			signature: 'verbose'
			boolean: true
			description: 'increase verbosity'
			alias: 'v'
	,
			signature: 'host'
			boolean: true
			description: 'get a shell into the host OS'
			alias: 's'
	,
			signature: 'container'
			parameter: 'container'
			default: null
			description: 'name of container to access'
			alias: 'c'
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

		if (options.host is true and options.container?)
			throw new Error('Please pass either --host or --container option')

		if not options.port?
			options.port = 22222

		verbose = if options.verbose then '-vvv' else ''

		Promise.try ->
			if not params.deviceIp?
				return forms.selectLocalResinOsDevice()
			return params.deviceIp
		.then (deviceIp) ->
			_.assign(options, { deviceIp })

			return if options.host

			if not options.container?
				return common.selectContainerFromDevice(deviceIp)

			return options.container
		.then (container) ->

			command = "ssh \
				#{verbose} \
				-t \
				-p #{options.port} \
				-o LogLevel=ERROR \
				-o StrictHostKeyChecking=no \
				-o UserKnownHostsFile=/dev/null \
				-o ControlMaster=no \
				 root@#{options.deviceIp}"

			if not options.host
			 command += " docker exec -ti #{container} /bin/sh"

			subShellCommand = getSubShellCommand(command)
			child_process.spawn subShellCommand.program, subShellCommand.args,
				stdio: 'inherit'
		.nodeify(done)
