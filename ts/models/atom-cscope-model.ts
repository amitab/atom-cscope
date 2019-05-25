import * as path from "path";
import {CompositeDisposable} from "atom";
import {LineInfo} from "./result-model"

interface Data {
  paths: string[];
  results: LineInfo[];
}

type DataChangeCallback = (itemName: string, newItem: LineInfo[]) => void;
type PathsUpdateCallback = (itemName: string, newItem: string[]) => void;

export class AtomCscopeModel {
  subscriptions: CompositeDisposable;
  dataChangeCallback: DataChangeCallback;
  pathsUpdateCallback: PathsUpdateCallback;
  data: Data;

  constructor(subscriptions: CompositeDisposable, pathsUpdateCallback: PathsUpdateCallback, dataChangeCallback: DataChangeCallback) {
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
    this.subscriptions.add(atom.project.onDidChangePaths((projects: string[]) => {
      var paths: string[] = new Array();
      for (var project in projects) {
        paths.push(path.basename(project));
      }

      this.pathsUpdateCallback('paths', paths);
    }));
  }

  clearResults() {
    this.results([]);
  }

  results(results: LineInfo[]) {
    this.dataChangeCallback('results', results);
  }
}
