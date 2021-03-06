seo-var-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить/изменить макропеременную
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label  Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
                .form-group(class='{ has-error: error.value }')
                    label.control-label  Значение
                    input.form-control(name='value', type='text', value='{ item.value }')
                    .help-block { error.value }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.error = false
            modal.item = {}
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                name: 'empty',
                value: 'empty'
            }

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
            }

            if (opts.id) {
                modal.loader = true

                API.request({
                    object: 'SeoVariable',
                    method: 'Info',
                    data: {id: 1},
                    success(response) {
                        modal.item = response
                    },
                    complete() {
                        modal.loader = false
                        modal.update()
                    }
                })
            }

        })