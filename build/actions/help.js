
/*
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
 */
var _, capitano, columnify, command, general, indent, messages, parse, print;

_ = require('lodash');

_.str = require('underscore.string');

capitano = require('capitano');

columnify = require('columnify');

messages = require('../utils/messages');

parse = function(object) {
  return _.fromPairs(_.map(object, function(item) {
    var signature;
    if (item.alias != null) {
      signature = item.toString();
    } else {
      signature = item.signature.toString();
    }
    return [signature, item.description];
  }));
};

indent = function(text) {
  text = _.map(_.str.lines(text), function(line) {
    return '    ' + line;
  });
  return text.join('\n');
};

print = function(data) {
  return console.log(indent(columnify(data, {
    showHeaders: false,
    minWidth: 35
  })));
};

general = function(params, options, done) {
  var commands, groupedCommands;
  console.log('Usage: rdt [COMMAND] [OPTIONS]\n');
  console.log(messages.reachingOut);
  console.log('\nPrimary commands:\n');
  commands = _.reject(capitano.state.commands, function(command) {
    return command.isWildcard();
  });
  groupedCommands = _.groupBy(commands, function(command) {
    if (command.primary) {
      return 'primary';
    }
    return 'secondary';
  });
  print(parse(groupedCommands.primary));
  if (!_.isEmpty(capitano.state.globalOptions)) {
    console.log('\nGlobal Options:\n');
    print(parse(capitano.state.globalOptions));
  }
  return done();
};

command = function(params, options, done) {
  return capitano.state.getMatchCommand(params.command, function(error, command) {
    if (error != null) {
      return done(error);
    }
    if ((command == null) || command.isWildcard()) {
      return done(new Error("Command not found: " + params.command));
    }
    console.log("Usage: " + command.signature);
    if (command.help != null) {
      console.log("\n" + command.help);
    } else if (command.description != null) {
      console.log("\n" + (_.str.humanize(command.description)));
    }
    if (!_.isEmpty(command.options)) {
      console.log('\nOptions:\n');
      print(parse(command.options));
    }
    return done();
  });
};

exports.help = {
  signature: 'help [command...]',
  description: 'Show help',
  help: 'Get detailed help for a specific command.\n\nExamples:\n\n	$ rdt help ssh\n	$ rdt help push',
  primary: true,
  options: [],
  action: function(params, options, done) {
    if (params.command != null) {
      return command(params, options, done);
    } else {
      return general(params, options, done);
    }
  }
};
