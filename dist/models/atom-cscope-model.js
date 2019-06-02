"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
class AtomCscopeModel {
    constructor(subscriptions, pathsUpdateCallback, dataChangeCallback) {
        this.dataChangeCallback = dataChangeCallback;
        this.pathsUpdateCallback = pathsUpdateCallback;
        this.subscriptions = subscriptions;
        this.data = {
            paths: atom.project.getPaths(),
            results: [],
            projectName: (projectPath) => {
                return path.basename(projectPath);
            }
        };
        this.setupEvents();
    }
    setupEvents() {
        this.subscriptions.add(atom.project.onDidChangePaths((projects) => {
            this.pathsUpdateCallback('paths', projects);
        }));
    }
    clearResults() {
        this.results([]);
    }
    results(results) {
        this.dataChangeCallback('results', results);
    }
}
exports.AtomCscopeModel = AtomCscopeModel;
//# sourceMappingURL=atom-cscope-model.js.map