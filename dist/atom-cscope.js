"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const atom_1 = require("atom");
const atom_cscope_view_model_1 = require("./viewModels/atom-cscope-view-model");
const cscope_1 = require("./cscope");
tslib_1.__exportStar(require("./config"), exports);
const history_1 = require("./history");
let viewModel;
let history;
let subscriptions;
let maxResults;
function refreshCscopeDB() {
    var exts = atom.config.get('atom-cscope.cscopeSourceFiles');
    if (exts.trim() == "")
        return;
    cscope_1.CscopeCommands.setupCscope(atom.project.getPaths(), exts, true)
        .then(() => {
        atom.notifications.addSuccess("Refreshed cscope database!");
    }).catch((data) => {
        var message = data != null ? data.toString() : "Unknown Error occured";
        atom.notifications.addError(message);
    });
}
exports.refreshCscopeDB = refreshCscopeDB;
function setupEvents() {
    viewModel.onSearch((params) => {
        if (history != null)
            history.clearHistory();
        var option = params.option;
        var keyword = params.keyword;
        var projects = params.path;
        if (keyword.trim() == "")
            return Promise.resolve(new Array());
        // The option must be acceptable by cscope
        if ([0, 1, 2, 3, 4, 6, 7, 8, 9].indexOf(option) == -1) {
            atom.notifications.addError("Invalid cscope option: " + option);
            return Promise.resolve(new Array());
        }
        var response = new Promise((resolve, reject) => {
            cscope_1.CscopeCommands.runCscopeCommands(option, keyword, projects)
                .then((data) => {
                if (data.length > maxResults || maxResults <= 0) {
                    atom.notifications.addWarning("Results more than #{maxResults}!");
                }
                resolve(data);
            })
                .catch((data) => {
                var message = data != null ? data.toString() : "Unknown Error occured";
                atom.notifications.addError(message);
                reject(message);
            });
        });
        return response;
    });
    viewModel.onRefresh(refreshCscopeDB);
    viewModel.onResultClick((model) => {
        if (history != null && history.isEmpty())
            history.saveCurrent();
        atom.workspace.open(model.projectDir, { initialLine: model.lineNumber - 1 });
        if (history == null)
            return;
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
exports.setupEvents = setupEvents;
async function activate() {
    subscriptions = new atom_1.CompositeDisposable();
    subscriptions.add(atom.config.observe("atom-cscope.EnableHistory", (newValue) => {
        if (newValue) {
            atom.notifications.addInfo("Enabled Cscope history!");
            history = new history_1.Navigation(10);
        }
        else {
            atom.notifications.addInfo("Disabled Cscope history!");
            history = null;
        }
    }));
    viewModel = new atom_cscope_view_model_1.AtomCscopeViewModel(subscriptions);
    setupEvents();
    subscriptions.add(atom.commands.add('atom-workspace', {
        'atom-cscope:toggle': () => viewModel.toggle(),
        'atom-cscope:switch-panes': () => {
            if (viewModel.isVisible()) {
                viewModel.switchPanes();
            }
        },
        'atom-cscope:refresh-db': () => refreshCscopeDB(),
        'atom-cscope:project-select': () => viewModel.view.openProjectSelector(),
        'atom-cscope:next': () => {
            if (history == null)
                return;
            history.openNext();
        },
        'atom-cscope:prev': () => {
            if (history == null)
                return;
            history.openPrev();
        }
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
}
exports.activate = activate;
function autoInputFromCursor(option) {
    var activeEditor = atom.workspace.getActiveTextEditor();
    if (activeEditor == null) {
        atom.notifications.addError("Could not find text under cursor.");
        return;
    }
    var selectedText = activeEditor.getSelectedText();
    var keyword = selectedText == "" ? activeEditor.getWordUnderCursor() : selectedText;
    if (keyword.trim() == "") {
        atom.notifications.addError("Could not find text under cursor.");
        return;
    }
    if (!viewModel.isVisible())
        viewModel.show();
    viewModel.invokeSearch(option.toString(), keyword);
}
exports.autoInputFromCursor = autoInputFromCursor;
function deactivate() {
    viewModel.deactivate();
    subscriptions.dispose();
}
exports.deactivate = deactivate;
//# sourceMappingURL=atom-cscope.js.map