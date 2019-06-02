import * as path from "path";

export interface LineInfo {
  projectDir: string;
  fileName: string;
  functionName: string;
  lineNumber: number;
  codeLine: string;
  isJustFile: boolean;
  relativePath: string
}

export class ResultModel {
  keyword: string;
  regex: RegExp;
  items: LineInfo[];

  constructor(keyword: string) {
    this.keyword = keyword;
    this.regex = new RegExp(this.keyword, 'g');
    this.items = new Array();
  }

  getItems(): LineInfo[] {
    return this.items;
  }

  processResults(results: string, cwd: string) {
    for (var line of results.split("\n")) {
      line = line.trim();
      if (line == "") continue;
      this.items.push(this.processLine(line, cwd));
    }
  }

  processLine(line: string, cwd: string) {
    var data: string[] = line.split(" ", 3);
    data.push(line.replace(data.join(" ") + " ", ""));
    var info: LineInfo = {
      projectDir: path.isAbsolute(data[0]) ? data[0] : path.join(cwd, data[0]),
      fileName: path.basename(data[0]),
      functionName: data[1],
      lineNumber: parseInt(data[2]),
      codeLine: data[3],
      isJustFile: data[3].trim() == "<unknown>",
      relativePath: data[0]
    }

    if (info.isJustFile) {
      info.fileName = info.fileName.replace(/</g, '&lt;');
      info.fileName = info.fileName.replace(/>/g, '&gt;');
      info.fileName = info.fileName.replace(this.regex, '<span class="text-highlight bold">\$&</span>');
    } else {
      info.codeLine = info.codeLine.replace(/</g, '&lt;');
      info.codeLine = info.codeLine.replace(/>/g, '&gt;');
      info.codeLine = info.codeLine.replace(this.regex, '<span class="text-highlight bold">\$&</span>');
    }

    return info;
  }
}
