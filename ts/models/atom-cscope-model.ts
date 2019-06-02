import * as path from "path";
import {CompositeDisposable} from "atom";
import {LineInfo} from "./result-model"

interface Data {
  paths: string[];
  results: LineInfo[];
  projectName: (projectPath: string) => string;
}

type DataChangeCallback = (itemName: string, newItem: LineInfo[]) => void;
type PathsUpdateCallback = (itemName: string, projects: string[]) => void;

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
      paths: atom.project.getPaths(),
      results: [],
      projectName: (projectPath: string) => {
        return path.basename(projectPath);
      }
    };
    this.setupEvents();
  }

  setupEvents() {
    this.subscriptions.add(atom.project.onDidChangePaths((projects: string[]) => {
      this.pathsUpdateCallback('paths', projects);
    }));
  }

  clearResults() {
    this.results([]);
  }

  results(results: LineInfo[]) {
    this.dataChangeCallback('results', results);
  }
}
