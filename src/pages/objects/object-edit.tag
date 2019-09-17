| import parallel from 'async/parallel'
| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'components/autocomplete.tag'
| import 'pages/objects/object-edit-objects.tag'
| import 'pages/objects/object-edit-maps.tag'
| import 'pages/objects/object-edit-parameters.tag'
| import 'lodash/lodash'

object-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#objects') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isMulti }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isMulti ? item.name || 'Мультиредактирование товаров' : isClone ? 'Клонирование товара' : item.name || 'Редактирование товара' }
        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#object-edit-home') Основная информация
            li: a(data-toggle='tab', href='#object-edit-images') Изображения
            li: a(data-toggle='tab', href='#object-edit-objects', if='{ item.hasItem}') Объекты
            li: a(data-toggle='tab', href='#object-edit-maps', if='{ item.hasItem}') Планировка
            li: a(data-toggle='tab', href='#object-edit-header') Фон
            li: a(data-toggle='tab', href='#object-edit-seo') SEO
        .tab-content
            #object-edit-home.tab-pane.fade.in.active
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-6
                            .col-md-12
                                .form-group(class='{ has-error: error.name }')
                                    label.control-label Наименование
                                    input.form-control(name='name', type='text', value='{ item.name }')
                                    .help-block { error.name }
                            .col-md-12
                                .form-group
                                    label.control-label URL товара
                                        .input-group
                                            input.form-control(name='url', value='{ item.url }')
                                            span.input-group-addon(onclick='{ permission(translite, "products", "0010") }')
                                                | Транслитерация
                            .col-md-12
                                .form-group
                                    label.control-label Тип объекта
                                    select.form-control(name='idType', value='{ item.idType }' disabled="disabled")
                                        option(value='')
                                        option(each='{ productTypes }', value='{ id }',
                                        selected='{ id == item.idType }', no-reorder) { name }
                            .col-md-12
                                .form-group
                                    label.control-label Адрес
                                        .input-group
                                            select.form-control(name='idLocation', value='{ item.idLocation }')
                                                option(value='')
                                                option(each='{ locations }', value='{ id }',
                                                selected='{ id == item.idLocation }', no-reorder) { name }
                                            span.input-group-addon(onclick='{ clickMain }', title="Объект главный/второстипенный")
                                                i.fa.fa-bullseye(if='{ item.isMain }')
                                                i.fa.fa-circle-o(if='{ !item.isMain }')

                        .col-md-6
                            .col-md-12
                                label.control-label Характеристики
                                object-edit-parameters(name='specifications', value='{ item.specifications }')
                            .col-md-12
                                .form-group
                                    label.control-label Метка
                                    select.form-control(name='idLabel', value='{ item.idLabel }')
                                        option(value='')
                                        option(each='{ objectLabels }', value='{ id }',
                                        selected='{ id == item.idLabel }', no-reorder) { name }

                    .row
                        .col-md-4
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                        | Отображать в меню

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

            #object-edit-images.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    object-edit-images(name='images', value='{ item.images }', section='objects')

            #object-edit-maps.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    object-edit-maps(name='maps', value='{ item.maps }')

            #object-edit-objects.tab-pane.fade
                object-edit-objects(name='objects', id='{ item.id }')

            #object-edit-header.tab-pane.fade
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


            #object-edit-seo.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-12
                            .form-group
                                button.btn.btn-primary.btn-sm(each='{ seoTags }', title='{ note }', type='button'
                                onclick='{ seoTag.insert }', no-reorder) { name }
                            .form-group
                                label.control-label  Head title
                                input.form-control(name='metaTitle', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.metaTitle }')
                            .form-group
                                label.control-label  Meta keywords
                                input.form-control(name='metaKeywords', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.metaKeywords }')
                            .form-group
                                label.control-label  Meta description
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
        self.locations = []
        self.loader = false
        self.error = false

        self.seoTag = new app.insertText()

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.clickMain = () => {
            self.item.isMain = !self.item.isMain
            self.update()
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
                    object: 'Objects',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Товар сохранен!', style: 'popup-success'})
                        if (self.isClone)
                            riot.route(`/objects/${self.item.id}`)
                        observable.trigger('products-reload')
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
                        object: 'Objects',
                        method: 'Info',
                        data: params,
                        success(response) {
                            self.item = response
                            callback(null, 'Object')
                        },
                        error(response) {
                            self.item = {}
                            callback('error', null)
                        }
                    })
                },
                callback => {
                    API.request({
                        object: 'Type',
                        method: 'Fetch',
                        success(response) {
                            self.productTypes = response.items
                            callback(null, 'ProductType')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                },
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
                },
                callback => {
                    API.request({
                        object: 'Location',
                        method: 'Fetch',
                        success(response) {
                            self.locations = response.items
                            callback(null, 'locations')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }

            ], (err, res) => {
                if (typeof callback === 'function')
                callback.bind(this)()
            })
        }

        self.reload = () => {
            observable.trigger('objects-edit', self.item.id)
        }

        observable.on('object-save', () => {
            self.submit()
        })

        observable.on('objects-edit', id => {
            self.error = false
            self.isMulti = false
            self.isClone = false
            self.loader = true
            self.update()

            getObject(id, () => {
                self.loader = false
                self.update()
            })
        })



        self.on('mount', () => {
            riot.route.exec()
        })






