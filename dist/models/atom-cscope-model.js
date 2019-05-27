"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
class AtomCscopeModel {
    constructor(subscriptions, pathsUpdateCallback, dataChangeCallback) {
        this.dataChangeCallback = dataChangeCallback;
        this.pathsUpdateCallback = pathsUpdateCallback;
        this.subscriptions = subscriptions;
        this.data = {
            paths: [],
            results: []
        };
        for (var project in atom.project.getPaths()) {
            this.data.paths.push(path.basename(project));
        }
        this.setupEvents();
    }
    setupEvents() {
        this.subscriptions.add(atom.project.onDidChangePaths((projects) => {
            var paths = new Array();
            for (var project of projects) {
                paths.push(path.basename(project));
            }
            this.pathsUpdateCallback('paths', paths);
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