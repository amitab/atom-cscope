import {CompositeDisposable, TextEditor} from 'atom';

import {AtomCscopeViewModel, Search} from './viewModels/atom-cscope-view-model';
import {LineInfo} from './models/result-model';
import {CscopeCommands} from './cscope';
export * from './config';
import {Navigation} from './history';

let viewModel: AtomCscopeViewModel;
let history: Navigation | null;
let subscriptions: CompositeDisposable;
let maxResults: number;

export function refreshCscopeDB() {
  var exts: string = atom.config.get('atom-cscope.cscopeSourceFiles');
  if (exts.trim() == "") return;

  CscopeCommands.setupCscope(atom.project.getPaths(), exts, true)
    .then(() => {
      atom.notifications.addSuccess("Refreshed cscope database!");
    }).catch((data: string) => {
      var message: string = data != null ? data.toString() : "Unknown Error occured";
      atom.notifications.addError(message);
    });
}

export function setupEvents() {
  viewModel.onSearch((params: Search) => {
    if (history != null)
      history.clearHistory();

    var option: number = params.option;
    var keyword: string = params.keyword;
    var projects: string[] = params.path;
    if (keyword.trim() == "")
      return Promise.resolve(new Array());

    // The option must be acceptable by cscope
    if ([0, 1, 2, 3, 4, 6, 7, 8, 9].indexOf(option) == -1) {
      atom.notifications.addError("Invalid cscope option: " + option);
      return Promise.resolve(new Array());
    }

    var response: Promise<LineInfo[]> = new Promise<LineInfo[]>((resolve, reject) => {
      CscopeCommands.runCscopeCommands(option, keyword, projects)
      .then((data: LineInfo[]) => {
        if (data.length > maxResults || maxResults <= 0) {
          atom.notifications.addWarning("Results more than #{maxResults}!");
        }
        resolve(data);
      })
      .catch((data: string) => {
        var message: string = data != null ? data.toString() : "Unknown Error occured";
        atom.notifications.addError(message);
        reject(message);
      });
    });

    return response;
  });

  viewModel.onRefresh(refreshCscopeDB);
  viewModel.onResultClick((model) => {
    if (history != null && history.isEmpty()) history.saveCurrent();
    atom.workspace.open(model.projectDir, {initialLine: model.lineNumber - 1});
    if (history == null) return;
    history.saveNew({
      path: model.projectDir,
      pos: {
        row: model.lineNumber - 1,
        column: 0
      },
      keyword: null
    });
  });
}

export async function activate() {
  subscriptions = new CompositeDisposable();
  subscriptions.add(atom.config.observe("atom-cscope.EnableHistory", (newValue) => {
    if (newValue) {
      atom.notifications.addInfo("Enabled Cscope history!");
      history = new Navigation(10);
    } else {
      atom.notifications.addInfo("Disabled Cscope history!");
      history = null;
    }
  }));

  viewModel = new AtomCscopeViewModel(subscriptions);
  setupEvents();

  subscriptions.add(atom.commands.add('atom-workspace', {
    'atom-cscope:toggle': () => viewModel.toggle(),
    'atom-cscope:switch-panes': () => {
      if (viewModel.isVisible()) {
        viewModel.switchPanes();
      }
    },
    'atom-cscope:refresh-db': () => refreshCscopeDB(),
    // 'atom-cscope:project-select': () => viewModel.view.openProjectSelector(),
    'atom-cscope:next': () => {
      if (history == null) return;
      history.openNext();
    },
    'atom-cscope:prev': () => {
      if (history == null) return;
      history.openPrev();
    }
  }));

  subscriptions.add(atom.commands.add('atom-workspace', {
    'atom-cscope:toggle-sample': () => viewModel.projectSelector.toggle()
  }));

  subscriptions.add(atom.commands.add('atom-workspace', {
    'atom-cscope:toggle-symbol': () => viewModel.togglePanelOption(0),
    'atom-cscope:toggle-global-definition': () => viewModel.togglePanelOption(1),
    'atom-cscope:toggle-functions-called-by': () => viewModel.togglePanelOption(2),
    'atom-cscope:toggle-functions-calling': () => viewModel.togglePanelOption(3),
    'atom-cscope:toggle-text-string': () => viewModel.togglePanelOption(4),
    'atom-cscope:toggle-egrep-pattern': () => viewModel.togglePanelOption(6),
    'atom-cscope:toggle-file': () => viewModel.togglePanelOption(7),
    'atom-cscope:toggle-files-including': () => viewModel.togglePanelOption(8),
    'atom-cscope:toggle-assignments-to': () => viewModel.togglePanelOption(9)
  }));

  subscriptions.add(atom.commands.add('atom-workspace', {
    'atom-cscope:find-symbol': () => autoInputFromCursor(0),
    'atom-cscope:find-global-definition': () => autoInputFromCursor(1),
    'atom-cscope:find-functions-called-by': () => autoInputFromCursor(2),
    'atom-cscope:find-functions-calling': () => autoInputFromCursor(3),
    'atom-cscope:find-text-string': () => autoInputFromCursor(4),
    'atom-cscope:find-egrep-pattern': () => autoInputFromCursor(6),
    'atom-cscope:find-file': () => autoInputFromCursor(7),
    'atom-cscope:find-files-including': () => autoInputFromCursor(8),
    'atom-cscope:find-assignments-to': () => autoInputFromCursor(9)
  }));

  subscriptions.add(atom.config.observe('atom-cscope.MaxCscopeResults', (newValue) => {
    maxResults = newValue;
  }));

  subscriptions.add(atom.config.observe('atom-cscope.HistorySize', (newValue) => {
    if (history == null) return;
    history.updateHistorySize(newValue);
  }));
}

export function autoInputFromCursor(option: number) {
  var activeEditor: TextEditor | undefined = atom.workspace.getActiveTextEditor();

  if (activeEditor == null) {
    atom.notifications.addError("Could not find text under cursor.");
    return;
  }

  var selectedText: string = activeEditor.getSelectedText();
  var keyword: string = selectedText == "" ? activeEditor.getWordUnderCursor() : selectedText;
  if (keyword.trim() == "") {
    atom.notifications.addError("Could not find text under cursor.");
    return;
  }
  if (!viewModel.isVisible()) viewModel.show();
  viewModel.invokeSearch(option.toString(), keyword);
}

export function deactivate() {
  viewModel.deactivate();
  subscriptions.dispose();
}
