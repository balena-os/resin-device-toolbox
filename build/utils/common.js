var Docker, Promise, _, chalk, form;

Promise = require('bluebird');

_ = require('lodash');

Docker = require('docker-toolbelt');

form = require('resin-cli-form');

chalk = require('chalk');

module.exports = {
  selectContainerFromDevice: Promise.method(function(deviceIp) {
    var docker;
    docker = new Docker({
      host: deviceIp,
      port: 2375
    });
    return docker.listContainersAsync().then(function(containers) {
      if (_.isEmpty(containers)) {
        throw new Error("No containers are running in " + deviceIp);
      }
      return form.ask({
        message: 'Select a container',
        type: 'list',
        choices: _.map(containers, function(container) {
          return {
            name: (container.Names[0] || 'Untitled') + " (" + container.Id + ")",
            value: container.Id
          };
        })
      });
    });
  }),
  pipeContainerStream: Promise.method(function(arg) {
    var deviceIp, docker, follow, name, outStream, ref;
    deviceIp = arg.deviceIp, name = arg.name, outStream = arg.outStream, follow = (ref = arg.follow) != null ? ref : false;
    docker = new Docker({
      host: deviceIp,
      port: 2375
    });
    return docker.getContainer(name).attachAsync({
      logs: !follow,
      stream: follow,
      stdout: true,
      stderr: true
    }).then(function(containerStream) {
      return containerStream.pipe(outStream);
    })["catch"](function(err) {
      err = '' + err.statusCode;
      if (err === '404') {
        return console.log(chalk.red.bold("Container '" + name + "' not found."));
      }
      throw err;
    });
  })
};
