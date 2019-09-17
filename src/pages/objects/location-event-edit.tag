| import 'pages/images/image-select.tag'
| import 'pages/objects/object-news-images.tag'

location-event-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')

        .btn-group
            a.btn.btn-default(href='#objects/location/{ item.idLocation }') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("news", "0100") : checkPermission("news", "0010") }',
            onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  { isNew ? item.name || 'Добавление события' : item.name || 'Редактирование события' }

        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#object-news-home') Основная информация
            li: a(data-toggle='tab', href='#object-news-images') Фото-галерея

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #object-news-home.tab-pane.fade.in.active
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
                                .col-md-2
                                    .form-group
                                        label.control-label Дата публикации
                                        datetime-picker.form-control(name='date', format='DD.MM.YYYY', value='{ item.date }')
                                .col-md-10
                                    .form-group
                                        .checkbox-inline
                                            label
                                                input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                                | Отображать на сайте

                    .row
                        .col-md-12
                            .form-group
                                label.control-label Краткое описание события
                                textarea.form-control(name='description', value='{ item.description }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Текст события
                                ckeditor(name='content', value='{ item.content }')
                #object-news-images.tab-pane.fade
                    object-edit-images(name='images', value='{ item.images }')


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
                    object: 'LocationEvents',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/objects/events/${self.item.id}`)
                        observable.trigger('location-event-reload')
                    }
                })
            }
        }

        observable.on('location-event-new', item => {
            let { group, name } = item
            self.error = false
            self.isNew = true
            self.item = {
                publicationDate: (new Date()).toLocaleDateString(),
                publicationDateDisplay: (new Date()).toLocaleDateString(),
                idGroup: group,
                nameCategory: decodeURI(name)
            }
            self.update()
        })

        observable.on('location-event-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.loader = true
            self.item = {}

            API.request({
                object: 'LocationEvents',
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
            self.item.id ? observable.trigger('location-event-edit', self.item.id) : observable.trigger('location-event-new')
        }

        self.on('mount', () => {
            riot.route.exec()
        })