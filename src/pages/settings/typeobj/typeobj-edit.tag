| import 'components/loader.tag'
| import 'components/autocomplete.tag'
| import 'lodash/lodash'

| import 'pages/settings/typeobj/typeobj-edit-parameters.tag'
| import 'pages/settings/parameters/parameters-list-select-modal.tag'

| import parallel from 'async/parallel'

typeobj-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#settings/typeobj') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 Редактирование типа объекта

        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#type-edit-home') Основная информация
            li: a(data-toggle='tab', href='#type-edit-texts') Содержание
            li: a(data-toggle='tab', href='#type-edit-parameters') Характеристики
            li: a(data-toggle='tab', href='#type-edit-header') Фон
            li: a(data-toggle='tab', href='#type-edit-seo') SEO

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #type-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-6(if='{ !isMulti }')
                            .form-group(class='{ has-error: error.name }')
                                label.control-label Наименование
                                input.form-control(name='name', type='text', value='{ item.name }')
                                .help-block { error.name }
                        .col-md-6
                            .form-group
                                label.control-label Код
                                input.form-control(name='code', type='text', value='{ item.code }')
                                .help-block { error.code }
                    .row
                        .col-md-12
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='hasItem', checked='{ item.hasItem }')
                                        | Содержит подобъекты


                #type-edit-texts.tab-pane.fade
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Заголовок
                                input.form-control(name='pageTitle', type='text', value='{ item.pageTitle }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Описание
                                ckeditor(name='pageDescription', value='{ item.pageDescription }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Содержание
                                ckeditor(name='pageContent', value='{ item.pageContent }')

                #type-edit-parameters.tab-pane.fade
                    typeobj-edit-parameters(name='specifications', value='{ item.specifications }')

                #type-edit-header.tab-pane.fade
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

                #type-edit-seo.tab-pane.fade
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
        self.loader = false
        self.error = false
        self.texts = []


        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty',
            code: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }


        self.submit = e => {
            var params = self.item

            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                self.loader = true


                API.request({
                    object: 'Type',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Тип объекта сохранен!', style: 'popup-success'})
                        observable.trigger('typeobj-reload')
                    },
                    complete() {
                        self.loader = false
                        self.update()
                    }
                })
            }
        }


        function getProduct(id, callback) {
            var params = {id}

            API.request({
                object: 'Type',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    callback(null, 'Typeobj')
                },
                error(response) {
                    self.item = {}
                    callback('error', null)
                }
            })
        }


        self.reload = () => {
            observable.trigger('typeobj-edit', self.item.id)
        }

        observable.on('typeobj-edit', id => {
            self.error = false
            self.loader = true
            self.update()

            getProduct(id, () => {
                self.loader = false
                self.update()
            })
        })



        self.on('mount', () => {
            riot.route.exec()
        })