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

		The '--host' option will get you a shell into the Host OS of the ResinOS device.
		No option will return a list of containers to enter or you can explicitly select
		one by passing its name to the --container option

		Examples:

			$ resin ssh
			$ resin ssh --host
			$ resin ssh --container chaotic_water
			$ resin ssh --container chaotic_water --port 22222
			$ resin ssh --verbose
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
			alias: 'h'
	,
			signature: 'container'
			parameter: 'container'
			default: null
			description: 'name of container to access'
			alias: 'h'
	,
			signature: 'port'
			parameter: 'port'
			description: 'ssh port number (default: 22222)'
			alias: 'h'
	]
	action: (params, options, done) ->
		child_process = require('child_process')
		Promise = require 'bluebird'
		Docker = require('docker-toolbelt')
		_ = require('lodash')
		form = require('resin-cli-form')
		{ discover } = require('resin-sync')

		if (options.host is true and options.container?)
			throw new Error('Please pass either --host or --container option')

		selectContainerFromDevice = Promise.method (deviceIp) ->
			docker = new Docker(host: deviceIp, port: 2375)

			docker.listContainersAsync()
			.then (containers) ->
				if _.isEmpty(containers)
					throw new Error("No containers are running in #{deviceIp}")

				return form.ask
					message: 'Select a container'
					type: 'list'
					choices: _.map containers, (container) ->
						return {
							name: "#{container.Names[0] or 'Untitled'} (#{container.Id})"
							value: container.Id
						}

		if not options.port?
			options.port = 22222

		verbose = if options.verbose then '-vvv' else ''

		Promise.try ->
			if not params.deviceIp?
				return discover.selectLocalResinOsDeviceForm()
			return params.deviceIp
		.then (deviceIp) ->
			_.assign(options, { deviceIp })

			return if options.host

			if not options.container?
				return selectContainerFromDevice(deviceIp)

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
