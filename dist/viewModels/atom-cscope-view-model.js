"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
//import {Ractive} from 'ractive';
const Ractive = require("ractive");
const atom_cscope_view_1 = require("../views/atom-cscope-view");
const atom_cscope_model_1 = require("../models/atom-cscope-model");
const select_view_1 = require("../views/select-view");
const cscope_1 = require("../cscope");
class AtomCscopeViewModel {
    constructor(subscriptions) {
        this.currentSearch = -1;
        this.previousSearch = {
            keyword: "",
            option: -1,
            path: new Array()
        };
        this.model = new atom_cscope_model_1.AtomCscopeModel(subscriptions, (itemName, paths) => {
            this.ractive.merge(itemName, paths);
            this.projectSelector.update(["All Projects"].concat(paths));
        }, (itemName, newItem) => {
            this.ractive.set(itemName, newItem);
        });
        this.view = new atom_cscope_view_1.AtomCscopeView(subscriptions);
        this.subscriptions = subscriptions;
        // Attach Modal
        this.addPanel();
        atom.config.observe('atom-cscope.WidgetLocation', () => {
            var wasVisible = this.modalPanel.isVisible();
            this.modalPanel.destroy();
            this.addPanel();
            if (wasVisible) {
                this.show();
            }
        });
        // Other views
        this.projectSelector = new select_view_1.Selector(["All Projects"].concat(atom.project.getPaths()), (item) => {
            const li = document.createElement('li');
            li.textContent = item;
            return li;
        }, (item) => {
            if (this.view.pathSelect == null)
                return;
            if (item.toLowerCase() === "all projects")
                item = "-1";
            this.view.pathSelect.value = item;
            if (this.view.pathSelect.value === "") {
                throw "Mistmatch between atom-select-list and #path-select";
            }
            this.projectSelector.hide();
        }, "No projects opened.", "atom-cscope-project-selector");
        this.cscopeOptSelector = new select_view_1.Selector(cscope_1.CscopeCommands.filter((item) => item != null), (item) => {
            const li = document.createElement('li');
            li.textContent = item;
            return li;
        }, (item) => {
            if (this.view.optionSelect == null)
                return;
            var num = cscope_1.Cscope.commandToNumber(item);
            this.view.optionSelect.value = num.toString();
            if (this.view.optionSelect.value === "") {
                throw "Mistmatch between atom-select-list and #option-select";
            }
            this.cscopeOptSelector.hide();
        }, "No cscope options registered.", "atom-cscope-option-selector");
        this.subscriptions.add(atom.commands.add('div.atom-cscope', {
            'atom-cscope:project-select': () => this.projectSelector.toggle(),
            'atom-cscope:option-select': () => this.cscopeOptSelector.toggle()
        }));
        // Initilaize
        this.ractive = new Ractive({
            el: this.view.target,
            data: this.model.data,
            template: this.view.template.toString()
        });
        this.view.initilaize();
        this.setupEvents();
    }
    addPanel() {
        switch (atom.config.get('atom-cscope.WidgetLocation')) {
            case 'bottom': {
                this.modalPanel = atom.workspace.addBottomPanel({
                    item: this.view.getElement(),
                    visible: false
                });
                this.view.wide();
                break;
            }
            case 'left': {
                this.modalPanel = atom.workspace.addLeftPanel({
                    item: this.view.getElement(),
                    visible: false
                });
                this.view.narrow();
                break;
            }
            case 'right': {
                this.modalPanel = atom.workspace.addRightPanel({
                    item: this.view.getElement(),
                    visible: false
                });
                this.view.narrow();
                break;
            }
            default: {
                this.modalPanel = atom.workspace.addTopPanel({
                    item: this.view.getElement(),
                    visible: false
                });
                this.view.wide();
                break;
            }
        }
    }
    setupEvents() {
        this.view.onCancel(() => this.hide());
        this.view.onMoveUp(() => this.view.selectPrev());
        this.view.onMoveDown(() => this.view.selectNext());
        this.view.onMoveToTop(() => this.view.selectFirst());
        this.view.onMoveToBottom(() => this.view.selectLast());
        this.view.onConfirm(() => {
            var newSearch = this.view.getSearchParams();
            var sameAsPrev = this.sameAsPreviousSearch(newSearch);
            if (this.view.hasSelection() && sameAsPrev) {
                this.openResult(this.view.currentSelection);
            }
            else if (!sameAsPrev) {
                this.performSearch(newSearch);
            }
        });
        this.ractive.on('search-force', () => {
            var newSearch = this.view.getSearchParams();
            this.performSearch(newSearch);
        });
        this.ractive.on('path-select', () => {
            if (this.view.input == null)
                return;
            this.view.inputFocus();
        });
        this.subscriptions.add(atom.config.observe('atom-cscope.LiveSearch', (newValue) => {
            if (!newValue) {
                this.liveSearchListener.dispose();
                return;
            }
            if (this.view.input == null)
                return;
            this.liveSearchListener = this.view.input.getModel().onDidStopChanging(() => {
                if (!newValue) {
                    return;
                }
                var newSearch = this.view.getSearchParams();
                var timeout = atom.config.get('atom-cscope.LiveSearchDelay');
                if (timeout <= 300) {
                    this.performSearch(newSearch);
                    return;
                }
                if (this.currentSearch != -1) {
                    window.clearTimeout(this.currentSearch);
                }
                this.currentSearch = window.setTimeout((newSearch) => {
                    this.performSearch(newSearch);
                    this.currentSearch = -1;
                }, timeout, newSearch);
            });
        }));
    }
    invokeSearch(option, keyword) {
        this.view.autoFill(option, keyword.trim());
        if (keyword.trim() == "") {
            return;
        }
        var newSearch = this.view.getSearchParams();
        this.performSearch(newSearch);
    }
    performSearch(newSearch) {
        this.view.startLoading();
        this.searchCallback(newSearch)
            .then((data) => {
            this.view.clearSelection();
            this.model.results(data);
            this.view.stopLoading();
        })
            .catch(() => {
            this.view.stopLoading();
            this.resetSearch();
        });
        this.previousSearch = newSearch;
        this.view.inputFocus();
    }
    sameAsPreviousSearch(newSearch) {
        if (newSearch.option != this.previousSearch.option ||
            newSearch.path.length != newSearch.path.length ||
            newSearch.keyword != this.previousSearch.keyword) {
            return false;
        }
        for (var i in newSearch.path) {
            if (newSearch.path[i] != this.previousSearch.path[i]) {
                return false;
            }
        }
        return true;
    }
    resetSearch() {
        this.previousSearch = {
            keyword: "",
            option: -1,
            path: new Array()
        };
    }
    openResult(index) {
        this.resultClickCallback(this.model.data.results[index]);
    }
    onResultClick(callback) {
        this.resultClickCallback = callback;
        this.ractive.on('result-click', (event) => {
            var temp = event.resolve().split(".");
            var model = this.model.data.results[parseInt(temp[temp.length - 1])];
            this.resultClickCallback(model);
            return this.view.selectItemView(parseInt(temp[temp.length - 1]));
        });
    }
    onRefresh(callback) {
        this.ractive.on('refresh', () => {
            callback();
            this.view.inputFocus();
        });
    }
    onSearch(callback) {
        this.searchCallback = callback;
    }
    show() {
        this.prevEditor = atom.workspace.getActiveTextEditor();
        this.modalPanel.show();
        this.view.inputFocus();
    }
    hide() {
        this.modalPanel.hide();
        if (this.prevEditor == undefined)
            return;
        var prevEditorView = atom.views.getView(this.prevEditor);
        if (prevEditorView) {
            prevEditorView.focus();
        }
    }
    toggle() {
        if (this.modalPanel.isVisible()) {
            this.hide();
        }
        else {
            this.show();
        }
    }
    switchPanes() {
        if (this.view.input == null)
            return;
        // @ts-ignore
        if (this.view.input.hasFocus() && this.prevEditor) {
            var prevEditorView = atom.views.getView(this.prevEditor);
            if (prevEditorView) {
                prevEditorView.focus();
            }
        }
        else {
            this.prevEditor = atom.workspace.getActiveTextEditor();
            this.view.inputFocus();
        }
    }
    togglePanelOption(option) {
        if (this.view.optionSelect != null && parseInt(this.view.optionSelect.value) === option) {
            this.toggle();
        }
        else {
            this.show();
            this.view.autoFill(option.toString(), '');
            this.model.clearResults();
        }
    }
    isVisible() {
        return this.modalPanel.isVisible();
    }
    deactivate() {
        this.modalPanel.destroy();
        this.view.destroy();
    }
}
exports.AtomCscopeViewModel = AtomCscopeViewModel;
//# sourceMappingURL=atom-cscope-view-model.js.map