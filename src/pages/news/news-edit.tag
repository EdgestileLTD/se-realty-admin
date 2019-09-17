| import './new-categories-list-modal.tag'
| import 'pages/images/image-select.tag'
| import 'pages/news/news-images.tag'



news-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#news') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("news", "0100") : checkPermission("news", "0010") }',
            onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  { isNew ? item.name || 'Добавление новости' : item.name || 'Редактирование новости' }
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
                        .col-md-2
                            .form-group
                                label.control-label Дата публикации
                                datetime-picker.form-control(name='date', format='DD.MM.YYYY', value='{ item.date }')
                        .col-md-10
                            .form-group
                                label.control-label Категория
                                .input-group
                                    input.form-control(name='nameGroup', value='{ item.nameGroup }', readonly)
                                    span.input-group-addon(onclick='{ changeGroup }')
                                        i.fa.fa-list
            .row
                .col-md-12
                    .form-group
                        label.control-label Краткое описание новости
                        textarea.form-control(name='description', value='{ item.description }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Текст новости
                        ckeditor(name='content', value='{ item.content }')
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
                        label.control-label Галерея изображений
            news-images(name='images', value='{ item.images }')
            .m-b-3


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
                    object: 'News',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/news/${self.item.id}`)
                        observable.trigger('news-reload')
                    }
                })
            }
        }

        self.changeGroup = () => {
            modals.create('new-categories-list-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idGroup = items[0].id
                        self.item.nameGroup = items[0].name
                        console.log(items[0])
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        observable.on('news-new', item => {
            self.error = false
            self.isNew = true
            self.item = {
                date: (new Date()).toLocaleDateString(),
                idGroup: item.category,
                nameGroup: item.name
            }
            console.log(self.item)
            self.update()
        })

        observable.on('news-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.loader = true
            self.item = {}

            API.request({
                object: 'News',
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
            self.item.id ? observable.trigger('news-edit', self.item.id) : observable.trigger('news-new')
        }

        self.on('mount', () => {
            riot.route.exec()
        })