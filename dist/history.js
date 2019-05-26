"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class History {
    constructor(size) {
        this.size = size;
        this.clear();
    }
    addHistory(item) {
        if (this.cur == this.stack.length - 1) {
            this.stack.push(item);
            ++this.cur;
        }
        else if (this.cur < this.stack.length) {
            this.stack.splice(++this.cur, 0, item);
        }
        if (this.cur > this.size) {
            --this.cur;
            this.stack.shift();
        }
    }
    moveBack() {
        if (this.cur <= 0)
            return null;
        return this.stack[--this.cur];
    }
    getCurrent() {
        return this.stack[this.cur];
    }
    moveFront() {
        if (this.cur >= this.stack.length - 1)
            return null;
        return this.stack[++this.cur];
    }
    clear() {
        this.stack = new Array(this.size);
        this.cur = -1;
    }
}
class Navigation {
    constructor(size) {
        this.history = new History(size);
    }
    saveNew(item) {
        this.history.addHistory(item);
    }
    saveCurrent() {
        var editor = atom.workspace.getActiveTextEditor();
        if (editor == null)
            return;
        var pos = editor.getCursorBufferPosition();
        var filePath = editor.getPath();
        if (pos && filePath) {
            var item = this.history.getCurrent();
            if (item != null &&
                item.path == filePath &&
                item.keyword == null &&
                item.pos.row == pos.row &&
                item.pos.column == pos.column)
                return;
            this.history.addHistory({
                path: filePath,
                pos: pos,
                keyword: null
            });
        }
    }
    isEmpty() {
        return (this.history.stack.length == 0);
    }
    clearHistory() {
        this.history.clear();
    }
    openPrev() {
        var item = this.history.moveBack();
        if (item == null)
            return;
        atom.workspace.open(item.path, { initialLine: item.pos.row, initialColumn: item.pos.column });
    }
    openNext() {
        var item = this.history.moveFront();
        if (item == null)
            return;
        atom.workspace.open(item.path, { initialLine: item.pos.row, initialColumn: item.pos.column });
    }
}
exports.Navigation = Navigation;
//# sourceMappingURL=history.js.map