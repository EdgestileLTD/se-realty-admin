| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import './pay-system-params-edit-modal.tag'

pay-system-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/pay-systems') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("paysystems", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Добавление платежной системы' : item.name || 'Редактирование платежной системы' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .form-group(class='{ has-error: error.name }')
                label.control-label Наименование
                input.form-control(name='name', type='text', value='{ item.name }')
                .help-block { error.name }
            ul.nav.nav-tabs.m-b-2
                li.active #[a(data-toggle='tab', href='#pay-system-edit-settings') Настройки]
                li #[a(data-toggle='tab', href='#pay-system-edit-main-info') Страница пояснений]
                li(if='{ item.code == null }') #[a(data-toggle='tab', href='#pay-system-edit-blank') Бланк счета]

            .tab-content
                #pay-system-edit-settings.tab-pane.fade.in.active
                    .row
                        .col-md-2
                            .form-group
                                .well.well-sm
                                    image-select(name='imagePath', section='shoppayment', alt='0', size='64', value='{ item.imagePath }')

                        .col-md-10
                            .row
                                .col-md-12
                                    .form-group
                                        label.control-label Плагин
                                        .input-group
                                            select.form-control(name='code', value='{ item.code }')
                                                option(value='')
                                                option(each='{ plugin in item.plugins }', value='{ plugin.id }', selected='{ plugin.id == item.code }')
                                                    | { plugin.name }
                                            span.input-group-addon(onclick='{ submit }')
                                                | Получить параметры
                            .row
                                .col-md-12
                                    .form-group
                                        label.control-label Справка URL
                                        input.form-control(name='urlHelp', type='text', value='{ item.urlHelp }')

                            .row
                                .col-md-12
                                    .form-group
                                        .checkbox-inline
                                            label
                                                input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                                | Отображать на сайте
                                        .checkbox-inline
                                            label
                                                input(type='checkbox', name='isTestMode', checked='{ item.isTestMode }')
                                                | Режим тестирования

                    .row(if='{ !isNew }')
                        .col-md-12
                            h4 Параметры

                    catalog-static(if='{ !isNew }', name='params', cols='{ paramsCols }', rows='{ item.params }',
                    dblclick='{ editParam }', add='{ addParams }')
                        #{'yield'}(to='body')
                            datatable-cell(name='key') { row.key }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='value') { row.value }

                #pay-system-edit-main-info.tab-pane.fade
                    .row
                        .col-md-12
                            .form-group
                                ckeditor(name='info', value='{ item.info }')

                #pay-system-edit-blank.tab-pane.fade(if='{ item.code == null }')
                    .row
                        .col-md-12
                            .form-group
                                ckeditor(name='blank', value='{ item.blank }')

    script(type='text/babel').
        var self = this

        self.isNew = false
        self.paramsSelectedCount = 0

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')
        self.item = {}

        self.rules = {
            name: 'empty'
        }

        self.afterChange = e => {
            if (e.target && e.target.name) {
                let name = e.target.name
                let value = e.target.value
                if (name === 'code') {
                    let item = self.item.plugins.filter(item => item.name === value)
                    if (item.length && !self.item.name) {
                        self.item.name = item[0].name
                    }
                }
            }

            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.paramsCols = [
            {name: 'key', value: 'Код'},
            {name: 'name', value: 'Заголовок'},
            {name: 'value', value: 'Значение'},
        ]

        self.reload = () => {
            observable.trigger('pay-systems-edit', self.item.id)
        }

        self.submit = () => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'PaySystem',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Платежная система сохранена!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`settings/pay-systems/${response.id}`)
                        observable.trigger('pay-systems-reload')
                    }
                })
            }
        }

        self.addParams = () => {
            modals.create('pay-system-params-edit-modal', {
                type: 'modal-primary',
                isNew: true,
                submit() {
                    var _this = this

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        self.item.params.push(_this.item)
                        self.update()
                        _this.modalHide()
                    }
                }
            })
        }

        self.editParam = e => {
            var oldParam = {}

            for (var key in e.item.row)
                oldParam[key] = e.item.row[key]

            modals.create('pay-system-params-edit-modal', {
                type: 'modal-primary',
                item: e.item.row,
                title: 'Редактирование параметра',
                submit() {
                    var _this = this

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'BankAccount',
                            method: 'Save',
                            data: _this.item,
                            success() {
                                self.update()
                                _this.modalHide()
                            }
                        })
                    }
                }

            })
        }

        self.removeParams = () => {
            self.paramsSelectedCount = 0
            self.item.params = self.tags.params.getUnselectedRows()
            self.update()
        }

        observable.on('pay-systems-edit', id => {
            self.error = false
            self.loader = true
            self.isNew = false
            self.item = {}
            self.update()

            API.request({
                object: 'PaySystem',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                },
                error() {
                    self.item = {}
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })

        })

        observable.on('pay-systems-new', () => {
            self.error = false
            self.loader = true
            self.isNew = true
            self.item = {}
            self.update()

            API.request({
                object: 'PaySystemPlugin',
                method: 'Fetch',
                success(response) {
                    self.item.plugins = response.items
                },
                error() {
                    self.item = {}
                    self.item.plugins = []
                },
                complete() {
                    self.update({loader: false})
                }
            })
        })

        self.on('mount', () => {
            riot.route.exec()
        })