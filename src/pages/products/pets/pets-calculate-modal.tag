pets-calculate-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Возрастная категория
        #{'yield'}(to="body")
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', value='{ item.name }', autofocus)
                    .help-block { error.name }
                .panel.panel-default
                    .panel-heading Возраст
                    .panel-body
                        .form-group
                            label.control-label Единица измерения
                            select.form-control(name='measure', value='{ item.measure }')
                                option(value='week', selected='{ "day" == item.measure }') Неделя
                                option(value='month', selected='{ "month" == item.measure }') Месяц
                                option(value='year', selected='{ "year" == item.measure }') Год
                        .form-group
                            label.control-label От
                            input.form-control(name='minAgeTr', type='number', value='{ item.minAgeTr }')
                        .form-group
                            label.control-label До
                            input.form-control(name='maxAgeTr', type='number', value='{ item.maxAgeTr }')
                .form-group
                    label.control-label Формула (импользуйте макропеременную [WEIGHT])
                    input.form-control(name='formula', value='{ item.formula }')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = opts.item
            modal.error = false
            modal.item["measure"] = "year"
            modal.mixin('validation')
            modal.mixin('change')

            modal.ageTransform = age => {
                if (age < 90 && age % 7 == 0) {
                    modal.item.measure = "week";
                    return Math.round(age / 7);
                }
                if (age < 365) {
                    modal.item.measure = "month";
                    return Math.round(age / 30.42);
                }
                modal.item.measure = "year";
                return Math.round(age / 365);
            }

            if (modal.item.minAge > 0 || modal.item.maxAge > 0) {
                modal.item.minAgeTr = modal.ageTransform(modal.item.minAge)
                modal.item.maxAgeTr = modal.ageTransform(modal.item.maxAge)
            }


           modal.one('updated', () => {
               modal.autofocus()
            })

            modal.rules = {
                name: 'empty'
            }

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {
                ...modal.error,
                ...modal.validation.validate(
                        modal.item,
                        modal.rules,
                        name
                    )
                }
            }
        })

