| import parallel from 'async/parallel'
| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'components/autocomplete.tag'
| import 'pages/objects/object-related-list.tag'
| import 'pages/objects/location-menu-list.tag'
| import 'pages/objects/location-event-list.tag'
| import 'pages/objects/object-list-select-modal.tag'
| import 'lodash/lodash'

location-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#objects/location') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isMulti }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isMulti ? item.name || 'Мультиредактирование товаров' : isClone ? 'Клонирование товара' : item.name || 'Редактирование товара' }
        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#location-edit-home') Основная информация
            li: a(data-toggle='tab', href='#location-edit-images') Изображения
            li: a(data-toggle='tab', href='#location-edit-objects') Объекты
            li: a(data-toggle='tab', href='#location-edit-news') События
            li: a(data-toggle='tab', href='#location-edit-files') Документы
            li: a(data-toggle='tab', href='#location-edit-header') Фон
            li: a(data-toggle='tab', href='#location-edit-seo') SEO
        .tab-content
            #location-edit-home.tab-pane.fade.in.active
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-6
                            .col-md-12
                                .form-group(class='{ has-error: error.name }')
                                    label.control-label Заголовок
                                    input.form-control(name='title', type='text', value='{ item.title }')
                                    .help-block { error.title }
                            .col-md-12
                                .form-group(class='{ has-error: error.name }')
                                    label.control-label Наименование
                                    input.form-control(name='name', type='text', value='{ item.name }')
                                    .help-block { error.name }
                            .col-md-12
                                .form-group
                                    label.control-label URL объекта
                                        .input-group
                                            input.form-control(name='url', value='{ item.url }')
                                            span.input-group-addon(onclick='{ permission(translite, "products", "0010") }')
                                                | Транслитерация
                            .col-md-12
                                .form-group
                                    label.control-label Адрес
                                    input.form-control(name='address', type='text', value='{ item.address }')
                        .col-md-6
                            .col-md-12
                                .form-group
                                    label.control-label Меню
                                    location-menu-list(name='menu', value='{ item.menu }', id='{ item.id }')

                    .row
                        .col-md-4
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                        | Активный
                        .col-md-4
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='isCompleted', checked='{ item.isCompleted }')
                                        | Завершенный проект
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Краткое описание
                                ckeditor(name='description', value='{ item.description }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Полный текст
                                ckeditor(name='content', value='{ item.content }')

            #location-edit-images.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    object-edit-images(name='images', value='{ item.images }', section='objects')

            #location-edit-objects.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    object-related-list(name='related', value='{ item.related }', idObject='{ item.id }')

            #location-edit-news.tab-pane.fade
                location-event-list(name='events', id='{ item.id }')


            #location-edit-files.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    object-edit-files(name='files', value='{ item.files }', idObject='{ item.id }')

            #location-edit-header.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-12
                            .form-group
                                .well.well-sm
                                    image-select(name='imagePath', alt='0', size='800', value='{ item.imagePath }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Краткое описание
                                ckeditor(name='textHeader', value='{ item.textHeader }')

            #location-edit-seo.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-12
                            .form-group
                                button.btn.btn-primary.btn-sm(each='{ seoTags }', title='{ note }', type='button'
                                onclick='{ seoTag.insert }', no-reorder) { name }
                            .form-group
                                label.control-label  Заголовок (до 50 симв.)
                                input.form-control(name='metaTitle', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.metaTitle }')
                            .form-group
                                label.control-label  Ключевые слова
                                input.form-control(name='metaKeywords', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.metaKeywords }')
                            .form-group
                                label.control-label  Описание (до 200 симв.)
                                textarea.form-control(rows='5', name='metaDescription', onfocus='{ seoTag.focus }',
                                style='min-width: 100%; max-width: 100%;', value='{ item.metaDescription }')


    style(scoped).
        .color {
            height: 12px;
            width: 12px;
            display: inline-block;
            border: 1px solid #ccc;
        }


    script(type='text/babel').
        var self = this

        self.item = {}
        self.currencies = []
        self.seoTags = []
        self.productTypes = []
        self.objectLabels = []
        self.loader = false
        self.error = false

        self.seoTag = new app.insertText()

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.submit = e => {
            var params = self.item

            if (self.isMulti) {
                self.error = false
                params = { ids: self.multiIds, ...self.item }
            } else {
                self.error = self.validation.validate(params, self.rules)
            }

            if (!self.error) {
                self.loader = true

                API.request({
                    object: 'Location',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Объект сохранен!', style: 'popup-success'})
                        if (self.isClone)
                            riot.route(`/objects/location/${self.item.id}`)
                        observable.trigger('location-reload')
                    },
                    complete() {
                        self.loader = false
                        self.update()
                    }
                })
            }
        }

        self.translite = e => {
            var params = {vars:[self.item.url]}

            API.request({
                object: 'Functions',
                method: 'Translit',
                data: params,
                success(response, xhr) {
                    self.item.code = response.items[0]
                    self.update()
                }
            })
        }


        function getObject(id, callback) {
            var params = {id}

            parallel([
                callback => {
                    API.request({
                        object: 'Location',
                        method: 'Info',
                        data: params,
                        success(response) {
                            self.item = response
                            callback(null, 'Location')
                        },
                        error(response) {
                            self.item = {}
                            callback('error', null)
                        }
                    })
                },
                /*
                callback => {
                    API.request({
                        object: 'Label',
                        method: 'Fetch',
                        success(response) {
                            self.objectLabels = response.items
                            callback(null, 'ObjectLabel')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }
                */

            ], (err, res) => {
                if (typeof callback === 'function')
                callback.bind(this)()
            })
        }

        self.reload = () => {
            observable.trigger('location-edit', self.id)
        }

        observable.on('location-save', () => {
            self.submit()
        })

        observable.on('location-edit', id => {
            self.id = id
            self.error = false
            self.isMulti = false
            self.isClone = false
            self.loader = true
            self.update()

            getObject(id, () => {
                self.loader = false
                self.update()
                observable.trigger('location-event-reload', id)
                observable.trigger('object-files', id)
            })
        })



        self.on('mount', () => {
            riot.route.exec()
        })






