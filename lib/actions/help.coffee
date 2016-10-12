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

_ = require('lodash')
_.str = require('underscore.string')
capitano = require('capitano')
columnify = require('columnify')
messages = require('../utils/messages')

parse = (object) ->
	_.fromPairs _.map object, (item) ->

		# Hacky way to determine if an object is
		# a function or a command
		if item.alias?
			signature = item.toString()
		else
			signature = item.signature.toString()

		return [
			signature
			item.description
		]

indent = (text) ->
	text = _.map _.str.lines(text), (line) ->
		return '    ' + line
	return text.join('\n')

print = (data) ->
	console.log indent columnify data,
		showHeaders: false
		minWidth: 35

general = (params, options, done) ->
	console.log('Usage: rdt [COMMAND] [OPTIONS]\n')
	console.log(messages.reachingOut)
	console.log('\nPrimary commands:\n')

	# We do not want the wildcard command
	# to be printed in the help screen.
	commands = _.reject capitano.state.commands, (command) ->
		return command.isWildcard()

	groupedCommands = _.groupBy commands, (command) ->
		if command.primary
			return 'primary'
		return 'secondary'

	print(parse(groupedCommands.primary))

	if not _.isEmpty(capitano.state.globalOptions)
		console.log('\nGlobal Options:\n')
		print(parse(capitano.state.globalOptions))

	return done()

command = (params, options, done) ->
	capitano.state.getMatchCommand params.command, (error, command) ->
		return done(error) if error?

		if not command? or command.isWildcard()
			return done(new Error("Command not found: #{params.command}"))

		console.log("Usage: #{command.signature}")

		if command.help?
			console.log("\n#{command.help}")
		else if command.description?
			console.log("\n#{_.str.humanize(command.description)}")

		if not _.isEmpty(command.options)
			console.log('\nOptions:\n')
			print(parse(command.options))

		return done()

exports.help =
	signature: 'help [command...]'
	description: 'Show help'
	help: '''
		Get detailed help for a specific command.

		Examples:

			$ rdt help ssh
			$ rdt help push
	'''
	primary: true
	options: []
	action: (params, options, done) ->
		if params.command?
			command(params, options, done)
		else
			general(params, options, done)
