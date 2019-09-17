| import parallel from 'async/parallel'
| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'components/autocomplete.tag'
| import 'pages/objects/object-edit-parameters.tag'
| import 'lodash/lodash'

object-items-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#objects/{ idObject }') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isMulti }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  Редактирование подобъекта
        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#object-edit-home') Основная информация
            li: a(data-toggle='tab', href='#object-edit-images') Изображения
            li: a(data-toggle='tab', href='#object-edit-seo') SEO
        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #object-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-6
                            .col-md-12
                                .form-group(class='{ has-error: error.name }')
                                    label.control-label Наименование
                                    input.form-control(name='name', type='text', value='{ item.name }')
                                    .help-block { error.name }
                            .col-md-12
                                .form-group
                                    label.control-label Краткое описание
                                    ckeditor(name='description', value='{ item.description }')
                            .col-md-12
                                .form-group
                                    .checkbox-inline
                                        label
                                            input(type='checkbox', name='isAvailable', checked='{ item.isAvailable }')
                                            | Доступный для продажи

                        .col-md-6
                            .col-md-12
                                .form-group
                                    label.control-label Характеристики
                                    object-edit-parameters(name='specifications', value='{ item.specifications }')



                    .row: .col-md-12
                        .form-group
                            checkbox-list(items='{ item.labels }')
                    .row
                        .col-md-12
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                        | Отображать на сайте

                    .row
                        .col-md-12
                            .form-group
                                label.control-label Полный текст
                                ckeditor(name='content', value='{ item.content }')

                #object-edit-images.tab-pane.fade
                    object-edit-images(name='images', value='{ item.images }', section='objects')

                #object-edit-seo.tab-pane.fade
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

        self.idObject = 0
        self.item = {}
        self.currencies = []
        self.seoTags = []
        self.productTypes = []
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
            //console.log('submit')

            if (!self.error) {
                self.loader = true

                API.request({
                    object: 'ObjectItems',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Товар сохранен!', style: 'popup-success'})

                        if (self.isClone)
                            riot.route(`/objects/${self.item.id}`)
                        observable.trigger('items-reload')
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
                        object: 'ObjectItems',
                        method: 'Info',
                        data: params,
                        success(response) {
                            self.item = response
                            self.idObject = response.idObject

                            //self.count = self.item.offers
                            //.map(i => i.count)
                            //.reduce((s,c) => +s + +c, 0)
                            callback(null, 'Object')
                        },
                        error(response) {
                            self.item = {}
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
            observable.trigger('object-items-edit', self.item.id)
        }

        observable.on('object-items-edit', id => {
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






