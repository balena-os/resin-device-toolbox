
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
var dockerInfoProperties, dockerVersionProperties;

dockerInfoProperties = ['Containers', 'ContainersRunning', 'ContainersPaused', 'ContainersStopped', 'Images', 'Driver', 'SystemTime', 'KernelVersion', 'OperatingSystem', 'Architecture'];

dockerVersionProperties = ['Version', 'ApiVersion'];

module.exports = {
  signature: 'scan',
  description: 'Scan for resinOS devices in your local network',
  help: '\nExamples:\n\n	$ rdt scan\n	$ rdt scan --verbose',
  primary: true,
  options: [
    {
      signature: 'verbose',
      boolean: true,
      description: 'Display full info',
      alias: 'v'
    }
  ],
  action: function(params, options, done) {
    var Docker, Promise, SpinnerPromise, _, discover, prettyjson;
    Promise = require('bluebird');
    _ = require('lodash');
    prettyjson = require('prettyjson');
    Docker = require('docker-toolbelt');
    discover = require('resin-sync').discover;
    SpinnerPromise = require('resin-cli-visuals').SpinnerPromise;
    return Promise["try"](function() {
      return new SpinnerPromise({
        promise: discover.discoverLocalResinOsDevices(),
        startMessage: 'Scanning for local resinOS devices..',
        stopMessage: 'Reporting scan results'
      });
    }).tap(function(devices) {
      if (_.isEmpty(devices)) {
        throw new Error('Could not find any resinOS devices in the local network');
      }
    }).map(function(arg) {
      var address, docker, host;
      host = arg.host, address = arg.address;
      docker = new Docker({
        host: address,
        port: 2375
      });
      return Promise.props({
        dockerInfo: docker.infoAsync().catchReturn('Could not get Docker info'),
        dockerVersion: docker.versionAsync().catchReturn('Could not get Docker version')
      }).then(function(arg1) {
        var dockerInfo, dockerVersion;
        dockerInfo = arg1.dockerInfo, dockerVersion = arg1.dockerVersion;
        if (!options.verbose) {
          if (_.isObject(dockerInfo)) {
            dockerInfo = _.pick(dockerInfo, dockerInfoProperties);
          }
          if (_.isObject(dockerVersion)) {
            dockerVersion = _.pick(dockerVersion, dockerVersionProperties);
          }
        }
        return {
          host: host,
          address: address,
          dockerInfo: dockerInfo,
          dockerVersion: dockerVersion
        };
      });
    }).then(function(devicesInfo) {
      return console.log(prettyjson.render(devicesInfo, {
        noColor: true
      }));
    }).nodeify(done);
  }
};
