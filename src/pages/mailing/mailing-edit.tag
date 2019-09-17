| import 'components/ckeditor.tag'
| import 'components/checkbox-list-inline.tag'

mailing-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#mailing') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  Рассылка:
            b  { item.subject }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        label.control-label Дата отложенной отправки
                        datetime-picker.form-control(name='senderDate', format='DD.MM.YYYY HH:mm', value='{ item.senderDateDisplay }')
                .col-md-4
                    .form-group
                        label.control-label Имя рассылки/кампании
                        input.form-control(name='name', type='text', value='{ item.name }')
                .col-md-3
                    .form-group
                        label.control-label Тема письма
                        input.form-control(name='subject', type='text', value='{ item.subject }')
                .col-md-3
                    .form-group
                        label.control-label Имя отправителя
                        input.form-control(name='senderName', type='text', value='{ item.senderName }')
            .row
                .col-md-12
                    .panel.panel-primary
                        .panel-heading
                            h3.panel-title Отметьте группы получателей
                        .panel-body
                            checkbox-list-inline(items='{ item.userGroups }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Тело письма
                        ckeditor(name='body', value='{ item.body }')

    script(type='text/babel').
        var self = this

        self.item = {}
        self.orders = []

        self.mixin('change')

        self.submit = e => {
            var params = self.item
            self.loader = true

            API.request({
                object: 'Mailing',
                method: 'Save',
                data: params,
                success(response) {
                    self.item = response
                    if (self.isNew)
                        riot.route(`/mailing/${self.item.id}`)
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                    observable.trigger('mailing-reload')
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        observable.on('mailing-edit', id => {
            var params = {id: id}
            self.loader = true
            self.isNew = false
            self.update()

            API.request({
                object: 'Mailing',
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

        observable.on('mailing-new', () => {
            self.item = {}
            self.isNew = true
            let now = new Date()
            now.setDate(now.getDate() + 1)
            self.item.senderDateDisplay = now.toLocaleDateString() + " 06:00"
            API.request({
                object: 'UserGroup',
                method: 'Fetch',
                success: (response) => {
                    self.item.userGroups = response.items
                    self.update()
                }
            })
        })

        self.reload = () => {
            observable.trigger('mailing-edit', self.item.id)
        }

        self.on('mount', () => {
            riot.route.exec()
        })