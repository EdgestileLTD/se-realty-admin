| import 'pages/images/image-select.tag'



section-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#sections') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("news", "0100") : checkPermission("news", "0010") }',
            onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  { isNew ? item.name || 'Добавление содержания' : item.name || 'Редактирование содержания' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        .well.well-sm
                            image-select(name='imagePath', alt='0', size='256', value='{ item.imagePath }')

                .col-md-10
                    .row
                        .col-md-12
                            .form-group(class='{ has-error: error.name }')
                                label.control-label Заголовок
                                input.form-control(name='name', type='text', value='{ item.name }')
                                .help-block { error.name }
                    .row
                        .col-md-12
                            .form-group
                                label.control-label URL
                                input.form-control(name='url', type='text', value='{ item.url }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Текст примечания
                        ckeditor(name='description', value='{ item.description }')
            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                | Отображать на сайте

    script(type='text/babel').
        var self = this

        self.isNew = false

        self.item = {}
        self.orders = []

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            name: 'empty'
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
                    object: 'SectionItem',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/sections/${self.item.id}`)
                        observable.trigger('section-reload')
                    }
                })
            }
        }

        observable.on('section-new', id => {
            self.error = false
            self.isNew = true
            self.item = {
                idSection: id,
            }
            self.update()
        })

        observable.on('section-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.loader = true
            self.item = {}

            API.request({
                object: 'SectionItem',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
            })
        })

        self.reload = () => {
            self.item.id ? observable.trigger('section-edit', self.item.id) : observable.trigger('section-new')
        }

        self.on('mount', () => {
            riot.route.exec()
        })