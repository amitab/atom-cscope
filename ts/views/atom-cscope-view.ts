import * as fs from 'fs';
import * as path from 'path';
import {CompositeDisposable} from "atom";

export class AtomCscopeView {
  subscriptions: CompositeDisposable;
  element: Element;
  target: string;
  template: string;
  currentSelection: number;

  resultList: Element;
  input: Element;
  optionSelect: Element;
  pathSelect: Element;
  loader: Element;

  constructor(subscriptions) {
    this.target = "#atom-cscope";
    this.currentSelection = 0;
    this.subscriptions = subscriptions;
    this.element = document.createElement('div');
    this.element.classList.add('atom-cscope');
    this.element.id = "atom-cscope";
    this.template = fs.readFileSync(path.join(__dirname, './view.html'));
  }

  hasSelection() {
    return this.resultList.querySelector('.selected')?
  }

  initilaize() {
    this.resultList = this.element.querySelector('#result-container');
    this.input = this.element.querySelector('#query-input');
    this.optionSelect = this.element.querySelector('#cscope-options');
    this.pathSelect = this.element.querySelector('#path-options');
    this.loader = this.element.querySelector('#loader');

    this.subscriptions.add(atom.config.observe('atom-cscope.LiveSearchDelay', (newValue: number) => {
      this.input.getModel().getBuffer().stoppedChangingDelay = newValue;
    }));
  }

  getSearchParams: () ->
    pathIndex = parseInt this.pathSelect.value
    if pathIndex == -1
      path = atom.project.getPaths()
    else
      path = [atom.project.getPaths()[pathIndex]]
    search =
      option: parseInt this.optionSelect.value
      path: path
      keyword: this.input.getModel().getText().trim()

    return search

  onMoveUp: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-up': callback

  onMoveDown: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-down': callback

  onMoveToBottom: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-to-bottom': callback

  onMoveToTop: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:move-to-top': callback

  onConfirm: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:confirm': callback

  onCancel: (callback) ->
    atom.commands.add 'atom-text-editor#query-input',
      'core:cancel': callback

  selectLast: () ->
    this.selectItemView this.resultList.childNodes.length - 1

  selectFirst: () ->
    this.selectItemView 0

  selectNext: () ->
    if this.resultList.childNodes[this.currentSelection].classList.contains 'selected'
      this.selectItemView (this.currentSelection + 1) % this.resultList.childNodes.length
    else
      this.selectItemView (this.currentSelection) % this.resultList.childNodes.length

  selectPrev: () ->
    newIndex = (this.currentSelection - 1) % this.resultList.childNodes.length
    newIndex += this.resultList.childNodes.length if newIndex < 0
    this.selectItemView newIndex

  selectItemView: (index) ->
    this.resultList.childNodes[this.currentSelection].classList.remove 'selected'
    this.resultList.childNodes[index].classList.add 'selected'
    this.currentSelection = index
    this.resultList.childNodes[index].scrollIntoView false

  getSelectedItemView: ->
    return this.resultList.childNodes[this.currentSelection]

  clearSelection: ->
    this.getSelectedItemView().classList.remove 'selected'
    this.currentSelection = 0

  # Courtesy: http://stackoverflow.com/a/20906852
  openSelectBox: (element) ->
    event = document.createEvent 'MouseEvents'
    event.initMouseEvent 'mousedown', true, true, window
    element.dispatchEvent event

  openProjectSelector: ->
    try
      this.openSelectBox this.pathSelect
    catch error
      console.log error
    false

  autoFill: (option, keyword) ->
    this.optionSelect.value = option
    this.input.getModel().setText keyword

  startLoading: () ->
    this.loader.classList.remove 'no-show'

  stopLoading: () ->
    callback = => this.loader.classList.add 'no-show'
    setTimeout callback, 600

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    this.element.remove()

  getElement: ->
    this.element
