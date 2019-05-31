"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const fs = require("fs");
const child_process = require("child_process");
const os = require("os");
const result_model_1 = require("./models/result-model");
exports.CscopeCommands = [
    "Find this C symbol",
    "Find this global definition",
    "Find functions called by this",
    "Find functions calling this",
    "Find this text string",
    null,
    "Find this egrep pattern",
    "Find this file",
    "Find files #including this file",
    "Find assignments to this symbol"
];
class Cscope {
    static commandToNumber(cmd) {
        if (exports.CscopeCommands.indexOf(cmd) == -1) {
            throw "Invalid cscope command #{cmd}";
        }
        return exports.CscopeCommands.indexOf(cmd);
    }
    static isValidCommandNumber(num) {
        if (num < exports.CscopeCommands.length && exports.CscopeCommands[num] != null)
            return true;
        return false;
    }
    static getSourceFiles(project, extStr) {
        var exts = new Array();
        for (var ext of extStr.split(/\s+/)) {
            exts.push("*" + ext);
        }
        var out = fs.openSync(path.join(project, 'cscope.files'), 'w');
        var args;
        var cmd;
        if (os.platform() == "win32") {
            cmd = 'C:\\Windows\\System32\\cmd.exe';
            args = ['/s', '/c', 'dir'].concat(exts);
            args.push('/b/s');
        }
        else {
            cmd = 'find';
            var temp = exts.shift();
            if (temp === undefined)
                return Promise.reject("No extensions provided.");
            args = ['.', '(', '-name', temp];
            for (var ext of exts) {
                args = args.concat(['-o', '-name', ext]);
            }
            args = args.concat.apply(args, [')', '-type', 'f']);
        }
        return this.runCommand(cmd, args, { cwd: project, detached: true, stdio: ['ignore', out, 'pipe'] });
    }
    static generateCscopeDB(project) {
        var cscope_binary = atom.config.get('atom-cscope.cscopeBinaryLocation');
        return this.runCommand(cscope_binary, ['-qRbi', 'cscope.files'], { cwd: project, detached: false });
    }
    static setupCscopeForPath(project, exts, force) {
        var cscopeExists = this.cscopeExists(project)
            .then((exists) => {
            if (!exists || force) {
                return this.getSourceFiles(project, exts)
                    .then(() => {
                    return this.generateCscopeDB(project);
                })
                    .then(() => {
                    return true;
                });
            }
            return Promise.resolve(true);
        });
        return cscopeExists;
    }
    static setupCscope(projects, exts, force) {
        var promises = new Array();
        for (var project of projects) {
            promises.push(this.setupCscopeForPath(project, exts, force));
        }
        return Promise.all(promises);
    }
    static cscopeExists(project) {
        var filePath = path.join(project, 'cscope.out');
        return new Promise((resolve) => {
            fs.access(filePath, fs.constants.R_OK | fs.constants.W_OK, (err) => {
                if (err) {
                    resolve(false);
                }
                else {
                    resolve(true);
                }
            });
        });
    }
    static runCommand(command, args, options) {
        var process = new Promise((resolve, reject) => {
            var output = '';
            var err = '';
            var child = child_process.spawn(command, args, options);
            if (child.stdout != null) {
                child.stdout.on('data', (data) => {
                    output += data.toString();
                });
            }
            if (child.stderr != null) {
                child.stderr.on('data', (data) => {
                    err += data.toString();
                });
            }
            child.on('error', (err) => {
                throw "Error executing command " + command + " [" + args.join() + "] " + err;
            });
            child.on('close', (code) => {
                console.log("Closed command with " + code);
                if (code == -2) {
                    reject("Unable to find cscope");
                }
                if (code != 0) {
                    reject(err);
                }
                else {
                    resolve(output);
                }
            });
            if (options.detached) {
                child.unref();
            }
        });
        return process;
    }
    static runCscopeCommand(num, keyword, cwd) {
        var cscopeBinary = atom.config.get('atom-cscope.cscopeBinaryLocation');
        if (keyword.trim() == '') {
            return Promise.resolve({ output: "", cwd: cwd });
        }
        else {
            return new Promise((resolve, reject) => {
                this.runCommand(cscopeBinary, ['-dL' + num, keyword], { cwd: cwd, detached: false })
                    .then((data) => {
                    resolve({ output: data, cwd: cwd });
                }).catch((errMsg) => {
                    reject(errMsg);
                });
            });
        }
    }
    static runCscopeCommands(num, keyword, projects) {
        var promises = new Array();
        var resultSet = new result_model_1.ResultModel(keyword);
        for (var project of projects) {
            promises.push(this.runCscopeCommand(num, keyword, project));
        }
        return Promise.all(promises)
            .then((values) => {
            for (var value of values) {
                resultSet.processResults(value.output, value.cwd);
            }
            return resultSet.getItems();
        });
    }
}
exports.Cscope = Cscope;
//# sourceMappingURL=cscope.js.map