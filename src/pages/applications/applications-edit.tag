applications-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#applications')
                i.fa.fa-chevron-left
            button.btn.btn-default(onclick='{ submit }')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew && reload }', onclick='{ reload }', title='Обновить')
                i.fa.fa-refresh
        .h4 { [item.last_name, item.first_name].join(' ').trim() || 'Редактирование заявки' }

        form(if='{ !error }', action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-4
                    .col-md-12
                        .form-group
                            label.control-label Заявитель
                            input.form-control(name='name', value='{ item.name }')
                    .col-md-12
                        .form-group
                            label.control-label Телефон
                            input.form-control(name='phone', value='{ item.phone }')
                    .col-md-12
                        .form-group
                            label.control-label E-mail
                            input.form-control(name='email', value='{ item.email }')

                .col-md-4
                    .col-md-12
                        .form-group
                            label.control-label Дата
                            datetime-picker.form-control(name='date', format='YYYY-MM-DD HH:mm:ss', value='{ item.date }', readonly="true")

                    .col-md-12
                        .form-group
                            label.control-label Объект
                            input.form-control(name='objectName', value='{ item.objectName }', readonly="true")
                    .col-md-12
                        .form-group
                            label.control-label подобъект
                            input.form-control(name='objectItem', value='{ item.objectItem }', readonly="true")
                .col-md-4
                    .col-md-12
                        .form-group
                            label.control-label Комментарий
                            textarea.form-control(name='comment', value='{ item.comment }',
                            style='min-width: 100%; max-width: 100%; min-height: 300px;')

        .row(if='{ error }')
            .col-md-12
                .alert.alert-danger
                    | Что-то пошло не так, попробуйте позже

        script.
            var self = this

            self.mixin('change')
            self.item = {}
            self.isNew = false

            /*
            self.selectService = function () {
                modals.create('services-list-select-modal', {
                    type: 'modal-primary',
                    submit: function () {
                        var items = this.datatable.getSelectedRows()
                        self.item.id_service = items[0].id
                        self.item.service = items[0].name
                        self.update()
                        this.modalHide()
                    }
                })
            }

            self.removeService = function () {
                if (self.item) {
                    self.item.id_service = null
                    self.item.service = ''
                }
            }

            self.selectObject = function () {
                modals.create('specialists-list-select-modal', {
                    type: 'modal-primary',
                    submit: function () {
                        var items = this.datatable.getSelectedRows()
                        self.item.id_specialist = items[0].id
                        self.item.specialist =
                                [items[0].last_name, items[0].first_name, items[0].middle_name].join(' ')
                        self.update()
                        this.modalHide()
                    }
                })
            }

            self.removeSpecialist = function () {
                if (self.item) {
                    self.item.id_specialist = null
                    self.item.specialist = ''
                }
            }
            */

            self.reload = function () {
                if (self.item && self.item.id)
                    app.trigger('applications-edit', self.item.id)
            }

            self.submit = function () {
                API.request({
                    object: 'Application',
                    method: 'Save',
                    data: self.item,
                    success: function (response, xhr) {
                        if (!self.isNew) {
                            self.update({item: response})
                            popups.create({title: 'Сохранено!', style: 'popup-success'})
                        } else if (response.id) {
                            riot.route('/applications/' + response.id)
                        }
                        app.trigger('applications-list-reload')
                    },
                    error: function () {
                        if (self.isNew)
                            popups.create({title: 'Ошибка!', text: 'Что-то пошло не так', style: 'popup-error'})
                        else
                            self.update({error: true})
                    }
                })
            }

            app.on('applications-edit', function (id) {
                self.update({
                    loader: true,
                    error: false,
                    isNew: false
                })

                API.request({
                    object: 'Application',
                    method: 'INFO',
                    data: {id: id},
                    success: function (response, xhr) {
                        self.update({
                            item: response,
                            loader: false
                        })
                    },
                    error: function () {
                        self.update({
                            error: true,
                            loader: false
                        })
                    }
                })
            })

            app.on('applications-new', function () {
                self.update({
                    isNew: true,
                    item: {title: ''}
                })
            })

            self.on('mount', function () {
                riot.route.exec()
            })