
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
var chalk, errors, messages, printErrorMessage;

errors = require('resin-cli-errors');

chalk = require('chalk');

messages = require('./messages');

printErrorMessage = function(message) {
  console.error(chalk.red(message));
  return console.error(chalk.red("\n" + messages.reachingOut + "\n"));
};

exports.handle = function(error) {
  var message;
  message = errors.interpret(error);
  if (message == null) {
    return;
  }
  if (process.env.DEBUG) {
    message = error.stack;
  }
  printErrorMessage(message);
  return process.exit(error.exitCode || 1);
};
