import-items-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Импорт
        #{'yield'}(to="body")
            loader(text='Импорт', indeterminate='true', if='{ loader }')
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    textarea.form-control(name='importtext', value='{ item.importtext }', style='height: 300px;')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed', disabled='{ cannotBeClosed }') Закрыть
            button(onclick='{ parent.submit }', type='button', class='btn btn-primary btn-embossed', disabled='{ cannotBeClosed }') Импорт

    script(type='text/babel').
        var self = this
        self.item = []

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = self.item
            modal.item.importtext = ''
            modal.error = false
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                importtext: 'empty'
            }

            modal.loader = false
        })

        self.submit = e => {
            opts.submit.bind(this, e)()
        }








