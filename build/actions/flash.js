
/*
Copyright 2016 Resin.io

Licensed under the Apache License, Version 2.0 (the 'License');
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an 'AS IS' BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */
var Promise, _, chalk, drivelist, form, fs, imageWrite, os, umount, visuals;

_ = require('lodash');

os = require('os');

Promise = require('bluebird');

umount = Promise.promisifyAll(require('umount'));

fs = Promise.promisifyAll(require('fs'));

drivelist = Promise.promisifyAll(require('drivelist'));

chalk = require('chalk');

visuals = require('resin-cli-visuals');

form = require('resin-cli-form');

imageWrite = require('etcher-image-write');

module.exports = {
  signature: 'flash <image>',
  description: 'Flash an image to a drive',
  help: 'Use this command to flash a ResinOS image to a drive.\n\nExamples:\n\n	$ rdt flash path/to/resinos.img\n	$ rdt flash path/to/resinos.img --drive /dev/disk2\n	$ rdt flash path/to/resinos.img --drive /dev/disk2 --yes',
  primary: true,
  options: [
    {
      signature: 'yes',
      boolean: true,
      description: 'confirm non-interactively',
      alias: 'y'
    }, {
      signature: 'drive',
      parameter: 'drive',
      description: 'drive',
      alias: 'd'
    }
  ],
  action: function(params, options, done) {
    return form.run([
      {
        message: 'Select drive',
        type: 'drive',
        name: 'drive'
      }, {
        message: 'This will erase the selected drive. Are you sure?',
        type: 'confirm',
        name: 'yes',
        "default": false
      }
    ], {
      override: {
        drive: options.drive,
        yes: options.yes || void 0
      }
    }).then(function(answers) {
      if (answers.yes !== true) {
        console.log(chalk.red.bold("Aborted image flash"));
        process.exit(0);
      }
      return drivelist.listAsync().then(function(drives) {
        var selectedDrive;
        selectedDrive = _.find(drives, {
          device: answers.drive
        });
        if (selectedDrive == null) {
          throw new Error("Drive not found: " + answers.drive);
        }
        return selectedDrive;
      });
    }).then(function(selectedDrive) {
      var progressBars;
      progressBars = {
        write: new visuals.Progress('Flashing'),
        check: new visuals.Progress('Validating')
      };
      return umount.umountAsync(selectedDrive.device).then(function() {
        return Promise.props({
          imageSize: fs.statAsync(params.image).get('size'),
          imageStream: Promise.resolve(fs.createReadStream(params.image)),
          driveFileDescriptor: fs.openAsync(selectedDrive.raw, 'rs+')
        });
      }).then(function(results) {
        return imageWrite.write({
          fd: results.driveFileDescriptor,
          device: selectedDrive.raw,
          size: selectedDrive.size
        }, {
          stream: results.imageStream,
          size: results.imageSize
        }, {
          check: true
        });
      }).then(function(writer) {
        return new Promise(function(resolve, reject) {
          writer.on('progress', function(state) {
            return progressBars[state.type].update(state);
          });
          writer.on('error', reject);
          return writer.on('done', resolve);
        });
      }).then(function() {
        var removedrive;
        if ((os.platform() === 'win32') && (selectedDrive.mountpoint != null)) {
          removedrive = Promise.promisifyAll(require('removedrive'));
          return removedrive.ejectAsync(selectedDrive.mountpoint);
        }
        return umount.umountAsync(selectedDrive.device);
      });
    }).asCallback(done);
  }
};
