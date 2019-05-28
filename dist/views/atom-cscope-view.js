"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const path = require("path");
class AtomCscopeView {
    constructor(subscriptions) {
        this.target = "#atom-cscope";
        this.currentSelection = 0;
        this.subscriptions = subscriptions;
        this.element = document.createElement('div');
        this.element.classList.add('atom-cscope');
        this.element.id = "atom-cscope";
        this.template = fs.readFileSync(path.join(__dirname, './view.html'));
        this.resultList = null;
        this.input = null;
        this.optionSelect = null;
        this.pathSelect = null;
        this.loader = null;
    }
    inputFocus() {
        if (this.input == null)
            return;
        this.input.focus();
    }
    hasSelection() {
        if (this.resultList == null)
            return false;
        var results = this.resultList;
        return results.querySelector('.selected') != null;
    }
    initilaize() {
        this.resultList = this.element.querySelector('#result-container');
        this.input = this.element.querySelector('#query-input');
        this.optionSelect = this.element.querySelector('#cscope-options');
        this.pathSelect = this.element.querySelector('#path-options');
        this.loader = this.element.querySelector('#loader');
        this.subscriptions.add(atom.config.observe('atom-cscope.LiveSearchDelay', (newValue) => {
            if (this.input == null)
                return;
            this.input.getModel().getBuffer().stoppedChangingDelay = newValue;
        }));
    }
    getSearchParams() {
        var pathIndex = this.pathSelect == null ? -1 : parseInt(this.pathSelect.value);
        var path;
        if (pathIndex == -1) {
            path = atom.project.getPaths();
        }
        else {
            path = [atom.project.getPaths()[pathIndex]];
        }
        var search = {
            keyword: this.input == null ? "" : this.input.getModel().getText().trim(),
            option: this.optionSelect == null ? -1 : parseInt(this.optionSelect.value),
            path: path
        };
        return search;
    }
    onMoveUp(callback) {
        atom.commands.add('atom-text-editor#query-input', {
            'core:move-up': callback
        });
    }
    onMoveDown(callback) {
        atom.commands.add('atom-text-editor#query-input', {
            'core:move-down': callback
        });
    }
    onMoveToBottom(callback) {
        atom.commands.add('atom-text-editor#query-input', {
            'core:move-to-bottom': callback
        });
    }
    onMoveToTop(callback) {
        atom.commands.add('atom-text-editor#query-input', {
            'core:move-to-top': callback
        });
    }
    onConfirm(callback) {
        atom.commands.add('atom-text-editor#query-input', {
            'core:confirm': callback
        });
    }
    onCancel(callback) {
        atom.commands.add('atom-text-editor#query-input', {
            'core:cancel': callback
        });
    }
    selectLast() {
        if (this.resultList == null)
            return;
        this.selectItemView(this.resultList.childNodes.length - 1);
    }
    selectFirst() {
        this.selectItemView(0);
    }
    selectNext() {
        if (this.resultList == null)
            return;
        var current = this.resultList.childNodes[this.currentSelection];
        if (current.classList.contains('selected')) {
            this.selectItemView((this.currentSelection + 1) % this.resultList.childNodes.length);
        }
        else {
            this.selectItemView((this.currentSelection) % this.resultList.childNodes.length);
        }
    }
    selectPrev() {
        if (this.resultList == null)
            return;
        var newIndex = (this.currentSelection - 1) % this.resultList.childNodes.length;
        if (newIndex < 0) {
            newIndex += this.resultList.childNodes.length;
        }
        this.selectItemView(newIndex);
    }
    selectItemView(index) {
        if (this.resultList == null)
            return;
        var current = this.resultList.childNodes[this.currentSelection];
        var newItem = this.resultList.childNodes[index];
        current.classList.remove('selected');
        newItem.classList.add('selected');
        this.currentSelection = index;
        newItem.scrollIntoView(false);
    }
    getSelectedItemView() {
        if (this.resultList == null)
            return null;
        return this.resultList.childNodes[this.currentSelection];
    }
    clearSelection() {
        var sel = this.getSelectedItemView();
        if (sel == null) {
            this.currentSelection = 0;
            return;
        }
        sel.classList.remove('selected');
        this.currentSelection = 0;
    }
    // Picked up from: http://stackoverflow.com/a/20906852
    openSelectBox(element) {
        var event = new MouseEvent('mousedown');
        element.dispatchEvent(event);
    }
    openProjectSelector() {
        try {
            if (this.pathSelect == null)
                return false;
            this.openSelectBox(this.pathSelect);
        }
        catch (error) {
            console.log(error);
        }
        return false;
    }
    autoFill(option, keyword) {
        if (this.input == null || this.optionSelect == null)
            return;
        this.optionSelect.value = option;
        this.input.getModel().setText(keyword);
    }
    startLoading() {
        if (this.loader == null)
            return;
        this.loader.classList.remove('no-show');
    }
    stopLoading() {
        setTimeout(() => {
            if (this.loader == null)
                return;
            this.loader.classList.add('no-show');
        }, 600);
    }
    // Returns an object that can be retrieved when package is activated
    serialize() { }
    // Tear down any state and detach
    destroy() {
        return this.element.remove();
    }
    getElement() {
        return this.element;
    }
}
exports.AtomCscopeView = AtomCscopeView;
//# sourceMappingURL=atom-cscope-view.js.map