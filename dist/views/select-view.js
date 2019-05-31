"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const SelectListView = require("atom-select-list");
class Selector {
    constructor(items, elementForItem, didConfirmSelection, emptyMessage, id) {
        this.element = document.createElement('div');
        this.element.classList.add('atom-cscope');
        this.element.id = id;
        this.selectListView = new SelectListView({
            items: items,
            elementForItem: elementForItem,
            emptyMessage: emptyMessage,
            didConfirmSelection: didConfirmSelection,
            didCancelSelection: () => {
                this.hide();
            }
        });
        this.element.appendChild(this.selectListView.element);
        this.panel = null;
    }
    update(items) {
        this.selectListView.update({
            items: items
        });
    }
    show() {
        this.previouslyFocusedElement = document.activeElement;
        if (!this.panel) {
            this.panel = atom.workspace.addModalPanel({ item: this });
        }
        this.panel.show();
        this.selectListView.focus();
    }
    hide() {
        if (this.panel) {
            this.panel.hide();
        }
        if (this.previouslyFocusedElement) {
            var el = this.previouslyFocusedElement;
            el.focus();
            this.previouslyFocusedElement = null;
        }
    }
    toggle() {
        if (this.panel && this.panel.isVisible()) {
            this.hide();
        }
        else {
            this.show();
        }
    }
    getElement() {
        return this.element;
    }
}
exports.Selector = Selector;
//# sourceMappingURL=select-view.js.map