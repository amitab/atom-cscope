"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Ractive = require("ractive");
const atom_cscope_model_1 = require("../models/atom-cscope-model");
class AtomCscopeViewModel {
    constructor(subscriptions) {
        this.resetSearch();
        this.model = new atom_cscope_model_1.AtomCscopeModel(subscriptions, (itemName, newItem) => {
            this.ractive.merge(itemName, newItem);
        }, (itemName, newItem) => {
            this.ractive.set(itemName, newItem);
        });
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
                this.modalPanel = atom.workspace.addBottomPanel(this.view.getElement(), false);
                break;
            }
            default: {
                this.modalPanel = atom.workspace.addTopPanel(this.view.getElement(), false);
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
            this.view.input.focus();
        });
        this.subscriptions.add(atom.config.observe('atom-cscope.LiveSearch', (newValue) => {
            if (!newValue) {
                this.liveSearchListener.dispose();
                return;
            }
            this.liveSearchListener = this.view.input.getModel().onDidStopChanging(() => {
                if (!newValue) {
                    return;
                }
                var newSearch = this.view.getSearchParams();
                this.performSearch(newSearch);
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
        this.view.input.focus();
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
            option: "",
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
            this.view.selectItemView();
        });
    }
    onRefresh(callback) {
        this.ractive.on('refresh', () => {
            callback();
            this.view.input.focus();
        });
    }
    onSearch(callback) {
        this.searchCallback = callback;
    }
    show() {
        this.prevEditor = atom.workspace.getActiveTextEditor();
        this.modalPanel.show();
        this.view.input.focus();
    }
    hide() {
        this.modalPanel.hide();
        var prevEditorView = atom.views.getView(this.prevEditor);
        if (prevEditorView) {
            prevEditorView.focus();
        }
    }
    toggle() {
        console.log('Atom Cscope was toggled!');
        if (this.modalPanel.isVisible()) {
            this.hide();
        }
        else {
            this.show();
        }
    }
    switchPanes() {
        if (this.view.input.hasFocus() && this.prevEditor) {
            var prevEditorView = atom.views.getView(this.prevEditor);
            if (prevEditorView) {
                prevEditorView.focus();
            }
        }
        else {
            this.view.input.focus();
        }
    }
    togglePanelOption(option) {
        if (parseInt(this.view.optionSelect.value) === option) {
            this.toggle();
        }
        else {
            this.show();
            this.view.autoFill(option, '');
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