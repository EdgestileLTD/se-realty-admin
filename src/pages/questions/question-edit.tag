question-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#questions') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("questions", "0100") : checkPermission("questions", "0010") }',
            onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 Вопросы:
            b {item.nameProduct}

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-3
                    .form-group
                        label.control-label Дата
                        input.form-control(name='createdAt', format='DD.MM.YYYY HH:mm', value='{ item.createdAt }', readonly='true')
                .col-md-5
                    .form-group(class='{ has-error: (error.idUser) }')
                        label.control-label Автор вопроса
                        input.form-control(name='name', value='{ item.name }')
                        .help-block { error.name }
                .col-md-4
                    .form-group(class='{ has-error: error.email }')
                        label.control-label Email
                        input.form-control(name='email', type='text', value='{ item.email }')
                        .help-block { error.email }
            .row
                .col-md-12
                    .form-group
                        label.control-label Вопрос
                        textarea.form-control(rows='5', name='question',
                        style='min-width: 100%; max-width: 100%;', value='{ item.question }')
            .row
                .col-md-12
                    .form-group
                        label.control-label
                            b Ответ администратора
                        textarea.form-control(rows='5', name='answer',
                        style='min-width: 100%; max-width: 100%;', value='{ item.answer }')
            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(name='isActive', type='checkbox', checked='{ item.isActive }')
                                | Отображать вопрос на сайте


    script(type='text/babel').
        var self = this

        self.item = {
            isActive: 1
        }

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            name: 'empty',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = e => {
            var params = self.item

            self.error = self.validation.validate(self.item, self.rules)
            if (!self.error) {
                API.request({
                    object: 'Question',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        if (self.isNew)
                            riot.route(`/questions/${self.item.id}`)
                        self.update()
                        observable.trigger('questions-reload')
                    }
                })
            }
        }


        observable.on('question-edit', id => {
            var params = {id}
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Question',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                },
                error(response) {
                    self.item = {}
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        })

        observable.on('question-new', () => {
            self.isNew = true
            self.item = {
                isActive: 1
            }
            self.update()
        })

        self.reload = () => {
            observable.trigger('question-edit', self.item.id)
        }

        self.on('mount', () => {
            riot.route.exec()
        })