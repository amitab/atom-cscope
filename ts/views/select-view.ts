import * as SelectListView from "atom-select-list";
import {Panel} from "atom";

export class Selector<T> {
  selectListView: SelectListView;
  element: HTMLElement;
  panel: Panel | null;
  previouslyFocusedElement: Element | null;

  constructor(items: T[], elementForItem: (item: T) => HTMLElement, didConfirmSelection: (item: T) => void, emptyMessage: string, id: string) {
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

  update(items: T[]) {
    this.selectListView.update({
      items: items
    });
  }

  show() {
    this.previouslyFocusedElement = document.activeElement;
    if (!this.panel) {
      this.panel = atom.workspace.addModalPanel({item: this});
    }
    this.panel.show();
    this.selectListView.focus();
  }

  hide() {
    if (this.panel) {
      this.panel.hide()
    }

    if (this.previouslyFocusedElement) {
      var el: HTMLElement = <HTMLElement> this.previouslyFocusedElement
      el.focus();
      this.previouslyFocusedElement = null;
    }
  }

  toggle() {
    if(this.panel && this.panel.isVisible()) {
      this.hide();
    } else {
      this.show();
    }
  }

  getElement() {
    return this.element;
  }
}
