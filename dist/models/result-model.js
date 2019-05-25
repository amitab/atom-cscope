"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
class ResultModel {
    constructor(keyword) {
        this.keyword = keyword;
        this.regex = new RegExp(this.keyword, 'g');
        this.items = new Array();
    }
    processResults(results, cwd) {
        for (var line of results.split("\n")) {
            line = line.trim();
            if (line == "")
                continue;
            this.items.push(this.processLine(line, cwd));
        }
    }
    processLine(line, cwd) {
        var data = line.split(" ", 3);
        data.push(line.replace(data.join(" ") + " ", ""));
        var info = {
            projectDir: path.isAbsolute(data[0]) ? data[0] : path.join(cwd, data[0]),
            fileName: path.basename(data[0]),
            functionName: data[1],
            lineNumber: parseInt(data[2]),
            codeLine: data[3],
            isJustFile: data[3].trim() == "<unknown>",
            relativePath: data[0]
        };
        if (info.isJustFile) {
            info.fileName = info.fileName.replace(/</g, '&lt;');
            info.fileName = info.fileName.replace(/>/g, '&gt;');
            info.fileName = info.fileName.replace(this.regex, '<span class="text-highlight bold">\$&</span>');
        }
        else {
            info.codeLine = info.codeLine.replace(/</g, '&lt;');
            info.codeLine = info.codeLine.replace(/>/g, '&gt;');
            info.codeLine = info.codeLine.replace(this.regex, '<span class="text-highlight bold">\$&</span>');
        }
        return info;
    }
}
exports.ResultModel = ResultModel;
//# sourceMappingURL=result-model.js.map