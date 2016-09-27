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

Promise = require('bluebird')
capitano = Promise.promisifyAll(require('capitano'))
actions = require('./actions')
{ errors, update } = require('./utils')

capitano.command
	signature: '*'
	action: ->
		capitano.execute(command: 'help')

capitano.globalOption
	signature: 'help'
	boolean: true
	alias: 'h'

# ---------- SSH Module ----------
capitano.command(actions.ssh)

# ---------- Sync Module ----------
capitano.command(actions.sync)

# ---------- Version Module ----------
capitano.command(actions.version)

# ---------- Help Module ----------
capitano.command(actions.help.help)

update.notify()

Promise.try ->
	cli = capitano.parse(process.argv)
	if cli.global?.help
		return capitano.executeAsync(command: "help #{cli.command ? ''}")

	capitano.executeAsync(cli)
.catch(errors.handle)
