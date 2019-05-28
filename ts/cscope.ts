import * as path from 'path';
import * as fs from 'fs';
import * as child_process from 'child_process';
import * as os from 'os';
import {ResultModel, LineInfo} from './models/result-model'

interface CscopeResult {
  output: string;
  cwd: string;
}

export class CscopeCommands {
  public static getSourceFiles(project: string, extStr: string): Promise<string> {
    var exts: string[] = new Array();
    for (var ext of extStr.split(/\s+/)) {
      exts.push("*" + ext);
    }
    var out: number = fs.openSync(path.join(project, 'cscope.files'), 'w');
    var args: string[];
    var cmd: string;
    if (os.platform() == "win32") {
      cmd = 'C:\\Windows\\System32\\cmd.exe';
      args = ['/s', '/c', 'dir'].concat(exts);
      args.push('/b/s');
    } else {
      cmd = 'find';
      var temp: string | undefined = exts.shift();
      if (temp === undefined) return Promise.reject("No extensions provided.");
      args = ['.', '(', '-name', temp];
      for (var ext of exts) {
        args = args.concat(['-o', '-name', ext]);
      }
      args = args.concat.apply(args, [')', '-type', 'f']);
    }
    return this.runCommand(cmd, args, {cwd: project, detached: true, stdio: ['ignore', out, 'pipe']});
  }

  public static generateCscopeDB(project: string): Promise<string> {
    var cscope_binary: string = atom.config.get('atom-cscope.cscopeBinaryLocation');
    return this.runCommand(cscope_binary, ['-qRbi', 'cscope.files'], {cwd: project, detached: false});
  }

  public static setupCscopeForPath(project: string, exts: string, force: boolean): Promise<boolean> {
    var cscopeExists: Promise<boolean> = this.cscopeExists(project)
    .then((exists: boolean) => {
      if (!exists || force) {
        return this.getSourceFiles(project, exts)
        .then(() => {
          return this.generateCscopeDB(project);
        })
        .then(() => {
          return true;
        })
      }
      return Promise.resolve(true);
    });

    return cscopeExists;
  }

  public static setupCscope(projects: string[], exts: string, force: boolean): Promise<boolean[]> {
    var promises: Promise<boolean>[] = new Array();
    for (var project of projects) {
      promises.push(this.setupCscopeForPath(project, exts, force));
    }

    return Promise.all(promises);
  }

  public static cscopeExists(project: string): Promise<boolean> {
    var filePath: string = path.join(project, 'cscope.out');
    return new Promise((resolve) => {
      fs.access(filePath, fs.constants.R_OK | fs.constants.W_OK, (err) => {
        if (err) {
          resolve(false);
        } else {
          resolve(true);
        }
      });
    });
  }

  public static runCommand(command: string, args: string[], options: child_process.SpawnOptions): Promise<string> {
    var process: Promise<string> = new Promise((resolve, reject) => {
      var output: string = '';
      var err: string = '';
      var child: child_process.ChildProcess = child_process.spawn(command, args, options);
      if (child.stdout != null) {
        child.stdout.on('data', (data: Buffer) => {
          output += data.toString();
        });
      }
      if (child.stderr != null) {
        child.stderr.on('data', (data: Buffer) => {
          err += data.toString();
        });
      }

      child.on('error', (err: string) => {
        throw "Error executing command " + command + " [" + args.join() + "] " + err;
      });
      child.on('close', (code: number) => {
        console.log("Closed command with " + code);
        if (code == -2) {
          reject("Unable to find cscope");
        }
        if (code != 0) {
          reject(err);
        } else {
          resolve(output);
        }
      });

      if (options.detached) {
        child.unref();
      }
    });
    return process;
  }

  public static runCscopeCommand(num: number, keyword: string, cwd: string): Promise<CscopeResult> {
    var cscopeBinary: string = atom.config.get('atom-cscope.cscopeBinaryLocation');
    if (keyword.trim() == '') {
      return Promise.resolve({output: "", cwd: cwd});
    } else {
      return new Promise<CscopeResult>((resolve, reject) => {
        this.runCommand(cscopeBinary, ['-dL' + num, keyword], {cwd: cwd, detached: false})
        .then((data: string) => {
          resolve({output: data, cwd: cwd});
        }).catch((errMsg: string) => {
          reject(errMsg);
        });
      });
    }
  }

  public static runCscopeCommands(num: number, keyword: string, projects: string[]): Promise<LineInfo[]> {
    var promises: Promise<CscopeResult>[] = new Array();
    var resultSet: ResultModel = new ResultModel(keyword);
    for (var project of projects) {
      promises.push(this.runCscopeCommand(num, keyword, project));
    }

    return Promise.all(promises)
      .then((values: CscopeResult[]) => {
        for (var value of values) {
          resultSet.processResults(value.output, value.cwd);
        }
        return resultSet.getItems();
      });
  }
}
