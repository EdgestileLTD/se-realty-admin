

review-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#reviews') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  Отзыв к товару:
            b  { isNew ? '' : item.nameProduct}

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        label.control-label Дата
                        datetime-picker.form-control(name='date', format='YYYY.MM.DD HH:mm', value='{ item.date }')
                .col-md-5
                    .form-group
                        label.control-label Автор отзыва
                        input.form-control(name='name', type='text', value='{ item.name }')
                .col-md-5
                    .form-group
                        label.control-label Email
                        input.form-control(name='email', type='text', value='{ item.email }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Комментарий
                        textarea.form-control(rows='5', name='commentary',
                        style='min-width: 100%; max-width: 100%;', value='{ item.commentary }')

            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(name='isActive', type='checkbox', checked='{ item.isActive }')
                                | Отображать отзыв на сайте


    script(type='text/babel').
        var self = this

        self.item = {}
        self.orders = []

        self.mixin('change')

        self.submit = e => {
            var params = self.item
            self.loader = true

            API.request({
                object: 'Review',
                method: 'Save',
                data: params,
                success(response) {
                    self.item = response
                    if (self.isNew)
                        riot.route(`/reviews/${self.item.id}`)
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                    observable.trigger('reviews-reload')
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        self.changePerson = () => {
            modals.create('persons-list-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idUser = items[0].id
                        self.item.userName = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.changeProduct = () => {
            modals.create('products-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idProduct = items[0].id
                        self.item.productName = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        observable.on('review-edit', id => {
            var params = {id: id}
            self.loader = true
            self.isNew = false

            API.request({
                object: 'Review',
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

        observable.on('review-new', () => {
            self.item = {}
            self.isNew = true
            self.update()
        })

        self.reload = () => {
            observable.trigger('review-edit', self.item.id)
        }

        self.on('mount', () => {
            riot.route.exec()
        })