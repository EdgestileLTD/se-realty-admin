| import './pets-calculate-modal.tag'

pets-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#products/pets') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("products", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Добавление питомца' : item.name || 'Редактирование питомца' }
        form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
            .form-group(class='{ has-error: error.name }')
                .row
                    .col-md-12
                        .form-group
                            label.control-label Наименование
                            input.form-control(name='name', type='text', value='{ item.name }')
                            .help-block { error.name }
                .row
                    .col-md-12
                        .form-group
                            label.control-label Формулы по возрастным категориям
                            br
                            catalog-static(name='calculates', cols='{ calculatesCols }', rows='{ item.calculates }',
                                add='{ addEditCalculate }', dblclick='{ addEditCalculate }', reorder='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='name') { row.name }
                                    datatable-cell(name='minAge') { parent.parent.parent.parent.displayAge(row.minAge) }
                                    datatable-cell(name='maxAge') { parent.parent.parent.parent.displayAge(row.maxAge) }
                                    datatable-cell(name='formula') { row.formula }


    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.calculatesCols = [
            {name: 'name', value: 'Возрастная группа'},
            {name: 'minAge', value: 'Мин. возраст'},
            {name: 'maxAge', value: 'Макс. возраст'},
            {name: 'formula', value: 'Формула'},
        ]

        self.rules = {
            name: 'empty',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = () => {
            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Pet',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Информация о питомце сохранена!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`products/pets/${self.item.id}`)
                        observable.trigger('products-labels-reload')
                        self.update()
                    }
                })
            }
        }

        self.addEditCalculate = (e) => {
            let isNew = e == undefined
            let row = {}
            if (!isNew)
                row = e.item.row
            modals.create('pets-calculate-modal', {
                type: 'modal-primary',
                item: row,
                submit() {
                    var _this = this,
                    params = {}
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        params = this.item
                        let k = 1;
                        switch (params.measure) {
                            case "year":
                                k = 365
                                break
                            case "month":
                                k = 30.42
                                break
                            case "week":
                                k = 7
                                break
                        }
                        params.minAge = Math.round(k * params.minAgeTr)
                        params.maxAge = Math.round(k * params.maxAgeTr)
                        if (isNew) {
                            if (self.item.calculates)
                                self.item.calculates.push(params)
                            else self.item.calculates = [params]
                        }
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.displayAge = (age) => {
            if (age < 90 && age % 7 == 0)
                return Math.round(age / 7) + " нед.";
            if (age < 365)
                return Math.round(age / 30.42) + " мес.";
            return Math.round(age / 365) + " г.";
        }

        self.reload = () => observable.trigger('pets-edit', self.item.id)

        observable.on('pets-new', () => {
            self.error = false
            self.item = {}
            self.isNew = true
            self.update()
        })

        observable.on('pets-edit', id => {
            self.error = false
            self.loader = true
            self.item = {}
            self.isNew = false
            self.update()

            API.request({
                object: 'Pet',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        })


