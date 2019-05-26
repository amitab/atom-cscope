import {TextEditor} from 'atom';

interface Position {
  row: number;
  column: number;
}

interface HistoryItem {
  path: string;
  pos: Position;
  keyword: string | null;
}

class History {
  size: number;
  cur: number;
  stack: HistoryItem[];


  constructor(size: number) {
    this.size = size;
    this.clear();
  }

  addHistory(item: HistoryItem) {
    if (this.cur == this.stack.length - 1) {
      this.stack.push(item);
      ++this.cur;
    } else if (this.cur < this.stack.length) {
      this.stack.splice(++this.cur, 0, item);
    }

    if (this.cur > this.size) {
      --this.cur;
      this.stack.shift();
    }
  }

  moveBack() {
    if (this.cur <= 0) return null;
    return this.stack[--this.cur];
  }

  getCurrent() {
    return this.stack[this.cur];
  }

  moveFront() {
    if (this.cur >= this.stack.length - 1) return null;
    return this.stack[++this.cur];
  }

  clear() {
    this.stack = new Array(this.size);
    this.cur = -1;
  }
}

export class Navigation {
  history: History;

  constructor(size: number) {
    this.history = new History(size);
  }

  saveNew(item: HistoryItem) {
    this.history.addHistory(item);
  }

  saveCurrent() {
    var editor: TextEditor | undefined = atom.workspace.getActiveTextEditor();
    if (editor == null) return;

    var pos: Position = editor.getCursorBufferPosition();
    var filePath: string | undefined = editor.getPath();

    if (pos && filePath) {
      var item: HistoryItem = this.history.getCurrent();

      if (item != null &&
          item.path == filePath &&
          item.keyword == null &&
          item.pos.row == pos.row &&
          item.pos.column == pos.column) return;

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
    var item: HistoryItem | null = this.history.moveBack();
    if (item == null) return;
    atom.workspace.open(item.path, {initialLine: item.pos.row, initialColumn: item.pos.column});
  }

  openNext() {
    var item: HistoryItem | null = this.history.moveFront();
    if (item == null) return;
    atom.workspace.open(item.path, {initialLine: item.pos.row, initialColumn: item.pos.column});
  }
}
